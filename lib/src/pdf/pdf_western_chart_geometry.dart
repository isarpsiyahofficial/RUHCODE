import 'dart:math' as math;

import '../calculation_core/ephemeris/ephemeris.dart';
import '../calculation_core/western/natal_chart.dart';
import '../calculation_core/western/natal_aspects.dart';
import 'persisted_western_natal_snapshot.dart';

final class PdfVectorPoint {
  const PdfVectorPoint(this.x, this.y);

  final double x;
  final double y;
}

final class PdfHouseRay {
  const PdfHouseRay({
    required this.houseNumber,
    required this.longitudeDegrees,
    required this.outer,
  });

  final int houseNumber;
  final double longitudeDegrees;
  final PdfVectorPoint outer;
}

final class PdfPlanetMarker {
  const PdfPlanetMarker({
    required this.body,
    required this.longitudeDegrees,
    required this.position,
  });

  final AstroBody body;
  final double longitudeDegrees;
  final PdfVectorPoint position;
}

final class PdfAspectChord {
  const PdfAspectChord({
    required this.bodyA,
    required this.bodyB,
    required this.aspect,
    required this.start,
    required this.end,
  });

  final AstroBody bodyA;
  final AstroBody bodyB;
  final MajorAspect aspect;
  final PdfVectorPoint start;
  final PdfVectorPoint end;
}

final class PdfWesternChartGeometry {
  PdfWesternChartGeometry({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required this.ascendantLongitude,
    required List<PdfHouseRay> houseRays,
    required List<PdfPlanetMarker> planetMarkers,
    required List<PdfAspectChord> aspectChords,
  })  : houseRays = List.unmodifiable(houseRays),
        planetMarkers = List.unmodifiable(planetMarkers),
        aspectChords = List.unmodifiable(aspectChords);

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final double ascendantLongitude;
  final List<PdfHouseRay> houseRays;
  final List<PdfPlanetMarker> planetMarkers;
  final List<PdfAspectChord> aspectChords;
}

abstract final class PdfWesternChartGeometryAdapter {
  static const double houseRadius = 1.0;
  static const double planetRadius = 0.82;
  static const double aspectRadius = 0.58;

  static PdfWesternChartGeometry fromChart(WesternNatalChart chart) {
    if (!chart.jdTt.isFinite || chart.sourceId.trim().isEmpty || chart.dataVersion.trim().isEmpty) {
      throw const FormatException('Western chart provenance is required for PDF geometry.');
    }
    if ((chart.placements.jdTt - chart.jdTt).abs() > 1e-12 ||
        chart.placements.sourceId != chart.sourceId ||
        chart.placements.dataVersion != chart.dataVersion ||
        (chart.aspects.jdTt - chart.jdTt).abs() > 1e-12 ||
        chart.aspects.sourceId != chart.sourceId ||
        chart.aspects.dataVersion != chart.dataVersion) {
      throw const FormatException('Western PDF geometry cannot mix calculation snapshots.');
    }

    final ascendant = chart.houses.ascendantLongitude;
    final houseRays = List<PdfHouseRay>.generate(12, (index) {
      final longitude = chart.houses.cusp(index + 1);
      return PdfHouseRay(
        houseNumber: index + 1,
        longitudeDegrees: longitude,
        outer: _pointForLongitude(
          longitudeDegrees: longitude,
          ascendantLongitude: ascendant,
          radius: houseRadius,
        ),
      );
    }, growable: false);

    final planetMarkers = chart.placements.placements
        .map(
          (placement) => PdfPlanetMarker(
            body: placement.body,
            longitudeDegrees: placement.longitudeDegrees,
            position: _pointForLongitude(
              longitudeDegrees: placement.longitudeDegrees,
              ascendantLongitude: ascendant,
              radius: planetRadius,
            ),
          ),
        )
        .toList(growable: false);

    final markersByBody = <AstroBody, PdfPlanetMarker>{
      for (final marker in planetMarkers) marker.body: marker,
    };
    if (markersByBody.length != planetMarkers.length) {
      throw const FormatException('Western PDF planet marker body set contains duplicates.');
    }

    final aspectChords = <PdfAspectChord>[];
    for (final hit in chart.aspects.aspects) {
      final a = markersByBody[hit.bodyA];
      final b = markersByBody[hit.bodyB];
      if (a == null || b == null) {
        throw const FormatException('Western PDF aspect refers to a body outside the placement set.');
      }
      aspectChords.add(
        PdfAspectChord(
          bodyA: hit.bodyA,
          bodyB: hit.bodyB,
          aspect: hit.aspect,
          start: _pointForLongitude(
            longitudeDegrees: a.longitudeDegrees,
            ascendantLongitude: ascendant,
            radius: aspectRadius,
          ),
          end: _pointForLongitude(
            longitudeDegrees: b.longitudeDegrees,
            ascendantLongitude: ascendant,
            radius: aspectRadius,
          ),
        ),
      );
    }

    return PdfWesternChartGeometry(
      jdTt: chart.jdTt,
      sourceId: chart.sourceId,
      dataVersion: chart.dataVersion,
      ascendantLongitude: ascendant,
      houseRays: houseRays,
      planetMarkers: planetMarkers,
      aspectChords: aspectChords,
    );
  }

  /// Builds the exact same vector projection directly from a persisted,
  /// fingerprint-verified natal snapshot. No historical calculation is rerun.
  static PdfWesternChartGeometry fromPersistedSnapshot(PersistedWesternNatalSnapshot snapshot) {
    final ascendant = snapshot.houseCuspsDeg.first;
    final houseRays = List<PdfHouseRay>.generate(12, (index) {
      final longitude = snapshot.houseCuspsDeg[index];
      return PdfHouseRay(
        houseNumber: index + 1,
        longitudeDegrees: longitude,
        outer: _pointForLongitude(
          longitudeDegrees: longitude,
          ascendantLongitude: ascendant,
          radius: houseRadius,
        ),
      );
    }, growable: false);

    final planetMarkers = snapshot.placements.map((placement) {
      final body = _astroBodyByName(placement.body);
      return PdfPlanetMarker(
        body: body,
        longitudeDegrees: placement.longitudeDeg,
        position: _pointForLongitude(
          longitudeDegrees: placement.longitudeDeg,
          ascendantLongitude: ascendant,
          radius: planetRadius,
        ),
      );
    }).toList(growable: false);

    final markersByBody = <AstroBody, PdfPlanetMarker>{
      for (final marker in planetMarkers) marker.body: marker,
    };
    if (markersByBody.length != planetMarkers.length) {
      throw const FormatException('Persisted Western PDF planet marker body set contains duplicates.');
    }

    final aspectChords = snapshot.aspects.map((hit) {
      final bodyA = _astroBodyByName(hit.bodyA);
      final bodyB = _astroBodyByName(hit.bodyB);
      final a = markersByBody[bodyA];
      final b = markersByBody[bodyB];
      if (a == null || b == null) {
        throw const FormatException('Persisted Western PDF aspect refers to an absent body.');
      }
      return PdfAspectChord(
        bodyA: bodyA,
        bodyB: bodyB,
        aspect: _majorAspectByName(hit.type),
        start: _pointForLongitude(
          longitudeDegrees: a.longitudeDegrees,
          ascendantLongitude: ascendant,
          radius: aspectRadius,
        ),
        end: _pointForLongitude(
          longitudeDegrees: b.longitudeDegrees,
          ascendantLongitude: ascendant,
          radius: aspectRadius,
        ),
      );
    }).toList(growable: false);

    return PdfWesternChartGeometry(
      jdTt: snapshot.ttJulianDay,
      sourceId: snapshot.sourceId,
      dataVersion: snapshot.dataVersion,
      ascendantLongitude: ascendant,
      houseRays: houseRays,
      planetMarkers: planetMarkers,
      aspectChords: aspectChords,
    );
  }

  static PdfVectorPoint _pointForLongitude({
    required double longitudeDegrees,
    required double ascendantLongitude,
    required double radius,
  }) {
    if (!longitudeDegrees.isFinite || longitudeDegrees < 0 || longitudeDegrees >= 360) {
      throw RangeError('Longitude must be in [0, 360) for PDF geometry.');
    }
    if (!ascendantLongitude.isFinite || ascendantLongitude < 0 || ascendantLongitude >= 360) {
      throw RangeError('Ascendant must be in [0, 360) for PDF geometry.');
    }
    if (!radius.isFinite || radius <= 0 || radius > 1) {
      throw RangeError('PDF geometry radius must be finite and in (0, 1].');
    }

    final relative = _normalize(longitudeDegrees - ascendantLongitude);
    // Ascendant is anchored at the left edge (9 o'clock). Increasing zodiac
    // longitude moves counter-clockwise in Cartesian chart coordinates.
    final angle = math.pi - (relative * math.pi / 180.0);
    return PdfVectorPoint(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  static AstroBody _astroBodyByName(String name) {
    for (final value in AstroBody.values) {
      if (value.name == name) return value;
    }
    throw FormatException('Unsupported persisted AstroBody: $name');
  }

  static MajorAspect _majorAspectByName(String name) {
    for (final value in MajorAspect.values) {
      if (value.name == name) return value;
    }
    throw FormatException('Unsupported persisted MajorAspect: $name');
  }

  static double _normalize(double degrees) {
    final value = degrees % 360.0;
    return value < 0 ? value + 360.0 : value;
  }
}
