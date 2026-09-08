enum CalculationDomain {
  western,
  vedic,
  planetaryHours,
  chinese,
  bazi,
  numerology,
}

enum PresentationConcern { interpretation, tarot, personalGrowth, monetization, pdf, ui }

final class VerifiedCalculationFact {
  VerifiedCalculationFact({
    required this.id,
    required this.domain,
    required this.factKey,
    required this.value,
    required this.sourceId,
    required this.version,
  }) {
    if ([id, factKey, value, sourceId, version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('Verified calculation fact requires identity and provenance');
    }
  }

  final String id;
  final CalculationDomain domain;
  final String factKey;
  final String value;
  final String sourceId;
  final String version;
}

final class InterpretationInput {
  InterpretationInput({required List<VerifiedCalculationFact> facts}) : facts = List.unmodifiable(facts) {
    if (facts.isEmpty) throw ArgumentError('Interpretation requires verified calculation facts');
    final ids = facts.map((e) => e.id).toSet();
    if (ids.length != facts.length) throw ArgumentError('Duplicate calculation fact id');
  }

  final List<VerifiedCalculationFact> facts;

  VerifiedCalculationFact requireFact(String factKey) => facts.firstWhere(
        (fact) => fact.factKey == factKey,
        orElse: () => throw StateError('Interpretation cannot invent missing calculation fact: $factKey'),
      );
}

final class DeterministicDailyMessageTrace {
  DeterministicDailyMessageTrace({
    required this.calculationInputKey,
    required List<String> factIds,
    required this.ruleSetVersion,
    required this.catalogVersion,
  }) : factIds = List.unmodifiable(factIds) {
    if ([calculationInputKey, ruleSetVersion, catalogVersion].any((v) => v.trim().isEmpty) || factIds.isEmpty) {
      throw ArgumentError('Daily message trace requires deterministic inputs and provenance');
    }
  }

  final String calculationInputKey;
  final List<String> factIds;
  final String ruleSetVersion;
  final String catalogVersion;

  String get deterministicKey => '$calculationInputKey|${factIds.join(',')}|$ruleSetVersion|$catalogVersion';
}

final class CalculationLayerContract {
  const CalculationLayerContract();

  static const Map<CalculationDomain, String> modulePaths = {
    CalculationDomain.western: 'lib/src/calculation_core/western',
    CalculationDomain.vedic: 'lib/src/calculation_core/vedic',
    CalculationDomain.planetaryHours: 'lib/src/calculation_core/planetary_hours',
    CalculationDomain.chinese: 'lib/src/calculation_core/chinese',
    CalculationDomain.bazi: 'lib/src/calculation_core/bazi',
    CalculationDomain.numerology: 'lib/src/calculation_core/numerology',
  };

  bool concernBelongsInsideCalculationCore(PresentationConcern concern) => false;

  void assertSeparated(PresentationConcern concern) {
    if (concernBelongsInsideCalculationCore(concern)) {
      throw StateError('$concern must not be embedded in calculation_core');
    }
  }
}

final class InterpretationPolicy {
  const InterpretationPolicy({
    required this.acceptsVerifiedObjectsOnly,
    required this.acceptsRawUserForm,
    required this.languageVariationCanChangeFacts,
  });

  final bool acceptsVerifiedObjectsOnly;
  final bool acceptsRawUserForm;
  final bool languageVariationCanChangeFacts;

  void validate() {
    if (!acceptsVerifiedObjectsOnly || acceptsRawUserForm || languageVariationCanChangeFacts) {
      throw StateError('Calculation and interpretation boundary violated');
    }
  }
}
