import '../ephemeris/ephemeris.dart';
import 'vedic_rashi_chart.dart';

final class VedicCompatibilityRule {
  VedicCompatibilityRule({
    required this.id,
    required this.version,
    required this.sourceId,
    required this.leftBody,
    required this.rightBody,
    required Iterable<int> allowedRelativeRashiDistances,
    required this.points,
  }) : allowedRelativeRashiDistances =
            Set<int>.unmodifiable(allowedRelativeRashiDistances) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Compatibility rules require id/version/source provenance.');
    }
    if (this.allowedRelativeRashiDistances.isEmpty ||
        this.allowedRelativeRashiDistances.any((value) => value < 1 || value > 12)) {
      throw RangeError('Compatibility relative Rashi distances must be within 1..12.');
    }
    if (!points.isFinite || points < 0) {
      throw RangeError('Compatibility points must be finite and non-negative.');
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final AstroBody leftBody;
  final AstroBody rightBody;
  final Set<int> allowedRelativeRashiDistances;
  final double points;
}

final class VedicCompatibilityRuleResult {
  const VedicCompatibilityRuleResult({
    required this.ruleId,
    required this.ruleVersion,
    required this.ruleSourceId,
    required this.relativeRashiDistance,
    required this.matched,
    required this.awardedPoints,
    required this.maxPoints,
  });

  final String ruleId;
  final String ruleVersion;
  final String ruleSourceId;
  final int relativeRashiDistance;
  final bool matched;
  final double awardedPoints;
  final double maxPoints;
}

final class VedicCompatibilityResult {
  const VedicCompatibilityResult({
    required this.ruleResults,
    required this.totalPoints,
    required this.maxPoints,
    required this.leftAyanamshaId,
    required this.leftAyanamshaDataVersion,
    required this.rightAyanamshaId,
    required this.rightAyanamshaDataVersion,
  });

  final List<VedicCompatibilityRuleResult> ruleResults;
  final double totalPoints;
  final double maxPoints;
  final String leftAyanamshaId;
  final String leftAyanamshaDataVersion;
  final String rightAyanamshaId;
  final String rightAyanamshaDataVersion;
}

/// RC-0122 compatibility is intentionally a separate Vedic subsystem.
///
/// No disputed Kuta/compatibility table is embedded as universal truth. The
/// evaluator accepts explicit versioned/source-tagged rules and keeps each rule
/// result visible so later professional catalogs can be independently audited.
abstract final class VedicCompatibilityEngine {
  static VedicCompatibilityResult evaluate({
    required VedicRashiChart left,
    required VedicRashiChart right,
    required Iterable<VedicCompatibilityRule> rules,
  }) {
    _validateChart(left, 'left');
    _validateChart(right, 'right');
    final catalog = rules.toList(growable: false);
    if (catalog.isEmpty) {
      throw ArgumentError('At least one versioned compatibility rule is required.');
    }
    final ids = <String>{};
    for (final rule in catalog) {
      if (!ids.add(rule.id)) {
        throw StateError('Duplicate Vedic compatibility rule id: ${rule.id}.');
      }
    }
    final leftByBody = <AstroBody, int>{
      for (final placement in left.placements)
        placement.placement.body: placement.rashiIndex,
    };
    final rightByBody = <AstroBody, int>{
      for (final placement in right.placements)
        placement.placement.body: placement.rashiIndex,
    };
    final results = <VedicCompatibilityRuleResult>[];
    var total = 0.0;
    var max = 0.0;
    for (final rule in catalog) {
      final leftRashi = leftByBody[rule.leftBody];
      final rightRashi = rightByBody[rule.rightBody];
      if (leftRashi == null || rightRashi == null) {
        throw StateError('Compatibility chart is missing a body required by ${rule.id}.');
      }
      final distance = ((rightRashi - leftRashi + 12) % 12) + 1;
      final matched = rule.allowedRelativeRashiDistances.contains(distance);
      final awarded = matched ? rule.points : 0.0;
      total += awarded;
      max += rule.points;
      results.add(
        VedicCompatibilityRuleResult(
          ruleId: rule.id,
          ruleVersion: rule.version,
          ruleSourceId: rule.sourceId,
          relativeRashiDistance: distance,
          matched: matched,
          awardedPoints: awarded,
          maxPoints: rule.points,
        ),
      );
    }
    return VedicCompatibilityResult(
      ruleResults: List<VedicCompatibilityRuleResult>.unmodifiable(results),
      totalPoints: total,
      maxPoints: max,
      leftAyanamshaId: left.ayanamshaId,
      leftAyanamshaDataVersion: left.ayanamshaDataVersion,
      rightAyanamshaId: right.ayanamshaId,
      rightAyanamshaDataVersion: right.ayanamshaDataVersion,
    );
  }

  static void _validateChart(VedicRashiChart chart, String side) {
    if (!chart.jdTt.isFinite ||
        chart.ayanamshaId.trim().isEmpty ||
        chart.ayanamshaDataVersion.trim().isEmpty ||
        chart.ephemerisSourceId.trim().isEmpty ||
        chart.ephemerisDataVersion.trim().isEmpty ||
        chart.placements.isEmpty) {
      throw StateError('Compatibility $side chart requires explicit Vedic provenance.');
    }
  }
}
