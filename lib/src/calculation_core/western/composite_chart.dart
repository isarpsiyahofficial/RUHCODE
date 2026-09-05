import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

final class CompositePlacement {
  const CompositePlacement({
    required this.body,
    required this.longitudeDegrees,
    required this.sign,
    required this.degreeInSign,
  });

  final AstroBody body;
  final double longitudeDegrees;
  final TropicalZodiacSign sign;
  final double degreeInSign;
}

final class WesternCompositeChart {
  WesternCompositeChart({
    required this.personAJdTt,
    required this.personBJdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<CompositePlacement> placements,
  }) : placements = List<CompositePlacement>.unmodifiable(placements);

  final double personAJdTt;
  final double personBJdTt;
  final String sourceId;
  final String dataVersion;
  final List<CompositePlacement> placements;

  CompositePlacement forBody(AstroBody body) =>
      placements.singleWhere((placement) => placement.body == body);
}

/// Builds a midpoint composite from two independently calculated natal
/// placement sets. Longitudes use the shortest circular arc, so pairs such as
/// 350° and 10° correctly produce 0° rather than 180°.
///
/// This core intentionally does not invent composite houses or angles. Those
/// require a separately specified time/location policy and remain outside this
/// RC-0071 machine proof.
abstract final class WesternCompositeChartBuilder {
  static WesternCompositeChart build({
    required NatalPlacementSet personA,
    required NatalPlacementSet personB,
  }) {
    if (personA.sourceId != personB.sourceId ||
        personA.dataVersion != personB.dataVersion) {
      throw StateError(
        'Composite chart requires matching ephemeris provenance.',
      );
    }

    final aByBody = <AstroBody, NatalPlacement>{
      for (final placement in personA.placements) placement.body: placement,
    };
    final bByBody = <AstroBody, NatalPlacement>{
      for (final placement in personB.placements) placement.body: placement,
    };
    if (aByBody.length != personA.placements.length ||
        bByBody.length != personB.placements.length) {
      throw StateError('Composite input contains duplicate bodies.');
    }
    if (aByBody.length != bByBody.length ||
        !aByBody.keys.every(bByBody.containsKey)) {
      throw StateError(
        'Composite chart requires identical natal body sets.',
      );
    }

    final placements = <CompositePlacement>[];
    for (final body in aByBody.keys) {
      final longitude = _circularMidpoint(
        aByBody[body]!.longitudeDegrees,
        bByBody[body]!.longitudeDegrees,
      );
      final signIndex = (longitude / 30.0).floor() % 12;
      placements.add(
        CompositePlacement(
          body: body,
          longitudeDegrees: longitude,
          sign: TropicalZodiacSign.values[signIndex],
          degreeInSign: longitude - signIndex * 30.0,
        ),
      );
    }
    placements.sort((a, b) => a.body.index.compareTo(b.body.index));

    return WesternCompositeChart(
      personAJdTt: personA.jdTt,
      personBJdTt: personB.jdTt,
      sourceId: personA.sourceId,
      dataVersion: personA.dataVersion,
      placements: placements,
    );
  }

  static double _circularMidpoint(double a, double b) {
    if (!a.isFinite || !b.isFinite) {
      throw ArgumentError('Composite longitudes must be finite.');
    }
    final normalizedA = _normalize(a);
    final normalizedB = _normalize(b);
    var delta = (normalizedB - normalizedA) % 360.0;
    if (delta < 0) delta += 360.0;
    if (delta > 180.0) delta -= 360.0;
    return _normalize(normalizedA + delta / 2.0);
  }

  static double _normalize(double degrees) {
    var value = degrees % 360.0;
    if (value < 0) value += 360.0;
    if (value >= 360.0) value -= 360.0;
    return value;
  }
}
