import 'dart:typed_data';

import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_page_geometry_inspector.dart';
import 'pdf_report_contract.dart';
import 'pdf_service.dart';

abstract interface class PdfReportContentAdapter<TSnapshot> {
  PdfReportKind get reportKind;
  PdfDataOrigin get dataOrigin;
  PdfCoverStyle get coverStyle;

  String documentTitle(TSnapshot snapshot, String localeTag);

  PdfReportDataset dataset(TSnapshot snapshot);

  List<PdfRenderSection> sections(TSnapshot snapshot);
}

abstract interface class PdfFontBundleProvider {
  Future<PdfFontBundle> loadForLocale(String localeTag);
}

final class PdfLocalReportService<TSnapshot> implements PdfService<TSnapshot> {
  const PdfLocalReportService({
    required this.adapter,
    required this.fontProvider,
    this.planner = const PdfReportPlanner(),
    this.dataValidator = const PdfReportDataValidator(),
    this.renderer = const PdfLocalRenderer(),
    this.pageGeometryInspector = const PdfPageGeometryInspector(),
  });

  static const double _pointsPerMillimeter = 72.0 / 25.4;

  final PdfReportContentAdapter<TSnapshot> adapter;
  final PdfFontBundleProvider fontProvider;
  final PdfReportPlanner planner;
  final PdfReportDataValidator dataValidator;
  final PdfLocalRenderer renderer;
  final PdfPageGeometryInspector pageGeometryInspector;

  @override
  Future<List<int>> buildReport({
    required TSnapshot snapshot,
    required PdfReportOptions options,
  }) async {
    final dataset = adapter.dataset(snapshot);
    final availableSections = dataValidator.validateAndProject(dataset);
    final request = PdfReportRequest(
      kind: adapter.reportKind,
      dataOrigin: adapter.dataOrigin,
      localeTag: options.localeTag,
      coverStyle: adapter.coverStyle,
      requestedSectionIds: List<String>.unmodifiable(options.sectionIds),
      branding: PdfBranding(
        professionalName: options.professionalName,
        brandName: options.brandName,
      ),
    );
    final plan = planner.build(
      request: request,
      availableSections: availableSections,
    );

    if (dataset.origin != adapter.dataOrigin) {
      throw const FormatException('PDF adapter origin and dataset origin do not match.');
    }

    final fonts = await fontProvider.loadForLocale(options.localeTag);
    final bytes = Uint8List.fromList(await renderer.render(
      PdfRenderPayload(
        plan: plan,
        dataset: dataset,
        documentTitle: adapter.documentTitle(snapshot, options.localeTag),
        sections: adapter.sections(snapshot),
        fonts: fonts,
      ),
    ));

    pageGeometryInspector.requireExpectedGeometry(
      bytes,
      expectedWidthPt: plan.pageSpec.widthMm * _pointsPerMillimeter,
      expectedHeightPt: plan.pageSpec.heightMm * _pointsPerMillimeter,
    );
    return bytes;
  }
}
