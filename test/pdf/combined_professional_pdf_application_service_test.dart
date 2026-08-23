import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/pdf/combined_professional_pdf_application_service.dart';
import 'package:ruh_code/src/pdf/pdf_combined_report.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';
import 'package:ruh_code/src/pdf/persisted_combined_pdf_projection.dart';

void main() {
  test('preview and build preserve exact persisted record/locale/section set', () async {
    final source = _FakeSource(<String, PersistedCalculationPdfSnapshot>{
      'a': _snapshot('a', 'subject-1', 'fake.a', 'a' * 64),
      'b': _snapshot('b', 'subject-1', 'fake.b', 'b' * 64),
    });
    final projection = PersistedCombinedPdfProjectionSource(
      snapshotSource: source,
      projectors: const <PersistedCombinedPdfMemberProjector>[
        _FakeProjector('fake.a', 'system.a', PdfSectionIds.placements),
        _FakeProjector('fake.b', 'system.b', PdfSectionIds.numerology),
      ],
    );
    final delegate = _CapturingPdfService();
    final service = CombinedProfessionalPdfApplicationService(
      featureAccess: FeatureAccessGuard(entitlements: const _AllowEntitlements()),
      recordCatalog: const _EmptyCatalog(),
      snapshotSource: source,
      projectionSource: projection,
      pdfService: delegate,
    );

    final preview = await service.preview(
      recordIds: const <String>['a', 'b'],
      localeTag: 'tr-TR',
      requestedSectionIds: const <String>[
        PdfSectionIds.placements,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
    );

    expect(preview.recordIds, <String>['a', 'b']);
    expect(preview.localeTag, 'tr');
    expect(preview.subjectId, 'subject-1');
    expect(preview.sectionIds.first, PdfSectionIds.cover);
    expect(preview.sectionIds.last, PdfSectionIds.technicalManifest);

    final bytes = await service.buildFromPreview(preview: preview);
    expect(bytes, <int>[1, 2, 3]);
    expect(delegate.lastOptions!.localeTag, preview.localeTag);
    expect(delegate.lastOptions!.sectionIds, preview.sectionIds);
    expect(delegate.lastSnapshot!.dataset.identity.snapshotDigest,
        preview.compositeSnapshotDigest);
  });

  test('build rejects persisted digest drift after preview', () async {
    final source = _FakeSource(<String, PersistedCalculationPdfSnapshot>{
      'a': _snapshot('a', 'subject-1', 'fake.a', 'a' * 64),
      'b': _snapshot('b', 'subject-1', 'fake.b', 'b' * 64),
    });
    final service = CombinedProfessionalPdfApplicationService(
      featureAccess: FeatureAccessGuard(entitlements: const _AllowEntitlements()),
      recordCatalog: const _EmptyCatalog(),
      snapshotSource: source,
      projectionSource: PersistedCombinedPdfProjectionSource(
        snapshotSource: source,
        projectors: const <PersistedCombinedPdfMemberProjector>[
          _FakeProjector('fake.a', 'system.a', PdfSectionIds.placements),
          _FakeProjector('fake.b', 'system.b', PdfSectionIds.numerology),
        ],
      ),
      pdfService: _CapturingPdfService(),
    );

    final preview = await service.preview(
      recordIds: const <String>['a', 'b'],
      localeTag: 'en',
      requestedSectionIds: const <String>[
        PdfSectionIds.placements,
        PdfSectionIds.numerology,
      ],
    );

    source.snapshots['b'] = _snapshot('b', 'subject-1', 'fake.b', 'c' * 64);
    await expectLater(
      service.buildFromPreview(preview: preview),
      throwsStateError,
    );
  });

  test('PRO guard blocks preview before persisted projection is used', () async {
    final source = _FakeSource(const <String, PersistedCalculationPdfSnapshot>{});
    final service = CombinedProfessionalPdfApplicationService(
      featureAccess: FeatureAccessGuard(entitlements: const _DenyEntitlements()),
      recordCatalog: const _EmptyCatalog(),
      snapshotSource: source,
      projectionSource: PersistedCombinedPdfProjectionSource(
        snapshotSource: source,
        projectors: const <PersistedCombinedPdfMemberProjector>[],
      ),
      pdfService: _CapturingPdfService(),
    );

    await expectLater(
      service.preview(
        recordIds: const <String>['a', 'b'],
        localeTag: 'tr',
        requestedSectionIds: const <String>[PdfSectionIds.placements],
      ),
      throwsA(isA<FeatureAccessDeniedException>()),
    );
  });
}

final class _FakeSource
    implements ProfessionalPdfSnapshotSource<PersistedCalculationPdfSnapshot> {
  _FakeSource(this.snapshots);
  final Map<String, PersistedCalculationPdfSnapshot> snapshots;

  @override
  Future<PersistedCalculationPdfSnapshot?> loadByRecordId(String recordId) async =>
      snapshots[recordId];
}

final class _FakeProjector implements PersistedCombinedPdfMemberProjector {
  const _FakeProjector(this.calculationType, this.systemId, this.sectionId);
  @override
  final String calculationType;
  @override
  final String systemId;
  final String sectionId;

  @override
  PdfCombinedMember project({
    required PersistedCalculationPdfSnapshot snapshot,
    required String localeTag,
  }) {
    final digest = snapshot.payload['digest']! as String;
    return PdfCombinedMember(
      systemId: systemId,
      identity: PdfSnapshotIdentity(
        subjectKind: PdfSubjectKind.profile,
        subjectId: snapshot.ownerEntityId,
        snapshotDigest: digest,
        engineVersion: snapshot.manifest.engineVersion,
        algorithmVersion: snapshot.manifest.algorithmVersion,
        dataVersion: snapshot.manifest.dataVersion,
        calculationManifestId: snapshot.manifest.id.value,
      ),
      sections: <PdfRenderSection>[
        PdfRenderSection(
          sectionId: sectionId,
          snapshotDigest: digest,
          title: '$localeTag $systemId',
          paragraphs: const <String>['content'],
          rows: const <List<String>>[],
        ),
      ],
    );
  }
}

final class _CapturingPdfService implements PdfService<PdfCombinedReportProjection> {
  PdfCombinedReportProjection? lastSnapshot;
  PdfReportOptions? lastOptions;

  @override
  Future<List<int>> buildReport({
    required PdfCombinedReportProjection snapshot,
    required PdfReportOptions options,
  }) async {
    lastSnapshot = snapshot;
    lastOptions = options;
    return <int>[1, 2, 3];
  }
}

final class _EmptyCatalog implements ProfessionalPdfRecordCatalog {
  const _EmptyCatalog();
  @override
  Future<List<PersistedCalculationPdfSummary>> listAvailableRecords() async =>
      const <PersistedCalculationPdfSummary>[];
}

final class _AllowEntitlements implements EntitlementService {
  const _AllowEntitlements();
  @override
  Future<bool> canUse(String featureId) async => true;
  @override
  Future<FeatureEntitlement> resolve(String featureId) =>
      throw UnimplementedError();
}

final class _DenyEntitlements implements EntitlementService {
  const _DenyEntitlements();
  @override
  Future<bool> canUse(String featureId) async => false;
  @override
  Future<FeatureEntitlement> resolve(String featureId) =>
      throw UnimplementedError();
}

PersistedCalculationPdfSnapshot _snapshot(
  String recordId,
  String owner,
  String calculationType,
  String digest,
) {
  final manifest = CalculationManifest(
    id: EntityId.parse(recordId == 'a'
        ? '11111111-1111-4111-8111-111111111111'
        : '22222222-2222-4222-8222-222222222222'),
    engineId: calculationType,
    engineVersion: '1.0.0',
    algorithmVersion: '1.0.0',
    dataVersion: 'fixture-v1',
    localDateTime: DateTime.utc(2026, 8, 24),
    utcDateTime: DateTime.utc(2026, 8, 24),
    location: const LocationRecord(
      label: 'Fixture',
      countryCode: 'TR',
      latitude: 0,
      longitude: 0,
      ianaTimeZoneId: 'Etc/UTC',
    ),
    validity: CalculationValidity.valid,
  );
  return PersistedCalculationPdfSnapshot(
    recordId: recordId,
    ownerEntityId: owner,
    calculationType: calculationType,
    payload: <String, Object?>{'digest': digest},
    createdAtUtc: DateTime.utc(2026, 8, 24),
    manifest: manifest,
  );
}
