import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/pdf/pdf_output_inspector.dart';

void main() {
  const inspector = PdfOutputInspector();

  test('accepts the classic-xref PDF emitted by the production pdf package', () async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (context) => pw.Text('RUH CODE structural inspection regression'),
      ),
    );

    final bytes = Uint8List.fromList(await document.save());
    final inspection = inspector.requireUsable(bytes);

    expect(inspection.pageObjectCount, 1);
    expect(inspection.pageTreeCountConsistent, isTrue);
    expect(inspection.startXrefTargetRecognized, isTrue);
    expect(inspection.xrefHasRootReference, isTrue);
    expect(inspection.rootReferenceResolvesToCatalog, isTrue);
    expect(inspection.catalogPagesReferenceResolves, isTrue);
  });

  test('classic trailer keeps Root visible after a nested dictionary', () {
    final body =
        '%PDF-1.7\n'
        '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
        '2 0 obj << /Type /Pages /Count 1 >> endobj\n'
        '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n';
    final xrefOffset = latin1.encode(body).length;
    final bytes = Uint8List.fromList(
      latin1.encode(
        '$body'
        'xref\n0 1\n0000000000 65535 f \n'
        'trailer << /Info << /Producer (RUH CODE) >> /Root 1 0 R >>\n'
        'startxref\n$xrefOffset\n'
        '%%EOF',
      ),
    );

    final inspection = inspector.requireUsable(bytes);
    expect(inspection.xrefHasRootReference, isTrue);
    expect(inspection.rootReferenceResolvesToCatalog, isTrue);
    expect(inspection.catalogPagesReferenceResolves, isTrue);
  });

  test('nested classic trailer still fails closed when Root is absent', () {
    final body =
        '%PDF-1.7\n'
        '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
        '2 0 obj << /Type /Pages /Count 1 >> endobj\n'
        '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n';
    final xrefOffset = latin1.encode(body).length;
    final bytes = Uint8List.fromList(
      latin1.encode(
        '$body'
        'xref\n0 1\n0000000000 65535 f \n'
        'trailer << /Info << /Producer (RUH CODE) >> >>\n'
        'startxref\n$xrefOffset\n'
        '%%EOF',
      ),
    );

    final inspection = inspector.inspect(bytes);
    expect(inspection.xrefHasRootReference, isFalse);
    expect(inspection.rootReferenceResolvesToCatalog, isFalse);
    expect(() => inspector.requireUsable(bytes), throwsStateError);
  });
}
