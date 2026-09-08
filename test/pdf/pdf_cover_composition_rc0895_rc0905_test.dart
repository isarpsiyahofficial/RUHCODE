import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/pdf/pdf_cover_composition.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  PdfReportPlan plan({
    PdfReportKind kind = PdfReportKind.western,
    PdfCoverStyle style = PdfCoverStyle.professional,
    String? logoAssetId,
  }) => PdfReportPlan(
        kind: kind,
        dataOrigin: PdfDataOrigin.user,
        localeTag: 'tr-TR',
        coverStyle: style,
        sectionIds: const <String>[PdfSectionIds.cover],
        branding: PdfBranding(logoAssetId: logoAssetId),
        pageSpec: PdfPageSpec.a4,
        typography: const PdfTypographyTokens(),
      );

  const vectorLogo = PdfResolvedLogo(
    assetId: 'professional_logo',
    svg: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 40"><path d="M1 1 L99 1 L99 39 L1 39 Z"/></svg>',
  );

  test('logo-free cover reserves no logo area and still renders', () async {
    final composition = const PdfCoverCompositionPlanner().build(plan: plan());
    expect(composition.showLogo, isFalse);
    expect(composition.reserveLogoSpace, isFalse);
    expect(composition.logoAssetId, isNull);

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => const PdfCoverWidget().build(
          composition: composition,
          title: 'Batı Astrolojisi Raporu',
          subtitle: 'Danışan raporu',
        ),
      ),
    );
    expect((await document.save()).length, greaterThan(400));
  });

  test('requested local vector logo renders only when resolved id matches', () async {
    final composition = const PdfCoverCompositionPlanner().build(
      plan: plan(logoAssetId: 'professional_logo'),
      resolvedLogo: vectorLogo,
    );
    expect(composition.showLogo, isTrue);
    expect(composition.reserveLogoSpace, isTrue);

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => const PdfCoverWidget().build(
          composition: composition,
          title: 'Profesyonel Rapor',
          logo: vectorLogo,
        ),
      ),
    );
    expect((await document.save()).length, greaterThan(400));
  });

  test('unresolved or mismatched logo fails closed without phantom spacing', () {
    final unresolved = const PdfCoverCompositionPlanner().build(
      plan: plan(logoAssetId: 'professional_logo'),
    );
    expect(unresolved.showLogo, isFalse);
    expect(unresolved.reserveLogoSpace, isFalse);

    expect(
      () => const PdfCoverCompositionPlanner().build(
        plan: plan(logoAssetId: 'professional_logo'),
        resolvedLogo: const PdfResolvedLogo(
          assetId: 'other_logo',
          svg: '<svg viewBox="0 0 10 10"><path d="M0 0 L10 10"/></svg>',
        ),
      ),
      throwsFormatException,
    );
  });

  test('report kind and selected cover style remain explicit', () {
    final western = const PdfCoverCompositionPlanner().build(
      plan: plan(kind: PdfReportKind.western),
    );
    final vedic = const PdfCoverCompositionPlanner().build(
      plan: plan(kind: PdfReportKind.vedic, style: PdfCoverStyle.clientFriendly),
    );
    final numerology = const PdfCoverCompositionPlanner().build(
      plan: plan(kind: PdfReportKind.numerology),
    );

    expect(western.systemIdentity, PdfSystemVisualIdentity.western);
    expect(vedic.systemIdentity, PdfSystemVisualIdentity.vedic);
    expect(vedic.style, PdfCoverStyle.clientFriendly);
    expect(numerology.systemIdentity, PdfSystemVisualIdentity.numerology);
  });

  test('combined reports require clearly separated unique systems', () {
    const guard = PdfCombinedSystemGuard();
    expect(
      () => guard.validate(const <PdfCombinedSystemSection>[
        PdfCombinedSystemSection(
          system: PdfSystemVisualIdentity.western,
          heading: 'Batı Astrolojisi',
          sectionIds: <String>[PdfSectionIds.chart],
        ),
        PdfCombinedSystemSection(
          system: PdfSystemVisualIdentity.vedic,
          heading: 'Vedik Astroloji',
          sectionIds: <String>[PdfSectionIds.vedicCharts],
        ),
        PdfCombinedSystemSection(
          system: PdfSystemVisualIdentity.numerology,
          heading: 'Numeroloji',
          sectionIds: <String>[PdfSectionIds.numerology],
        ),
      ]),
      returnsNormally,
    );

    expect(
      () => guard.validate(const <PdfCombinedSystemSection>[
        PdfCombinedSystemSection(
          system: PdfSystemVisualIdentity.western,
          heading: 'Batı Astrolojisi',
          sectionIds: <String>[PdfSectionIds.chart],
        ),
        PdfCombinedSystemSection(
          system: PdfSystemVisualIdentity.western,
          heading: 'Vedik diye yanlış etiketlenmiş',
          sectionIds: <String>[PdfSectionIds.vedicCharts],
        ),
      ]),
      throwsFormatException,
    );
  });
}
