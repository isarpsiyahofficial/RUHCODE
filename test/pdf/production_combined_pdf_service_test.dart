import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_combined_report.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_font_release_manifest.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/production_combined_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('production combined PDF composition', () {
    test('uses the real local renderer when canonical fonts are release-ready', () {
      expect(PdfFontReleaseManifest.isReleaseReady, isTrue);

      final service = createProductionCombinedPdfService(bundle: rootBundle);

      expect(service, isA<PdfCombinedReportService>());
    });

    test('renders PDF bytes through the packaged verified font assets', () async {
      final service = createProductionCombinedPdfService(bundle: rootBundle);
      final snapshot = const PdfCombinedReportBuilder().build(
        members: <PdfCombinedMember>[
          PdfCombinedMember(
            systemId: 'western.natal',
            identity: PdfSnapshotIdentity(
              subjectKind: PdfSubjectKind.profile,
              subjectId: 'production-pdf-test',
              snapshotDigest:
                  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              engineVersion: 'engine.v1',
              algorithmVersion: 'algorithm.v1',
              dataVersion: 'data.v1',
              calculationManifestId: 'manifest-western',
            ),
            sections: <PdfRenderSection>[
              PdfRenderSection(
                sectionId: PdfSectionIds.placements,
                snapshotDigest:
                    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                title: 'Yerleşimler',
                paragraphs: <String>['Çevrimdışı üretim doğrulaması'],
              ),
            ],
          ),
          PdfCombinedMember(
            systemId: 'numerology.pythagorean',
            identity: PdfSnapshotIdentity(
              subjectKind: PdfSubjectKind.profile,
              subjectId: 'production-pdf-test',
              snapshotDigest:
                  'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
              engineVersion: 'engine.v1',
              algorithmVersion: 'algorithm.v1',
              dataVersion: 'data.v1',
              calculationManifestId: 'manifest-numerology',
            ),
            sections: <PdfRenderSection>[
              PdfRenderSection(
                sectionId: PdfSectionIds.numerology,
                snapshotDigest:
                    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
                title: 'Numeroloji',
                paragraphs: <String>['Offline production rendering'],
              ),
            ],
          ),
        ],
        coverTitle: 'Kombine Danışmanlık Raporu',
        technicalTitle: 'Hesaplama Kaynakları',
        systemHeader: 'Sistem',
        fieldHeader: 'Alan',
        valueHeader: 'Değer',
      );

      final bytes = await service.buildReport(
        snapshot: snapshot,
        options: PdfReportOptions(
          localeTag: 'tr',
          sectionIds: snapshot.sections
              .map((section) => section.sectionId)
              .toList(growable: false),
          subjectName: 'Airplane Test',
          generatedAtUtc: DateTime.utc(2026, 9, 12, 12),
        ),
      );

      expect(bytes.length, greaterThan(1024));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}