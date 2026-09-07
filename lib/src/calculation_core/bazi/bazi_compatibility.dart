import 'bazi_four_pillars.dart';

final class BaziCompatibilityRule {
  BaziCompatibilityRule({
    required this.id,
    required this.version,
    required this.sourceId,
    required this.maxScore,
    required this.evaluate,
  }) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('BaZi compatibility rule metadata must not be empty.');
    }
    if (!maxScore.isFinite || maxScore <= 0) {
      throw ArgumentError.value(maxScore, 'maxScore', 'must be finite and positive');
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final double maxScore;
  final double Function(BaziFourPillarsSnapshot a, BaziFourPillarsSnapshot b) evaluate;
}

final class BaziCompatibilityRuleResult {
  const BaziCompatibilityRuleResult({
    required this.ruleId,
    required this.score,
    required this.maxScore,
    required this.sourceId,
    required this.version,
  });

  final String ruleId;
  final double score;
  final double maxScore;
  final String sourceId;
  final String version;
}

final class BaziCompatibilitySnapshot {
  const BaziCompatibilitySnapshot({required this.results});
  final List<BaziCompatibilityRuleResult> results;

  double get score => results.fold<double>(0, (sum, item) => sum + item.score);
  double get maxScore => results.fold<double>(0, (sum, item) => sum + item.maxScore);
}

/// RC-0158 foundation. Compatibility is deliberately rule/version/source driven.
/// No universal relationship doctrine is embedded as calculation truth.
abstract final class BaziCompatibilityEngine {
  static BaziCompatibilitySnapshot evaluate({
    required BaziFourPillarsSnapshot a,
    required BaziFourPillarsSnapshot b,
    required List<BaziCompatibilityRule> rules,
  }) {
    if (rules.isEmpty) throw ArgumentError.value(rules, 'rules', 'must not be empty');
    final ids = <String>{};
    final output = <BaziCompatibilityRuleResult>[];
    for (final rule in rules) {
      if (!ids.add(rule.id)) throw StateError('Duplicate BaZi compatibility rule: ${rule.id}');
      final value = rule.evaluate(a, b);
      if (!value.isFinite || value < 0 || value > rule.maxScore) {
        throw StateError('Compatibility rule ${rule.id} produced an invalid score.');
      }
      output.add(BaziCompatibilityRuleResult(
        ruleId: rule.id,
        score: value,
        maxScore: rule.maxScore,
        sourceId: rule.sourceId,
        version: rule.version,
      ));
    }
    return BaziCompatibilitySnapshot(results: List.unmodifiable(output));
  }
}
