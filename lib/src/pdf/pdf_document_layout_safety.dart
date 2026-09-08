import 'pdf_report_contract.dart';

/// Document-level safety rules for professional PDF pagination.
///
/// These rules are deliberately expressed in physical document units rather
/// than device pixels so phone/tablet viewport size cannot leak into PDF layout.
final class PdfDocumentLayoutSafety {
  const PdfDocumentLayoutSafety({this.minimumSafeMarginMm = 12});

  final double minimumSafeMarginMm;

  void validate(PdfReportPlan plan) {
    final page = plan.pageSpec;
    if (minimumSafeMarginMm <= 0 || !minimumSafeMarginMm.isFinite) {
      throw const FormatException('Minimum PDF safe margin must be finite and positive.');
    }
    if (page.widthMm != PdfPageSpec.a4.widthMm || page.heightMm != PdfPageSpec.a4.heightMm) {
      throw const FormatException('Professional PDF layout must use A4 document geometry.');
    }
    final margins = <double>[
      page.marginTopMm,
      page.marginRightMm,
      page.marginBottomMm,
      page.marginLeftMm,
    ];
    if (margins.any((value) => !value.isFinite || value < minimumSafeMarginMm)) {
      throw FormatException(
        'Professional PDF margins must be at least $minimumSafeMarginMm mm.',
      );
    }
    if (page.contentWidthMm <= 0 || page.contentHeightMm <= 0) {
      throw const FormatException('PDF page has no usable content rectangle.');
    }
  }

  /// Layout strings stay Unicode and are never byte/character truncated merely
  /// to fit a screen width. The renderer is responsible for wrapping them in
  /// the A4 content rectangle.
  String preserveWrappingText(String value) {
    final normalized = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (normalized.isEmpty) {
      throw const FormatException('PDF layout text cannot be blank.');
    }
    if (normalized.contains(RegExp(r'[\u0000\u0008\u000B\u000C\u000E-\u001F]'))) {
      throw const FormatException('PDF layout text contains unsupported control characters.');
    }
    return normalized;
  }
}
