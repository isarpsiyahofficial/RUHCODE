import '../../calculation_core/numerology/pythagorean_snapshot.dart';
import '../../calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';

/// Locale-neutral UI row. [metricId] is localized by the presentation layer;
/// calculation values never depend on interface language.
final class NumerologyPresentationRow {
  const NumerologyPresentationRow({required this.metricId, required this.value});

  final String metricId;
  final String value;
}

final class NumerologyPresentationSection {
  const NumerologyPresentationSection({required this.sectionId, required this.rows});

  final String sectionId;
  final List<NumerologyPresentationRow> rows;
}

final class NumerologyPresentationModel {
  const NumerologyPresentationModel({
    required this.snapshotDigest,
    required this.birthDateIso,
    required this.targetDateIso,
    required this.sections,
  });

  final String snapshotDigest;
  final String birthDateIso;
  final String? targetDateIso;
  final List<NumerologyPresentationSection> sections;

  Iterable<NumerologyPresentationRow> get allRows sync* {
    for (final section in sections) {
      yield* section.rows;
    }
  }
}

/// Projects the canonical calculation snapshot into deterministic UI data.
/// It deliberately does not calculate numerology and does not contain TR/EN
/// labels. Labels belong to localization; values belong to the snapshot.
abstract final class NumerologyPresentationAdapter {
  static const String schemaVersion = 'numerology-ui-presentation-v1';

  static NumerologyPresentationModel fromSnapshot(
    PythagoreanNumerologySnapshot snapshot,
  ) {
    final profile = snapshot.profile;
    final extended = snapshot.extendedName;
    final cycles = snapshot.personalCycles;

    final sections = <NumerologyPresentationSection>[
      NumerologyPresentationSection(
        sectionId: 'core',
        rows: <NumerologyPresentationRow>[
          NumerologyPresentationRow(metricId: 'life_path', value: '${profile.lifePath}'),
          NumerologyPresentationRow(metricId: 'expression', value: '${profile.expression}'),
          NumerologyPresentationRow(metricId: 'soul_urge', value: '${profile.soulUrge}'),
          NumerologyPresentationRow(metricId: 'personality', value: '${profile.personality}'),
          NumerologyPresentationRow(metricId: 'birthday', value: '${profile.birthday}'),
          NumerologyPresentationRow(metricId: 'maturity', value: '${profile.maturity}'),
        ],
      ),
      NumerologyPresentationSection(
        sectionId: 'name_analysis',
        rows: <NumerologyPresentationRow>[
          NumerologyPresentationRow(metricId: 'balance', value: '${extended.balance}'),
          NumerologyPresentationRow(
            metricId: 'karmic_lessons',
            value: extended.karmicLessons.join(','),
          ),
          NumerologyPresentationRow(
            metricId: 'hidden_passions',
            value: extended.hiddenPassions.join(','),
          ),
        ],
      ),
      NumerologyPresentationSection(
        sectionId: 'periods',
        rows: <NumerologyPresentationRow>[
          NumerologyPresentationRow(
            metricId: 'pinnacles',
            value: snapshot.pinnaclesChallenges.pinnacles.join(','),
          ),
          NumerologyPresentationRow(
            metricId: 'challenges',
            value: snapshot.pinnaclesChallenges.challenges.join(','),
          ),
        ],
      ),
      if (cycles != null)
        NumerologyPresentationSection(
          sectionId: 'personal_cycles',
          rows: <NumerologyPresentationRow>[
            NumerologyPresentationRow(metricId: 'personal_year', value: '${cycles.personalYear}'),
            NumerologyPresentationRow(metricId: 'personal_month', value: '${cycles.personalMonth}'),
            NumerologyPresentationRow(metricId: 'personal_day', value: '${cycles.personalDay}'),
          ],
        ),
    ];

    final metricIds = <String>{};
    for (final section in sections) {
      if (section.sectionId.trim().isEmpty) {
        throw StateError('Numerology UI section ID cannot be blank.');
      }
      for (final row in section.rows) {
        if (row.metricId.trim().isEmpty || !metricIds.add(row.metricId)) {
          throw StateError('Numerology UI metric IDs must be non-blank and unique.');
        }
      }
    }

    return NumerologyPresentationModel(
      snapshotDigest: PythagoreanSnapshotFingerprint.sha256Hex(snapshot),
      birthDateIso: snapshot.birthDate.isoKey,
      targetDateIso: snapshot.targetDate?.isoKey,
      sections: List<NumerologyPresentationSection>.unmodifiable(
        sections.map(
          (section) => NumerologyPresentationSection(
            sectionId: section.sectionId,
            rows: List<NumerologyPresentationRow>.unmodifiable(section.rows),
          ),
        ),
      ),
    );
  }
}
