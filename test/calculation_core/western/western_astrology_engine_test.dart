import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/western_astrology_engine.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

EclipticState state(AstroBody body, double longitude) => EclipticState(
      body: body,
      jdTt: 2460000.5,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: 'test-source',
      dataVersion: 'v1',
    );

CalculationManifest manifest({
  String engineId = 'western-astrology',
  String dataVersion = 'v1',
}) =>
    CalculationManifest(
      id: EntityId.parse('11111111-1111-4111-8111-111111111111'),
      engineId: engineId,
      engineVersion: '1.0.0',
      algorithmVersion: 'western-v1',
      dataVersion: dataVersion,
      localDateTime: DateTime.utc(2023, 2, 25, 12),
      utcDateTime: DateTime.utc(2023, 2, 25, 12),
      location: const LocationRecord(
        label: 'Test',
        countryCode: 'TR',
        latitude: 41.0,
        longitude: 29.0,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: CalculationValidity.valid,
      houseSystemId: 'whole-sign',
      zodiacSystemId: 'tropical',
    );

void main() {
  test('dedicated western engine assembles a WesternNatalChart', () async {
    const engine = WesternAstrologyEngine();
    final result = await engine.calculate(
      WesternAstrologyInput(
        manifest: manifest(),
        states: [
          state(AstroBody.sun, 0),
          state(AstroBody.moon, 90),
          state(AstroBody.mercury, 120),
        ],
        houses: EqualHouseSystems.wholeSign(ascendantLongitude: 95),
      ),
    );

    expect(engine.engineId, 'western-astrology');
    expect(result.manifest.engineId, 'western-astrology');
    expect(result.value.placements.placements, hasLength(3));
    expect(result.value.dataVersion, 'v1');
  });

  test('fails closed on a foreign engine manifest', () async {
    const engine = WesternAstrologyEngine();
    expect(
      () => engine.calculate(
        WesternAstrologyInput(
          manifest: manifest(engineId: 'vedic-astrology'),
          states: [state(AstroBody.sun, 0)],
          houses: EqualHouseSystems.equal(ascendantLongitude: 0),
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('fails closed on ephemeris/manifest data-version mismatch', () async {
    const engine = WesternAstrologyEngine();
    expect(
      () => engine.calculate(
        WesternAstrologyInput(
          manifest: manifest(dataVersion: 'other'),
          states: [state(AstroBody.sun, 0)],
          houses: EqualHouseSystems.equal(ascendantLongitude: 0),
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
