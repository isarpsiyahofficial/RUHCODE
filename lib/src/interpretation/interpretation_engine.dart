abstract interface class InterpretationEngine<TSnapshot> {
  String get interpretationVersion;

  Future<InterpretationBundle> interpret({
    required TSnapshot snapshot,
    required String localeTag,
  });
}

final class InterpretationBundle {
  const InterpretationBundle({
    required this.items,
    required this.sourceRuleIds,
    this.interpretationVersion = 'unspecified',
  });

  final List<String> items;
  final List<String> sourceRuleIds;
  final String interpretationVersion;
}

final class InterpretationQualityException implements Exception {
  const InterpretationQualityException(this.message);

  final String message;

  @override
  String toString() => 'InterpretationQualityException: $message';
}

/// Central fail-closed validation for rendered interpretation bundles.
///
/// This guard deliberately validates structure and repetition only. It does not
/// pretend to infer semantic truth or manufacture conflict resolution from raw
/// prose. Domain-specific engines must model contradictions explicitly before
/// merging claims.
abstract final class InterpretationQualityGuard {
  static final RegExp _placeholder = RegExp(r'\{[^}]+\}');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _sentenceBoundary = RegExp(r'[.!?]+');

  static void validate(
    InterpretationBundle bundle, {
    int maxSentenceOccurrences = 2,
  }) {
    if (bundle.interpretationVersion.trim().isEmpty ||
        bundle.interpretationVersion == 'unspecified') {
      throw const InterpretationQualityException(
        'Interpretation bundle must carry an explicit version.',
      );
    }
    if (bundle.items.length != bundle.sourceRuleIds.length) {
      throw const InterpretationQualityException(
        'Interpretation items and sourceRuleIds must have equal length.',
      );
    }
    if (maxSentenceOccurrences < 1) {
      throw RangeError.value(
        maxSentenceOccurrences,
        'maxSentenceOccurrences',
        'Must be at least 1.',
      );
    }

    final normalizedItems = <String>{};
    final ruleIds = <String>{};
    final sentenceCounts = <String, int>{};

    for (var index = 0; index < bundle.items.length; index++) {
      final item = bundle.items[index].trim();
      final ruleId = bundle.sourceRuleIds[index].trim();
      if (item.isEmpty) {
        throw InterpretationQualityException(
          'Interpretation item $index is blank.',
        );
      }
      if (ruleId.isEmpty) {
        throw InterpretationQualityException(
          'Interpretation source rule $index is blank.',
        );
      }
      if (!ruleIds.add(ruleId)) {
        throw InterpretationQualityException(
          'Duplicate interpretation ruleId: $ruleId',
        );
      }
      if (_placeholder.hasMatch(item)) {
        throw InterpretationQualityException(
          'Unresolved placeholder in interpretation rule $ruleId.',
        );
      }

      final normalizedItem = _normalize(item);
      if (!normalizedItems.add(normalizedItem)) {
        throw InterpretationQualityException(
          'Duplicate interpretation item detected for rule $ruleId.',
        );
      }

      for (final rawSentence in item.split(_sentenceBoundary)) {
        final sentence = _normalize(rawSentence);
        if (sentence.isEmpty) continue;
        final count = (sentenceCounts[sentence] ?? 0) + 1;
        sentenceCounts[sentence] = count;
        if (count > maxSentenceOccurrences) {
          throw InterpretationQualityException(
            'Repeated interpretation sentence exceeds allowed frequency: '
            '$sentence',
          );
        }
      }
    }
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(_whitespace, ' ');
}
