import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/csv_codec.dart';

void main() {
  const codec = RuhCsvDocumentCodec();

  test('round-trips unicode, commas, quotes and embedded newlines', () {
    const rows = <List<String?>>[
      <String?>['id', 'name', 'note'],
      <String?>['1', 'İbrahim Yeşilyurt', 'virgül, tırnak " ve\nyeni satır'],
      <String?>['2', '東京', 'مرحبا 🌙'],
    ];

    final encoded = codec.encode(rows);
    expect(encoded, contains('"virgül, tırnak "" ve\nyeni satır"'));
    expect(codec.decode(encoded), rows);
  });

  test('preserves null, empty string, zero and literal null sentinel', () {
    const rows = <List<String?>>[
      <String?>['null', 'empty', 'zero', 'literal'],
      <String?>[null, '', '0', r'\N'],
    ];

    final encoded = codec.encode(rows);
    expect(codec.decode(encoded), rows);
  });

  test('preserves arbitrary leading backslashes', () {
    const rows = <List<String?>>[
      <String?>[r'\path', r'\\server\share', r'\N', r'\\N'],
    ];
    expect(codec.decode(codec.encode(rows)), rows);
  });

  test('uses CRLF between records and accepts LF input', () {
    const rows = <List<String?>>[
      <String?>['a', 'b'],
      <String?>['c', 'd'],
    ];
    expect(codec.encode(rows), 'a,b\r\nc,d');
    expect(codec.decode('a,b\nc,d\n'), rows);
  });

  test('machine decimal representation remains locale independent', () {
    const rows = <List<String?>>[
      <String?>['amount'],
      <String?>['12.45'],
    ];
    final encoded = codec.encode(rows);
    expect(encoded, contains('12.45'));
    expect(encoded, isNot(contains('12,45')));
    expect(codec.decode(encoded), rows);
  });

  test('rejects unterminated quoted fields', () {
    expect(() => codec.decode('a,"broken'), throwsFormatException);
  });

  test('does not append an empty row for a trailing newline', () {
    expect(
      codec.decode('a,b\r\nc,d\r\n'),
      const <List<String?>>[
        <String?>['a', 'b'],
        <String?>['c', 'd'],
      ],
    );
  });
}
