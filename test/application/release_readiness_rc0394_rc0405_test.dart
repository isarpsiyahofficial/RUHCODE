import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/release_readiness_policy.dart';

void main() {
  ReleaseGateEvidence evidence({
    ReleaseGateState akiles = ReleaseGateState.pass,
    ReleaseGateState locale = ReleaseGateState.pass,
    ReleaseGateState calculation = ReleaseGateState.pass,
  }) => ReleaseGateEvidence(
        githubIsCanonicalRepository: true,
        githubManagesDevelopmentTestRelease: true,
        calculationCoreCi: calculation,
        trEnKeyParity: locale,
        criticalAstronomyRegression: ReleaseGateState.pass,
        akilesMigrationRegression: akiles,
        referenceEngineComparison: ReleaseGateState.pass,
        explainableCalculationDelta: ReleaseGateState.pass,
      );

  test('all release gates must pass', () {
    expect(ReleaseReadinessPolicy.evaluate(evidence()).allowed, isTrue);
  });

  test('broken calculation CI blocks release', () {
    final decision = ReleaseReadinessPolicy.evaluate(
      evidence(calculation: ReleaseGateState.fail),
    );
    expect(decision.allowed, isFalse);
    expect(decision.blockers, contains('calculation core CI failed'));
  });

  test('missing TR/EN parity evidence blocks release', () {
    final decision = ReleaseReadinessPolicy.evaluate(
      evidence(locale: ReleaseGateState.blocked),
    );
    expect(decision.allowed, isFalse);
  });

  test('AKILES migration cannot be waved through without evidence', () {
    final decision = ReleaseReadinessPolicy.evaluate(
      evidence(akiles: ReleaseGateState.blocked),
    );
    expect(decision.allowed, isFalse);
    expect(
      decision.blockers,
      contains('AKILES migration regression is blocked/missing evidence'),
    );
  });
}
