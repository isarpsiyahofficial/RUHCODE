import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_export_governance.dart';

void main() {
  const sandbox = '/data/user/0/com.ruhcode/files';
  const cache = '$sandbox/cache/share';

  PdfExportRequest demo({
    bool watermark = true,
    String? clientId,
    bool demoData = true,
    String output = '$sandbox/demo.pdf',
  }) => PdfExportRequest(
        reportId: 'demo-fixture-v1',
        audience: PdfExportAudience.freeDemo,
        isPro: false,
        usesDemoData: demoData,
        watermarkEnabled: watermark,
        clientId: clientId,
        outputPath: output,
        sandboxRoot: sandbox,
        shareCacheRoot: cache,
        contentOrder: const ['cover', 'summary', 'chart'],
      );

  PdfExportRequest professional({String clientId = 'client-42'}) => PdfExportRequest(
        reportId: 'client-report-v1',
        audience: PdfExportAudience.professionalClient,
        isPro: true,
        usesDemoData: false,
        watermarkEnabled: false,
        clientId: clientId,
        outputPath: '$sandbox/client-report.pdf',
        sandboxRoot: sandbox,
        shareCacheRoot: cache,
        contentOrder: const ['cover', 'client', 'chart', 'interpretation'],
      );

  group('RC-1249..RC-1257 authorization and demo isolation', () {
    const policy = PdfExportAuthorizationPolicy();

    test('Free sample is allowed only with isolated demo data and watermark', () {
      expect(() => policy.validate(demo()), returnsNormally);
      expect(() => policy.validate(demo(watermark: false)), throwsStateError);
      expect(() => policy.validate(demo(demoData: false)), throwsStateError);
      expect(() => policy.validate(demo(clientId: 'real-client')), throwsStateError);
    });

    test('real client export requires PRO but full report may disable watermark', () {
      expect(() => policy.validate(professional()), returnsNormally);
      final freeReal = PdfExportRequest(
        reportId: 'blocked',
        audience: PdfExportAudience.professionalClient,
        isPro: false,
        usesDemoData: false,
        watermarkEnabled: false,
        clientId: 'client-1',
        outputPath: '$sandbox/blocked.pdf',
        sandboxRoot: sandbox,
        shareCacheRoot: cache,
        contentOrder: const ['client'],
      );
      expect(() => policy.validate(freeReal), throwsStateError);
    });
  });

  group('RC-1258..RC-1271 lifecycle, cancellation, scope and determinism', () {
    test('cancelled export cleans temp and is never successful', () async {
      final storage = _MemoryPdfStorage();
      final coordinator = PdfExportCoordinator(storage: storage);
      final cancellation = PdfExportCancellationToken()..cancel();
      final state = await coordinator.export(
        request: demo(),
        cancellation: cancellation,
        generate: () async => <int>[1, 2, 3],
      );
      expect(state, PdfExportRunState.cancelled);
      expect(storage.published, isEmpty);
      expect(storage.temporary, isEmpty);
    });

    test('failed export cleans partial file and never publishes success', () async {
      final storage = _MemoryPdfStorage();
      final coordinator = PdfExportCoordinator(storage: storage);
      final state = await coordinator.export(
        request: demo(),
        cancellation: PdfExportCancellationToken(),
        generate: () async => throw StateError('renderer crash'),
      );
      expect(state, PdfExportRunState.failed);
      expect(storage.published, isEmpty);
      expect(storage.temporary, isEmpty);
    });

    test('successful export publishes atomically and removes temp', () async {
      final storage = _MemoryPdfStorage();
      final coordinator = PdfExportCoordinator(storage: storage);
      final state = await coordinator.export(
        request: professional(),
        cancellation: PdfExportCancellationToken(),
        generate: () async => <int>[37, 80, 68, 70],
      );
      expect(state, PdfExportRunState.completed);
      expect(storage.temporary, isEmpty);
      expect(storage.published['$sandbox/client-report.pdf'], <int>[37, 80, 68, 70]);
    });

    test('sandbox escape is fail-closed', () {
      const policy = PdfExportAuthorizationPolicy();
      expect(
        () => policy.validate(demo(output: '/sdcard/arbitrary/report.pdf')),
        throwsStateError,
      );
    });

    test('same-client jobs are serialized and global concurrency is bounded', () async {
      final storage = _MemoryPdfStorage();
      final coordinator = PdfExportCoordinator(storage: storage, maximumConcurrentJobs: 2);
      var active = 0;
      var maxActive = 0;
      final order = <String>[];

      Future<List<int>> generation(String label) async {
        active++;
        if (active > maxActive) maxActive = active;
        order.add('start:$label');
        await Future<void>.delayed(const Duration(milliseconds: 15));
        order.add('end:$label');
        active--;
        return <int>[1];
      }

      final first = coordinator.export(
        request: professional(clientId: 'same'),
        cancellation: PdfExportCancellationToken(),
        generate: () => generation('a'),
      );
      final second = coordinator.export(
        request: PdfExportRequest(
          reportId: 'client-report-v2',
          audience: PdfExportAudience.professionalClient,
          isPro: true,
          usesDemoData: false,
          watermarkEnabled: false,
          clientId: 'same',
          outputPath: '$sandbox/client-report-2.pdf',
          sandboxRoot: sandbox,
          shareCacheRoot: cache,
          contentOrder: const ['cover', 'client'],
        ),
        cancellation: PdfExportCancellationToken(),
        generate: () => generation('b'),
      );
      await Future.wait([first, second]);
      expect(maxActive, 1);
      expect(order, ['start:a', 'end:a', 'start:b', 'end:b']);
    });

    test('filename collisions resolve deterministically', () {
      const policy = PdfExportCollisionPolicy();
      final existing = <String>{
        '$sandbox/report.pdf',
        '$sandbox/report (2).pdf',
      };
      expect(policy.resolve('$sandbox/report.pdf', existing), '$sandbox/report (3).pdf');
    });

    test('content order is explicit, unique and stable', () {
      const policy = PdfExportAuthorizationPolicy();
      expect(() => policy.validate(demo()), returnsNormally);
      final duplicate = PdfExportRequest(
        reportId: 'duplicate',
        audience: PdfExportAudience.freeDemo,
        isPro: false,
        usesDemoData: true,
        watermarkEnabled: true,
        outputPath: '$sandbox/duplicate.pdf',
        sandboxRoot: sandbox,
        shareCacheRoot: cache,
        contentOrder: const ['cover', 'cover'],
      );
      expect(() => policy.validate(duplicate), throwsStateError);
    });
  });
}

final class _MemoryPdfStorage implements PdfExportStorage {
  final Map<String, List<int>> temporary = <String, List<int>>{};
  final Map<String, List<int>> published = <String, List<int>>{};

  @override
  Future<void> writeTemporary(String path, List<int> bytes) async {
    temporary[path] = List<int>.of(bytes);
  }

  @override
  Future<void> publishAtomically(String temporaryPath, String finalPath) async {
    final bytes = temporary.remove(temporaryPath);
    if (bytes == null) throw StateError('missing temp');
    published[finalPath] = bytes;
  }

  @override
  Future<void> deleteIfExists(String path) async {
    temporary.remove(path);
  }
}
