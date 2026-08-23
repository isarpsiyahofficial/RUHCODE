import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_page_geometry_inspector.dart';

void main() {
  const inspector = PdfPageGeometryInspector();

  Uint8List bytes(String value) => Uint8List.fromList(latin1.encode(value));

  test('accepts expected A4 MediaBox dimensions within tolerance', () {
    final result = inspector.requireExpectedGeometry(
      bytes('%PDF-1.7\n1 0 obj << /MediaBox [0 0 595.2756 841.8898] >> endobj'),
      expectedWidthPt: 595.2756,
      expectedHeightPt: 841.8898,
    );

    expect(result.mediaBoxCount, 1);
    expect(result.allPositive, isTrue);
    expect(result.allMatchExpected, isTrue);
  });

  test('rejects page format drift', () {
    expect(
      () => inspector.requireExpectedGeometry(
        bytes('%PDF-1.7\n1 0 obj << /MediaBox [0 0 612 792] >> endobj'),
        expectedWidthPt: 595.2756,
        expectedHeightPt: 841.8898,
      ),
      throwsStateError,
    );
  });

  test('rejects missing MediaBox', () {
    expect(
      () => inspector.requireExpectedGeometry(
        bytes('%PDF-1.7\n1 0 obj << /Type /Page >> endobj'),
        expectedWidthPt: 595.2756,
        expectedHeightPt: 841.8898,
      ),
      throwsStateError,
    );
  });

  test('rejects non-positive MediaBox geometry', () {
    expect(
      () => inspector.requireExpectedGeometry(
        bytes('%PDF-1.7\n1 0 obj << /MediaBox [0 0 0 841.8898] >> endobj'),
        expectedWidthPt: 595.2756,
        expectedHeightPt: 841.8898,
      ),
      throwsStateError,
    );
  });

  test('requires every serialized MediaBox to match expected geometry', () {
    expect(
      () => inspector.requireExpectedGeometry(
        bytes(
          '%PDF-1.7\n'
          '1 0 obj << /MediaBox [0 0 595.2756 841.8898] >> endobj\n'
          '2 0 obj << /MediaBox [0 0 612 792] >> endobj',
        ),
        expectedWidthPt: 595.2756,
        expectedHeightPt: 841.8898,
      ),
      throwsStateError,
    );
  });
}
