import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';
import 'package:ruh_code/src/calculation_core/western/predictive_techniques.dart';

final class _PredictiveEphemeris implements EphemerisProvider {
  _PredictiveEphemeris({this.mismatchProvenance = false});

  final bool mismatchProvenance;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 1000,
        endJdTt: 2000,
        sourceId: 'fixture',
        dataVersion: 'v1',
        checksumSha256: 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final speed = switch (body) {
      AstroBody.sun => 1.0,
      AstroBody.moon => 12.0,
      AstroBody.mars => 0.5,
      _ => 0.25,
    };
    final base = switch (body) {
      AstroBody.sun => 350.0,
      AstroBody.moon => 100.0,
      AstroBody.mars => 20.0,
      _ => 0.0,
    };
    var longitude = (base + (jdTt - 1000.0) * speed) % 360.0;
    if (longitude < 0) longitude += 360.0;
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: speed,
      sourceId: mismatchProvenance ? 'wrong' : coverage.sourceId,
      dataVersion: coverage.dataVersion,
    );
  }
}

NatalPlacement _placement(AstroBody body, double longitude) {
  final signIndex = (longitude / 30).floor();
  return NatalPlacement(
    body: body,
    longitudeDegrees: longitude,
    longitudeSpeedDegreesPerDay: 1,
    sign: TropicalZodiacSign.values[signIndex],
    degreeInSign: longitude - signIndex * 30,
    houseNumber: 1,
    motion: ApparentMotion.direct,
  );
}

void main() {
  test('RC-0076 uses one ephemeris day per explicit year of age', () {
    final result = WesternSecondaryProgressions.calculate(
      natalJdTt: 1000,
      ageYears: 30,
      bodies: const [AstroBody.sun, AstroBody.moon],
      ephemeris: _PredictiveEphemeris(),
    );

    expect(result.progressedJdTt, 1030);
    expect(result.states.length, 2);
    expect(result.states.firstWhere((s) => s.body == AstroBody.sun).longitudeDegrees, 20);
    expect(result.states.firstWhere((s) => s.body == AstroBody.moon).longitudeDegrees, 100);
  });

  test('RC-0076 fails closed on duplicate body requests', () {
    expect(
      () => WesternSecondaryProgressions.calculate(
        natalJdTt: 1000,
        ageYears: 1,
        bodies: const [AstroBody.sun, AstroBody.sun],
        ephemeris: _PredictiveEphemeris(),
      ),
      throwsArgumentError,
    );
  });

  test('RC-0077 derives a single Solar Arc from the progressed Sun', () {
    final natal = NatalPlacementSet(
      jdTt: 1000,
      sourceId: 'fixture',
      dataVersion: 'v1',
      placements: [
        _placement(AstroBody.sun, 350),
        _placement(AstroBody.mars, 355),
      ],
    );

    final result = WesternSolarArc.calculate(
      natal: natal,
      ageYears: 20,
      ephemeris: _PredictiveEphemeris(),
    );

    expect(result.progressedJdTt, 1020);
    expect(result.arcDegrees, 20);
    expect(
      result.placements.firstWhere((p) => p.body == AstroBody.mars).directedLongitudeDegrees,
      15,
    );
  });

  test('RC-0077 rejects natal and ephemeris provenance mismatch', () {
    final natal = NatalPlacementSet(
      jdTt: 1000,
      sourceId: 'fixture',
      dataVersion: 'v1',
      placements: [_placement(AstroBody.sun, 350)],
    );
    expect(
      () => WesternSolarArc.calculate(
        natal: natal,
        ageYears: 1,
        ephemeris: _PredictiveEphemeris(mismatchProvenance: true),
      ),
      throwsStateError,
    );
  });

  test('RC-0078 advances one house/sign per year and repeats every twelve', () {
    final age0 = WesternAnnualProfections.calculate(
      ageYears: 0,
      natalAscendantLongitudeDegrees: 95,
    );
    final age13 = WesternAnnualProfections.calculate(
      ageYears: 13,
      natalAscendantLongitudeDegrees: 95,
    );

    expect(age0.activatedHouse, 1);
    expect(age0.natalAscendantSign, TropicalZodiacSign.cancer);
    expect(age0.activatedSign, TropicalZodiacSign.cancer);
    expect(age13.activatedHouse, 2);
    expect(age13.activatedSign, TropicalZodiacSign.leo);
  });

  test('RC-0078 rejects non-normalized Ascendant longitude', () {
    expect(
      () => WesternAnnualProfections.calculate(
        ageYears: 10,
        natalAscendantLongitudeDegrees: 360,
      ),
      throwsRangeError,
    );
  });

  test('predictive techniques reject mismatched returned ephemeris provenance', () {
    expect(
      () => WesternSecondaryProgressions.calculate(
        natalJdTt: 1000,
        ageYears: 2,
        bodies: const [AstroBody.sun],
        ephemeris: _PredictiveEphemeris(mismatchProvenance: true),
      ),
      throwsStateError,
    );
  });
}
