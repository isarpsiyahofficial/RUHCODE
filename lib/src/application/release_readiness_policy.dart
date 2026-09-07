enum ReleaseGateState { pass, fail, blocked }

final class ReleaseGateEvidence {
  const ReleaseGateEvidence({
    required this.githubIsCanonicalRepository,
    required this.githubManagesDevelopmentTestRelease,
    required this.calculationCoreCi,
    required this.trEnKeyParity,
    required this.criticalAstronomyRegression,
    required this.akilesMigrationRegression,
    required this.referenceEngineComparison,
    required this.explainableCalculationDelta,
  });

  final bool githubIsCanonicalRepository;
  final bool githubManagesDevelopmentTestRelease;
  final ReleaseGateState calculationCoreCi;
  final ReleaseGateState trEnKeyParity;
  final ReleaseGateState criticalAstronomyRegression;
  final ReleaseGateState akilesMigrationRegression;
  final ReleaseGateState referenceEngineComparison;
  final ReleaseGateState explainableCalculationDelta;
}

final class ReleaseDecision {
  const ReleaseDecision({required this.allowed, required this.blockers});
  final bool allowed;
  final List<String> blockers;
}

abstract final class ReleaseReadinessPolicy {
  static ReleaseDecision evaluate(ReleaseGateEvidence evidence) {
    final blockers = <String>[];
    if (!evidence.githubIsCanonicalRepository) {
      blockers.add('GitHub is not configured as canonical repository');
    }
    if (!evidence.githubManagesDevelopmentTestRelease) {
      blockers.add('development/test/release is not governed through GitHub');
    }

    _requirePass(blockers, 'calculation core CI', evidence.calculationCoreCi);
    _requirePass(blockers, 'TR/EN key parity', evidence.trEnKeyParity);
    _requirePass(
      blockers,
      'critical astronomy regression',
      evidence.criticalAstronomyRegression,
    );
    _requirePass(
      blockers,
      'AKILES migration regression',
      evidence.akilesMigrationRegression,
    );
    _requirePass(
      blockers,
      'reference-engine comparison',
      evidence.referenceEngineComparison,
    );
    _requirePass(
      blockers,
      'explainable calculation delta',
      evidence.explainableCalculationDelta,
    );

    return ReleaseDecision(
      allowed: blockers.isEmpty,
      blockers: List.unmodifiable(blockers),
    );
  }

  static void _requirePass(
    List<String> blockers,
    String name,
    ReleaseGateState state,
  ) {
    switch (state) {
      case ReleaseGateState.pass:
        return;
      case ReleaseGateState.fail:
        blockers.add('$name failed');
      case ReleaseGateState.blocked:
        blockers.add('$name is blocked/missing evidence');
    }
  }
}
