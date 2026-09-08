import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';

void main() {
  test('PDF report metadata preserves optional names and date', () {
    final generatedAt = DateTime.utc(2026, 9, 8, 11, 30);
    final options = PdfReportOptions(
      localeTag: 'tr',
      sectionIds: const <String>['cover', 'summary'],
      subjectName: 'Danışan Adı',
      professionalName: 'Uzman Adı',
      brandName: 'Ruh Code',
      generatedAtUtc: generatedAt,
    );
    expect(options.subjectName, 'Danışan Adı');
    expect(options.professionalName, 'Uzman Adı');
    expect(options.brandName, 'Ruh Code');
    expect(options.generatedAtUtc, generatedAt);
  });

  test('generation date can be omitted', () {
    const options = PdfReportOptions(
      localeTag: 'en',
      sectionIds: <String>['cover', 'summary'],
      subjectName: 'Client Name',
    );
    expect(options.generatedAtUtc, isNull);
  });
}
