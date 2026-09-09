import 'feature_catalog.dart';

enum EntitlementScenario {
  free,
  pro,
  rewardedTemporary,
  offlinePro,
  purchaseRestore,
  reinstallRestore,
  deviceChangeRestore,
}

final class EntitlementScenarioExpectation {
  const EntitlementScenarioExpectation({
    required this.featureId,
    required this.scenario,
    required this.allowed,
    required this.requiresStoreRestore,
  });

  final String featureId;
  final EntitlementScenario scenario;
  final bool allowed;
  final bool requiresStoreRestore;
}

/// Binding RC-1286..RC-1292 matrix generator. Every canonical Feature ID is
/// exercised under every entitlement lifecycle scenario. It is intentionally
/// derived from the central feature catalog so UI-local premium flags cannot
/// silently escape coverage.
abstract final class RuhEntitlementScenarioMatrix {
  static List<EntitlementScenarioExpectation> build() {
    RuhFeatureCatalog.validate();
    final rows = <EntitlementScenarioExpectation>[];
    for (final featureId in RuhFeatureIds.all.toList()..sort()) {
      final policy = RuhFeatureCatalog.policyFor(featureId);
      for (final scenario in EntitlementScenario.values) {
        rows.add(
          EntitlementScenarioExpectation(
            featureId: featureId,
            scenario: scenario,
            allowed: _allowed(policy, scenario),
            requiresStoreRestore: scenario == EntitlementScenario.purchaseRestore ||
                scenario == EntitlementScenario.reinstallRestore ||
                scenario == EntitlementScenario.deviceChangeRestore,
          ),
        );
      }
    }
    validate(rows);
    return List.unmodifiable(rows);
  }

  static bool _allowed(FeaturePolicy policy, EntitlementScenario scenario) {
    final free = policy.baseAccess == FeatureBaseAccess.free;
    return switch (scenario) {
      EntitlementScenario.free => free,
      EntitlementScenario.pro => true,
      EntitlementScenario.rewardedTemporary => free || policy.temporaryUnlockAllowed,
      EntitlementScenario.offlinePro => true,
      EntitlementScenario.purchaseRestore => true,
      EntitlementScenario.reinstallRestore => true,
      EntitlementScenario.deviceChangeRestore => true,
    };
  }

  static void validate(Iterable<EntitlementScenarioExpectation> rows) {
    final list = rows.toList(growable: false);
    final expected = RuhFeatureIds.all.length * EntitlementScenario.values.length;
    if (list.length != expected) {
      throw StateError('Entitlement matrix must contain exactly $expected rows.');
    }
    for (final featureId in RuhFeatureIds.all) {
      for (final scenario in EntitlementScenario.values) {
        final count = list.where((row) => row.featureId == featureId && row.scenario == scenario).length;
        if (count != 1) {
          throw StateError('Feature $featureId must have exactly one ${scenario.name} row.');
        }
      }
    }
  }
}

/// RC-1293..RC-1303: core usage and portable transfer stay account-backend
/// independent. External storage is user-selected transport, not Ruh Code cloud.
final class OfflineFirstAccountPolicy {
  const OfflineFirstAccountPolicy();

  bool get ruhCodeAccountRequired => false;
  bool get emailPasswordRequiredForCoreUse => false;
  bool get accountBackendRequired => false;
  bool get csvBackupSupportsDeviceTransfer => true;
  bool get oldDeviceCanExport => true;
  bool get newDeviceCanImport => true;
  bool get ruhCodeServerRequiredForTransfer => false;
  bool get userMayChooseExternalTransport => true;
  bool get ruhCodeManagesExternalCloudStorage => false;
  bool get automaticCloudBackupIsCoreRequirement => false;
  bool get primaryArchitectureIsOfflineFirst => true;

  void validate() {
    if (ruhCodeAccountRequired || emailPasswordRequiredForCoreUse || accountBackendRequired || ruhCodeServerRequiredForTransfer) {
      throw StateError('Core Ruh Code usage/transfer must remain server-account independent.');
    }
    if (!csvBackupSupportsDeviceTransfer || !oldDeviceCanExport || !newDeviceCanImport || !userMayChooseExternalTransport || !primaryArchitectureIsOfflineFirst) {
      throw StateError('Portable offline-first transfer guarantees are incomplete.');
    }
    if (ruhCodeManagesExternalCloudStorage || automaticCloudBackupIsCoreRequirement) {
      throw StateError('External cloud transport must not become a core Ruh Code dependency.');
    }
  }
}
