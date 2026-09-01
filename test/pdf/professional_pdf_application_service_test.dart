import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/pdf/guarded_pdf_service.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';
import 'package:ruh_code/src/pdf/professional_pdf_application_service.dart';

void main() {
  test('FREE user cannot execute professional PDF delegate', () async {
    final delegate = _RecordingPdfService();
    final service = _buildService(hasPro: false, delegate: delegate);

    await expectLater(
      service.build(
        const ProfessionalPdfBuildRequest(
          recordId: 'calc-1',
          localeTag: 'tr-TR',
          sectionIds: ['chart'],
        ),
      ),
      throwsA(isA<FeatureAccessDeniedException>()),
    );
    expect(delegate.calls, 0);
  });

  test('PRO build loads exact record, preserves section order and inspects PDF', () async {
    final delegate = _RecordingPdfService();
    final source = _SnapshotSource({'calc-1': 'snapshot-1'});
    final entitlements = PolicyEntitlementService(
      snapshotProvider: _StaticSnapshotProvider(hasPro: true),
      clock: const _FixedClock(),
    );
    final service = ProfessionalPdfApplicationService<String>(
      snapshotSource: source,
      pdfService: GuardedProfessionalPdfService<String>(
        featureAccess: FeatureAccessGuard(entitlements: entitlements),
        delegate: delegate,
      ),
    );

    final result = await service.build(
      const ProfessionalPdfBuildRequest(
        recordId: ' calc-1 ',
        localeTag: 'en-US',
        sectionIds: ['chart', 'placements', 'notes'],
        professionalName: 'Ada',
        brandName: 'Ruh Code Studio',
      ),
    );

    expect(source.requestedIds, ['calc-1']);
    expect(delegate.calls, 1);
    expect(delegate.lastSnapshot, 'snapshot-1');
    expect(delegate.lastOptions!.sectionIds, ['chart', 'placements', 'notes']);
    expect(delegate.lastOptions!.localeTag, 'en-US');
    expect(result.recordId, 'calc-1');
    expect(result.sectionIds, ['chart', 'placements', 'notes']);
    expect(result.inspection.structurallyUsable, isTrue);
  });

  test('missing record, duplicate sections and unsupported locale fail closed', () async {
    final delegate = _RecordingPdfService();
    final service = _buildService(hasPro: true, delegate: delegate, snapshots: const {});

    await expectLater(
      service.build(
        const ProfessionalPdfBuildRequest(
          recordId: 'missing',
          localeTag: 'tr',
          sectionIds: ['chart'],
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      service.build(
        const ProfessionalPdfBuildRequest(
          recordId: 'calc-1',
          localeTag: 'de-DE',
          sectionIds: ['chart'],
        ),
      ),
      throwsFormatException,
    );
    await expectLater(
      service.build(
        const ProfessionalPdfBuildRequest(
          recordId: 'calc-1',
          localeTag: 'tr',
          sectionIds: ['chart', 'chart'],
        ),
      ),
      throwsFormatException,
    );
    expect(delegate.calls, 0);
  });
}

ProfessionalPdfApplicationService<String> _buildService({
  required bool hasPro,
  required _RecordingPdfService delegate,
  Map<String, String> snapshots = const {'calc-1': 'snapshot-1'},
}) {
  final entitlements = PolicyEntitlementService(
    snapshotProvider: _StaticSnapshotProvider(hasPro: hasPro),
    clock: const _FixedClock(),
  );
  return ProfessionalPdfApplicationService<String>(
    snapshotSource: _SnapshotSource(snapshots),
    pdfService: GuardedProfessionalPdfService<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      delegate: delegate,
    ),
  );
}

final class _SnapshotSource implements ProfessionalPdfSnapshotSource<String> {
  _SnapshotSource(this.snapshots);

  final Map<String, String> snapshots;
  final requestedIds = <String>[];

  @override
  Future<String?> loadByRecordId(String recordId) async {
    requestedIds.add(recordId);
    return snapshots[recordId];
  }
}

final class _RecordingPdfService implements PdfService<String> {
  int calls = 0;
  String? lastSnapshot;
  PdfReportOptions? lastOptions;

  @override
  Future<List<int>> buildReport({
    required String snapshot,
    required PdfReportOptions options,
  }) async {
    calls += 1;
    lastSnapshot = snapshot;
    lastOptions = options;
    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => pw.Text('Ruh Code test report'),
      ),
    );
    return document.save();
  }
}

final class _StaticSnapshotProvider implements EntitlementSnapshotProvider {
  const _StaticSnapshotProvider({required this.hasPro});

  final bool hasPro;

  @override
  Future<EntitlementSnapshot> load() async => EntitlementSnapshot(hasPro: hasPro);
}

final class _FixedClock implements EntitlementClock {
  const _FixedClock();

  @override
  Future<DateTime> nowUtc() async => DateTime.utc(2026, 8, 22, 0, 0);
}
