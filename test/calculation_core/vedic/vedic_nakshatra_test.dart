import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_nakshatra.dart';

VedicCalculationSnapshot _snapshot(double moonLongitude) {
  return VedicCalculationSnapshot(
    jdTt: 2451545.0,
    ephemerisSourceId: 'fixture',
    ephemerisDataVersion: 'v1',
    ayanamshaId: 'lahiri-chitrapaksha',
    ayanamshaDataVersion: 'fixture-v1',
    ayanamshaDegrees: 24,
    placements: [
      VedicPlacement(
        body: AstroBody.moon,
        siderealLongitudeDegrees: moonLongitude,
        longitudeSpeedDegreesPerDay: 13.2,
      ),
    ],
  );
}

void main() {
  test('RC-0088 starts the 27-fold cycle at Ashwini', () {
    final result = VedicNakshatra.fromSnapshot(_snapshot(0));
    expect(result.nakshatraIndex, 0);
    expect(result.nakshatraId, 'ashwini');
    expect(result.pada, 1);
  });

  test('RC-0089 changes Pada every quarter of a Nakshatra', () {
    const padaSpan = VedicNakshatra.padaSpanDegrees;
    expect(VedicNakshatra.fromSnapshot(_snapshot(padaSpan - 1e-9)).pada, 1);
    expect(VedicNakshatra.fromSnapshot(_snapshot(padaSpan)).pada, 2);
    expect(VedicNakshatra.fromSnapshot(_snapshot(2 * padaSpan)).pada, 3);
    expect(VedicNakshatra.fromSnapshot(_snapshot(3 * padaSpan)).pada, 4);
  });

  test('RC-0088 crosses to Bharani at exactly one Nakshatra span', () {
    final result = VedicNakshatra.fromSnapshot(
      _snapshot(VedicNakshatra.nakshatraSpanDegrees),
    );
    expect(result.nakshatraIndex, 1);
    expect(result.nakshatraId, 'bharani');
    expect(result.pada, 1);
  });

  test('RC-0088/RC-0089 map the end of the cycle to Revati Pada 4', () {
    final result = VedicNakshatra.fromSnapshot(_snapshot(359.999999));
    expect(result.nakshatraIndex, 26);
    expect(result.nakshatraId, 'revati');
    expect(result.pada, 4);
  });

  test('RC-0088 fails closed without exactly one Moon', () {
    final empty = VedicCalculationSnapshot(
      jdTt: 2451545.0,
      ephemerisSourceId: 'fixture',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
      ayanamshaDegrees: 24,
      placements: const [],
    );
    expect(() => VedicNakshatra.fromSnapshot(empty), throwsStateError);
  });
}
