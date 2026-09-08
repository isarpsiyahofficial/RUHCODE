import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/architecture/offline_startup_and_dependency_governance.dart';

void main() {
  test('production startup can become locally ready without network', () {
    final plan = OfflineStartupPlan.productionDefault();
    expect(plan.canBecomeLocallyReadyOffline, isTrue);
    expect(
      plan.tasks.where((task) => task.requiresNetwork),
      everyElement(predicate<StartupTask>((task) => !task.requiredBeforeLocalReady)),
    );
  });

  test('network dependency before local-ready fails closed', () {
    expect(
      () => OfflineStartupPlan(const [
        StartupTask(
          kind: StartupTaskKind.monetizationNetwork,
          requiredBeforeLocalReady: true,
          requiresNetwork: true,
        ),
      ]),
      throwsStateError,
    );
  });

  test('QA reference cannot become runtime dependency without redistribution approval', () {
    const policy = VerificationReferencePolicy();
    const akilesRuntime = RuntimeReferenceApproval(
      id: 'AKILES',
      use: ReferenceUse.runtime,
      redistributionApproved: false,
    );
    const swissRuntime = RuntimeReferenceApproval(
      id: 'Swiss Ephemeris',
      use: ReferenceUse.runtime,
      redistributionApproved: false,
    );
    expect(() => policy.requireRuntimeApproval(akilesRuntime), throwsStateError);
    expect(() => policy.requireRuntimeApproval(swissRuntime), throwsStateError);
  });

  test('development QA reference stays legal-policy separate from runtime approval', () {
    const policy = VerificationReferencePolicy();
    const reference = RuntimeReferenceApproval(
      id: 'comparison-source',
      use: ReferenceUse.developmentQaOnly,
      redistributionApproved: false,
    );
    expect(() => policy.requireRuntimeApproval(reference), returnsNormally);
  });

  test('dependency update cannot reach release without every regression and lockfile gate', () {
    const blocked = DependencyChangeGate(
      ciPassed: true,
      calculationRegressionPassed: true,
      pdfRegressionPassed: true,
      backupRoundTripPassed: false,
      lockfilePresent: true,
    );
    expect(blocked.mayPromoteToRelease, isFalse);
    expect(blocked.requireReleaseReady, throwsStateError);

    const missingLock = DependencyChangeGate(
      ciPassed: true,
      calculationRegressionPassed: true,
      pdfRegressionPassed: true,
      backupRoundTripPassed: true,
      lockfilePresent: false,
    );
    expect(missingLock.mayPromoteToRelease, isFalse);

    const green = DependencyChangeGate(
      ciPassed: true,
      calculationRegressionPassed: true,
      pdfRegressionPassed: true,
      backupRoundTripPassed: true,
      lockfilePresent: true,
    );
    expect(green.mayPromoteToRelease, isTrue);
    expect(green.requireReleaseReady, returnsNormally);
  });
}
