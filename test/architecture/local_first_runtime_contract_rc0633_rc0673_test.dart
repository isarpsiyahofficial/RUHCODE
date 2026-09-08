import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/architecture/local_first_runtime_contract.dart';

void main() {
  test('Production default keeps every core capability on-device', () {
    final contract = LocalFirstRuntimeContract.productionDefault();
    expect(contract.capabilityLocations.length, CoreCapability.values.length);
    expect(contract.canRunCoreWithoutNetwork(), isTrue);
  });

  test('Missing core capability fails closed', () {
    expect(
      () => LocalFirstRuntimeContract(capabilityLocations: const {}),
      throwsArgumentError,
    );
  });

  test('Remote core capability fails closed', () {
    final locations = {
      for (final capability in CoreCapability.values) capability: RuntimeLocation.onDevice,
    };
    locations[CoreCapability.pdfExport] = RuntimeLocation.optionalRemote;
    expect(
      () => LocalFirstRuntimeContract(capabilityLocations: locations),
      throwsStateError,
    );
  });

  test('Server and paid external dependencies cannot become core requirements', () {
    final locations = {
      for (final capability in CoreCapability.values) capability: RuntimeLocation.onDevice,
    };
    for (final dependency in ExternalDependency.values) {
      expect(
        () => LocalFirstRuntimeContract(
          capabilityLocations: locations,
          requiredDependencies: {dependency},
        ),
        throwsStateError,
      );
    }
  });

  test('Core cost model rejects per-user server work', () {
    const CoreCostModel(requiresPerUserServerWork: false).validate();
    expect(
      () => const CoreCostModel(requiresPerUserServerWork: true).validate(),
      throwsStateError,
    );
  });

  test('Bundled interpretation catalog and optional AI are mandatory architecture boundaries', () {
    final locations = {
      for (final capability in CoreCapability.values) capability: RuntimeLocation.onDevice,
    };
    expect(
      () => LocalFirstRuntimeContract(
        capabilityLocations: locations,
        bundledInterpretationCatalog: false,
      ),
      throwsStateError,
    );
    expect(
      () => LocalFirstRuntimeContract(
        capabilityLocations: locations,
        aiIsOptional: false,
      ),
      throwsStateError,
    );
  });

  test('Daily interpretation is local calculation plus rules plus catalog without per-view AI', () {
    const DailyInterpretationRuntimePolicy(
      usesVerifiedCalculationObjects: true,
      usesLocalRuleEngine: true,
      usesBundledCatalog: true,
    ).validate();
    expect(
      () => const DailyInterpretationRuntimePolicy(
        usesVerifiedCalculationObjects: true,
        usesLocalRuleEngine: true,
        usesBundledCatalog: true,
        requiresAiRequestPerView: true,
      ).validate(),
      throwsStateError,
    );
  });
}
