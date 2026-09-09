import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('RC-1272 release fixture renders a real deterministic sample PDF', () async {
    final fixture = jsonDecode(
      File('test/fixtures/pdf/rc1272_free_sample_fixture.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(fixture['usesDemoData'], isTrue);
    expect(fixture['clientId'], isNull);
    expect(fixture['watermark'], 'DEMO / SAMPLE');

    final sections = (fixture['sections'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (_) => <pw.Widget>[
          pw.Text(fixture['watermark']! as String),
          pw.Text(fixture['title']! as String),
          ...sections.map(
            (section) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(section['id']! as String),
                pw.Text(section['text']! as String),
              ],
            ),
          ),
        ],
      ),
    );

    final bytes = await document.save();
    expect(bytes.length, greaterThan(200));
    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
  });
}
