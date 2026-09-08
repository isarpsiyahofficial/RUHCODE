import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/pdf/pdf_vector_rendering.dart';
import 'package:ruh_code/src/pdf/pdf_vector_widget.dart';

void main() {
  test('western chart is SVG vector-only with vector aspect lines', () async {
    final graphic = const PdfWesternChartVectorBuilder().build(
      points: const <PdfChartPoint>[
        PdfChartPoint(label: '☉', longitudeDegrees: 15),
        PdfChartPoint(label: '☽', longitudeDegrees: 120),
        PdfChartPoint(label: '♄', longitudeDegrees: 210),
      ],
      aspects: const <PdfAspectVector>[
        PdfAspectVector(fromIndex: 0, toIndex: 1, kind: 'trine'),
        PdfAspectVector(fromIndex: 1, toIndex: 2, kind: 'square'),
      ],
    );

    expect(graphic.semanticKind, 'western_astrology_chart');
    expect(graphic.svg, contains('<circle'));
    expect(graphic.svg, contains('<line'));
    expect(graphic.svg.toLowerCase(), isNot(contains('<image')));
    expect(graphic.svg.toLowerCase(), isNot(contains('.jpeg')));

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => const PdfVectorWidget().build(graphic),
      ),
    );
    final bytes = await document.save();
    expect(bytes.length, greaterThan(500));
  });

  test('vedic chart is square vector geometry with exactly twelve houses', () async {
    final graphic = const PdfVedicChartVectorBuilder().build(
      houseLabels: const <String>[
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
      ],
    );

    expect(graphic.widthPt, graphic.heightPt);
    expect(graphic.svg, contains('viewBox="0 0 600 600"'));
    expect(graphic.svg, contains('<polygon'));
    expect(graphic.svg.toLowerCase(), isNot(contains('<image')));

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => const PdfVectorWidget().build(graphic),
      ),
    );
    final bytes = await document.save();
    expect(bytes.length, greaterThan(500));
  });

  test('raster payloads fail closed', () {
    const graphic = PdfVectorGraphic(
      svg: '<svg viewBox="0 0 10 10"><image href="data:image/jpeg;base64,AAAA"/></svg>',
      widthPt: 10,
      heightPt: 10,
      semanticKind: 'invalid',
    );
    expect(graphic.validate, throwsFormatException);
  });

  test('numerology tables require true rectangular PDF table data', () {
    expect(
      () => PdfStructuredTableRules.validateNumerology(const <List<String>>[
        <String>['Metric', 'Value'],
        <String>['Life Path', '7'],
      ]),
      returnsNormally,
    );
    expect(
      () => PdfStructuredTableRules.validateNumerology(const <List<String>>[
        <String>['Metric'],
        <String>['Life Path'],
      ]),
      throwsFormatException,
    );
  });

  test('BaZi tables enforce aligned four-or-more-column structure', () {
    expect(
      () => PdfStructuredTableRules.validateBazi(const <List<String>>[
        <String>['Pillar', 'Stem', 'Branch', 'Element'],
        <String>['Year', '甲', '子', 'Wood'],
      ]),
      returnsNormally,
    );
    expect(
      () => PdfStructuredTableRules.validateBazi(const <List<String>>[
        <String>['Pillar', 'Stem', 'Branch'],
        <String>['Year', '甲', '子'],
      ]),
      throwsFormatException,
    );
  });

  test('invalid Vedic proportions and aspect endpoints fail closed', () {
    expect(
      () => const PdfVedicChartVectorBuilder().build(
        houseLabels: <String>['1', '2'],
      ),
      throwsFormatException,
    );
    expect(
      () => const PdfWesternChartVectorBuilder().build(
        points: <PdfChartPoint>[
          PdfChartPoint(label: 'Sun', longitudeDegrees: 10),
        ],
        aspects: <PdfAspectVector>[
          PdfAspectVector(fromIndex: 0, toIndex: 2, kind: 'square'),
        ],
      ),
      throwsFormatException,
    );
  });
}
