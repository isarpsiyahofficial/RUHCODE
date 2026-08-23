import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/pdf_combined_report.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';
import 'package:ruh_code/src/pdf/persisted_combined_pdf_projection.dart';

void main() {
  test('loads multiple persisted records and seals one deterministic projection', () async {
    final source = _FakeSource(<String, PersistedCalculationPdfSnapshot>{
      'western': _snapshot('western', 'subject-1', 'fake.western'),
      'numbers': _snapshot('numbers', 'subject-1', 'fake.numerology'),
    });
    final bridge = PersistedCombinedPdfProjectionSource(
      snapshotSource: source,
      projectors: const <PersistedCombinedPdfMemberProjector>[
        _FakeProjector('fake.western', 'western', PdfSectionIds.placements),
        _FakeProjector('fake.numerology', 'numerology', PdfSectionIds.numerology),
      ],
    );

    final result = await bridge.load(
      recordIds: const <String>['numbers', 'western'],
      localeTag: 'tr-TR',
    );

    expect(result.memberSystemIds, <String>['numerology', 'western']);
    expect(result.dataset.identity.subjectId, 'subject-1');
    expect(result.dataset.identity.snapshotDigest, hasLength(64));
    expect(result.sections.first.sectionId, PdfSectionIds.cover);
    expect(result.sections.last.sectionId, PdfSectionIds.technicalManifest);
  });

  test('rejects records that belong to different subjects before composition', () async {
    final source = _FakeSource(<String, PersistedCalculationPdfSnapshot>{
      'a': _snapshot('a', 'subject-a', 'fake.a'),
      'b': _snapshot('b', 'subject-b', 'fake.b'),
    });
    final bridge = PersistedCombinedPdfProjectionSource(
      snapshotSource: source,
      projectors: const <PersistedCombinedPdfMemberProjector>[
        _FakeProjector('fake.a', 'a', PdfSectionIds.placements),
        _FakeProjector('fake.b', 'b', PdfSectionIds.numerology),
      ],
    );

    await expectLater(
      bridge.load(recordIds: const <String>['a', 'b'], localeTag: 'en'),
      throwsFormatException,
    );
  });

  test('rejects duplicate record IDs and unsupported locale', () async {
    final source = _FakeSource(<String, PersistedCalculationPdfSnapshot>{
      'a': _snapshot('a', 'subject-a', 'fake.a'),
    });
    final bridge = PersistedCombinedPdfProjectionSource(
      snapshotSource: source,
      projectors: const <PersistedCombinedPdfMemberProjector>[
        _FakeProjector('fake.a', 'a', PdfSectionIds.placements),
      ],
    );

    await expectLater(
      bridge.load(recordIds: const <String>['a', 'a'], localeTag: 'tr'),
      throwsFormatException,
    );
    await expectLater(
      bridge.load(recordIds: const <String>['a', 'missing'], localeTag: 'de'),
      throwsFormatException,
    );
  });
}

final class _FakeSource
    implements ProfessionalPdfSnapshotSource<PersistedCalculationPdfSnapshot> {
  const _FakeSource(this.snapshots);

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
    final digest = systemId == 'a'
        ? 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        : systemId == 'b'
            ? 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
            : systemId == 'western'
                ? 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'
                : 'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';
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

PersistedCalculationPdfSnapshot _snapshot(
  String recordId,
  String owner,
  String calculationType,
) {
  final manifest = CalculationManifest(
    id: EntityId.parse('11111111-1111-4111-8111-111111111111'),
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
    payload: const <String, Object?>{},
    createdAtUtc: DateTime.utc(2026, 8, 24),
    manifest: manifest,
  );
}
