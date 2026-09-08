import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/calculation_validity.dart';
import 'package:ruh_code/src/calculation_core/golden/golden_dataset_policy.dart';

void main() {
  test('unknown birth time never fabricates ascendant or houses', () {
    const policy = MissingBirthTimePolicy();
    for (final feature in <CalculationFeature>[
      CalculationFeature.ascendant,
      CalculationFeature.houses,
      CalculationFeature.vedicHourSensitive,
    ]) {
      final result = policy.availabilityFor(
        feature: feature,
        birthTimeKnown: false,
        determinismKey: 'engine1|algo1|input|config',
      );
      expect(result.validity, CalculationValidity.unavailable);
      expect(result.value, isNull);
      expect(result.localizedMessage('tr'), isNotEmpty);
      expect(result.localizedMessage('en'), isNotEmpty);
    }
  });

  test('missing birth time still exposes only calculations that remain possible', () {
    const policy = MissingBirthTimePolicy();
    final result = policy.availabilityFor(
      feature: CalculationFeature.numerology,
      birthTimeKnown: false,
      determinismKey: 'engine1|algo1|input|config',
    );
    expect(result.validity, CalculationValidity.partial);
    expect(result.value, isTrue);
  });

  test('polar day/night never fabricates planetary hours', () {
    const policy = PlanetaryHourAvailabilityPolicy();
    final result = policy.evaluate(
      observation: const SolarBoundaryObservation(
        sunriseUtc: null,
        sunsetUtc: null,
        reasonCode: 'polar_day_or_night',
      ),
      determinismKey: 'engine1|algo1|polar|config',
    );
    expect(result.validity, CalculationValidity.unavailable);
    expect(result.value, isNull);
    expect(result.localizedMessage('tr'), contains('hesaplanamıyor'));
  });

  test('same determinism key cannot silently produce a different outcome', () {
    const guard = DeterminismGuard();
    final first = CalculationOutcome.valid(
      value: 12.5,
      determinismKey: 'v1|a1|same|same',
    );
    final second = CalculationOutcome.valid(
      value: 13.5,
      determinismKey: 'v1|a1|same|same',
    );
    expect(() => guard.requireSameOutcome(first, second), throwsStateError);
  });

  test('golden release policy requires independent domains and edge coverage', () {
    const policy = GoldenDatasetPolicy();
    expect(() => policy.validateReleaseCorpus(const []), throwsStateError);
  });

  test('AKILES golden cannot be authoritative without AKILES provenance', () {
    const policy = GoldenDatasetPolicy();
    const value = GoldenCaseDescriptor(
      id: 'akiles-1',
      domain: GoldenDomain.akilesRegression,
      inputFingerprint: 'input',
      expectedFingerprint: 'expected',
      sourceId: 'unknown-source',
      sourceVersion: 'v1',
      edgeCases: <GoldenEdgeCase>{GoldenEdgeCase.signBoundary},
      authoritative: true,
    );
    expect(() => policy.validateAuthoritativeCase(value), throwsStateError);
  });
}
