import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/product/report_entitlement_core.dart';

void main() {
  CalculationResultRef result(String id) => CalculationResultRef(
        resultId: id,
        manifestId: 'manifest-$id',
        engineId: 'engine-western',
        engineVersion: '1.0.0',
        payloadDigest: 'sha256-$id',
      );

  group('RC-0271..RC-0274 professional PDF source integrity', () {
    test('TR and EN reports bind sections to existing manifests without recalculation', () {
      final source = result('r1');
      final section = ProfessionalReportSection(
        id: 'natal',
        title: 'Natal',
        source: source,
        renderPayload: 'render-only payload',
      );
      final service = ProfessionalReportService();
      final at = DateTime.utc(2026, 9, 7);
      final tr = service.build(
        tier: AppTier.pro,
        reportId: 'tr-report',
        locale: ReportLocale.tr,
        generatedAtUtc: at,
        sections: [section],
      );
      final en = service.build(
        tier: AppTier.pro,
        reportId: 'en-report',
        locale: ReportLocale.en,
        generatedAtUtc: at,
        sections: [section],
      );
      expect(tr.sourceManifestBySection['natal'], source.manifestId);
      expect(en.sourceManifestBySection['natal'], source.manifestId);
      expect(identical(tr.sections.single.source, source), isTrue);
      expect(identical(en.sections.single.source, source), isTrue);
    });

    test('PDF is PRO-only and rejects invalid report structures', () {
      final service = ProfessionalReportService();
      expect(
        () => service.build(
          tier: AppTier.free,
          reportId: 'free-report',
          locale: ReportLocale.tr,
          generatedAtUtc: DateTime.utc(2026, 9, 7),
          sections: [
            ProfessionalReportSection(
              id: 'a',
              title: 'A',
              source: result('r2'),
              renderPayload: 'x',
            ),
          ],
        ),
        throwsStateError,
      );
      expect(
        () => ProfessionalReportDocument(
          id: 'empty',
          locale: ReportLocale.en,
          generatedAtUtc: DateTime.utc(2026, 9, 7),
          sections: const [],
        ),
        throwsArgumentError,
      );
    });
  });

  group('RC-0275..RC-0305 single-app Free/PRO boundary', () {
    const policy = ProductEntitlementPolicy();

    test('Free exposes real basic value while advanced tools stay PRO', () {
      for (final feature in [
        ProductFeature.westernNatalBasic,
        ProductFeature.sunMoonRising,
        ProductFeature.vedicBasic,
        ProductFeature.chineseZodiacBasic,
        ProductFeature.numerologyBasic,
        ProductFeature.moonPhase,
        ProductFeature.currentPlanetaryHour,
        ProductFeature.dailyFreeCards,
      ]) {
        expect(policy.allows(tier: AppTier.free, feature: feature), isTrue,
            reason: '$feature should be Free');
      }
      for (final feature in [
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
      ]) {
        expect(policy.allows(tier: AppTier.free, feature: feature), isFalse,
            reason: '$feature should require PRO');
        expect(policy.allows(tier: AppTier.pro, feature: feature), isTrue,
            reason: '$feature should be available to PRO');
      }
    });

    test('rewarded unlock is temporary and only supported for premium daily content', () {
      final grant = DateTime.utc(2026, 9, 7, 9);
      final unlock = RewardedUnlock(
        feature: ProductFeature.dailyPremiumCards,
        grantedAtUtc: grant,
        expiresAtUtc: grant.add(const Duration(minutes: 30)),
      );
      expect(
        policy.allows(
          tier: AppTier.free,
          feature: ProductFeature.dailyPremiumCards,
          nowUtc: grant.add(const Duration(minutes: 10)),
          rewardedUnlock: unlock,
        ),
        isTrue,
      );
      expect(
        policy.allows(
          tier: AppTier.free,
          feature: ProductFeature.dailyPremiumCards,
          nowUtc: grant.add(const Duration(minutes: 31)),
          rewardedUnlock: unlock,
        ),
        isFalse,
      );
      expect(
        () => RewardedUnlock(
          feature: ProductFeature.synastry,
          grantedAtUtc: grant,
          expiresAtUtc: grant.add(const Duration(minutes: 30)),
        ),
        throwsArgumentError,
      );
    });

    test('PRO is ad-free and tier never mutates calculation truth', () {
      final source = result('truth');
      expect(policy.showsAds(AppTier.pro), isFalse);
      expect(policy.showsAds(AppTier.free), isTrue);
      expect(
        identical(
          policy.preserveCalculationTruth(tier: AppTier.free, result: source),
          source,
        ),
        isTrue,
      );
      expect(
        identical(
          policy.preserveCalculationTruth(tier: AppTier.pro, result: source),
          source,
        ),
        isTrue,
      );
    });
  });
}
