import 'package:flutter/services.dart';

import 'pdf_asset_font_provider.dart';
import 'pdf_combined_report.dart';
import 'pdf_font_release_manifest.dart';
import 'pdf_service.dart';
import 'unavailable_pdf_service.dart';

/// Production composition for combined PDF byte rendering.
///
/// This boundary deliberately remains fail-closed until the canonical font
/// release manifest proves that the exact approved binaries are packaged and
/// SHA-256 pinned. Once that contract becomes release-ready, the same runtime
/// path switches to the real local renderer without a second composition
/// change.
PdfService<PdfCombinedReportProjection> createProductionCombinedPdfService({
  required AssetBundle bundle,
}) {
  if (!PdfFontReleaseManifest.isReleaseReady) {
    return UnavailablePdfService<PdfCombinedReportProjection>(
      PdfFontReleaseManifest.blockingReason,
    );
  }

  final specs = <PdfFontAssetSpec>[
    for (final localeTag in const <String>['tr', 'en'])
      PdfFontAssetSpec(
        localeTag: localeTag,
        familyName: PdfFontReleaseManifest.familyName,
        licenseId: PdfFontReleaseManifest.licenseId,
        regularAssetPath: PdfFontReleaseManifest.regularAssetPath,
        boldAssetPath: PdfFontReleaseManifest.boldAssetPath,
        regularSha256: PdfFontReleaseManifest.regularSha256,
        boldSha256: PdfFontReleaseManifest.boldSha256,
      ),
  ];

  return PdfCombinedReportService(
    fontProvider: PdfAssetFontBundleProvider(bundle: bundle, specs: specs),
  );
}
