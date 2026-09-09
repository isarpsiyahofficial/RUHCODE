import 'dart:async';

/// Release-facing PDF export policy for RC-1249..RC-1272.
///
/// This policy deliberately separates demo exports from real-client exports.
/// The renderer receives an already-authorized [PdfExportRequest] and cannot
/// silently turn a Free/demo request into a professional client report.
enum PdfExportAudience { freeDemo, professionalClient }

enum PdfExportRunState { queued, generating, cancelled, failed, completed }

enum PdfAppLifecycleMode { foregroundOnly, continueWhileBackgrounded }

final class PdfExportRequest {
  const PdfExportRequest({
    required this.reportId,
    required this.audience,
    required this.isPro,
    required this.usesDemoData,
    required this.watermarkEnabled,
    required this.outputPath,
    required this.sandboxRoot,
    required this.shareCacheRoot,
    required this.contentOrder,
    this.clientId,
    this.lifecycleMode = PdfAppLifecycleMode.foregroundOnly,
  });

  final String reportId;
  final PdfExportAudience audience;
  final bool isPro;
  final bool usesDemoData;
  final bool watermarkEnabled;
  final String? clientId;
  final String outputPath;
  final String sandboxRoot;
  final String shareCacheRoot;
  final List<String> contentOrder;
  final PdfAppLifecycleMode lifecycleMode;
}

/// Fail-closed authorization and data-isolation boundary.
final class PdfExportAuthorizationPolicy {
  const PdfExportAuthorizationPolicy();

  void validate(PdfExportRequest request) {
    if (request.reportId.trim().isEmpty) {
      throw StateError('PDF export requires a stable report id.');
    }
    if (request.contentOrder.isEmpty ||
        request.contentOrder.any((value) => value.trim().isEmpty)) {
      throw StateError('PDF export requires a deterministic content order.');
    }
    if (request.contentOrder.toSet().length != request.contentOrder.length) {
      throw StateError('PDF content order cannot contain duplicate section ids.');
    }

    switch (request.audience) {
      case PdfExportAudience.freeDemo:
        if (!request.usesDemoData) {
          throw StateError('Free PDF export must use isolated demo data.');
        }
        if (request.clientId != null && request.clientId!.trim().isNotEmpty) {
          throw StateError('Demo PDF must not carry a real client id.');
        }
        if (!request.watermarkEnabled) {
          throw StateError('Free sample PDF must be visibly watermarked as demo.');
        }
      case PdfExportAudience.professionalClient:
        if (!request.isPro) {
          throw StateError('Real-client PDF export requires PRO entitlement.');
        }
        if (request.usesDemoData) {
          throw StateError('Professional client PDF cannot silently use demo data.');
        }
        if (request.clientId == null || request.clientId!.trim().isEmpty) {
          throw StateError('Professional client PDF requires a stable client id.');
        }
        // Watermark is optional for full professional reports by design.
    }

    _requireScopedPath(request.outputPath, request.sandboxRoot, label: 'output');
    _requireScopedPath(request.shareCacheRoot, request.sandboxRoot, label: 'share cache');
  }

  void _requireScopedPath(String path, String root, {required String label}) {
    final normalizedRoot = _normalize(root);
    final normalizedPath = _normalize(path);
    if (normalizedRoot.isEmpty ||
        normalizedPath.isEmpty ||
        (normalizedPath != normalizedRoot && !normalizedPath.startsWith('$normalizedRoot/'))) {
      throw StateError('PDF $label path escapes the app sandbox.');
    }
    if (normalizedPath.contains('/../') || normalizedPath.endsWith('/..')) {
      throw StateError('PDF $label path traversal is forbidden.');
    }
  }

  String _normalize(String value) =>
      value.trim().replaceAll('\\', '/').replaceAll(RegExp('/+'), '/').replaceFirst(RegExp(r'/$'), '');
}

/// Mutable cancellation token owned by the presentation/application layer.
final class PdfExportCancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
  void throwIfCancelled() {
    if (_cancelled) throw const PdfExportCancelled();
  }
}

final class PdfExportCancelled implements Exception {
  const PdfExportCancelled();
  @override
  String toString() => 'PdfExportCancelled';
}

/// Storage adapter used by the export coordinator. Implementations should use
/// app-private temporary/cache storage and an atomic final publish operation.
abstract interface class PdfExportStorage {
  Future<void> writeTemporary(String path, List<int> bytes);
  Future<void> publishAtomically(String temporaryPath, String finalPath);
  Future<void> deleteIfExists(String path);
}

/// A bounded, keyed coordinator: globally limits concurrent PDF jobs and also
/// serializes jobs for the same client/report key to avoid same-client races.
final class PdfExportCoordinator {
  PdfExportCoordinator({
    required this.storage,
    this.maximumConcurrentJobs = 2,
    this.authorization = const PdfExportAuthorizationPolicy(),
  }) : assert(maximumConcurrentJobs > 0);

  final PdfExportStorage storage;
  final int maximumConcurrentJobs;
  final PdfExportAuthorizationPolicy authorization;

  int _activeJobs = 0;
  final List<Completer<void>> _capacityWaiters = <Completer<void>>[];
  final Map<String, Future<void>> _keyTails = <String, Future<void>>{};

  Future<PdfExportRunState> export({
    required PdfExportRequest request,
    required PdfExportCancellationToken cancellation,
    required Future<List<int>> Function() generate,
  }) async {
    authorization.validate(request);
    final key = request.clientId?.trim().isNotEmpty == true
        ? 'client:${request.clientId}'
        : 'report:${request.reportId}';

    final previous = _keyTails[key] ?? Future<void>.value();
    final done = Completer<void>();
    _keyTails[key] = done.future;
    await previous;
    await _acquireCapacity();

    final temporaryPath = '${request.shareCacheRoot}/${request.reportId}.partial.pdf';
    try {
      cancellation.throwIfCancelled();
      final bytes = await generate();
      cancellation.throwIfCancelled();
      if (bytes.isEmpty) throw StateError('Generated PDF is empty.');
      await storage.writeTemporary(temporaryPath, bytes);
      cancellation.throwIfCancelled();
      await storage.publishAtomically(temporaryPath, request.outputPath);
      // Successful publication must not leave a temporary export behind.
      await storage.deleteIfExists(temporaryPath);
      return PdfExportRunState.completed;
    } on PdfExportCancelled {
      await storage.deleteIfExists(temporaryPath);
      return PdfExportRunState.cancelled;
    } catch (_) {
      await storage.deleteIfExists(temporaryPath);
      return PdfExportRunState.failed;
    } finally {
      _releaseCapacity();
      done.complete();
      if (identical(_keyTails[key], done.future)) _keyTails.remove(key);
    }
  }

  Future<void> _acquireCapacity() async {
    if (_activeJobs < maximumConcurrentJobs) {
      _activeJobs++;
      return;
    }
    final waiter = Completer<void>();
    _capacityWaiters.add(waiter);
    await waiter.future;
    _activeJobs++;
  }

  void _releaseCapacity() {
    _activeJobs--;
    if (_capacityWaiters.isNotEmpty) _capacityWaiters.removeAt(0).complete();
  }
}

/// Deterministic collision resolver shared by platform adapters.
final class PdfExportCollisionPolicy {
  const PdfExportCollisionPolicy();

  String resolve(String desiredPath, Set<String> existingPaths) {
    if (!existingPaths.contains(desiredPath)) return desiredPath;
    final dot = desiredPath.toLowerCase().endsWith('.pdf') ? desiredPath.length - 4 : desiredPath.length;
    final stem = desiredPath.substring(0, dot);
    final extension = desiredPath.substring(dot);
    var index = 2;
    while (existingPaths.contains('$stem ($index)$extension')) index++;
    return '$stem ($index)$extension';
  }
}
