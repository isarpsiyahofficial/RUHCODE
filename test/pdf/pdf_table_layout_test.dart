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

  test('large table chunks preserve every body row exactly once and in order', () {
    const layout = PdfTableLayout(maxBodyRowsPerChunk: 7);
    final input = <List<String>>[
      <String>['Index', 'Value'],
      for (var index = 0; index < 100; index++)
        <String>['$index', 'value-$index'],
    ];

    final chunks = layout.chunk(input);

    expect(chunks, hasLength(15));
    for (final chunk in chunks) {
      expect(chunk.rows.first, input.first);
      expect(chunk.rows.length, inInclusiveRange(2, 8));
    }

    final reconstructedBody = <List<String>>[
      for (final chunk in chunks) ...chunk.rows.skip(1),
    ];
    expect(reconstructedBody, input.skip(1).toList(growable: false));
    expect(reconstructedBody.map((row) => row.first).toSet(), hasLength(100));
  });

  test('chunk snapshots do not alias later input row mutations', () {
    const layout = PdfTableLayout(maxBodyRowsPerChunk: 1);
    final input = <List<String>>[
      <String>['Header', 'Value'],
      <String>['A', '1'],
      <String>['B', '2'],
    ];

    final chunks = layout.chunk(input);
    input[0][0] = 'Mutated Header';
    input[1][0] = 'Mutated A';

    expect(chunks[0].rows.first.first, 'Header');
    expect(chunks[0].rows[1].first, 'A');
    expect(chunks[1].rows.first.first, 'Header');
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
