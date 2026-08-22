import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/pdf/guarded_pdf_service.dart';
import 'package:ruh_code/src/pdf/pdf_platform_gateway.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';
import 'package:ruh_code/src/pdf/professional_pdf_application_service.dart';
import 'package:ruh_code/src/pdf/professional_pdf_delivery_service.dart';

void main() {
  test('PDF platform policy rejects path injection and non-PDF bytes', () {
    const policy = PdfPlatformPolicy(maxPdfBytes: 1024);
    expect(() => policy.validateFileName('../report.pdf'), throwsFormatException);
    expect(() => policy.validateFileName('report.txt'), throwsFormatException);
    expect(() => policy.validateBytes(<int>[1, 2, 3]), throwsFormatException);
    expect(policy.validateFileName('Ruh_Code_Raporu.pdf'), 'Ruh_Code_Raporu.pdf');
    expect(
      policy.validateBytes(latin1.encode('%PDF-1.7\n%%EOF')).length,
      greaterThan(5),
    );
  });

  test('save cancellation remains a normal result after validated build', () async {
    final gateway = _FakePdfGateway(saveUri: null);
    final service = ProfessionalPdfDeliveryService<String>(
      applicationService: _applicationService(),
      platformGateway: gateway,
    );

    final result = await service.save(
      request: const ProfessionalPdfBuildRequest(
        recordId: 'calc-1',
        localeTag: 'tr',
        sectionIds: <String>['chart'],
      ),
      fileName: 'rapor.pdf',
    );

    expect(result.status, ProfessionalPdfDeliveryStatus.cancelled);
    expect(gateway.savedBytes, isNotEmpty);
  });

  test('dismissed share is cancellation, unavailable is explicit', () async {
    final dismissed = _FakePdfGateway(shareStatus: PdfShareStatus.dismissed);
    final dismissedService = ProfessionalPdfDeliveryService<String>(
      applicationService: _applicationService(),
      platformGateway: dismissed,
    );
    final request = const ProfessionalPdfBuildRequest(
      recordId: 'calc-1',
      localeTag: 'en',
      sectionIds: <String>['chart'],
    );

    expect(
      (await dismissedService.share(request: request, fileName: 'report.pdf')).status,
      ProfessionalPdfDeliveryStatus.cancelled,
    );

    final unavailable = _FakePdfGateway(shareStatus: PdfShareStatus.unavailable);
    final unavailableService = ProfessionalPdfDeliveryService<String>(
      applicationService: _applicationService(),
      platformGateway: unavailable,
    );
    expect(
      (await unavailableService.share(request: request, fileName: 'report.pdf')).status,
      ProfessionalPdfDeliveryStatus.unavailable,
    );
  });
}

ProfessionalPdfApplicationService<String> _applicationService() {
  final entitlementService = PolicyEntitlementService(
    snapshotProvider: const _ProSnapshotProvider(),
    clock: const _FixedClock(),
  );
  return ProfessionalPdfApplicationService<String>(
    snapshotSource: const _SnapshotSource(),
    pdfService: GuardedProfessionalPdfService<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlementService),
      delegate: const _PdfService(),
    ),
  );
}

final class _SnapshotSource implements ProfessionalPdfSnapshotSource<String> {
  const _SnapshotSource();
  @override
  Future<String?> loadByRecordId(String recordId) async =>
      recordId == 'calc-1' ? 'snapshot-1' : null;
}

final class _PdfService implements PdfService<String> {
  const _PdfService();
  @override
  Future<List<int>> buildReport({
    required String snapshot,
    required PdfReportOptions options,
  }) async {
    final padding = List<String>.filled(80, 'x').join();
    return latin1.encode(
      '%PDF-1.7\n'
      '1 0 obj << /Type /Catalog >> endobj\n'
      '2 0 obj << /Type /Pages /Count 1 >> endobj\n'
      '3 0 obj << /Type /Page /Parent 2 0 R >> endobj\n'
      '$padding\n%%EOF\n',
    );
  }
}

final class _FakePdfGateway implements PdfPlatformGateway {
  _FakePdfGateway({
    this.saveUri,
    this.shareStatus = PdfShareStatus.success,
  });

  final Uri? saveUri;
  final PdfShareStatus shareStatus;
  List<int> savedBytes = const <int>[];

  @override
  Future<Uri?> savePdf({
    required String suggestedFileName,
    required List<int> bytes,
  }) async {
    savedBytes = List<int>.from(bytes);
    return saveUri;
  }

  @override
  Future<PdfShareStatus> sharePdf({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  }) async => shareStatus;
}

final class _ProSnapshotProvider implements EntitlementSnapshotProvider {
  const _ProSnapshotProvider();
  @override
  Future<EntitlementSnapshot> load() async => const EntitlementSnapshot(hasPro: true);
}

final class _FixedClock implements EntitlementClock {
  const _FixedClock();
  @override
  Future<DateTime> nowUtc() async => DateTime.utc(2026, 8, 22);
}
