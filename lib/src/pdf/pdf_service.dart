abstract interface class PdfService<TSnapshot> {
  Future<List<int>> buildReport({
    required TSnapshot snapshot,
    required PdfReportOptions options,
  });
}

final class PdfReportOptions {
  const PdfReportOptions({
    required this.localeTag,
    required this.sectionIds,
    this.professionalName,
    this.brandName,
  });

  final String localeTag;
  final List<String> sectionIds;
  final String? professionalName;
  final String? brandName;
}
