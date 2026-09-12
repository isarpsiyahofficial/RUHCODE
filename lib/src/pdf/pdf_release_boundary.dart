import 'pdf_report_contract.dart';

/// Binding release boundary for Ruh Code's human-readable PDF reports.
///
/// PDF is intentionally not a technical backup format. Restorable application
/// data belongs to the CSV/backup subsystem. This boundary also makes the
/// privacy and rendering assumptions explicit so they can be guarded by tests
/// and CI instead of remaining documentation-only promises.
final class PdfReleaseBoundary {
  const PdfReleaseBoundary({
    this.onDeviceOnly = true,
    this.sendsPersonalDataOffDevice = false,
    this.recomputesCalculations = false,
    this.capturesApplicationScreens = false,
    this.usesLowResolutionChartJpeg = false,
  });

  final bool onDeviceOnly;
  final bool sendsPersonalDataOffDevice;
  final bool recomputesCalculations;
  final bool capturesApplicationScreens;
  final bool usesLowResolutionChartJpeg;

  void validate({required PdfReportPlan plan}) {
    if (!onDeviceOnly || sendsPersonalDataOffDevice) {
      throw const FormatException(
        'Ruh Code PDF generation must remain completely on-device.',
      );
    }
    if (recomputesCalculations) {
      throw const FormatException(
        'PDF generation must consume the verified calculation snapshot without recalculating it.',
      );
    }
    if (capturesApplicationScreens) {
      throw const FormatException(
        'PDF report layout cannot be built from application screenshots.',
      );
    }
    if (usesLowResolutionChartJpeg) {
      throw const FormatException(
        'Professional PDF charts cannot use low-resolution JPEG screenshots.',
      );
    }
    if (plan.localeTag != 'tr' && plan.localeTag != 'en') {
      throw FormatException('Unsupported PDF release locale: ${plan.localeTag}.');
    }
    if (plan.pageSpec.widthMm != PdfPageSpec.a4.widthMm ||
        plan.pageSpec.heightMm != PdfPageSpec.a4.heightMm) {
      throw const FormatException('Professional PDF v1 must use real A4 document geometry.');
    }
  }
}

/// Small, deterministic filename policy used by the PDF delivery layer.
/// It removes characters rejected by common Android/desktop filesystems while
/// keeping Turkish and other Unicode letters intact.
abstract final class PdfReportFileName {
  static String build({
    required String subjectName,
    required PdfReportKind kind,
    required DateTime generatedAtUtc,
  }) {
    final normalizedSubject = _sanitize(subjectName);
    final safeSubject = normalizedSubject.isEmpty ? 'Ruh_Code' : normalizedSubject;
    final date = generatedAtUtc.toUtc().toIso8601String().substring(0, 10);
    return '${safeSubject}_${kind.name}_$date.pdf';
  }

  static String _sanitize(String value) {
    final withoutReserved = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'[\u0000-\u001F]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return withoutReserved.replaceAll(RegExp(r'[. ]+$'), '');
  }
}