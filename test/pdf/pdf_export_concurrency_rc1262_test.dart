import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_export_governance.dart';

void main() {
  test('RC-1262 global PDF concurrency never exceeds configured bound', () async {
    final storage = _Storage();
    final coordinator = PdfExportCoordinator(
      storage: storage,
      maximumConcurrentJobs: 2,
    );
    var active = 0;
    var maxActive = 0;

    Future<List<int>> generate() async {
      active++;
      if (active > maxActive) maxActive = active;
      await Future<void>.delayed(const Duration(milliseconds: 25));
      active--;
      return <int>[37, 80, 68, 70];
    }

    PdfExportRequest request(int index) => PdfExportRequest(
          reportId: 'report-$index',
          audience: PdfExportAudience.professionalClient,
          isPro: true,
          usesDemoData: false,
          watermarkEnabled: false,
          clientId: 'client-$index',
          outputPath: '/app/files/report-$index.pdf',
          sandboxRoot: '/app/files',
          shareCacheRoot: '/app/files/cache',
          contentOrder: const <String>['cover', 'client', 'chart'],
        );

    await Future.wait(
      List<Future<PdfExportRunState>>.generate(
        6,
        (index) => coordinator.export(
          request: request(index),
          cancellation: PdfExportCancellationToken(),
          generate: generate,
        ),
      ),
    );

    expect(maxActive, 2);
  });
}

final class _Storage implements PdfExportStorage {
  final Map<String, List<int>> temporary = <String, List<int>>{};

  @override
  Future<void> writeTemporary(String path, List<int> bytes) async {
    temporary[path] = List<int>.from(bytes);
  }

  @override
  Future<void> publishAtomically(String temporaryPath, String finalPath) async {
    if (temporary.remove(temporaryPath) == null) {
      throw StateError('missing temp');
    }
  }

  @override
  Future<void> deleteIfExists(String path) async {
    temporary.remove(path);
  }
}
