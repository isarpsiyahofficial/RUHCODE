import '../calculation_core/numerology/compatibility.dart';
import 'interpretation_engine.dart';

final class NumerologyCompatibilityInterpretationKey {
  const NumerologyCompatibilityInterpretationKey({
    required this.metric,
    required this.exactMatch,
  });

  final NumerologyCompatibilityMetric metric;
  final bool exactMatch;

  String get stableId =>
      'numerology.compatibility.${metric.name}.${exactMatch ? 'match' : 'difference'}';

  @override
  bool operator ==(Object other) =>
      other is NumerologyCompatibilityInterpretationKey &&
      other.metric == metric &&
      other.exactMatch == exactMatch;

  @override
  int get hashCode => Object.hash(metric, exactMatch);
}

final class NumerologyCompatibilityContentEntry {
  NumerologyCompatibilityContentEntry({
    required this.ruleId,
    required this.tr,
    required this.en,
  }) {
    if (ruleId.trim().isEmpty) {
      throw const FormatException('Compatibility ruleId cannot be blank.');
    }
    if (tr.trim().isEmpty || en.trim().isEmpty) {
      throw const FormatException(
        'Compatibility content requires independent non-empty TR and EN text.',
      );
    }
    if (_containsPlaceholder(tr) || _containsPlaceholder(en)) {
      throw const FormatException(
        'Compatibility content cannot contain unresolved placeholders.',
      );
    }
  }

  final String ruleId;
  final String tr;
  final String en;

  static bool _containsPlaceholder(String value) =>
      RegExp(r'\{[^}]+\}').hasMatch(value);
}

final class NumerologyCompatibilityCatalog {
  NumerologyCompatibilityCatalog(
    Map<NumerologyCompatibilityInterpretationKey,
            NumerologyCompatibilityContentEntry>
        entries,
  ) : _entries = Map.unmodifiable(entries) {
    final expected = <NumerologyCompatibilityInterpretationKey>{};
    for (final metric in NumerologyCompatibilityMetric.values) {
      expected.add(
        NumerologyCompatibilityInterpretationKey(
          metric: metric,
          exactMatch: true,
        ),
      );
      expected.add(
        NumerologyCompatibilityInterpretationKey(
          metric: metric,
          exactMatch: false,
        ),
      );
    }

    final actual = _entries.keys.toSet();
    if (actual.length != expected.length || !actual.containsAll(expected)) {
      throw StateError(
        'Compatibility catalog must contain exactly match+difference content '
        'for all ${NumerologyCompatibilityMetric.values.length} metrics.',
      );
    }

    final ruleIds = <String>{};
    for (final entry in _entries.values) {
      if (!ruleIds.add(entry.ruleId)) {
        throw StateError('Compatibility ruleId values must be unique.');
      }
    }
  }

  final Map<NumerologyCompatibilityInterpretationKey,
      NumerologyCompatibilityContentEntry> _entries;

  NumerologyCompatibilityContentEntry entryFor(
    NumerologyCompatibilityInterpretationKey key,
  ) {
    final entry = _entries[key];
    if (entry == null) {
      throw StateError('Missing compatibility interpretation: ${key.stableId}');
    }
    return entry;
  }
}

final class PythagoreanCompatibilityInterpretationEngine
    implements InterpretationEngine<PythagoreanCompatibilityResult> {
  PythagoreanCompatibilityInterpretationEngine({required this.catalog});

  final NumerologyCompatibilityCatalog catalog;

  @override
  String get interpretationVersion => 'numerology.compatibility.content.v1';

  @override
  Future<InterpretationBundle> interpret({
    required PythagoreanCompatibilityResult snapshot,
    required String localeTag,
  }) async {
    if (localeTag != 'tr' && localeTag != 'en') {
      throw ArgumentError.value(
        localeTag,
        'localeTag',
        'Numerology compatibility v1 supports only tr and en.',
      );
    }

    final items = <String>[];
    final ruleIds = <String>[];
    for (final comparison in snapshot.comparisons) {
      final entry = catalog.entryFor(
        NumerologyCompatibilityInterpretationKey(
          metric: comparison.metric,
          exactMatch: comparison.exactMatch,
        ),
      );
      items.add(localeTag == 'tr' ? entry.tr : entry.en);
      ruleIds.add(entry.ruleId);
    }

    return InterpretationBundle(
      items: List<String>.unmodifiable(items),
      sourceRuleIds: List<String>.unmodifiable(ruleIds),
    );
  }
}
