import 'dart:async';
import 'dart:typed_data';

import 'pdf_output_inspector.dart';

/// Release-facing workload classes required by RC-0942..RC-0950.
enum PdfPerformanceWorkload {
  fivePages(minimumPages: 5, minimumTableRows: 0),
  twentyFivePages(minimumPages: 25, minimumTableRows: 0),
  fiftyPlusPages(minimumPages: 50, minimumTableRows: 0),
  hundredsOfTableRows(minimumPages: 1, minimumTableRows: 300);

  const PdfPerformanceWorkload({
    required this.minimumPages,
    required this.minimumTableRows,
  });

  final int minimumPages;
  final int minimumTableRows;
}

/// Observation captured by a host/device performance harness.
///
/// Memory and device responsiveness are evidence, not assumptions: callers
/// must explicitly provide measured values. This keeps RC-0947/0948 from being
/// promoted merely because a PDF happened to render on a developer machine.
final class PdfPerformanceObservation {
  const PdfPerformanceObservation({
    required this.workload,
    required this.generatedPages,
    required this.tableRows,
    required this.peakResidentBytes,
    required this.elapsed,
    required this.uiHeartbeatCount,
    required this.deviceClass,
  });

  final PdfPerformanceWorkload workload;
  final int generatedPages;
  final int tableRows;
  final int peakResidentBytes;
  final Duration elapsed;
  final int uiHeartbeatCount;
  final String deviceClass;

  bool get hasUiHeartbeat => uiHeartbeatCount > 0;
}

final class PdfPerformanceBudget {
  const PdfPerformanceBudget({
    // 384 MiB is deliberately conservative for a report-generation task. It
    // is a gate value, not a claim that every supported device has this RAM.
    this.maximumPeakResidentBytes = 384 * 1024 * 1024,
    this.maximumElapsed = const Duration(seconds: 45),
  });

  final int maximumPeakResidentBytes;
  final Duration maximumElapsed;

  void validate(PdfPerformanceObservation observation) {
    if (observation.generatedPages < observation.workload.minimumPages) {
      throw StateError(
        'PDF performance fixture dropped pages: '
        'required=${observation.workload.minimumPages} '
        'actual=${observation.generatedPages}.',
      );
    }
    if (observation.tableRows < observation.workload.minimumTableRows) {
      throw StateError(
        'PDF performance fixture did not exercise enough table rows: '
        'required=${observation.workload.minimumTableRows} '
        'actual=${observation.tableRows}.',
      );
    }
    if (observation.peakResidentBytes <= 0 ||
        observation.peakResidentBytes > maximumPeakResidentBytes) {
      throw StateError(
        'PDF generation peak RSS is outside the release budget: '
        '${observation.peakResidentBytes} bytes.',
      );
    }
    if (observation.elapsed <= Duration.zero ||
        observation.elapsed > maximumElapsed) {
      throw StateError(
        'PDF generation elapsed time is outside the release budget: '
        '${observation.elapsed.inMilliseconds} ms.',
      );
    }
    if (!observation.hasUiHeartbeat) {
      throw StateError(
        'PDF generation has no UI-heartbeat evidence; main-isolate lockup '
        'cannot be ruled out.',
      );
    }
    if (observation.deviceClass.trim().isEmpty) {
      throw StateError('PDF performance evidence must identify its device class.');
    }
  }
}

/// A publication target that exposes an atomic commit operation.
///
/// Implementations may use temp-file + rename, transactional storage, or an
/// equivalent platform primitive. `commitCompletePdf` must be the only point
/// at which a newly generated report becomes visible to the user.
abstract interface class AtomicPdfPublicationTarget {
  Future<void> commitCompletePdf(Uint8List bytes);
}

/// Prevents an incomplete/truncated generation from becoming a successful PDF.
final class PdfAtomicCompletionGate {
  const PdfAtomicCompletionGate({
    this.inspector = const PdfOutputInspector(),
  });

  final PdfOutputInspector inspector;

  Future<Uint8List> generateAndCommit({
    required Future<Uint8List> Function() generate,
    required AtomicPdfPublicationTarget target,
    int minimumPages = 1,
  }) async {
    if (minimumPages <= 0) {
      throw ArgumentError.value(minimumPages, 'minimumPages');
    }

    // Generation happens before any publication mutation. An exception,
    // cancellation, empty result, or truncated result therefore leaves the
    // previously visible report untouched.
    final bytes = await generate();
    inspector.requirePageCount(bytes, minimum: minimumPages);
    await target.commitCompletePdf(bytes);
    return bytes;
  }
}
