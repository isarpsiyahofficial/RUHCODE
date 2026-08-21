enum FeatureBaseAccess { free, pro }

final class FeaturePolicy {
  const FeaturePolicy({
    required this.id,
    required this.baseAccess,
    this.temporaryUnlockAllowed = false,
  });

  final String id;
  final FeatureBaseAccess baseAccess;
  final bool temporaryUnlockAllowed;
}

/// Canonical product feature IDs. UI, routes and services must reference these
/// IDs instead of inventing local premium flags.
abstract final class RuhFeatureIds {
  static const todayOverview = 'today.overview';
  static const personalProfiles = 'records.profiles';
  static const westernNatalBasic = 'western.natal.basic';
  static const westernAdvanced = 'western.advanced';
  static const vedicBasic = 'vedic.basic';
  static const vedicAdvanced = 'vedic.advanced';
  static const chineseBasic = 'chinese.basic';
  static const planetaryHours = 'planetary_hours.basic';
  static const numerologyBasic = 'numerology.basic';
  static const numerologyAdvanced = 'numerology.advanced';
  static const baziBasic = 'bazi.basic';
  static const baziAdvanced = 'bazi.advanced';
  static const professionalClients = 'professional.clients';
  static const professionalPresets = 'professional.presets';
  static const pdfSamplePreview = 'pdf.sample_preview';
  static const pdfProfessionalExport = 'pdf.professional_export';
  static const fullBackup = 'backup.full';

  static const all = <String>{
    todayOverview,
    personalProfiles,
    westernNatalBasic,
    westernAdvanced,
    vedicBasic,
    vedicAdvanced,
    chineseBasic,
    planetaryHours,
    numerologyBasic,
    numerologyAdvanced,
    baziBasic,
    baziAdvanced,
    professionalClients,
    professionalPresets,
    pdfSamplePreview,
    pdfProfessionalExport,
    fullBackup,
  };
}

abstract final class RuhFeatureCatalog {
  static const policies = <String, FeaturePolicy>{
    RuhFeatureIds.todayOverview: FeaturePolicy(
      id: RuhFeatureIds.todayOverview,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.personalProfiles: FeaturePolicy(
      id: RuhFeatureIds.personalProfiles,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.westernNatalBasic: FeaturePolicy(
      id: RuhFeatureIds.westernNatalBasic,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.westernAdvanced: FeaturePolicy(
      id: RuhFeatureIds.westernAdvanced,
      baseAccess: FeatureBaseAccess.pro,
      temporaryUnlockAllowed: true,
    ),
    RuhFeatureIds.vedicBasic: FeaturePolicy(
      id: RuhFeatureIds.vedicBasic,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.vedicAdvanced: FeaturePolicy(
      id: RuhFeatureIds.vedicAdvanced,
      baseAccess: FeatureBaseAccess.pro,
      temporaryUnlockAllowed: true,
    ),
    RuhFeatureIds.chineseBasic: FeaturePolicy(
      id: RuhFeatureIds.chineseBasic,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.planetaryHours: FeaturePolicy(
      id: RuhFeatureIds.planetaryHours,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.numerologyBasic: FeaturePolicy(
      id: RuhFeatureIds.numerologyBasic,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.numerologyAdvanced: FeaturePolicy(
      id: RuhFeatureIds.numerologyAdvanced,
      baseAccess: FeatureBaseAccess.pro,
      temporaryUnlockAllowed: true,
    ),
    RuhFeatureIds.baziBasic: FeaturePolicy(
      id: RuhFeatureIds.baziBasic,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.baziAdvanced: FeaturePolicy(
      id: RuhFeatureIds.baziAdvanced,
      baseAccess: FeatureBaseAccess.pro,
      temporaryUnlockAllowed: true,
    ),
    RuhFeatureIds.professionalClients: FeaturePolicy(
      id: RuhFeatureIds.professionalClients,
      baseAccess: FeatureBaseAccess.pro,
    ),
    RuhFeatureIds.professionalPresets: FeaturePolicy(
      id: RuhFeatureIds.professionalPresets,
      baseAccess: FeatureBaseAccess.pro,
    ),
    RuhFeatureIds.pdfSamplePreview: FeaturePolicy(
      id: RuhFeatureIds.pdfSamplePreview,
      baseAccess: FeatureBaseAccess.free,
    ),
    RuhFeatureIds.pdfProfessionalExport: FeaturePolicy(
      id: RuhFeatureIds.pdfProfessionalExport,
      baseAccess: FeatureBaseAccess.pro,
      temporaryUnlockAllowed: true,
    ),
    RuhFeatureIds.fullBackup: FeaturePolicy(
      id: RuhFeatureIds.fullBackup,
      baseAccess: FeatureBaseAccess.free,
    ),
  };

  static FeaturePolicy policyFor(String featureId) {
    final policy = policies[featureId];
    if (policy == null) {
      throw ArgumentError.value(featureId, 'featureId', 'Unknown Ruh Code feature ID.');
    }
    return policy;
  }

  static void validate() {
    if (policies.length != RuhFeatureIds.all.length || !policies.keys.toSet().containsAll(RuhFeatureIds.all)) {
      throw const StateError('Feature policy catalog must cover every canonical feature ID exactly once.');
    }
  }
}
