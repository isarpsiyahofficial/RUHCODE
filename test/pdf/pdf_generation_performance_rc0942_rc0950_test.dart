import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/pdf/pdf_generation_performance.dart';
import 'package:ruh_code/src/pdf/pdf_output_inspector.dart';

void main() {
  const inspector = PdfOutputInspector();

  Future<Uint8List> fixedPagePdf(int pageCount) async {
    final document = pw.Document();
    for (var i = 0; i < pageCount; i += 1) {
      document.addPage(
        pw.Page(
          build: (_) => pw.Text('Ruh Code long report page ${i + 1}'),
        ),
      );
    }
    return Uint8List.fromList(await document.save());
  }

  test('5 page professional report fixture is structurally complete', () async {
    final bytes = await fixedPagePdf(5);
    expect(inspector.requirePageCount(bytes, exact: 5).pageObjectCount, 5);
  });

  test('25 page professional report fixture is structurally complete', () async {
    final bytes = await fixedPagePdf(25);
    expect(inspector.requirePageCount(bytes, exact: 25).pageObjectCount, 25);
  });

  test('50+ page professional report fixture is structurally complete', () async {
    final bytes = await fixedPagePdf(52);
    expect(inspector.requirePageCount(bytes, minimum: 50).pageObjectCount, 52);
  });

  test('hundreds of true table rows can be serialized into a usable PDF', () async {
    final rows = List<pw.TableRow>.generate(
      320,
      (index) => pw.TableRow(
        children: <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text('Row ${index + 1}'),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text('Professional value ${index + 1}'),
          ),
        ],
      ),
    );
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        maxPages: 100,
        build: (_) => <pw.Widget>[
          pw.Table(children: rows),
        ],
      ),
    );
    final bytes = Uint8List.fromList(await document.save());
    final inspection = inspector.requireUsable(bytes);
    expect(inspection.pageObjectCount, greaterThan(1));
    expect(rows, hasLength(320));
  });

  test('performance budget requires measured memory, device and UI heartbeat evidence', () {
    const budget = PdfPerformanceBudget();
    expect(
      () => budget.validate(const PdfPerformanceObservation(
        workload: PdfPerformanceWorkload.fiftyPlusPages,
        generatedPages: 52,
        tableRows: 0,
        peakResidentBytes: 64 * 1024 * 1024,
        elapsed: Duration(seconds: 2),
        uiHeartbeatCount: 8,
        deviceClass: 'mid-range-android-test-fixture',
      )),
      returnsNormally,
    );
    expect(
      () => budget.validate(const PdfPerformanceObservation(
        workload: PdfPerformanceWorkload.fiftyPlusPages,
        generatedPages: 52,
        tableRows: 0,
        peakResidentBytes: 64 * 1024 * 1024,
        elapsed: Duration(seconds: 2),
        uiHeartbeatCount: 0,
        deviceClass: 'mid-range-android-test-fixture',
      )),
      throwsStateError,
    );
  });

  test('unfinished PDF bytes are never committed as a successful report', () async {
    final target = _RecordingTarget();
    const gate = PdfAtomicCompletionGate();

    await expectLater(
      gate.generateAndCommit(
        generate: () async => Uint8List.fromList(
          latin1.encode('%PDF-1.7\ntruncated without a page tree or EOF'),
        ),
        target: target,
      ),
      throwsStateError,
    );
    expect(target.commitCount, 0);
    expect(target.lastBytes, isNull);
  });

  test('complete PDF is committed only after structural validation', () async {
    final target = _RecordingTarget();
    const gate = PdfAtomicCompletionGate();
    final source = await fixedPagePdf(5);

    final result = await gate.generateAndCommit(
      generate: () async => source,
      target: target,
      minimumPages: 5,
    );

    expect(result, source);
    expect(target.commitCount, 1);
    expect(target.lastBytes, source);
  });

  test('generation exception leaves existing publication untouched', () async {
    final target = _RecordingTarget();
    const gate = PdfAtomicCompletionGate();

    await expectLater(
      gate.generateAndCommit(
        generate: () async => throw StateError('renderer failed'),
        target: target,
      ),
      throwsStateError,
    );
    expect(target.commitCount, 0);
  });
}

final class _RecordingTarget implements AtomicPdfPublicationTarget {
  int commitCount = 0;
  Uint8List? lastBytes;

  @override
  Future<void> commitCompletePdf(Uint8List bytes) async {
    commitCount += 1;
    lastBytes = Uint8List.fromList(bytes);
  }
}
