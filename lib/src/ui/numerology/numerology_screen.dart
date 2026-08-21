import 'package:flutter/material.dart';

import 'numerology_presentation.dart';

/// Functional, deliberately neutral numerology surface.
///
/// Final visual styling remains governed by the approved UI-reference contract.
/// This widget only binds the canonical presentation model to a real screen and
/// never recalculates numerology values.
class NumerologyScreen extends StatelessWidget {
  const NumerologyScreen({
    super.key,
    required this.model,
    this.locale = const Locale('tr'),
  });

  final NumerologyPresentationModel? model;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final copy = NumerologyScreenCopy.forLocale(locale);
    final presentation = model;

    return Scaffold(
      appBar: AppBar(title: Text(copy.title)),
      body: presentation == null
          ? _NumerologyEmptyState(copy: copy)
          : ListView(
              key: const Key('numerology-result-list'),
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                Text(
                  copy.resultTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  copy.dateSummary(
                    presentation.birthDateIso,
                    presentation.targetDateIso,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                for (final section in presentation.sections)
                  _NumerologySectionCard(
                    section: section,
                    copy: copy,
                  ),
              ],
            ),
    );
  }
}

class _NumerologyEmptyState extends StatelessWidget {
  const _NumerologyEmptyState({required this.copy});

  final NumerologyScreenCopy copy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.pin_outlined, size: 44),
            const SizedBox(height: 16),
            Text(
              copy.emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              copy.emptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumerologySectionCard extends StatelessWidget {
  const _NumerologySectionCard({
    required this.section,
    required this.copy,
  });

  final NumerologyPresentationSection section;
  final NumerologyScreenCopy copy;

  @override
  Widget build(BuildContext context) {
    final sectionLabel = copy.sectionLabel(section.sectionId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              sectionLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < section.rows.length; index++) ...<Widget>[
              _NumerologyMetricRow(
                row: section.rows[index],
                label: copy.metricLabel(section.rows[index].metricId),
              ),
              if (index != section.rows.length - 1) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumerologyMetricRow extends StatelessWidget {
  const _NumerologyMetricRow({required this.row, required this.label});

  final NumerologyPresentationRow row;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Semantics(
          label: '$label: ${row.value}',
          child: Text(
            row.value,
            key: Key('numerology-metric-${row.metricId}'),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

/// Small explicit TR/EN copy contract for this first functional surface.
/// It intentionally fails closed for unknown metric/section IDs so calculation
/// additions cannot silently leak raw technical IDs into the UI.
final class NumerologyScreenCopy {
  const NumerologyScreenCopy._({
    required this.title,
    required this.resultTitle,
    required this.emptyTitle,
    required this.emptyBody,
    required this._sections,
    required this._metrics,
    required this._birthDateLabel,
    required this._targetDateLabel,
  });

  final String title;
  final String resultTitle;
  final String emptyTitle;
  final String emptyBody;
  final Map<String, String> _sections;
  final Map<String, String> _metrics;
  final String _birthDateLabel;
  final String _targetDateLabel;

  static NumerologyScreenCopy forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return _tr;
      case 'en':
        return _en;
      default:
        throw UnsupportedError(
          'Numerology screen supports only tr/en in v1; got ${locale.languageCode}.',
        );
    }
  }

  String sectionLabel(String sectionId) {
    final value = _sections[sectionId];
    if (value == null) {
      throw StateError('Missing localized numerology section: $sectionId');
    }
    return value;
  }

  String metricLabel(String metricId) {
    final value = _metrics[metricId];
    if (value == null) {
      throw StateError('Missing localized numerology metric: $metricId');
    }
    return value;
  }

  String dateSummary(String birthDateIso, String? targetDateIso) {
    if (targetDateIso == null) {
      return '$_birthDateLabel: $birthDateIso';
    }
    return '$_birthDateLabel: $birthDateIso  •  $_targetDateLabel: $targetDateIso';
  }

  static const _tr = NumerologyScreenCopy._(
    title: 'Numeroloji',
    resultTitle: 'Numeroloji Sonuçları',
    emptyTitle: 'Henüz hesaplama yok',
    emptyBody: 'Bir profil seçip numeroloji hesaplaması yaptığında sonuçların burada görünür.',
    birthDateLabel: 'Doğum tarihi',
    targetDateLabel: 'Hedef tarih',
    sections: <String, String>{
      'core': 'Temel Sayılar',
      'name_analysis': 'İsim Analizi',
      'periods': 'Dönemler',
      'personal_cycles': 'Kişisel Döngüler',
    },
    metrics: <String, String>{
      'life_path': 'Yaşam Yolu',
      'expression': 'İfade / Kader',
      'soul_urge': 'Ruh Arzusu',
      'personality': 'Kişilik',
      'birthday': 'Doğum Günü',
      'maturity': 'Olgunluk',
      'balance': 'Denge',
      'karmic_lessons': 'Karmik Dersler',
      'hidden_passions': 'Gizli Tutkular',
      'pinnacles': 'Zirveler',
      'challenges': 'Zorluklar',
      'personal_year': 'Kişisel Yıl',
      'personal_month': 'Kişisel Ay',
      'personal_day': 'Kişisel Gün',
    },
  );

  static const _en = NumerologyScreenCopy._(
    title: 'Numerology',
    resultTitle: 'Numerology Results',
    emptyTitle: 'No calculation yet',
    emptyBody: 'Choose a profile and run a numerology calculation to see the results here.',
    birthDateLabel: 'Birth date',
    targetDateLabel: 'Target date',
    sections: <String, String>{
      'core': 'Core Numbers',
      'name_analysis': 'Name Analysis',
      'periods': 'Periods',
      'personal_cycles': 'Personal Cycles',
    },
    metrics: <String, String>{
      'life_path': 'Life Path',
      'expression': 'Expression / Destiny',
      'soul_urge': 'Soul Urge',
      'personality': 'Personality',
      'birthday': 'Birthday',
      'maturity': 'Maturity',
      'balance': 'Balance',
      'karmic_lessons': 'Karmic Lessons',
      'hidden_passions': 'Hidden Passions',
      'pinnacles': 'Pinnacles',
      'challenges': 'Challenges',
      'personal_year': 'Personal Year',
      'personal_month': 'Personal Month',
      'personal_day': 'Personal Day',
    },
  );
}
