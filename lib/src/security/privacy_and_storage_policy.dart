enum PermissionKind { notifications, location, files }

enum PermissionDecision { notRequested, granted, denied, deniedPermanently }

enum AppLockMethod { none, pin, biometric }

enum SecureKeyOrigin { platformKeystore, userDerived }

enum TechnicalLogCode {
  storageOpenFailed,
  exportFailed,
  importFailed,
  calculationFailed,
  permissionDenied,
  authenticationFailed,
}

final class PermissionIsolationPolicy {
  const PermissionIsolationPolicy();

  bool coreUsageAllowed({
    required PermissionKind deniedPermission,
    required PermissionDecision decision,
  }) {
    return true;
  }

  bool notificationFeaturesAllowed(PermissionDecision decision) =>
      decision == PermissionDecision.granted;

  bool manualLocationAllowed(PermissionDecision decision) => true;
}

final class ExportPrivacyPolicy {
  const ExportPrivacyPolicy();

  bool canSendToThirdParty({
    required bool userExplicitlyInitiated,
    required bool localArtifactReady,
  }) =>
      userExplicitlyInitiated && localArtifactReady;

  bool get requiresRemoteUpload => false;
  bool get writesToArbitraryRootFolder => false;
}

final class EncryptionPolicy {
  const EncryptionPolicy({
    required this.databaseEncryptionEnabled,
    required this.keyOrigin,
  });

  final bool databaseEncryptionEnabled;
  final SecureKeyOrigin keyOrigin;

  void validate() {
    if (databaseEncryptionEnabled && keyOrigin != SecureKeyOrigin.platformKeystore && keyOrigin != SecureKeyOrigin.userDerived) {
      throw StateError('Encrypted local data requires a non-embedded key origin.');
    }
  }

  bool get fixedApplicationStringKeyAllowed => false;
  bool get serverRoundTripRequired => false;
}

final class AppLockPolicy {
  const AppLockPolicy({
    required this.method,
    required this.hasPinFallback,
  });

  final AppLockMethod method;
  final bool hasPinFallback;

  void validate() {
    if (method == AppLockMethod.biometric && !hasPinFallback) {
      throw StateError('Biometric app lock requires a secure PIN fallback.');
    }
  }

  bool exportAllowedAfterSuccessfulUnlock({required bool unlocked}) => unlocked;
}

final class PrivacySafeLogEvent {
  const PrivacySafeLogEvent({
    required this.code,
    required this.timestampUtc,
    this.component,
  });

  final TechnicalLogCode code;
  final DateTime timestampUtc;
  final String? component;

  Map<String, Object?> toMap() => <String, Object?>{
        'code': code.name,
        'timestampUtc': timestampUtc.toUtc().toIso8601String(),
        if (component != null) 'component': component,
      };
}

final class ProductionLogPolicy {
  const ProductionLogPolicy();

  Set<String> get prohibitedPersonalFields => const <String>{
        'customerName',
        'clientName',
        'fullBirthDate',
        'birthDate',
        'consultationNotes',
        'notes',
        'birthPlace',
      };

  void validatePayload(Map<String, Object?> payload) {
    for (final key in payload.keys) {
      if (prohibitedPersonalFields.contains(key)) {
        throw StateError('Personal data field is prohibited in production logs: $key');
      }
    }
  }

  bool get analyticsRequiredForCoreUsage => false;
  bool get telemetryRequiredForCoreUsage => false;
  bool get debugLogsAllowedInRelease => false;
}
