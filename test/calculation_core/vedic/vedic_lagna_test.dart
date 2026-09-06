import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_lagna.dart';

final class _FixedAyanamsha implements VedicAyanamshaProvider {
  const _FixedAyanamsha(this.value);

  final double value;

  @override
  String get id => 'lahiri-chitrapaksha';

  @override
  String get dataVersion => 'fixture-v1';

  @override
  double degreesAt(double jdTt) => value;
}

void main() {
  test('RC-0084 produces deterministic sidereal Lagna and rashi fields', () {
    final first = VedicLagna.calculate(
      julianDayUt1: 2451545.0,
      julianDayTt: 2451545.0,
      longitudeDegreesEast: 0,
      latitudeDegreesNorth: 0,
      ayanamsha: const _FixedAyanamsha(24),
    );
    final second = VedicLagna.calculate(
      julianDayUt1: 2451545.0,
      julianDayTt: 2451545.0,
      longitudeDegreesEast: 0,
      latitudeDegreesNorth: 0,
      ayanamsha: const _FixedAyanamsha(24),
    );

    expect(second.siderealLongitudeDegrees, first.siderealLongitudeDegrees);
    expect(first.siderealLongitudeDegrees, inInclusiveRange(0.0, 360.0));
    expect(first.rashiIndex, inInclusiveRange(0, 11));
    expect(first.degreesWithinRashi, inInclusiveRange(0.0, 30.0));
    expect(first.ayanamshaId, 'lahiri-chitrapaksha');
    expect(first.ayanamshaDataVersion, 'fixture-v1');
  });

  test('changing ayanamsha shifts Lagna by the same circular amount', () {
    final lahiri = VedicLagna.calculate(
      julianDayUt1: 2451545.0,
      julianDayTt: 2451545.0,
      longitudeDegreesEast: 29,
      latitudeDegreesNorth: 41,
      ayanamsha: const _FixedAyanamsha(24),
    );
    final alternate = VedicLagna.calculate(
      julianDayUt1: 2451545.0,
      julianDayTt: 2451545.0,
      longitudeDegreesEast: 29,
      latitudeDegreesNorth: 41,
      ayanamsha: const _FixedAyanamsha(22),
    );
    final shift = (alternate.siderealLongitudeDegrees -
            lahiri.siderealLongitudeDegrees +
            360.0) %
        360.0;
    expect(shift, closeTo(2.0, 1e-10));
  });

  test('invalid location and invalid ayanamsha fail closed', () {
    expect(
      () => VedicLagna.calculate(
        julianDayUt1: 2451545.0,
        julianDayTt: 2451545.0,
        longitudeDegreesEast: 181,
        latitudeDegreesNorth: 0,
        ayanamsha: const _FixedAyanamsha(24),
      ),
      throwsRangeError,
    );
    expect(
      () => VedicLagna.calculate(
        julianDayUt1: 2451545.0,
        julianDayTt: 2451545.0,
        longitudeDegreesEast: 0,
        latitudeDegreesNorth: 90,
        ayanamsha: const _FixedAyanamsha(24),
      ),
      throwsRangeError,
    );
    expect(
      () => VedicLagna.calculate(
        julianDayUt1: 2451545.0,
        julianDayTt: 2451545.0,
        longitudeDegreesEast: 0,
        latitudeDegreesNorth: 0,
        ayanamsha: const _FixedAyanamsha(double.nan),
      ),
      throwsStateError,
    );
  });
}
