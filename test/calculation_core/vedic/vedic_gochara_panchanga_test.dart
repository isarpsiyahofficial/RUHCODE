import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_gochara.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_panchanga.dart';

void main() {
  group('RC-0111 Gochara', () {
    test('uses independent Vedic engine with exact provenance', () {
      final snapshot = VedicGochara.calculate(
        jdTt: 2451545.0,
        ephemeris: _FakeEphemeris(),
        ayanamsha: _FakeAyanamsha(),
        bodies: const <AstroBody>[AstroBody.sun, AstroBody.moon],
      );
      expect(snapshot.vedic.ephemerisSourceId, 'fixture-ephemeris');
      expect(snapshot.vedic.ayanamshaId, 'fixture-lahiri');
      expect(snapshot.forBody(AstroBody.sun).siderealLongitudeDegrees, closeTo(76, 1e-12));
      expect(snapshot.forBody(AstroBody.moon).siderealLongitudeDegrees, closeTo(106, 1e-12));
    });

    test('fails closed on duplicate bodies', () {
      expect(
        () => VedicGochara.calculate(
          jdTt: 2451545.0,
          ephemeris: _FakeEphemeris(),
          ayanamsha: _FakeAyanamsha(),
          bodies: const <AstroBody>[AstroBody.sun, AstroBody.sun],
        ),
        throwsArgumentError,
      );
    });
  });

  group('RC-0113/0115/0116/0117 Panchanga core', () {
    test('computes Tithi, daily Nakshatra, Yoga and Karana', () {
      final value = VedicPanchanga.calculateFromSnapshot(
        _snapshot(sun: 10, moon: 25),
      );
      expect(value.tithiIndex, 2);
      expect(value.tithiInPaksha, 2);
      expect(value.paksha, VedicPaksha.shukla);
      expect(value.nakshatraIndex, 2);
      expect(value.yogaIndex, 3);
      expect(value.karanaHalfTithiIndex, 3);
      expect(value.karana, VedicKarana.balava);
    });

    test('maps fixed and repeating Karanas across the 60 half-tithis', () {
      expect(
        VedicPanchanga.calculateFromSnapshot(_snapshot(sun: 0, moon: 1)).karana,
        VedicKarana.kimstughna,
      );
      expect(
        VedicPanchanga.calculateFromSnapshot(_snapshot(sun: 0, moon: 343)).karana,
        VedicKarana.shakuni,
      );
      expect(
        VedicPanchanga.calculateFromSnapshot(_snapshot(sun: 0, moon: 349)).karana,
        VedicKarana.chatushpada,
      );
      expect(
        VedicPanchanga.calculateFromSnapshot(_snapshot(sun: 0, moon: 355)).karana,
        VedicKarana.naga,
      );
    });

    test('handles Krishna Paksha and 360-degree wrap', () {
      final value = VedicPanchanga.calculateFromSnapshot(
        _snapshot(sun: 350, moon: 170),
      );
      expect(value.tithiIndex, 16);
      expect(value.tithiInPaksha, 1);
      expect(value.paksha, VedicPaksha.krishna);
      expect(value.yogaIndex, 13);
    });

    test('fails closed without Sun and Moon completeness', () {
      final incomplete = VedicCalculationSnapshot(
        jdTt: 2451545.0,
        ephemerisSourceId: 'fixture-ephemeris',
        ephemerisDataVersion: '1',
        ayanamshaId: 'fixture-lahiri',
        ayanamshaDataVersion: '1',
        ayanamshaDegrees: 24,
        placements: const <VedicPlacement>[
          VedicPlacement(
            body: AstroBody.sun,
            siderealLongitudeDegrees: 10,
            longitudeSpeedDegreesPerDay: 1,
          ),
        ],
      );
      expect(() => VedicPanchanga.calculateFromSnapshot(incomplete), throwsStateError);
    });
  });
}

VedicCalculationSnapshot _snapshot({required double sun, required double moon}) {
  return VedicCalculationSnapshot(
    jdTt: 2451545.0,
    ephemerisSourceId: 'fixture-ephemeris',
    ephemerisDataVersion: '1',
    ayanamshaId: 'fixture-lahiri',
    ayanamshaDataVersion: '1',
    ayanamshaDegrees: 24,
    placements: <VedicPlacement>[
      VedicPlacement(
        body: AstroBody.sun,
        siderealLongitudeDegrees: sun,
        longitudeSpeedDegreesPerDay: 1,
      ),
      VedicPlacement(
        body: AstroBody.moon,
        siderealLongitudeDegrees: moon,
        longitudeSpeedDegreesPerDay: 13,
      ),
    ],
  );
}

final class _FakeAyanamsha implements VedicAyanamshaProvider {
  @override
  String get id => 'fixture-lahiri';

  @override
  String get dataVersion => '1';

  @override
  double degreesAt(double jdTt) => 24;
}

final class _FakeEphemeris implements EphemerisProvider {
  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2451544.0,
        endJdTt: 2451546.0,
        sourceId: 'fixture-ephemeris',
        dataVersion: '1',
        checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final longitude = switch (body) {
      AstroBody.sun => 100.0,
      AstroBody.moon => 130.0,
      _ => 200.0 + body.index,
    };
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: coverage.sourceId,
      dataVersion: coverage.dataVersion,
    );
  }
}
