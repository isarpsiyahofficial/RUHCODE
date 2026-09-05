import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/eclipse_overlay.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

NatalPlacement _placement(AstroBody body, double longitude) {
  final signIndex = (longitude / 30).floor();
  return NatalPlacement(
    body: body,
    longitudeDegrees: longitude,
    longitudeSpeedDegreesPerDay: 0,
    sign: TropicalZodiacSign.values[signIndex],
    degreeInSign: longitude - signIndex * 30,
    houseNumber: 1,
    motion: ApparentMotion.stationary,
  );
}

NatalPlacementSet _natal() => NatalPlacementSet(
      jdTt: 1000,
      sourceId: 'verified-eclipse-fixture',
      dataVersion: 'v1',
      placements: [
        _placement(AstroBody.sun, 10),
        _placement(AstroBody.moon, 191),
        _placement(AstroBody.mars, 90),
      ],
    );

void main() {
  test('RC-0079 computes deterministic eclipse conjunction/opposition overlay', () {
    final result = WesternEclipseOverlay.calculate(
      natal: _natal(),
      eclipses: const [
        VerifiedEclipseEvent(
          kind: EclipseKind.solar,
          jdTt: 1100,
          longitudeDegrees: 11,
          sourceId: 'verified-eclipse-fixture',
          dataVersion: 'v1',
        ),
      ],
      maximumOrbDegrees: 3,
    );

    expect(result.contacts.length, 2);
    expect(result.contacts[0].natalBody, AstroBody.sun);
    expect(result.contacts[0].contactKind, EclipseContactKind.conjunction);
    expect(result.contacts[0].orbDegrees, closeTo(1, 1e-12));
    expect(result.contacts[1].natalBody, AstroBody.moon);
    expect(result.contacts[1].contactKind, EclipseContactKind.opposition);
    expect(result.contacts[1].orbDegrees, closeTo(0, 1e-12));
  });

  test('RC-0079 does not fabricate contacts outside configured orb', () {
    final result = WesternEclipseOverlay.calculate(
      natal: _natal(),
      eclipses: const [
        VerifiedEclipseEvent(
          kind: EclipseKind.lunar,
          jdTt: 1200,
          longitudeDegrees: 45,
          sourceId: 'verified-eclipse-fixture',
          dataVersion: 'v1',
        ),
      ],
    );
    expect(result.contacts, isEmpty);
  });

  test('RC-0079 fails closed on eclipse/natal provenance mismatch', () {
    expect(
      () => WesternEclipseOverlay.calculate(
        natal: _natal(),
        eclipses: const [
          VerifiedEclipseEvent(
            kind: EclipseKind.solar,
            jdTt: 1100,
            longitudeDegrees: 10,
            sourceId: 'other-source',
            dataVersion: 'v1',
          ),
        ],
      ),
      throwsStateError,
    );
  });

  test('RC-0079 rejects invalid eclipse longitude and unsafe orb', () {
    expect(
      () => WesternEclipseOverlay.calculate(
        natal: _natal(),
        eclipses: const [
          VerifiedEclipseEvent(
            kind: EclipseKind.solar,
            jdTt: 1100,
            longitudeDegrees: 360,
            sourceId: 'verified-eclipse-fixture',
            dataVersion: 'v1',
          ),
        ],
      ),
      throwsRangeError,
    );
    expect(
      () => WesternEclipseOverlay.calculate(
        natal: _natal(),
        eclipses: const [],
        maximumOrbDegrees: 0,
      ),
      throwsRangeError,
    );
  });
}
