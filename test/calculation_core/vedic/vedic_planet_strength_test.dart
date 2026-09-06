import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_planet_strength.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_shadbala.dart';

ShadbalaComponentValue _component(ShadbalaComponent component) =>
    ShadbalaComponentValue(
      component: component,
      rupa: 1,
      methodId: 'fixture-${component.name}',
      methodVersion: '1',
      sourceId: 'test-source',
    );

void main() {
  test('keeps Shadbala as one explicit metric without hidden weighting', () {
    final shadbala = PlanetShadbala(
      body: AstroBody.sun,
      components: ShadbalaComponent.values.map(_component),
    );
    final metric = VedicPlanetStrengthEngine.shadbalaMetric(shadbala);
    expect(metric.id, 'shadbala.totalRupa');
    expect(metric.value, 6);
    expect(metric.unit, 'rupa');

    final profile = VedicPlanetStrengthProfile(
      body: AstroBody.sun,
      metrics: [metric],
    );
    final snapshot = VedicPlanetStrengthEngine.assemble(
      jdTt: 2460000.5,
      ephemerisSourceId: 'fixture-ephemeris',
      ephemerisDataVersion: '1',
      ayanamshaId: 'fixture-ayanamsha',
      ayanamshaDataVersion: '1',
      profiles: [profile],
    );
    expect(snapshot.profiles.single.metric('shadbala.totalRupa').value, 6);
  });

  test('accepts a separately sourced strength metric without merging doctrines', () {
    final profile = VedicPlanetStrengthProfile(
      body: AstroBody.moon,
      metrics: [
        VedicStrengthMetric(
          id: 'fixture.metric',
          value: 2.5,
          unit: 'fixture-unit',
          methodId: 'fixture-method',
          methodVersion: '1',
          sourceId: 'fixture-source',
        ),
      ],
    );
    expect(profile.metric('fixture.metric').sourceId, 'fixture-source');
  });

  test('fails closed on duplicate metric ids and invalid snapshot provenance', () {
    VedicStrengthMetric metric() => VedicStrengthMetric(
          id: 'same',
          value: 1,
          unit: 'u',
          methodId: 'm',
          methodVersion: '1',
          sourceId: 's',
        );
    expect(
      () => VedicPlanetStrengthProfile(
        body: AstroBody.sun,
        metrics: [metric(), metric()],
      ),
      throwsStateError,
    );
    expect(
      () => VedicPlanetStrengthEngine.assemble(
        jdTt: double.nan,
        ephemerisSourceId: 'e',
        ephemerisDataVersion: '1',
        ayanamshaId: 'a',
        ayanamshaDataVersion: '1',
        profiles: [
          VedicPlanetStrengthProfile(body: AstroBody.sun, metrics: [metric()]),
        ],
      ),
      throwsStateError,
    );
  });
}
