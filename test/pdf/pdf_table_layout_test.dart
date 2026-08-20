import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_table_layout.dart';

void main() {
  test('splits long tables and repeats the header deterministically', () {
    const layout = PdfTableLayout(maxBodyRowsPerChunk: 2);
    final chunks = layout.chunk(<List<String>>[
      <String>['Planet', 'Degree'],
      <String>['Sun', '10'],
      <String>['Moon', '20'],
      <String>['Mars', '30'],
      <String>['Venus', '40'],
      <String>['Jupiter', '50'],
    ]);

    expect(chunks, hasLength(3));
    expect(chunks[0].rows, <List<String>>[
      <String>['Planet', 'Degree'],
      <String>['Sun', '10'],
      <String>['Moon', '20'],
    ]);
    expect(chunks[1].rows.first, <String>['Planet', 'Degree']);
    expect(chunks[2].rows.first, <String>['Planet', 'Degree']);
    expect(chunks[2].rows.last, <String>['Jupiter', '50']);
  });

  test('rejects inconsistent column widths before rendering', () {
    const layout = PdfTableLayout();
    expect(
      () => layout.chunk(<List<String>>[
        <String>['A', 'B'],
        <String>['only-one'],
      ]),
      throwsFormatException,
    );
  });

  test('single row remains a single chunk', () {
    const layout = PdfTableLayout();
    final chunks = layout.chunk(<List<String>>[
      <String>['A', 'B'],
    ]);
    expect(chunks, hasLength(1));
    expect(chunks.single.rows.single, <String>['A', 'B']);
  });
}
