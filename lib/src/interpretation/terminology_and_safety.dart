enum InterpretationSubject { sun, moon, ascendant, planet, house, aspect }

enum InterpretationSafetyCategory {
  allowed,
  medicalDiagnosis,
  legalCertainty,
  financialGuarantee,
  deathPrediction,
}

class TerminologyEntry {
  const TerminologyEntry({
    required this.key,
    required this.en,
    required this.tr,
    required this.keepTechnicalTerm,
  });

  final String key;
  final String en;
  final String tr;
  final bool keepTechnicalTerm;
}

class TerminologyGlossary {
  TerminologyGlossary(Iterable<TerminologyEntry> entries)
      : _entries = Map.unmodifiable({for (final entry in entries) entry.key: entry}) {
    if (_entries.length != entries.length) {
      throw StateError('duplicate terminology key');
    }
    if (!_entries.containsKey('ascendant') || !_entries.containsKey('house')) {
      throw StateError('core terminology is incomplete');
    }
  }

  final Map<String, TerminologyEntry> _entries;

  TerminologyEntry require(String key) {
    final entry = _entries[key];
    if (entry == null) throw StateError('unknown terminology key: $key');
    return entry;
  }

  static TerminologyGlossary core() => TerminologyGlossary(const [
        TerminologyEntry(
          key: 'ascendant',
          en: 'Ascendant',
          tr: 'Yükselen',
          keepTechnicalTerm: false,
        ),
        TerminologyEntry(
          key: 'house',
          en: 'House',
          tr: 'Ev',
          keepTechnicalTerm: false,
        ),
        TerminologyEntry(
          key: 'nakshatra',
          en: 'Nakshatra',
          tr: 'Nakshatra',
          keepTechnicalTerm: true,
        ),
        TerminologyEntry(
          key: 'antardasha',
          en: 'Antardasha',
          tr: 'Antardasha',
          keepTechnicalTerm: true,
        ),
      ]);
}

class InterpretationRule {
  InterpretationRule({
    required this.id,
    required this.interpretationVersion,
    required this.subject,
    required this.conditionKey,
    required this.templateTr,
    required this.templateEn,
    required this.allowedPlaceholders,
  }) {
    if (id.trim().isEmpty || interpretationVersion.trim().isEmpty) {
      throw ArgumentError('rule id and interpretationVersion are required');
    }
    if (conditionKey.trim().isEmpty) {
      throw ArgumentError('conditionKey is required');
    }
    _validateTemplate(templateTr);
    _validateTemplate(templateEn);
  }

  final String id;
  final String interpretationVersion;
  final InterpretationSubject subject;
  final String conditionKey;
  final String templateTr;
  final String templateEn;
  final Set<String> allowedPlaceholders;

  void _validateTemplate(String template) {
    final placeholders = RegExp(r'\{([a-zA-Z0-9_]+)\}')
        .allMatches(template)
        .map((m) => m.group(1)!)
        .toSet();
    final unsupported = placeholders.difference(allowedPlaceholders);
    if (unsupported.isNotEmpty) {
      throw StateError('unsupported placeholders: $unsupported');
    }
  }

  String render({required String languageCode, required Map<String, String> values}) {
    var output = languageCode.toLowerCase() == 'tr' ? templateTr : templateEn;
    final requiredKeys = RegExp(r'\{([a-zA-Z0-9_]+)\}')
        .allMatches(output)
        .map((m) => m.group(1)!)
        .toSet();
    for (final key in requiredKeys) {
      final value = values[key];
      if (value == null || value.trim().isEmpty) {
        throw StateError('missing placeholder value: $key');
      }
      output = output.replaceAll('{$key}', value);
    }
    if (RegExp(r'\{[^}]+\}').hasMatch(output)) {
      throw StateError('unresolved placeholder remains');
    }
    return output;
  }
}

class InterpretationRuleMatcher {
  const InterpretationRuleMatcher();

  InterpretationRule requireMatch({
    required InterpretationRule rule,
    required InterpretationSubject calculatedSubject,
    required String calculatedConditionKey,
  }) {
    if (rule.subject != calculatedSubject || rule.conditionKey != calculatedConditionKey) {
      throw StateError('interpretation rule does not match calculation fact');
    }
    return rule;
  }
}

class InterpretationComposer {
  const InterpretationComposer();

  List<String> deduplicate(Iterable<String> factors) {
    final seen = <String>{};
    final result = <String>[];
    for (final factor in factors) {
      final normalized = factor.trim();
      if (normalized.isEmpty || !seen.add(normalized)) continue;
      result.add(normalized);
    }
    return List.unmodifiable(result);
  }

  /// Conflicting factors remain separate evidence instead of being collapsed
  /// into one deterministic claim.
  List<String> preserveConflictingFactors(Iterable<String> factors) =>
      deduplicate(factors);
}

class InterpretationSafetyPolicy {
  const InterpretationSafetyPolicy();

  void requireAllowed(InterpretationSafetyCategory category) {
    if (category != InterpretationSafetyCategory.allowed) {
      throw StateError('unsafe certainty category is forbidden: ${category.name}');
    }
  }

  String evidenceLabel(String languageCode) => languageCode.toLowerCase() == 'tr'
      ? 'Hesaplanan astronomik/numerolojik veri'
      : 'Calculated astronomical/numerological data';

  String traditionLabel(String languageCode) => languageCode.toLowerCase() == 'tr'
      ? 'Geleneksel yorum'
      : 'Traditional interpretation';
}
