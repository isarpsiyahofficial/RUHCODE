/// Product/report boundaries for RC-0271..RC-0305.
///
/// Calculation truth is supplied as immutable result references. This layer
/// never recalculates astronomy/numerology and monetization never changes a
/// calculation result.
enum AppTier { free, pro }
enum ReportLocale { tr, en }
enum ProductFeature {
  westernNatalBasic,
  sunMoonRising,
  vedicBasic,
  chineseZodiacBasic,
  numerologyBasic,
  moonPhase,
  currentPlanetaryHour,
  dailyFreeCards,
  dailyPremiumCards,
  westernAdvanced,
  vedicAdvanced,
  bazi,
  numerologyAdvanced,
  synastry,
  composite,
  transitAnalysis,
  progressions,
  solarLunarReturn,
  professionalClients,
  professionalPdf,
  extendedDateAnalysis,
  offlineCalculation,
}

final class CalculationResultRef {
  CalculationResultRef({
    required this.resultId,
    required this.manifestId,
    required this.engineId,
    required this.engineVersion,
    required this.payloadDigest,
  }) {
    _text(resultId, 'resultId');
    _text(manifestId, 'manifestId');
    _text(engineId, 'engineId');
    _text(engineVersion, 'engineVersion');
    _text(payloadDigest, 'payloadDigest');
  }

  final String resultId;
  final String manifestId;
  final String engineId;
  final String engineVersion;
  final String payloadDigest;
}

/// A report section references an already-produced calculation result.
/// There is intentionally no callback/function capable of recalculation here.
final class ProfessionalReportSection {
  ProfessionalReportSection({
    required this.id,
    required this.title,
    required this.source,
    required this.renderPayload,
  }) {
    _text(id, 'section id');
    _text(title, 'section title');
    _text(renderPayload, 'renderPayload');
  }

  final String id;
  final String title;
  final CalculationResultRef source;
  final String renderPayload;
}

final class ProfessionalReportDocument {
  ProfessionalReportDocument({
    required this.id,
    required this.locale,
    required this.generatedAtUtc,
    required Iterable<ProfessionalReportSection> sections,
  }) : sections = List.unmodifiable(sections) {
    _text(id, 'report id');
    if (!generatedAtUtc.isUtc) throw ArgumentError('generatedAtUtc must be UTC');
    if (this.sections.isEmpty) throw ArgumentError('report requires at least one section');
    _unique(this.sections.map((e) => e.id), 'report section');
  }

  final String id;
  final ReportLocale locale;
  final DateTime generatedAtUtc;
  final List<ProfessionalReportSection> sections;

  /// Evidence that report content is bound to the same calculation artifacts
  /// the application used, rather than a report-specific recalculation pass.
  Map<String, String> get sourceManifestBySection => Map.unmodifiable({
        for (final section in sections) section.id: section.source.manifestId,
      });
}

final class RewardedUnlock {
  RewardedUnlock({
    required this.feature,
    required this.grantedAtUtc,
    required this.expiresAtUtc,
  }) {
    if (!grantedAtUtc.isUtc || !expiresAtUtc.isUtc) {
      throw ArgumentError('rewarded unlock times must be UTC');
    }
    if (!expiresAtUtc.isAfter(grantedAtUtc)) {
      throw ArgumentError('rewarded unlock expiry must be after grant');
    }
    if (feature != ProductFeature.dailyPremiumCards) {
      throw ArgumentError('rewarded unlock is restricted to supported temporary premium daily content');
    }
  }

  final ProductFeature feature;
  final DateTime grantedAtUtc;
  final DateTime expiresAtUtc;

  bool activeAt(DateTime instantUtc) {
    if (!instantUtc.isUtc) throw ArgumentError('instantUtc must be UTC');
    return !instantUtc.isBefore(grantedAtUtc) && instantUtc.isBefore(expiresAtUtc);
  }
}

/// Monetization policy is deliberately separate from calculation engines.
final class ProductEntitlementPolicy {
  const ProductEntitlementPolicy();

  static const Set<ProductFeature> _free = {
    ProductFeature.westernNatalBasic,
    ProductFeature.sunMoonRising,
    ProductFeature.vedicBasic,
    ProductFeature.chineseZodiacBasic,
    ProductFeature.numerologyBasic,
    ProductFeature.moonPhase,
    ProductFeature.currentPlanetaryHour,
    ProductFeature.dailyFreeCards,
  };

  static const Set<ProductFeature> _pro = {
    ..._free,
    ProductFeature.dailyPremiumCards,
    ProductFeature.westernAdvanced,
    ProductFeature.vedicAdvanced,
    ProductFeature.bazi,
    ProductFeature.numerologyAdvanced,
    ProductFeature.synastry,
    ProductFeature.composite,
    ProductFeature.transitAnalysis,
    ProductFeature.progressions,
    ProductFeature.solarLunarReturn,
    ProductFeature.professionalClients,
    ProductFeature.professionalPdf,
    ProductFeature.extendedDateAnalysis,
    ProductFeature.offlineCalculation,
  };

  bool allows({
    required AppTier tier,
    required ProductFeature feature,
    DateTime? nowUtc,
    RewardedUnlock? rewardedUnlock,
  }) {
    if (tier == AppTier.pro) return _pro.contains(feature);
    if (_free.contains(feature)) return true;
    if (rewardedUnlock == null || nowUtc == null) return false;
    if (rewardedUnlock.feature != feature) return false;
    return rewardedUnlock.activeAt(nowUtc);
  }

  bool showsAds(AppTier tier) => tier == AppTier.free;

  /// Accuracy is invariant across tiers: access may differ, result identity may not.
  CalculationResultRef preserveCalculationTruth({
    required AppTier tier,
    required CalculationResultRef result,
  }) => result;
}

final class ProfessionalReportService {
  ProfessionalReportService({ProductEntitlementPolicy? policy})
      : policy = policy ?? const ProductEntitlementPolicy();

  final ProductEntitlementPolicy policy;

  ProfessionalReportDocument build({
    required AppTier tier,
    required String reportId,
    required ReportLocale locale,
    required DateTime generatedAtUtc,
    required Iterable<ProfessionalReportSection> sections,
  }) {
    if (!policy.allows(tier: tier, feature: ProductFeature.professionalPdf)) {
      throw StateError('professional PDF requires PRO entitlement');
    }
    return ProfessionalReportDocument(
      id: reportId,
      locale: locale,
      generatedAtUtc: generatedAtUtc,
      sections: sections,
    );
  }
}

void _text(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field cannot be blank');
}

void _unique(Iterable<String> values, String kind) {
  final seen = <String>{};
  for (final value in values) {
    _text(value, '$kind id');
    if (!seen.add(value)) throw ArgumentError('duplicate $kind id: $value');
  }
}
