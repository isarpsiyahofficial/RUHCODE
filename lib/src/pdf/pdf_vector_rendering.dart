import 'dart:math' as math;

/// Immutable vector graphic payload for the PDF renderer.
///
/// The payload is SVG text so `package:pdf` can embed it as vector drawing
/// instructions rather than rasterizing a screenshot/JPEG first.
final class PdfVectorGraphic {
  const PdfVectorGraphic({
    required this.svg,
    required this.widthPt,
    required this.heightPt,
    required this.semanticKind,
  });

  final String svg;
  final double widthPt;
  final double heightPt;
  final String semanticKind;

  void validate() {
    if (!widthPt.isFinite || !heightPt.isFinite || widthPt <= 0 || heightPt <= 0) {
      throw const FormatException('PDF vector dimensions must be finite positive values.');
    }
    if (semanticKind.trim().isEmpty) {
      throw const FormatException('PDF vector semantic kind cannot be blank.');
    }
    final normalized = svg.toLowerCase();
    if (!normalized.contains('<svg') || !normalized.contains('viewbox=')) {
      throw const FormatException('PDF vector payload must be an SVG with a viewBox.');
    }
    if (normalized.contains('<image') ||
        normalized.contains('data:image') ||
        normalized.contains('.jpg') ||
        normalized.contains('.jpeg') ||
        normalized.contains('.png')) {
      throw const FormatException('Raster image payloads are forbidden inside PDF chart vectors.');
    }
    if (!(normalized.contains('<line') ||
        normalized.contains('<path') ||
        normalized.contains('<circle') ||
        normalized.contains('<polygon') ||
        normalized.contains('<rect'))) {
      throw const FormatException('PDF vector payload contains no vector drawing primitives.');
    }
  }
}

final class PdfChartPoint {
  const PdfChartPoint({
    required this.label,
    required this.longitudeDegrees,
  });

  final String label;
  final double longitudeDegrees;

  void validate() {
    if (label.trim().isEmpty) {
      throw const FormatException('PDF chart point label cannot be blank.');
    }
    if (!longitudeDegrees.isFinite || longitudeDegrees < 0 || longitudeDegrees >= 360) {
      throw const FormatException('PDF chart longitude must be in [0, 360).');
    }
  }
}

final class PdfAspectVector {
  const PdfAspectVector({
    required this.fromIndex,
    required this.toIndex,
    required this.kind,
  });

  final int fromIndex;
  final int toIndex;
  final String kind;

  void validate(int pointCount) {
    if (fromIndex < 0 || toIndex < 0 || fromIndex >= pointCount || toIndex >= pointCount) {
      throw const FormatException('PDF aspect endpoint is outside the chart point set.');
    }
    if (fromIndex == toIndex) {
      throw const FormatException('PDF aspect cannot connect a point to itself.');
    }
    if (kind.trim().isEmpty) {
      throw const FormatException('PDF aspect kind cannot be blank.');
    }
  }
}

/// Builds a true vector Western wheel. No bitmap/screenshot input is accepted.
final class PdfWesternChartVectorBuilder {
  const PdfWesternChartVectorBuilder();

  PdfVectorGraphic build({
    required List<PdfChartPoint> points,
    List<PdfAspectVector> aspects = const <PdfAspectVector>[],
  }) {
    if (points.isEmpty) {
      throw const FormatException('Western PDF chart requires at least one verified point.');
    }
    for (final point in points) {
      point.validate();
    }
    for (final aspect in aspects) {
      aspect.validate(points.length);
    }

    const size = 600.0;
    const center = size / 2;
    const outerRadius = 260.0;
    const innerRadius = 205.0;
    const pointRadius = 225.0;
    final svg = StringBuffer()
      ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 600" preserveAspectRatio="xMidYMid meet">')
      ..writeln('<circle cx="300" cy="300" r="260" fill="none" stroke="#111" stroke-width="2"/>')
      ..writeln('<circle cx="300" cy="300" r="205" fill="none" stroke="#444" stroke-width="1.4"/>');

    for (var degree = 0; degree < 360; degree += 30) {
      final angle = _angle(degree.toDouble());
      final x1 = center + innerRadius * math.cos(angle);
      final y1 = center + innerRadius * math.sin(angle);
      final x2 = center + outerRadius * math.cos(angle);
      final y2 = center + outerRadius * math.sin(angle);
      svg.writeln('<line x1="${_n(x1)}" y1="${_n(y1)}" x2="${_n(x2)}" y2="${_n(y2)}" stroke="#333" stroke-width="1.2"/>');
    }

    final coordinates = <({double x, double y})>[];
    for (final point in points) {
      final angle = _angle(point.longitudeDegrees);
      coordinates.add((
        x: center + pointRadius * math.cos(angle),
        y: center + pointRadius * math.sin(angle),
      ));
    }

    for (final aspect in aspects) {
      final a = coordinates[aspect.fromIndex];
      final b = coordinates[aspect.toIndex];
      svg.writeln('<line x1="${_n(a.x)}" y1="${_n(a.y)}" x2="${_n(b.x)}" y2="${_n(b.y)}" stroke="#555" stroke-width="1.1" vector-effect="non-scaling-stroke"/>');
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final position = coordinates[index];
      svg
        ..writeln('<circle cx="${_n(position.x)}" cy="${_n(position.y)}" r="10" fill="white" stroke="#111" stroke-width="1.2"/>')
        ..writeln('<text x="${_n(position.x)}" y="${_n(position.y + 4)}" text-anchor="middle" font-size="11">${_escape(point.label)}</text>');
    }

    svg.writeln('</svg>');
    final graphic = PdfVectorGraphic(
      svg: svg.toString(),
      widthPt: size,
      heightPt: size,
      semanticKind: 'western_astrology_chart',
    );
    graphic.validate();
    return graphic;
  }

  static double _angle(double longitude) => (longitude - 90) * math.pi / 180;
}

/// Builds a square North-Indian-style Vedic chart using vector geometry.
/// The fixed square viewBox keeps the chart proportions exact at any PDF zoom.
final class PdfVedicChartVectorBuilder {
  const PdfVedicChartVectorBuilder();

  PdfVectorGraphic build({required List<String> houseLabels}) {
    if (houseLabels.length != 12) {
      throw const FormatException('Vedic PDF chart requires exactly 12 house labels.');
    }
    if (houseLabels.any((value) => value.trim().isEmpty)) {
      throw const FormatException('Vedic PDF house labels cannot be blank.');
    }
    const size = 600.0;
    const positions = <({double x, double y})>[
      (x: 300, y: 72),
      (x: 438, y: 116),
      (x: 528, y: 210),
      (x: 528, y: 390),
      (x: 438, y: 484),
      (x: 300, y: 528),
      (x: 162, y: 484),
      (x: 72, y: 390),
      (x: 72, y: 210),
      (x: 162, y: 116),
      (x: 300, y: 210),
      (x: 300, y: 390),
    ];
    final svg = StringBuffer()
      ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 600" preserveAspectRatio="xMidYMid meet">')
      ..writeln('<rect x="30" y="30" width="540" height="540" fill="none" stroke="#111" stroke-width="2"/>')
      ..writeln('<polygon points="300,30 570,300 300,570 30,300" fill="none" stroke="#222" stroke-width="1.6"/>')
      ..writeln('<line x1="30" y1="30" x2="570" y2="570" stroke="#333" stroke-width="1.2"/>')
      ..writeln('<line x1="570" y1="30" x2="30" y2="570" stroke="#333" stroke-width="1.2"/>');
    for (var index = 0; index < 12; index++) {
      final position = positions[index];
      svg.writeln('<text x="${_n(position.x)}" y="${_n(position.y)}" text-anchor="middle" font-size="15">${_escape(houseLabels[index])}</text>');
    }
    svg.writeln('</svg>');
    final graphic = PdfVectorGraphic(
      svg: svg.toString(),
      widthPt: size,
      heightPt: size,
      semanticKind: 'vedic_chart',
    );
    graphic.validate();
    return graphic;
  }
}

/// Structural rules for tabular PDF sections. Numerology and BaZi are rendered
/// by the PDF widget table engine, not by screenshots.
abstract final class PdfStructuredTableRules {
  static void validateNumerology(List<List<String>> rows) {
    _validateRectangular(rows, minColumns: 2, semanticName: 'Numerology');
  }

  static void validateBazi(List<List<String>> rows) {
    _validateRectangular(rows, minColumns: 4, semanticName: 'BaZi');
  }

  static void _validateRectangular(
    List<List<String>> rows, {
    required int minColumns,
    required String semanticName,
  }) {
    if (rows.length < 2) {
      throw FormatException('$semanticName PDF table requires a header and at least one data row.');
    }
    final width = rows.first.length;
    if (width < minColumns) {
      throw FormatException('$semanticName PDF table requires at least $minColumns columns.');
    }
    for (final row in rows) {
      if (row.length != width) {
        throw FormatException('$semanticName PDF table columns must remain aligned.');
      }
    }
  }
}

String _n(double value) => value.toStringAsFixed(2);

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
