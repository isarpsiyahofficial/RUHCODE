import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/pdf/guarded_pdf_service.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';

void main() {
  test('Free entitlement cannot execute professional PDF delegate', () async {
    final entitlements = _StaticEntitlementService(false);
    final delegate = _RecordingPdfService();
    final service = GuardedProfessionalPdfService<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      delegate: delegate,
    );

    await expectLater(
      service.buildReport(
        snapshot: 'snapshot-a',
        options: const PdfReportOptions(
          localeTag: 'tr',
          sectionIds: <String>['summary'],
        ),
      ),
      throwsA(isA<FeatureAccessDeniedException>()),
    );

    expect(delegate.calls, 0);
    expect(entitlements.calls, <String>[RuhFeatureIds.pdfProfessionalExport]);
  });

  test('PRO entitlement executes professional PDF delegate exactly once', () async {
    final entitlements = _StaticEntitlementService(true);
    final delegate = _RecordingPdfService();
    final service = GuardedProfessionalPdfService<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      delegate: delegate,
    );

    final bytes = await service.buildReport(
      snapshot: 'snapshot-a',
      options: const PdfReportOptions(
        localeTag: 'en',
        sectionIds: <String>['summary'],
      ),
    );

    expect(bytes, <int>[1, 2, 3]);
    expect(delegate.calls, 1);
    expect(delegate.lastSnapshot, 'snapshot-a');
    expect(entitlements.calls, <String>[RuhFeatureIds.pdfProfessionalExport]);
  });
}

final class _RecordingPdfService implements PdfService<String> {
  int calls = 0;
  String? lastSnapshot;

  @override
  Future<List<int>> buildReport({
    required String snapshot,
    required PdfReportOptions options,
  }) async {
    calls += 1;
    lastSnapshot = snapshot;
    return <int>[1, 2, 3];
  }
}

final class _StaticEntitlementService implements EntitlementService {
  _StaticEntitlementService(this.allowed);

  final bool allowed;
  final List<String> calls = <String>[];

  @override
  Future<bool> canUse(String featureId) async {
    calls.add(featureId);
    return allowed;
  }

  @override
  Future<FeatureEntitlement> resolve(String featureId) async {
    return FeatureEntitlement(
      featureId: featureId,
      tier: allowed ? EntitlementTier.pro : EntitlementTier.free,
    );
  }
}
