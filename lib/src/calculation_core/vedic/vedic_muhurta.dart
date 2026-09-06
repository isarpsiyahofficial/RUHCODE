import 'vedic_panchanga_snapshot.dart';

enum MuhurtaPanchangaField { tithi, vara, nakshatra, yoga, karana }

final class MuhurtaRule {
  MuhurtaRule({
    required this.id,
    required this.version,
    required this.sourceId,
    required this.field,
    required Iterable<int> acceptedValues,
    required this.points,
  }) : acceptedValues = Set<int>.unmodifiable(acceptedValues) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Muhurta rules require id/version/source provenance.');
    }
    if (this.acceptedValues.isEmpty || this.acceptedValues.any((value) => value < 1)) {
      throw RangeError('Muhurta accepted values must contain positive canonical indices.');
    }
    if (!points.isFinite || points < 0) {
      throw RangeError('Muhurta rule points must be finite and non-negative.');
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final MuhurtaPanchangaField field;
  final Set<int> acceptedValues;
  final double points;
}

final class MuhurtaRuleResult {
  const MuhurtaRuleResult({
    required this.ruleId,
    required this.ruleVersion,
    required this.ruleSourceId,
    required this.observedValue,
    required this.matched,
    required this.awardedPoints,
    required this.maxPoints,
  });

  final String ruleId;
  final String ruleVersion;
  final String ruleSourceId;
  final int observedValue;
  final bool matched;
  final double awardedPoints;
  final double maxPoints;
}

final class MuhurtaEvaluation {
  const MuhurtaEvaluation({
    required this.jdTt,
    required this.sunriseJdUt1,
    required this.ruleResults,
    required this.totalPoints,
    required this.maxPoints,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.sunriseSourceId,
    required this.sunriseDataVersion,
  });

  final double jdTt;
  final double sunriseJdUt1;
  final List<MuhurtaRuleResult> ruleResults;
  final double totalPoints;
  final double maxPoints;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final String sunriseSourceId;
  final String sunriseDataVersion;
}

/// RC-0123 keeps Muhurta as an independent tool boundary.
///
/// This evaluator consumes the already provenance-tagged five-limb Panchanga
/// snapshot. It does not embed a universal electional doctrine; each rule must
/// be independently versioned/source-tagged and remains visible in the result.
abstract final class VedicMuhurtaEngine {
  static MuhurtaEvaluation evaluate({
    required VedicPanchangaSnapshot panchanga,
    required Iterable<MuhurtaRule> rules,
  }) {
    _validatePanchanga(panchanga);
    final catalog = rules.toList(growable: false);
    if (catalog.isEmpty) {
      throw ArgumentError('Muhurta evaluation requires at least one versioned rule.');
    }
    final ids = <String>{};
    final results = <MuhurtaRuleResult>[];
    var total = 0.0;
    var max = 0.0;
    for (final rule in catalog) {
      if (!ids.add(rule.id)) {
        throw StateError('Duplicate Muhurta rule id: ${rule.id}.');
      }
      final observed = _observedValue(panchanga, rule.field);
      final matched = rule.acceptedValues.contains(observed);
      final awarded = matched ? rule.points : 0.0;
      total += awarded;
      max += rule.points;
      results.add(
        MuhurtaRuleResult(
          ruleId: rule.id,
          ruleVersion: rule.version,
          ruleSourceId: rule.sourceId,
          observedValue: observed,
          matched: matched,
          awardedPoints: awarded,
          maxPoints: rule.points,
        ),
      );
    }
    return MuhurtaEvaluation(
      jdTt: panchanga.core.jdTt,
      sunriseJdUt1: panchanga.vara.sunriseJdUt1,
      ruleResults: List<MuhurtaRuleResult>.unmodifiable(results),
      totalPoints: total,
      maxPoints: max,
      ephemerisSourceId: panchanga.core.ephemerisSourceId,
      ephemerisDataVersion: panchanga.core.ephemerisDataVersion,
      ayanamshaId: panchanga.core.ayanamshaId,
      ayanamshaDataVersion: panchanga.core.ayanamshaDataVersion,
      sunriseSourceId: panchanga.vara.sourceId,
      sunriseDataVersion: panchanga.vara.dataVersion,
    );
  }

  static int _observedValue(
    VedicPanchangaSnapshot panchanga,
    MuhurtaPanchangaField field,
  ) {
    switch (field) {
      case MuhurtaPanchangaField.tithi:
        return panchanga.core.tithiIndex;
      case MuhurtaPanchangaField.vara:
        return panchanga.vara.vara.index + 1;
      case MuhurtaPanchangaField.nakshatra:
        return panchanga.core.nakshatraIndex;
      case MuhurtaPanchangaField.yoga:
        return panchanga.core.yogaIndex;
      case MuhurtaPanchangaField.karana:
        return panchanga.core.karanaHalfTithiIndex;
    }
  }

  static void _validatePanchanga(VedicPanchangaSnapshot panchanga) {
    final core = panchanga.core;
    final vara = panchanga.vara;
    if (!core.jdTt.isFinite ||
        core.tithiIndex < 1 ||
        core.tithiIndex > 30 ||
        core.nakshatraIndex < 1 ||
        core.nakshatraIndex > 27 ||
        core.yogaIndex < 1 ||
        core.yogaIndex > 27 ||
        core.karanaHalfTithiIndex < 1 ||
        core.karanaHalfTithiIndex > 60 ||
        core.ephemerisSourceId.trim().isEmpty ||
        core.ephemerisDataVersion.trim().isEmpty ||
        core.ayanamshaId.trim().isEmpty ||
        core.ayanamshaDataVersion.trim().isEmpty ||
        !vara.sunriseJdUt1.isFinite ||
        vara.sourceId.trim().isEmpty ||
        vara.dataVersion.trim().isEmpty) {
      throw StateError('Muhurta requires a complete provenance-tagged Panchanga snapshot.');
    }
  }
}
