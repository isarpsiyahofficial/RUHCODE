import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_output_inspector.dart';

void main() {
  const inspector = PdfOutputInspector();

  Uint8List bytes(String value) => Uint8List.fromList(latin1.encode(value));

  Uint8List fakePdfWithPages(int pageCount, {int? declaredPageCount}) {
    final pageObjects = List<String>.generate(
      pageCount,
      (index) => '${index + 3} 0 obj << /Type /Page /Parent 2 0 R >> endobj',
    ).join('\n');
    return bytes(
      '%PDF-1.7\n'
      '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
      '2 0 obj << /Type /Pages /Count ${declaredPageCount ?? pageCount} >> endobj\n'
      '$pageObjects\n'
      'trailer << /Root 1 0 R >>\n'
      '%%EOF',
    );
  }

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
    expect(inspection.declaredPageCount, 1);
    expect(inspection.pageTreeCountConsistent, isTrue);
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
    expect(inspection.declaredPageCount, 0);
    expect(inspection.pageTreeCountConsistent, isTrue);
    expect(inspection.structurallyUsable, isFalse);
  });

  test('rejects pages tree count that disagrees with actual page objects', () {
    final inspection = inspector.inspect(fakePdfWithPages(24, declaredPageCount: 25));
    expect(inspection.pageObjectCount, 24);
    expect(inspection.declaredPageCount, 25);
    expect(inspection.pageTreeCountConsistent, isFalse);
    expect(() => inspector.requireUsable(fakePdfWithPages(24, declaredPageCount: 25)), throwsStateError);
  });

  test('rejects a pages tree that omits mandatory Count', () {
    final malformed = bytes(
      '%PDF-1.7\n'
      '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
      '2 0 obj << /Type /Pages /Kids [3 0 R] >> endobj\n'
      '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n'
      'trailer << /Root 1 0 R >>\n'
      '%%EOF',
    );
    final inspection = inspector.inspect(malformed);
    expect(inspection.declaredPageCount, isNull);
    expect(inspection.pageTreeCountConsistent, isFalse);
    expect(() => inspector.requireUsable(malformed), throwsStateError);
  });

  test('page-count gate verifies 5 page regression fixture', () {
    expect(
      inspector.requirePageCount(fakePdfWithPages(5), exact: 5).pageObjectCount,
      5,
    );
  });

  test('page-count gate verifies 25 page regression fixture', () {
    expect(
      inspector.requirePageCount(fakePdfWithPages(25), exact: 25).pageObjectCount,
      25,
    );
  });

  test('page-count gate verifies 50+ page regression fixture', () {
    expect(
      inspector.requirePageCount(fakePdfWithPages(52), minimum: 50).pageObjectCount,
      52,
    );
  });

  test('page-count gate rejects silently dropped pages', () {
    expect(
      () => inspector.requirePageCount(fakePdfWithPages(24), exact: 25),
      throwsStateError,
    );
  });

  test('page-count contract rejects contradictory limits', () {
    expect(
      () => inspector.requirePageCount(fakePdfWithPages(5), exact: 5, minimum: 1),
      throwsArgumentError,
    );
    expect(
      () => inspector.requirePageCount(fakePdfWithPages(5), minimum: 6, maximum: 5),
      throwsArgumentError,
    );
  });
}