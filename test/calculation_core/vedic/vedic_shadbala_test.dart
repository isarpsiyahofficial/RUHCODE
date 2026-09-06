import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_shadbala.dart';

ShadbalaComponentValue _value(ShadbalaComponent component, double rupa) =>
    ShadbalaComponentValue(
      component: component,
      rupa: rupa,
      methodId: 'fixture-${component.name}',
      methodVersion: '1',
      sourceId: 'test-only',
    );

void main() {
  test('requires and aggregates exactly six canonical Shadbala groups', () {
    final planet = PlanetShadbala(
      body: AstroBody.sun,
      components: [
        _value(ShadbalaComponent.sthana, 1),
        _value(ShadbalaComponent.dig, 2),
        _value(ShadbalaComponent.kala, 3),
        _value(ShadbalaComponent.cheshta, 4),
        _value(ShadbalaComponent.naisargika, 5),
        _value(ShadbalaComponent.drik, 6),
      ],
    );
    expect(planet.totalRupa, 21);
    expect(planet.component(ShadbalaComponent.drik).sourceId, 'test-only');

    final snapshot = VedicShadbalaEngine.assemble(
      jdTt: 2460000.5,
      ephemerisSourceId: 'fixture-ephemeris',
      ephemerisDataVersion: '1',
      ayanamshaId: 'fixture-ayanamsha',
      ayanamshaDataVersion: '1',
      planets: [planet],
    );
    expect(snapshot.planets.single.body, AstroBody.sun);
  });

  test('fails closed on incomplete component sets', () {
    expect(
      () => PlanetShadbala(
        body: AstroBody.sun,
        components: [
          _value(ShadbalaComponent.sthana, 1),
          _value(ShadbalaComponent.dig, 1),
        ],
      ),
      throwsStateError,
    );
  });

  test('fails closed on duplicate components and missing provenance', () {
    expect(
      () => PlanetShadbala(
        body: AstroBody.sun,
        components: [
          _value(ShadbalaComponent.sthana, 1),
          _value(ShadbalaComponent.sthana, 1),
          _value(ShadbalaComponent.dig, 1),
          _value(ShadbalaComponent.kala, 1),
          _value(ShadbalaComponent.cheshta, 1),
          _value(ShadbalaComponent.naisargika, 1),
          _value(ShadbalaComponent.drik, 1),
        ],
      ),
      throwsStateError,
    );
    expect(
      () => ShadbalaComponentValue(
        component: ShadbalaComponent.sthana,
        rupa: 1,
        methodId: '',
        methodVersion: '1',
        sourceId: 'test-only',
      ),
      throwsArgumentError,
    );
  });
}
