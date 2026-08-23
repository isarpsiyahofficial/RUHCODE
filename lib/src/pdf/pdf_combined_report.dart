import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'pdf_cover_section.dart';
import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_local_service.dart';
import 'pdf_report_contract.dart';
import 'pdf_service.dart';

/// One already-validated calculation system projection that may participate in
/// a combined professional report.
///
/// The member keeps its original snapshot identity. [PdfCombinedReportBuilder]
/// validates all members belong to the same stable subject, verifies every
/// supplied render section belongs to that member digest, then derives one
/// deterministic composite digest. No child calculation is recomputed here.
final class PdfCombinedMember {
  const PdfCombinedMember({
    required this.systemId,
    required this.identity,
    required this.sections,
  });

  final String systemId;
  final PdfSnapshotIdentity identity;
  final List<PdfRenderSection> sections;
}

final class PdfCombinedReportProjection {
  const PdfCombinedReportProjection({
    required this.dataset,
    required this.sections,
    required this.memberSystemIds,
  });

  final PdfReportDataset dataset;
  final List<PdfRenderSection> sections;
  final List<String> memberSystemIds;
}

/// Strict composition layer for true multi-system professional reports.
///
/// Rules:
/// - at least two distinct systems are required;
/// - all child snapshots must belong to the same subject kind + stable ID;
/// - child snapshot digests remain independently validated and are never
///   replaced or reinterpreted as another system;
/// - child systems may not claim the same content section ID;
/// - a single deterministic composite SHA-256 identifies the exact ordered set
///   of child snapshot identities used by the report;
/// - cover and technical-manifest sections are created once at the combined
///   level, preventing duplicate or ambiguous report sections.
final class PdfCombinedReportBuilder {
  const PdfCombinedReportBuilder();

  PdfCombinedReportProjection build({
    required Iterable<PdfCombinedMember> members,
    required String coverTitle,
    required String technicalTitle,
    required String systemHeader,
    required String fieldHeader,
    required String valueHeader,
  }) {
    final normalized = members.toList(growable: false)
      ..sort((a, b) => a.systemId.compareTo(b.systemId));
    if (normalized.length < 2) {
      throw const FormatException(
        'Combined PDF requires at least two calculation systems.',
      );
    }
    if (coverTitle.trim().isEmpty ||
        technicalTitle.trim().isEmpty ||
        systemHeader.trim().isEmpty ||
        fieldHeader.trim().isEmpty ||
        valueHeader.trim().isEmpty) {
      throw const FormatException('Combined PDF labels must not be blank.');
    }

    final systemIds = <String>{};
    PdfSnapshotIdentity? firstIdentity;
    final childSectionIds = <String>{};

    for (final member in normalized) {
      final systemId = member.systemId.trim();
      if (systemId.isEmpty) {
        throw const FormatException('Combined PDF system ID cannot be blank.');
      }
      if (!systemIds.add(systemId)) {
        throw FormatException('Duplicate combined PDF system: $systemId');
      }
      member.identity.validate();
      final first = firstIdentity;
      if (first == null) {
        firstIdentity = member.identity;
      } else if (first.subjectKind != member.identity.subjectKind ||
          first.subjectId != member.identity.subjectId) {
        throw const FormatException(
          'Combined PDF members must belong to the same subject.',
        );
      }

      if (member.sections.isEmpty) {
        throw FormatException('Combined PDF member $systemId has no sections.');
      }
      for (final section in member.sections) {
        if (!PdfSectionIds.all.contains(section.sectionId)) {
          throw FormatException(
            'Combined PDF member $systemId uses unknown section ${section.sectionId}.',
          );
        }
        if (section.sectionId == PdfSectionIds.cover ||
            section.sectionId == PdfSectionIds.technicalManifest) {
          throw FormatException(
            'Combined PDF child $systemId cannot provide shared section ${section.sectionId}.',
          );
        }
        if (section.snapshotDigest != member.identity.snapshotDigest) {
          throw FormatException(
            'Combined PDF section ${section.sectionId} does not belong to $systemId snapshot.',
          );
        }
        if (!section.hasContent) {
          throw FormatException(
            'Combined PDF section ${section.sectionId} for $systemId is empty.',
          );
        }
        if (!childSectionIds.add(section.sectionId)) {
          throw FormatException(
            'Combined PDF systems collide on section ${section.sectionId}.',
          );
        }
      }
    }

    final identity = _combinedIdentity(normalized, firstIdentity!);
    final digest = identity.snapshotDigest;
    final renderSections = <PdfRenderSection>[
      PdfCoverSectionAdapter.build(
        snapshotDigest: digest,
        title: coverTitle.trim(),
      ),
      for (final member in normalized)
        for (final section in member.sections)
          PdfRenderSection(
            sectionId: section.sectionId,
            snapshotDigest: digest,
            title: section.title,
            paragraphs: List<String>.unmodifiable(section.paragraphs),
            rows: List<List<String>>.unmodifiable(
              section.rows.map((row) => List<String>.unmodifiable(row)),
            ),
          ),
      PdfRenderSection(
        sectionId: PdfSectionIds.technicalManifest,
        snapshotDigest: digest,
        title: technicalTitle.trim(),
        paragraphs: const <String>[],
        rows: <List<String>>[
          <String>[systemHeader.trim(), fieldHeader.trim(), valueHeader.trim()],
          for (final member in normalized) ...<List<String>>[
            <String>[
              member.systemId,
              'snapshotSha256',
              member.identity.snapshotDigest,
            ],
            <String>[
              member.systemId,
              'engineVersion',
              member.identity.engineVersion,
            ],
            <String>[
              member.systemId,
              'algorithmVersion',
              member.identity.algorithmVersion,
            ],
            <String>[
              member.systemId,
              'dataVersion',
              member.identity.dataVersion,
            ],
            if (member.identity.calculationManifestId != null)
              <String>[
                member.systemId,
                'calculationManifestId',
                member.identity.calculationManifestId!,
              ],
          ],
        ],
      ),
    ];

    final refs = <PdfSectionDataRef>[
      PdfCoverSectionAdapter.dataRef(snapshotDigest: digest),
      for (final sectionId in childSectionIds)
        PdfSectionDataRef(
          sectionId: sectionId,
          snapshotDigest: digest,
          hasContent: true,
        ),
      PdfSectionDataRef(
        sectionId: PdfSectionIds.technicalManifest,
        snapshotDigest: digest,
        hasContent: true,
      ),
    ];

    return PdfCombinedReportProjection(
      dataset: PdfReportDataset(
        origin: PdfDataOrigin.user,
        identity: identity,
        sections: List<PdfSectionDataRef>.unmodifiable(refs),
      ),
      sections: List<PdfRenderSection>.unmodifiable(renderSections),
      memberSystemIds: List<String>.unmodifiable(
        normalized.map((member) => member.systemId),
      ),
    );
  }

  PdfSnapshotIdentity _combinedIdentity(
    List<PdfCombinedMember> members,
    PdfSnapshotIdentity subject,
  ) {
    final canonical = jsonEncode(<String, Object?>{
      'schema': 'ruhcode.pdf.combined.identity.v1',
      'subjectKind': subject.subjectKind.name,
      'subjectId': subject.subjectId,
      'members': <Object?>[
        for (final member in members)
          <String, Object?>{
            'systemId': member.systemId,
            'snapshotSha256': member.identity.snapshotDigest,
            'engineVersion': member.identity.engineVersion,
            'algorithmVersion': member.identity.algorithmVersion,
            'dataVersion': member.identity.dataVersion,
            'calculationManifestId': member.identity.calculationManifestId,
          },
      ],
    });
    final digest = sha256.convert(utf8.encode(canonical)).toString();
    return PdfSnapshotIdentity(
      subjectKind: subject.subjectKind,
      subjectId: subject.subjectId,
      snapshotDigest: digest,
      engineVersion: 'ruhcode.pdf.combined',
      algorithmVersion: 'combined.v1',
      dataVersion: 'members-sha256.v1',
    );
  }
}

final class PdfCombinedReportContentAdapter
    implements PdfReportContentAdapter<PdfCombinedReportProjection> {
  const PdfCombinedReportContentAdapter({required this.localeTag});

  final String localeTag;

  @override
  PdfReportKind get reportKind => PdfReportKind.combined;

  @override
  PdfDataOrigin get dataOrigin => PdfDataOrigin.user;

  @override
  PdfCoverStyle get coverStyle => PdfCoverStyle.professional;

  @override
  String documentTitle(PdfCombinedReportProjection snapshot, String locale) {
    _requireLocale(locale);
    if (locale != localeTag) {
      throw const StateError('Combined PDF locale drift detected.');
    }
    return locale == 'tr'
        ? 'Kombine Danışmanlık Raporu'
        : 'Combined Consultation Report';
  }

  @override
  PdfReportDataset dataset(PdfCombinedReportProjection snapshot) =>
      snapshot.dataset;

  @override
  List<PdfRenderSection> sections(PdfCombinedReportProjection snapshot) =>
      snapshot.sections;

  static void _requireLocale(String locale) {
    if (locale != 'tr' && locale != 'en') {
      throw FormatException('Unsupported combined PDF locale: $locale');
    }
  }
}

final class PdfCombinedReportService
    implements PdfService<PdfCombinedReportProjection> {
  const PdfCombinedReportService({required this.fontProvider});

  final PdfFontBundleProvider fontProvider;

  @override
  Future<List<int>> buildReport({
    required PdfCombinedReportProjection snapshot,
    required PdfReportOptions options,
  }) {
    return PdfLocalReportService<PdfCombinedReportProjection>(
      adapter: PdfCombinedReportContentAdapter(localeTag: options.localeTag),
      fontProvider: fontProvider,
    ).buildReport(snapshot: snapshot, options: options);
  }
}
