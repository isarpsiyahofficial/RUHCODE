import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/entitlements/entitlement_scenario_matrix.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';

void main() {
  group('RC-1286..RC-1292 entitlement lifecycle matrix', () {
    test('every Feature ID is covered exactly once in every scenario', () {
      final rows = RuhEntitlementScenarioMatrix.build();
      expect(rows.length, RuhFeatureIds.all.length * EntitlementScenario.values.length);
      for (final featureId in RuhFeatureIds.all) {
        for (final scenario in EntitlementScenario.values) {
          expect(
            rows.where((row) => row.featureId == featureId && row.scenario == scenario).length,
            1,
            reason: '$featureId missing/duplicated for ${scenario.name}',
          );
        }
      }
    });

    test('Free scenario follows the canonical catalog and PRO covers every feature', () {
      final rows = RuhEntitlementScenarioMatrix.build();
      for (final featureId in RuhFeatureIds.all) {
        final policy = RuhFeatureCatalog.policyFor(featureId);
        final free = rows.single((row) => row.featureId == featureId && row.scenario == EntitlementScenario.free);
        final pro = rows.single((row) => row.featureId == featureId && row.scenario == EntitlementScenario.pro);
        expect(free.allowed, policy.baseAccess == FeatureBaseAccess.free);
        expect(pro.allowed, isTrue);
      }
    });

    test('rewarded temporary unlock never opens a non-rewardable PRO feature', () {
      final rows = RuhEntitlementScenarioMatrix.build();
      for (final featureId in RuhFeatureIds.all) {
        final policy = RuhFeatureCatalog.policyFor(featureId);
        final rewarded = rows.single((row) => row.featureId == featureId && row.scenario == EntitlementScenario.rewardedTemporary);
        expect(rewarded.allowed, policy.baseAccess == FeatureBaseAccess.free || policy.temporaryUnlockAllowed);
      }
    });

    test('offline PRO and all restore scenarios preserve full PRO capability', () {
      final rows = RuhEntitlementScenarioMatrix.build();
      for (final scenario in const [
        EntitlementScenario.offlinePro,
        EntitlementScenario.purchaseRestore,
        EntitlementScenario.reinstallRestore,
        EntitlementScenario.deviceChangeRestore,
      ]) {
        expect(rows.where((row) => row.scenario == scenario).every((row) => row.allowed), isTrue);
      }
      for (final scenario in const [
        EntitlementScenario.purchaseRestore,
        EntitlementScenario.reinstallRestore,
        EntitlementScenario.deviceChangeRestore,
      ]) {
        expect(rows.where((row) => row.scenario == scenario).every((row) => row.requiresStoreRestore), isTrue);
      }
    });
  });

  test('RC-1293..RC-1303 core use and device transfer stay server-account independent', () {
    const policy = OfflineFirstAccountPolicy();
    policy.validate();
    expect(policy.ruhCodeAccountRequired, isFalse);
    expect(policy.emailPasswordRequiredForCoreUse, isFalse);
    expect(policy.accountBackendRequired, isFalse);
    expect(policy.csvBackupSupportsDeviceTransfer, isTrue);
    expect(policy.oldDeviceCanExport, isTrue);
    expect(policy.newDeviceCanImport, isTrue);
    expect(policy.ruhCodeServerRequiredForTransfer, isFalse);
    expect(policy.userMayChooseExternalTransport, isTrue);
    expect(policy.ruhCodeManagesExternalCloudStorage, isFalse);
    expect(policy.automaticCloudBackupIsCoreRequirement, isFalse);
    expect(policy.primaryArchitectureIsOfflineFirst, isTrue);
  });
}
