import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_accuracy_contract.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  const contract = SpkStateAccuracyContract();
  const expected = SpkCartesianState(
    xKm: 100000000,
    yKm: -20000000,
    zKm: 3000000,
    vxKmPerSecond: 12,
    vyKmPerSecond: -24,
    vzKmPerSecond: 3,
  );

  test('accepts state inside explicit raw ephemeris tolerances', () {
    const actual = SpkCartesianState(
      xKm: 100000000.0005,
      yKm: -20000000.0009,
      zKm: 2999999.9992,
      vxKmPerSecond: 12.0000000005,
      vyKmPerSecond: -24.0000000008,
      vzKmPerSecond: 3.0000000002,
    );

    final result = contract.compare(actual: actual, expected: expected);
    expect(result.passed, isTrue);
    expect(result.maxPositionAxisErrorKm, lessThanOrEqualTo(0.001));
    expect(
      result.maxVelocityAxisErrorKmPerSecond,
      lessThanOrEqualTo(1e-9),
    );
    expect(
      () => contract.requireWithinTolerance(actual: actual, expected: expected),
      returnsNormally,
    );
  });

  test('fails closed when any position axis exceeds one metre', () {
    const actual = SpkCartesianState(
      xKm: 100000000.002,
      yKm: -20000000,
      zKm: 3000000,
      vxKmPerSecond: 12,
      vyKmPerSecond: -24,
      vzKmPerSecond: 3,
    );

    final result = contract.compare(actual: actual, expected: expected);
    expect(result.passed, isFalse);
    expect(
      () => contract.requireWithinTolerance(actual: actual, expected: expected),
      throwsStateError,
    );
  });

  test('fails closed when any velocity axis exceeds contract', () {
    const actual = SpkCartesianState(
      xKm: 100000000,
      yKm: -20000000,
      zKm: 3000000,
      vxKmPerSecond: 12.000000002,
      vyKmPerSecond: -24,
      vzKmPerSecond: 3,
    );

    final result = contract.compare(actual: actual, expected: expected);
    expect(result.passed, isFalse);
    expect(
      () => contract.requireWithinTolerance(actual: actual, expected: expected),
      throwsStateError,
    );
  });

  test('rejects non-finite evidence rather than comparing it', () {
    const badExpected = SpkCartesianState(
      xKm: double.nan,
      yKm: 0,
      zKm: 0,
      vxKmPerSecond: 0,
      vyKmPerSecond: 0,
      vzKmPerSecond: 0,
    );

    expect(
      () => contract.compare(actual: expected, expected: badExpected),
      throwsFormatException,
    );
  });
}
