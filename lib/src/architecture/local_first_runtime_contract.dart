enum CoreCapability {
  westernAstrology,
  vedicAstrology,
  numerology,
  bazi,
  planetaryHours,
  dailyAstrology,
  dailyNumerology,
  userProfiles,
  professionalClients,
  consultationNotes,
  personalGrowthRecords,
  tarotSessionRecords,
  favorites,
  notificationPlanning,
  pdfExport,
  csvExport,
  csvImport,
}

enum RuntimeLocation { onDevice, optionalRemote }

enum ExternalDependency {
  ownedApi,
  vps,
  databaseServer,
  firebase,
  supabase,
  aws,
  cloudflareDatabase,
  paidAstrologyApi,
  paidNumerologyApi,
  paidTimezoneApi,
  paidCitySearchApi,
  paidPdfApi,
  paidAiApi,
}

final class LocalFirstRuntimeContract {
  LocalFirstRuntimeContract({
    required Map<CoreCapability, RuntimeLocation> capabilityLocations,
    Set<ExternalDependency> requiredDependencies = const {},
    this.bundledInterpretationCatalog = true,
    this.aiIsOptional = true,
  })  : capabilityLocations = Map.unmodifiable(capabilityLocations),
        requiredDependencies = Set.unmodifiable(requiredDependencies) {
    final missing = CoreCapability.values.where((c) => !this.capabilityLocations.containsKey(c));
    if (missing.isNotEmpty) {
      throw ArgumentError('Every core capability needs an explicit runtime location: ${missing.join(', ')}');
    }
    final remoteCore = this.capabilityLocations.entries.where((e) => e.value != RuntimeLocation.onDevice);
    if (remoteCore.isNotEmpty) {
      throw StateError('Core capabilities must remain on-device: ${remoteCore.map((e) => e.key).join(', ')}');
    }
    if (this.requiredDependencies.isNotEmpty) {
      throw StateError('Core product cannot require server or paid external dependencies');
    }
    if (!bundledInterpretationCatalog) {
      throw StateError('Core interpretation catalog must ship with the application');
    }
    if (!aiIsOptional) {
      throw StateError('AI cannot be a mandatory core dependency');
    }
  }

  final Map<CoreCapability, RuntimeLocation> capabilityLocations;
  final Set<ExternalDependency> requiredDependencies;
  final bool bundledInterpretationCatalog;
  final bool aiIsOptional;

  factory LocalFirstRuntimeContract.productionDefault() => LocalFirstRuntimeContract(
        capabilityLocations: {
          for (final capability in CoreCapability.values) capability: RuntimeLocation.onDevice,
        },
      );

  bool canRunCoreWithoutNetwork() =>
      capabilityLocations.values.every((location) => location == RuntimeLocation.onDevice) &&
      requiredDependencies.isEmpty &&
      bundledInterpretationCatalog;
}

final class CoreCostModel {
  const CoreCostModel({required this.requiresPerUserServerWork});
  final bool requiresPerUserServerWork;

  void validate() {
    if (requiresPerUserServerWork) {
      throw StateError('Core architecture must not create per-user server work/cost');
    }
  }
}

final class DailyInterpretationRuntimePolicy {
  const DailyInterpretationRuntimePolicy({
    required this.usesVerifiedCalculationObjects,
    required this.usesLocalRuleEngine,
    required this.usesBundledCatalog,
    this.requiresNetworkDownloadPerView = false,
    this.requiresAiRequestPerView = false,
  });

  final bool usesVerifiedCalculationObjects;
  final bool usesLocalRuleEngine;
  final bool usesBundledCatalog;
  final bool requiresNetworkDownloadPerView;
  final bool requiresAiRequestPerView;

  void validate() {
    if (!usesVerifiedCalculationObjects || !usesLocalRuleEngine || !usesBundledCatalog) {
      throw StateError('Daily interpretation must be calculation + rule engine + bundled catalog');
    }
    if (requiresNetworkDownloadPerView || requiresAiRequestPerView) {
      throw StateError('Daily interpretation cannot require per-view network/AI work');
    }
  }
}
