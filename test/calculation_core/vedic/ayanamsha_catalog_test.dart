import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/ayanamsha_catalog.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';

final class _Ayanamsha implements VedicAyanamshaProvider {
  const _Ayanamsha(this.name, this.value);
  final String name;
  final double value;

  @override
  String get id => name;
  @override
  String get dataVersion => 'fixture-v1';
  @override
  double degreesAt(double jdTt) => value;
}

final class _Ephemeris implements EphemerisProvider {
  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 1000,
        endJdTt: 2000,
        sourceId: 'fixture',
        dataVersion: 'v1',
        checksumSha256:
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) =>
      EclipticState(
        body: body,
        jdTt: jdTt,
        longitudeDegrees: 100,
        latitudeDegrees: 0,
        distanceAu: 1,
        longitudeSpeedDegreesPerDay: 1,
        sourceId: coverage.sourceId,
        dataVersion: coverage.dataVersion,
      );
}

void main() {
  test('RC-0082 defaults to Lahiri/Chitrapaksha', () {
    final catalog = VedicAyanamshaCatalog(providers: const [
      _Ayanamsha(VedicAyanamshaIds.lahiriChitrapaksha, 24),
      _Ayanamsha('raman', 22),
    ]);
    expect(catalog.defaultId, VedicAyanamshaIds.lahiriChitrapaksha);
    expect(catalog.resolve().id, VedicAyanamshaIds.lahiriChitrapaksha);
    expect(catalog.resolve('   ').id, VedicAyanamshaIds.lahiriChitrapaksha);

    final snapshot = ConfiguredVedicCalculation.calculate(
      jdTt: 1500,
      bodies: const [AstroBody.sun],
      ephemeris: _Ephemeris(),
      ayanamshas: catalog,
    );
    expect(snapshot.ayanamshaId, VedicAyanamshaIds.lahiriChitrapaksha);
    expect(snapshot.forBody(AstroBody.sun).siderealLongitudeDegrees, 76);
  });

  test('RC-0083 supports an explicit alternative without changing engine', () {
    final catalog = VedicAyanamshaCatalog(providers: const [
      _Ayanamsha(VedicAyanamshaIds.lahiriChitrapaksha, 24),
      _Ayanamsha('raman', 22),
    ]);
    final snapshot = ConfiguredVedicCalculation.calculate(
      jdTt: 1500,
      bodies: const [AstroBody.sun],
      ephemeris: _Ephemeris(),
      ayanamshas: catalog,
      ayanamshaId: 'raman',
    );
    expect(snapshot.ayanamshaId, 'raman');
    expect(snapshot.forBody(AstroBody.sun).siderealLongitudeDegrees, 78);
    expect(catalog.availableIds, containsAll(['lahiri-chitrapaksha', 'raman']));
  });

  test('catalog fails closed when canonical default is unavailable', () {
    expect(
      () => VedicAyanamshaCatalog(
        providers: const [_Ayanamsha('raman', 22)],
      ),
      throwsStateError,
    );
  });

  test('catalog rejects duplicate and unknown ayanamsha ids', () {
    expect(
      () => VedicAyanamshaCatalog(providers: const [
        _Ayanamsha(VedicAyanamshaIds.lahiriChitrapaksha, 24),
        _Ayanamsha(VedicAyanamshaIds.lahiriChitrapaksha, 25),
      ]),
      throwsArgumentError,
    );
    final catalog = VedicAyanamshaCatalog(providers: const [
      _Ayanamsha(VedicAyanamshaIds.lahiriChitrapaksha, 24),
    ]);
    expect(() => catalog.resolve('unknown'), throwsStateError);
  });
}
