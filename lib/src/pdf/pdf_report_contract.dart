export 'pdf_service.dart' show PdfReportOptions;

enum PdfReportKind {
  western,
  vedic,
  numerology,
  bazi,
  combined,
  sample,
}

enum PdfDataOrigin {
  user,
  demo,
}

enum PdfCoverStyle {
  professional,
  clientFriendly,
}

final class PdfPageSpec {
  const PdfPageSpec({
    required this.widthMm,
    required this.heightMm,
    required this.marginTopMm,
    required this.marginRightMm,
    required this.marginBottomMm,
    required this.marginLeftMm,
  });

  static const a4 = PdfPageSpec(
    widthMm: 210,
    heightMm: 297,
    marginTopMm: 16,
    marginRightMm: 16,
    marginBottomMm: 18,
    marginLeftMm: 16,
  );

  final double widthMm;
  final double heightMm;
  final double marginTopMm;
  final double marginRightMm;
  final double marginBottomMm;
  final double marginLeftMm;

  double get contentWidthMm => widthMm - marginLeftMm - marginRightMm;
  double get contentHeightMm => heightMm - marginTopMm - marginBottomMm;
}

final class PdfTypographyTokens {
  const PdfTypographyTokens({
    this.coverTitlePt = 28,
    this.h1Pt = 20,
    this.h2Pt = 15,
    this.bodyPt = 10.5,
    this.captionPt = 8.5,
    this.tablePt = 9,
    this.lineHeight = 1.35,
  });

  final double coverTitlePt;
  final double h1Pt;
  final double h2Pt;
  final double bodyPt;
  final double captionPt;
  final double tablePt;
  final double lineHeight;

  void validate() {
    final values = <double>[
      coverTitlePt,
      h1Pt,
      h2Pt,
      bodyPt,
      captionPt,
      tablePt,
      lineHeight,
    ];
    if (values.any((value) => !value.isFinite || value <= 0)) {
      throw const FormatException('PDF typography tokens must be finite positive values.');
    }
    if (!(coverTitlePt > h1Pt && h1Pt > h2Pt && h2Pt > bodyPt && bodyPt > captionPt)) {
      throw const FormatException('PDF typography hierarchy is invalid.');
    }
  }
}

abstract final class PdfSectionIds {
  static const cover = 'cover';
  static const subject = 'subject';
  static const summary = 'summary';
  static const chart = 'chart';
  static const placements = 'placements';
  static const houses = 'houses';
  static const aspects = 'aspects';
  static const interpretation = 'interpretation';
  static const vedicCharts = 'vedic_charts';
  static const dasha = 'dasha';
  static const panchanga = 'panchanga';
  static const numerology = 'numerology';
  static const bazi = 'bazi';
  static const customNotes = 'custom_notes';
  static const technicalManifest = 'technical_manifest';

  static const all = <String>{
    cover,
    subject,
    summary,
    chart,
    placements,
    houses,
    aspects,
    interpretation,
    vedicCharts,
    dasha,
    panchanga,
    numerology,
    bazi,
    customNotes,
    technicalManifest,
  };
}

final class PdfSectionInput {
  const PdfSectionInput({
    required this.id,
    required this.hasContent,
  });

  final String id;
  final bool hasContent;
}

final class PdfBranding {
  const PdfBranding({
    this.professionalName,
    this.brandName,
    this.logoAssetId,
  });

  final String? professionalName;
  final String? brandName;
  final String? logoAssetId;

  bool get hasAny =>
      _nonBlank(professionalName) || _nonBlank(brandName) || _nonBlank(logoAssetId);

  static bool _nonBlank(String? value) => value != null && value.trim().isNotEmpty;
}

final class PdfReportRequest {
  const PdfReportRequest({
    required this.kind,
    required this.dataOrigin,
    required this.localeTag,
    required this.coverStyle,
    required this.requestedSectionIds,
    this.branding = const PdfBranding(),
    this.pageSpec = PdfPageSpec.a4,
    this.typography = const PdfTypographyTokens(),
  });

  final PdfReportKind kind;
  final PdfDataOrigin dataOrigin;
  final String localeTag;
  final PdfCoverStyle coverStyle;
  final List<String> requestedSectionIds;
  final PdfBranding branding;
  final PdfPageSpec pageSpec;
  final PdfTypographyTokens typography;
}

final class PdfReportPlan {
  const PdfReportPlan({
    required this.kind,
    required this.dataOrigin,
    required this.localeTag,
    required this.coverStyle,
    required this.sectionIds,
    required this.branding,
    required this.pageSpec,
    required this.typography,
  });

  final PdfReportKind kind;
  final PdfDataOrigin dataOrigin;
  final String localeTag;
  final PdfCoverStyle coverStyle;
  final List<String> sectionIds;
  final PdfBranding branding;
  final PdfPageSpec pageSpec;
  final PdfTypographyTokens typography;
}

final class PdfReportPlanner {
  const PdfReportPlanner();

  PdfReportPlan build({
    required PdfReportRequest request,
    required List<PdfSectionInput> availableSections,
  }) {
    _validateRequest(request);

    final availability = <String, bool>{};
    for (final section in availableSections) {
      if (!PdfSectionIds.all.contains(section.id)) {
        throw FormatException('Unknown PDF section id: ${section.id}.');
      }
      if (availability.containsKey(section.id)) {
        throw FormatException('Duplicate PDF section availability: ${section.id}.');
      }
      availability[section.id] = section.hasContent;
    }

    final selected = <String>[];
    final seen = <String>{};
    for (final id in request.requestedSectionIds) {
      if (!PdfSectionIds.all.contains(id)) {
        throw FormatException('Unknown requested PDF section id: $id.');
      }
      if (!seen.add(id)) {
        throw FormatException('Duplicate requested PDF section id: $id.');
      }
      if (availability[id] == true) {
        selected.add(id);
      }
    }

    if (availability[PdfSectionIds.cover] == true && !selected.contains(PdfSectionIds.cover)) {
      selected.insert(0, PdfSectionIds.cover);
    }

    if (selected.where((id) => id != PdfSectionIds.cover).isEmpty) {
      throw const FormatException('PDF report has no non-empty content section.');
    }

    return PdfReportPlan(
      kind: request.kind,
      dataOrigin: request.dataOrigin,
      localeTag: request.localeTag,
      coverStyle: request.coverStyle,
      sectionIds: List.unmodifiable(selected),
      branding: request.branding,
      pageSpec: request.pageSpec,
      typography: request.typography,
    );
  }

  void _validateRequest(PdfReportRequest request) {
    if (request.localeTag != 'tr' && request.localeTag != 'en') {
      throw FormatException('Unsupported PDF locale: ${request.localeTag}.');
    }
    if (request.kind == PdfReportKind.sample && request.dataOrigin != PdfDataOrigin.demo) {
      throw const FormatException('Sample PDF must use demo data only.');
    }
    if (request.kind != PdfReportKind.sample && request.dataOrigin != PdfDataOrigin.user) {
      throw const FormatException('Non-sample PDF must use user data origin.');
    }
    if (request.pageSpec.widthMm != PdfPageSpec.a4.widthMm ||
        request.pageSpec.heightMm != PdfPageSpec.a4.heightMm) {
      throw const FormatException('Ruh Code professional PDF v1 supports A4 only.');
    }
    if (request.pageSpec.contentWidthMm <= 0 || request.pageSpec.contentHeightMm <= 0) {
      throw const FormatException('PDF page margins leave no usable content area.');
    }
    request.typography.validate();
  }
}
