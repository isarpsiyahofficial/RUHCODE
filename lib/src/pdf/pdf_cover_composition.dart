import 'package:pdf/widgets.dart' as pw;

import 'pdf_report_contract.dart';

/// Resolved logo data is deliberately separated from [PdfBranding.logoAssetId].
/// The asset id is a local reference; only locally resolved SVG bytes/text reach
/// the renderer. A missing logo never creates a placeholder or reserved gap.
final class PdfResolvedLogo {
  const PdfResolvedLogo({required this.assetId, required this.svg});

  final String assetId;
  final String svg;

  void validate() {
    if (assetId.trim().isEmpty || svg.trim().isEmpty) {
      throw const FormatException('Resolved PDF logo must have an asset id and SVG payload.');
    }
    final lower = svg.toLowerCase();
    if (!lower.contains('<svg') || !lower.contains('viewbox=')) {
      throw const FormatException('PDF logo must be a vector SVG with a viewBox.');
    }
    if (lower.contains('<image') || lower.contains('data:image')) {
      throw const FormatException('Raster payloads are forbidden inside the PDF logo SVG.');
    }
  }
}

enum PdfSystemVisualIdentity {
  western,
  vedic,
  numerology,
  bazi,
  combined,
  sample,
}

final class PdfCoverComposition {
  const PdfCoverComposition({
    required this.style,
    required this.systemIdentity,
    required this.showLogo,
    required this.logoAssetId,
    required this.reserveLogoSpace,
  });

  final PdfCoverStyle style;
  final PdfSystemVisualIdentity systemIdentity;
  final bool showLogo;
  final String? logoAssetId;
  final bool reserveLogoSpace;
}

final class PdfCoverCompositionPlanner {
  const PdfCoverCompositionPlanner();

  PdfCoverComposition build({
    required PdfReportPlan plan,
    PdfResolvedLogo? resolvedLogo,
  }) {
    final requestedLogo = plan.branding.logoAssetId?.trim();
    final wantsLogo = requestedLogo != null && requestedLogo.isNotEmpty;

    if (resolvedLogo != null) {
      resolvedLogo.validate();
      if (!wantsLogo || resolvedLogo.assetId != requestedLogo) {
        throw const FormatException('Resolved PDF logo does not match the requested local logo asset.');
      }
    }

    final showLogo = wantsLogo && resolvedLogo != null;
    return PdfCoverComposition(
      style: plan.coverStyle,
      systemIdentity: _identity(plan.kind),
      showLogo: showLogo,
      logoAssetId: showLogo ? requestedLogo : null,
      reserveLogoSpace: showLogo,
    );
  }

  static PdfSystemVisualIdentity _identity(PdfReportKind kind) => switch (kind) {
        PdfReportKind.western => PdfSystemVisualIdentity.western,
        PdfReportKind.vedic => PdfSystemVisualIdentity.vedic,
        PdfReportKind.numerology => PdfSystemVisualIdentity.numerology,
        PdfReportKind.bazi => PdfSystemVisualIdentity.bazi,
        PdfReportKind.combined => PdfSystemVisualIdentity.combined,
        PdfReportKind.sample => PdfSystemVisualIdentity.sample,
      };
}

/// Actual cover widget. There is intentionally no empty SizedBox/logo slot when
/// [composition.showLogo] is false, so logo-free reports remain balanced.
final class PdfCoverWidget {
  const PdfCoverWidget();

  pw.Widget build({
    required PdfCoverComposition composition,
    required String title,
    String? subtitle,
    PdfResolvedLogo? logo,
  }) {
    if (title.trim().isEmpty) {
      throw const FormatException('PDF cover title cannot be blank.');
    }
    if (composition.showLogo) {
      if (logo == null) {
        throw const FormatException('PDF cover requested a logo but no resolved vector logo was supplied.');
      }
      logo.validate();
      if (logo.assetId != composition.logoAssetId) {
        throw const FormatException('PDF cover logo id mismatch.');
      }
    }

    final children = <pw.Widget>[];
    if (composition.showLogo) {
      children.add(
        pw.Container(
          constraints: const pw.BoxConstraints(maxWidth: 128, maxHeight: 72),
          child: pw.SvgImage(svg: logo!.svg),
        ),
      );
      children.add(pw.SizedBox(height: 22));
    }

    children.add(pw.Text(title, style: pw.TextStyle(fontSize: _titleSize(composition.style))));
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      children.add(pw.SizedBox(height: 10));
      children.add(pw.Text(subtitle.trim(), style: const pw.TextStyle(fontSize: 12)));
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: _alignment(composition),
      children: children,
    );
  }

  static double _titleSize(PdfCoverStyle style) => switch (style) {
        PdfCoverStyle.professional => 28,
        PdfCoverStyle.clientFriendly => 25,
      };

  static pw.CrossAxisAlignment _alignment(PdfCoverComposition composition) =>
      composition.style == PdfCoverStyle.professional
          ? pw.CrossAxisAlignment.start
          : pw.CrossAxisAlignment.center;
}

/// Combined reports keep each system in an explicit, non-ambiguous section.
/// A Western payload cannot be relabelled as Vedic (or vice versa).
final class PdfCombinedSystemSection {
  const PdfCombinedSystemSection({
    required this.system,
    required this.heading,
    required this.sectionIds,
  });

  final PdfSystemVisualIdentity system;
  final String heading;
  final List<String> sectionIds;

  void validate() {
    if (system == PdfSystemVisualIdentity.combined || system == PdfSystemVisualIdentity.sample) {
      throw const FormatException('Combined report child sections require a concrete calculation system.');
    }
    if (heading.trim().isEmpty || sectionIds.isEmpty) {
      throw const FormatException('Combined report system sections require a heading and content.');
    }
  }
}

final class PdfCombinedSystemGuard {
  const PdfCombinedSystemGuard();

  void validate(List<PdfCombinedSystemSection> sections) {
    if (sections.length < 2) {
      throw const FormatException('Combined PDF reports require at least two clearly separated systems.');
    }
    final seen = <PdfSystemVisualIdentity>{};
    for (final section in sections) {
      section.validate();
      if (!seen.add(section.system)) {
        throw FormatException('Duplicate combined PDF system section: ${section.system.name}.');
      }
    }
  }
}
