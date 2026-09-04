import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_astrology_engine.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

void main() {
  const engine = VedicAstrologyEngine();

  CalculationManifest manifest({
    String engineId = 'vedic-astrology',
    String dataVersion = 'de440s-test',
    String? zodiacSystemId = 'sidereal',
    String? ayanamshaId = 'test-ayanamsha',
    CalculationValidity validity = CalculationValidity.valid,
  }) {
    return CalculationManifest(
      id: EntityId.parse('123e4567-e89b-42d3-a456-426614174000'),
      engineId: engineId,
      engineVersion: '1.0.0',
      algorithmVersion: 'test',
      dataVersion: dataVersion,
      localDateTime: DateTime.utc(2000, 1, 1, 12),
      utcDateTime: DateTime.utc(2000, 1, 1, 12),
      location: const LocationRecord(
        label: 'Test',
        countryCode: 'TR',
        latitude: 41.0,
        longitude: 29.0,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: validity,
      zodiacSystemId: zodiacSystemId,
      ayanamshaId: ayanamshaId,
    );
  }

  EclipticState state({
    AstroBody body = AstroBody.sun,
    double longitude = 10,
    double jdTt = 2451545.0,
    String sourceId = 'test-source',
    String dataVersion = 'de440s-test',
  }) {
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0.5,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: sourceId,
      dataVersion: dataVersion,
    );
  }

  test('is a separate CalculationEngine with a Vedic engine id', () {
    expect(engine.engineId, 'vedic-astrology');
    expect(engine.engineId, isNot('western-astrology'));
    expect(engine.engineVersion, isNotEmpty);
  });

  test('converts explicit tropical states to normalized sidereal placements', () async {
    final result = await engine.calculate(
      VedicAstrologyInput(
        manifest: manifest(),
        states: <EclipticState>[
          state(body: AstroBody.sun, longitude: 10),
          state(body: AstroBody.moon, longitude: 100),
        ],
        ayanamshaDegrees: 24,
      ),
    );

    expect(result.value.ayanamshaId, 'test-ayanamsha');
    expect(result.value.ayanamshaDegrees, 24);
    expect(result.value.placements, hasLength(2));
    expect(result.value.placements[0].tropicalLongitudeDegrees, 10);
    expect(result.value.placements[0].siderealLongitudeDegrees, 346);
    expect(result.value.placements[1].siderealLongitudeDegrees, 76);
    expect(result.value.dataVersion, 'de440s-test');
  });

  test('rejects a foreign engine manifest', () async {
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(engineId: 'western-astrology'),
          states: <EclipticState>[state()],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
  });

  test('requires explicit sidereal and ayanamsha manifest identity', () async {
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(zodiacSystemId: 'tropical'),
          states: <EclipticState>[state()],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(ayanamshaId: null),
          states: <EclipticState>[state()],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
  });

  test('rejects invalid ayanamsha and provenance mismatches', () async {
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(),
          states: <EclipticState>[state()],
          ayanamshaDegrees: double.nan,
        ),
      ),
      throwsRangeError,
    );
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(),
          states: <EclipticState>[state(dataVersion: 'other')],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(),
          states: <EclipticState>[
            state(body: AstroBody.sun),
            state(body: AstroBody.moon, jdTt: 2451545.5),
          ],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
  });

  test('rejects duplicate bodies instead of silently overwriting them', () async {
    expect(
      () => engine.calculate(
        VedicAstrologyInput(
          manifest: manifest(),
          states: <EclipticState>[state(), state(longitude: 11)],
          ayanamshaDegrees: 24,
        ),
      ),
      throwsStateError,
    );
  });
}
