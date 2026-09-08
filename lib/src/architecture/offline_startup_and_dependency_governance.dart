enum StartupTaskKind {
  localDatabase,
  localSettings,
  bundledCityTimezoneCatalog,
  cachedEntitlements,
  monetizationNetwork,
  optionalExternalOperation,
}

final class StartupTask {
  const StartupTask({
    required this.kind,
    required this.requiredBeforeLocalReady,
    required this.requiresNetwork,
  });

  final StartupTaskKind kind;
  final bool requiredBeforeLocalReady;
  final bool requiresNetwork;
}

/// The application may schedule optional network work, but local readiness may
/// never wait on network availability.
final class OfflineStartupPlan {
  OfflineStartupPlan(Iterable<StartupTask> tasks)
      : tasks = List<StartupTask>.unmodifiable(tasks) {
    final blockingNetwork = this.tasks.where(
          (task) => task.requiredBeforeLocalReady && task.requiresNetwork,
        );
    if (blockingNetwork.isNotEmpty) {
      throw StateError(
        'Local startup cannot require network tasks: '
        '${blockingNetwork.map((e) => e.kind.name).join(', ')}',
      );
    }
  }

  final List<StartupTask> tasks;

  factory OfflineStartupPlan.productionDefault() => OfflineStartupPlan(const [
        StartupTask(
          kind: StartupTaskKind.localDatabase,
          requiredBeforeLocalReady: true,
          requiresNetwork: false,
        ),
        StartupTask(
          kind: StartupTaskKind.localSettings,
          requiredBeforeLocalReady: true,
          requiresNetwork: false,
        ),
        StartupTask(
          kind: StartupTaskKind.bundledCityTimezoneCatalog,
          requiredBeforeLocalReady: false,
          requiresNetwork: false,
        ),
        StartupTask(
          kind: StartupTaskKind.cachedEntitlements,
          requiredBeforeLocalReady: false,
          requiresNetwork: false,
        ),
        StartupTask(
          kind: StartupTaskKind.monetizationNetwork,
          requiredBeforeLocalReady: false,
          requiresNetwork: true,
        ),
        StartupTask(
          kind: StartupTaskKind.optionalExternalOperation,
          requiredBeforeLocalReady: false,
          requiresNetwork: true,
        ),
      ]);

  bool get canBecomeLocallyReadyOffline => tasks
      .where((task) => task.requiredBeforeLocalReady)
      .every((task) => !task.requiresNetwork);
}

enum ReferenceUse { developmentQaOnly, runtime }

final class RuntimeReferenceApproval {
  const RuntimeReferenceApproval({
    required this.id,
    required this.use,
    required this.redistributionApproved,
  });

  final String id;
  final ReferenceUse use;
  final bool redistributionApproved;

  void validateRuntimeUse() {
    if (use == ReferenceUse.runtime && !redistributionApproved) {
      throw StateError(
        'Runtime dependency requires explicit redistribution approval: $id',
      );
    }
  }
}

/// A QA comparison source never becomes a runtime dependency merely because it
/// was useful for verification.
final class VerificationReferencePolicy {
  const VerificationReferencePolicy();

  void requireRuntimeApproval(RuntimeReferenceApproval approval) {
    approval.validateRuntimeUse();
  }
}

/// Dependency updates cannot enter release merely because resolution succeeds.
/// They must prove the critical calculation, PDF and backup contracts again.
final class DependencyChangeGate {
  const DependencyChangeGate({
    required this.ciPassed,
    required this.calculationRegressionPassed,
    required this.pdfRegressionPassed,
    required this.backupRoundTripPassed,
    required this.lockfilePresent,
  });

  final bool ciPassed;
  final bool calculationRegressionPassed;
  final bool pdfRegressionPassed;
  final bool backupRoundTripPassed;
  final bool lockfilePresent;

  bool get mayPromoteToRelease =>
      ciPassed &&
      calculationRegressionPassed &&
      pdfRegressionPassed &&
      backupRoundTripPassed &&
      lockfilePresent;

  void requireReleaseReady() {
    if (!mayPromoteToRelease) {
      throw StateError(
        'Dependency change is not release-ready until CI, calculation, PDF, '
        'backup round-trip and lockfile gates are all green.',
      );
    }
  }
}
