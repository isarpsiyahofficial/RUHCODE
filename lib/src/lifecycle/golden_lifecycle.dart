enum GoldenModule {
  westernNatal,
  vedic,
  numerology,
  bazi,
  planetaryHours,
  professionalClient,
  backup,
  pdf,
}

enum ModuleCompletionGate {
  calculation,
  ui,
  interpretation,
  turkish,
  english,
  export,
  pdf,
  cache,
  tests,
}

final class ModuleCompletionEvidence {
  ModuleCompletionEvidence({
    required this.module,
    required Map<ModuleCompletionGate, bool> gates,
  }) : gates = Map.unmodifiable(gates);

  final GoldenModule module;
  final Map<ModuleCompletionGate, bool> gates;

  bool get isComplete =>
      ModuleCompletionGate.values.every((gate) => gates[gate] == true);

  Set<ModuleCompletionGate> get missingGates => ModuleCompletionGate.values
      .where((gate) => gates[gate] != true)
      .toSet();
}

final class ModuleCompletionChecklist {
  ModuleCompletionChecklist(Iterable<ModuleCompletionEvidence> evidence)
      : evidence = List.unmodifiable(evidence) {
    _validateUniqueModules();
  }

  final List<ModuleCompletionEvidence> evidence;

  void validateForRelease() {
    final byModule = {for (final item in evidence) item.module: item};
    final missing = GoldenModule.values
        .where((module) => !byModule.containsKey(module))
        .toList();
    if (missing.isNotEmpty) {
      throw StateError('Missing module completion evidence: $missing');
    }
    final incomplete = evidence.where((item) => !item.isComplete).toList();
    if (incomplete.isNotEmpty) {
      final detail = incomplete
          .map((item) => '${item.module.name}:${item.missingGates.map((e) => e.name).join(',')}')
          .join(';');
      throw StateError('Incomplete module completion evidence: $detail');
    }
  }

  void _validateUniqueModules() {
    final seen = <GoldenModule>{};
    for (final item in evidence) {
      if (!seen.add(item.module)) {
        throw StateError('Duplicate module completion evidence: ${item.module.name}');
      }
    }
  }
}

enum GoldenLocale { tr, en }
enum GoldenEntitlement { free, pro }
enum GoldenConnectivity { offline, online }
enum GoldenInstallState { cleanInstall, upgrade }

enum GoldenLifecycleStage {
  createClient,
  calculateNatal,
  calculateVedic,
  calculateNumerology,
  addNote,
  createConsultation,
  exportPdf,
  exportCsvBackup,
  clearApplicationData,
  restoreBackup,
  reopenSameClient,
  verifyBirthData,
  verifyCalculationResults,
  verifyNotes,
  verifyProfessionalSettings,
  exportPdfAfterRestore,
  verifyRestoreParity,
}

final class GoldenLifecycleScenario {
  const GoldenLifecycleScenario({
    required this.locale,
    required this.entitlement,
    required this.connectivity,
    required this.installState,
  });

  final GoldenLocale locale;
  final GoldenEntitlement entitlement;
  final GoldenConnectivity connectivity;
  final GoldenInstallState installState;

  String get key =>
      '${locale.name}|${entitlement.name}|${connectivity.name}|${installState.name}';
}

final class GoldenLifecycleSnapshot {
  const GoldenLifecycleSnapshot({
    required this.clientId,
    required this.birthDataDigest,
    required this.calculationDigest,
    required this.notesDigest,
    required this.professionalSettingsDigest,
    required this.pdfSemanticDigest,
  });

  final String clientId;
  final String birthDataDigest;
  final String calculationDigest;
  final String notesDigest;
  final String professionalSettingsDigest;
  final String pdfSemanticDigest;

  void validateNonEmpty() {
    final values = <String>[
      clientId,
      birthDataDigest,
      calculationDigest,
      notesDigest,
      professionalSettingsDigest,
      pdfSemanticDigest,
    ];
    if (values.any((value) => value.trim().isEmpty)) {
      throw StateError('Golden lifecycle snapshots require stable non-empty identities/digests.');
    }
  }
}

final class GoldenLifecycleExecution {
  GoldenLifecycleExecution({
    required this.scenario,
    required Iterable<GoldenLifecycleStage> completedStages,
    required this.beforeRestore,
    required this.afterRestore,
    required this.releaseBuild,
    required this.criticalTestsPassed,
    this.hasSkippedCriticalTests = false,
  }) : completedStages = List.unmodifiable(completedStages);

  final GoldenLifecycleScenario scenario;
  final List<GoldenLifecycleStage> completedStages;
  final GoldenLifecycleSnapshot beforeRestore;
  final GoldenLifecycleSnapshot afterRestore;
  final bool releaseBuild;
  final bool criticalTestsPassed;
  final bool hasSkippedCriticalTests;

  void validate() {
    beforeRestore.validateNonEmpty();
    afterRestore.validateNonEmpty();
    if (!releaseBuild) {
      throw StateError('Golden Lifecycle must execute against a release build.');
    }
    if (!criticalTestsPassed) {
      throw StateError('Critical lifecycle tests are red.');
    }
    if (hasSkippedCriticalTests) {
      throw StateError('Critical lifecycle tests may not be skipped.');
    }
    if (completedStages.length != GoldenLifecycleStage.values.length) {
      throw StateError('Golden Lifecycle contains missing or duplicate stages.');
    }
    for (var i = 0; i < GoldenLifecycleStage.values.length; i++) {
      if (completedStages[i] != GoldenLifecycleStage.values[i]) {
        throw StateError(
          'Golden Lifecycle stage ${GoldenLifecycleStage.values[i].name} must execute at index $i.',
        );
      }
    }
    _requireEqual('clientId', beforeRestore.clientId, afterRestore.clientId);
    _requireEqual(
      'birthData',
      beforeRestore.birthDataDigest,
      afterRestore.birthDataDigest,
    );
    _requireEqual(
      'calculationResults',
      beforeRestore.calculationDigest,
      afterRestore.calculationDigest,
    );
    _requireEqual('notes', beforeRestore.notesDigest, afterRestore.notesDigest);
    _requireEqual(
      'professionalSettings',
      beforeRestore.professionalSettingsDigest,
      afterRestore.professionalSettingsDigest,
    );
    _requireEqual(
      'pdfSemanticResult',
      beforeRestore.pdfSemanticDigest,
      afterRestore.pdfSemanticDigest,
    );
  }

  static void _requireEqual(String label, String before, String after) {
    if (before != after) {
      throw StateError('Golden Lifecycle restore parity failed for $label.');
    }
  }
}

final class GoldenLifecycleMatrix {
  const GoldenLifecycleMatrix();

  List<GoldenLifecycleScenario> buildRequiredScenarios() {
    return [
      for (final locale in GoldenLocale.values)
        for (final entitlement in GoldenEntitlement.values)
          for (final connectivity in GoldenConnectivity.values)
            for (final installState in GoldenInstallState.values)
              GoldenLifecycleScenario(
                locale: locale,
                entitlement: entitlement,
                connectivity: connectivity,
                installState: installState,
              ),
    ];
  }

  void validateExecutions(Iterable<GoldenLifecycleExecution> executions) {
    final required = {for (final scenario in buildRequiredScenarios()) scenario.key};
    final actual = <String>{};
    for (final execution in executions) {
      if (!actual.add(execution.scenario.key)) {
        throw StateError('Duplicate Golden Lifecycle scenario: ${execution.scenario.key}');
      }
      execution.validate();
    }
    final missing = required.difference(actual);
    final extra = actual.difference(required);
    if (missing.isNotEmpty || extra.isNotEmpty) {
      throw StateError('Golden Lifecycle scenario coverage mismatch; missing=$missing extra=$extra');
    }
  }
}
