enum OfflineCoreCapability {
  westernChart,
  vedic,
  numerology,
  bazi,
  planetaryHours,
  records,
  pdfExport,
  csvExport,
  csvRestore,
  professionalClientManagement,
}

enum InternetOptionalCapability {
  advertising,
  storeVerification,
  explicitExternalShare,
}

final class OfflineCoreContract {
  const OfflineCoreContract._();

  static const Set<OfflineCoreCapability> requiredInAirplaneMode = {
    OfflineCoreCapability.westernChart,
    OfflineCoreCapability.vedic,
    OfflineCoreCapability.numerology,
    OfflineCoreCapability.bazi,
    OfflineCoreCapability.planetaryHours,
    OfflineCoreCapability.records,
    OfflineCoreCapability.pdfExport,
    OfflineCoreCapability.csvExport,
    OfflineCoreCapability.csvRestore,
    OfflineCoreCapability.professionalClientManagement,
  };

  static const Set<InternetOptionalCapability> permittedInternetOnly = {
    InternetOptionalCapability.advertising,
    InternetOptionalCapability.storeVerification,
    InternetOptionalCapability.explicitExternalShare,
  };

  static void validate() {
    if (requiredInAirplaneMode.length != OfflineCoreCapability.values.length ||
        !requiredInAirplaneMode.containsAll(OfflineCoreCapability.values)) {
      throw StateError('Every core capability must remain available in airplane mode.');
    }
    if (permittedInternetOnly.length != InternetOptionalCapability.values.length ||
        !permittedInternetOnly.containsAll(InternetOptionalCapability.values)) {
      throw StateError('Internet-only exceptions must be explicit and exhaustive.');
    }
  }
}

final class AirplaneModeEvidence {
  AirplaneModeEvidence({
    required this.airplaneModeEnabled,
    required this.releaseArtifact,
    required Iterable<OfflineCoreCapability> exercisedCapabilities,
    required this.coreCompletedEndToEnd,
  }) : exercisedCapabilities = Set.unmodifiable(exercisedCapabilities);

  final bool airplaneModeEnabled;
  final bool releaseArtifact;
  final Set<OfflineCoreCapability> exercisedCapabilities;
  final bool coreCompletedEndToEnd;

  void validateForRelease() {
    OfflineCoreContract.validate();
    if (!airplaneModeEnabled) {
      throw StateError('Physical airplane-mode evidence is required.');
    }
    if (!releaseArtifact) {
      throw StateError('Airplane-mode lifecycle must use a release artifact.');
    }
    final missing = OfflineCoreContract.requiredInAirplaneMode
        .difference(exercisedCapabilities);
    if (missing.isNotEmpty) {
      throw StateError('Airplane-mode evidence misses core capabilities: $missing');
    }
    if (!coreCompletedEndToEnd) {
      throw StateError('Offline core lifecycle did not complete end to end.');
    }
  }
}
