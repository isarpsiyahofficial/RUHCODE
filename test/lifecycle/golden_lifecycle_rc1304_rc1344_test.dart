import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/lifecycle/golden_lifecycle.dart';

void main() {
  ModuleCompletionEvidence completeEvidence(GoldenModule module) {
    return ModuleCompletionEvidence(
      module: module,
      gates: {
        for (final gate in ModuleCompletionGate.values) gate: true,
      },
    );
  }

  GoldenLifecycleSnapshot snapshot(String suffix) {
    return GoldenLifecycleSnapshot(
      clientId: 'client-001',
      birthDataDigest: 'birth-$suffix',
      calculationDigest: 'calc-$suffix',
      notesDigest: 'notes-$suffix',
      professionalSettingsDigest: 'settings-$suffix',
      pdfSemanticDigest: 'pdf-$suffix',
    );
  }

  GoldenLifecycleExecution passingExecution(GoldenLifecycleScenario scenario) {
    const stable = GoldenLifecycleSnapshot(
      clientId: 'client-001',
      birthDataDigest: 'birth-v1',
      calculationDigest: 'calc-v1',
      notesDigest: 'notes-v1',
      professionalSettingsDigest: 'settings-v1',
      pdfSemanticDigest: 'pdf-v1',
    );
    return GoldenLifecycleExecution(
      scenario: scenario,
      completedStages: GoldenLifecycleStage.values,
      beforeRestore: stable,
      afterRestore: stable,
      releaseBuild: true,
      criticalTestsPassed: true,
    );
  }

  test('RC-1304..1315 requires every module and every completion gate', () {
    final checklist = ModuleCompletionChecklist(
      GoldenModule.values.map(completeEvidence),
    );
    expect(checklist.validateForRelease, returnsNormally);

    final broken = ModuleCompletionChecklist([
      for (final module in GoldenModule.values)
        if (module != GoldenModule.vedic) completeEvidence(module),
    ]);
    expect(broken.validateForRelease, throwsStateError);

    final incomplete = ModuleCompletionChecklist([
      for (final module in GoldenModule.values)
        if (module == GoldenModule.westernNatal)
          ModuleCompletionEvidence(
            module: module,
            gates: {
              for (final gate in ModuleCompletionGate.values)
                gate: gate != ModuleCompletionGate.tests,
            },
          )
        else
          completeEvidence(module),
    ]);
    expect(incomplete.validateForRelease, throwsStateError);
  });

  test('RC-1316..1334 enforces ordered real release lifecycle and restore parity', () {
    const scenario = GoldenLifecycleScenario(
      locale: GoldenLocale.tr,
      entitlement: GoldenEntitlement.pro,
      connectivity: GoldenConnectivity.offline,
      installState: GoldenInstallState.cleanInstall,
    );
    expect(passingExecution(scenario).validate, returnsNormally);

    final wrongOrder = GoldenLifecycleStage.values.toList()
      ..[0] = GoldenLifecycleStage.calculateNatal
      ..[1] = GoldenLifecycleStage.createClient;
    final outOfOrder = GoldenLifecycleExecution(
      scenario: scenario,
      completedStages: wrongOrder,
      beforeRestore: snapshot('same'),
      afterRestore: snapshot('same'),
      releaseBuild: true,
      criticalTestsPassed: true,
    );
    expect(outOfOrder.validate, throwsStateError);

    final mismatch = GoldenLifecycleExecution(
      scenario: scenario,
      completedStages: GoldenLifecycleStage.values,
      beforeRestore: snapshot('before'),
      afterRestore: snapshot('after'),
      releaseBuild: true,
      criticalTestsPassed: true,
    );
    expect(mismatch.validate, throwsStateError);
  });

  test('RC-1335..1342 covers TR/EN x Free/PRO x offline/online x clean/upgrade', () {
    const matrix = GoldenLifecycleMatrix();
    final scenarios = matrix.buildRequiredScenarios();
    expect(scenarios, hasLength(16));
    expect(scenarios.map((e) => e.key).toSet(), hasLength(16));
    expect(
      () => matrix.validateExecutions(scenarios.map(passingExecution)),
      returnsNormally,
    );

    expect(
      () => matrix.validateExecutions(scenarios.skip(1).map(passingExecution)),
      throwsStateError,
    );
  });

  test('RC-1343..1344 rejects debug builds, red critical tests and skipped critical tests', () {
    const scenario = GoldenLifecycleScenario(
      locale: GoldenLocale.en,
      entitlement: GoldenEntitlement.pro,
      connectivity: GoldenConnectivity.online,
      installState: GoldenInstallState.upgrade,
    );
    const stable = GoldenLifecycleSnapshot(
      clientId: 'client-001',
      birthDataDigest: 'birth-v1',
      calculationDigest: 'calc-v1',
      notesDigest: 'notes-v1',
      professionalSettingsDigest: 'settings-v1',
      pdfSemanticDigest: 'pdf-v1',
    );

    GoldenLifecycleExecution execution({
      bool releaseBuild = true,
      bool criticalTestsPassed = true,
      bool skipped = false,
    }) => GoldenLifecycleExecution(
      scenario: scenario,
      completedStages: GoldenLifecycleStage.values,
      beforeRestore: stable,
      afterRestore: stable,
      releaseBuild: releaseBuild,
      criticalTestsPassed: criticalTestsPassed,
      hasSkippedCriticalTests: skipped,
    );

    expect(() => execution(releaseBuild: false).validate(), throwsStateError);
    expect(() => execution(criticalTestsPassed: false).validate(), throwsStateError);
    expect(() => execution(skipped: true).validate(), throwsStateError);
  });
}
