import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_output_inspector.dart';

void main() {
  const inspector = PdfOutputInspector();

  Uint8List bytes(String value) => Uint8List.fromList(latin1.encode(value));

  test('accepts a minimal structurally usable PDF shape', () {
    final inspection = inspector.requireUsable(bytes(
      '%PDF-1.7\n'
      '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
      '2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n'
      '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n'
      'trailer << /Root 1 0 R >>\n'
      '%%EOF',
    ));

    expect(inspection.hasHeader, isTrue);
    expect(inspection.hasEofMarker, isTrue);
    expect(inspection.hasCatalog, isTrue);
    expect(inspection.hasPagesTree, isTrue);
    expect(inspection.pageObjectCount, 1);
  });

  test('rejects truncated output without EOF', () {
    expect(
      () => inspector.requireUsable(bytes(
        '%PDF-1.7\n'
        '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
        '2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n'
        '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n',
      )),
      throwsStateError,
    );
  });

  test('does not count /Pages tree as a page object', () {
    final inspection = inspector.inspect(bytes(
      '%PDF-1.7\n'
      '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
      '2 0 obj << /Type /Pages /Kids [] /Count 0 >> endobj\n'
      '%%EOF.................................................................',
    ));

    expect(inspection.pageObjectCount, 0);
    expect(inspection.structurallyUsable, isFalse);
  });
}
