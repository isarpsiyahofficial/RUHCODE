enum RuntimeCapability {
  westernCalculation,
  vedicCalculation,
  chineseCalculation,
  baziCalculation,
  numerologyCalculation,
  planetaryHoursCalculation,
  profileReadWrite,
  pdfGeneration,
  backupExport,
  premiumVerification,
  cloudSync,
}

enum RuntimeDependency { localOnly, remoteRequired }

final class RuntimeCapabilityDefinition {
  const RuntimeCapabilityDefinition({
    required this.capability,
    required this.dependency,
    required this.reason,
  });

  final RuntimeCapability capability;
  final RuntimeDependency dependency;
  final String reason;
}

/// Explicit offline/online boundary for RC-0366..RC-0371.
///
/// Core calculations, profile access and PDF generation must not acquire a
/// network dependency through convenience APIs. Remote-only concerns are kept
/// behind separate capabilities.
abstract final class RuntimeCapabilityPolicy {
  static const definitions = <RuntimeCapabilityDefinition>[
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.westernCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'deterministic on-device calculation',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.vedicCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'deterministic on-device calculation',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.chineseCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'calendar/rule calculation remains local',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.baziCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'calendar/rule calculation remains local',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.numerologyCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'deterministic local calculation',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.planetaryHoursCalculation,
      dependency: RuntimeDependency.localOnly,
      reason: 'sunrise/sunset inputs and calculation remain local',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.profileReadWrite,
      dependency: RuntimeDependency.localOnly,
      reason: 'local encrypted profile store is primary',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.pdfGeneration,
      dependency: RuntimeDependency.localOnly,
      reason: 'reports render from stored calculation artifacts',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.backupExport,
      dependency: RuntimeDependency.localOnly,
      reason: 'user-controlled local export',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.premiumVerification,
      dependency: RuntimeDependency.remoteRequired,
      reason: 'server/store-backed entitlement authenticity check',
    ),
    RuntimeCapabilityDefinition(
      capability: RuntimeCapability.cloudSync,
      dependency: RuntimeDependency.remoteRequired,
      reason: 'explicit optional remote synchronization',
    ),
  ];

  static RuntimeCapabilityDefinition definitionFor(RuntimeCapability capability) =>
      definitions.singleWhere((item) => item.capability == capability);

  static bool worksOffline(RuntimeCapability capability) =>
      definitionFor(capability).dependency == RuntimeDependency.localOnly;

  static Set<RuntimeCapability> get launchNetworkAllowList => const {};
}

/// A premium decision must come from a verifier; callers cannot construct an
/// authoritative entitlement from a local mutable boolean.
abstract interface class PremiumEntitlementVerifier {
  Future<VerifiedPremiumEntitlement> verify();
}

final class VerifiedPremiumEntitlement {
  VerifiedPremiumEntitlement({
    required this.subjectId,
    required this.verifiedAtUtc,
    required this.expiresAtUtc,
    required this.verifierId,
    required this.signedAssertionId,
  }) {
    if (!verifiedAtUtc.isUtc || !expiresAtUtc.isUtc) {
      throw ArgumentError('entitlement timestamps must be UTC');
    }
    if (!expiresAtUtc.isAfter(verifiedAtUtc)) {
      throw ArgumentError('entitlement expiry must follow verification');
    }
    if (subjectId.trim().isEmpty ||
        verifierId.trim().isEmpty ||
        signedAssertionId.trim().isEmpty) {
      throw ArgumentError('verified entitlement provenance required');
    }
  }

  final String subjectId;
  final DateTime verifiedAtUtc;
  final DateTime expiresAtUtc;
  final String verifierId;
  final String signedAssertionId;

  bool isValidAt(DateTime nowUtc) {
    if (!nowUtc.isUtc) throw ArgumentError('nowUtc must be UTC');
    return !nowUtc.isBefore(verifiedAtUtc) && nowUtc.isBefore(expiresAtUtc);
  }
}
