import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/earth_orientation.dart';
import 'package:ruh_code/src/calculation_core/time/time_scales.dart';

final class _FixedEopProvider implements EarthOrientationProvider {
  _FixedEopProvider(this.offsetSeconds);

  final double offsetSeconds;

  @override
  EarthOrientationSample sampleAt(DateTime utcInstant) => EarthOrientationSample(
        utcInstant: utcInstant,
        ut1MinusUtcSeconds: offsetSeconds,
        sourceId: 'fixture-iers-eop',
        dataVersion: 'fixture-v1',
      );
}

final class _MismatchedProvider implements EarthOrientationProvider {
  @override
  EarthOrientationSample sampleAt(DateTime utcInstant) => EarthOrientationSample(
        utcInstant: utcInstant.add(const Duration(seconds: 1)),
        ut1MinusUtcSeconds: 0.1,
        sourceId: 'fixture-iers-eop',
        dataVersion: 'fixture-v1',
      );
}

void main() {
  test('UT1 Julian Day is derived from explicit UT1-UTC sample', () {
    final utc = DateTime.utc(2026, 8, 18, 12);
    final context = AstronomicalTimeContext.fromUtc(
      utcInstant: utc,
      earthOrientationProvider: _FixedEopProvider(0.25),
    );
    // Subtracting two Julian-day doubles near 2.46 million loses several low
    // bits through cancellation. 2e-10 day (~17 microseconds) stays well below
    // the EOP accuracy budget while testing the intended 0.25-second offset.
    expect(
      context.jdUt1 - context.jdUtc,
      closeTo(0.25 / TimeScales.secondsPerDay, 2e-10),
    );
    expect(context.ut1MinusUtcSeconds, 0.25);
    expect(context.earthOrientationSourceId, 'fixture-iers-eop');
    expect(context.earthOrientationDataVersion, 'fixture-v1');
  });

  test('TT and UT1 remain separate values in astronomical context', () {
    final context = AstronomicalTimeContext.fromUtc(
      utcInstant: DateTime.utc(2026, 8, 18, 12),
      earthOrientationProvider: _FixedEopProvider(0.2),
    );
    expect(context.jdTt, isNot(context.jdUt1));
    expect(context.jdTt, greaterThan(context.jdUtc));
  });

  test('out-of-bound UT1-UTC is rejected', () {
    expect(
      () => AstronomicalTimeContext.fromUtc(
        utcInstant: DateTime.utc(2026, 8, 18),
        earthOrientationProvider: _FixedEopProvider(0.9),
      ),
      throwsRangeError,
    );
  });

  test('mismatched EOP sample timestamp is rejected', () {
    expect(
      () => AstronomicalTimeContext.fromUtc(
        utcInstant: DateTime.utc(2026, 8, 18),
        earthOrientationProvider: _MismatchedProvider(),
      ),
      throwsStateError,
    );
  });

  test('non-UTC astronomical context input is rejected', () {
    expect(
      () => AstronomicalTimeContext.fromUtc(
        utcInstant: DateTime(2026, 8, 18),
        earthOrientationProvider: _FixedEopProvider(0.1),
      ),
      throwsArgumentError,
    );
  });
}
