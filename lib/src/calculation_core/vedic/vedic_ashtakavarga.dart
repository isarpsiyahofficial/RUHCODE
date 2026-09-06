import '../ephemeris/ephemeris.dart';
import 'vedic_rashi_chart.dart';

enum AshtakavargaContributorKind { graha, lagna }

final class AshtakavargaContributor {
  const AshtakavargaContributor.graha(this.id, this.body)
      : kind = AshtakavargaContributorKind.graha;

  const AshtakavargaContributor.lagna(this.id)
      : kind = AshtakavargaContributorKind.lagna,
        body = null;

  final String id;
  final AshtakavargaContributorKind kind;
  final AstroBody? body;
}

final class AshtakavargaRule {
  AshtakavargaRule({
    required this.subject,
    required this.contributorId,
    required Iterable<int> favorableRelativeHouses,
  }) : favorableRelativeHouses = Set<int>.unmodifiable(favorableRelativeHouses) {
    if (contributorId.trim().isEmpty || this.favorableRelativeHouses.isEmpty) {
      throw ArgumentError('Ashtakavarga rules require a contributor and favorable houses.');
    }
    if (this.favorableRelativeHouses.any((house) => house < 1 || house > 12)) {
      throw RangeError('Ashtakavarga relative houses must be within 1..12.');
    }
  }

  final AstroBody subject;
  final String contributorId;
  final Set<int> favorableRelativeHouses;
}

final class AshtakavargaRuleSet {
  AshtakavargaRuleSet({
    required this.id,
    required this.version,
    required this.sourceId,
    required Iterable<AshtakavargaContributor> contributors,
    required Iterable<AshtakavargaRule> rules,
  })  : contributors = List<AshtakavargaContributor>.unmodifiable(contributors),
        rules = List<AshtakavargaRule>.unmodifiable(rules) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Ashtakavarga rule sets require id/version/source provenance.');
    }
    if (this.contributors.isEmpty || this.rules.isEmpty) {
      throw ArgumentError('Ashtakavarga rule sets require contributors and rules.');
    }
    final contributorIds = <String>{};
    for (final contributor in this.contributors) {
      if (contributor.id.trim().isEmpty || !contributorIds.add(contributor.id)) {
        throw StateError('Ashtakavarga contributor ids must be non-empty and unique.');
      }
      if (contributor.kind == AshtakavargaContributorKind.graha && contributor.body == null) {
        throw StateError('Graha contributors require an AstroBody.');
      }
    }
    final ruleKeys = <String>{};
    for (final rule in this.rules) {
      if (!contributorIds.contains(rule.contributorId)) {
        throw StateError('Ashtakavarga rule references an unknown contributor.');
      }
      final key = '${rule.subject.name}:${rule.contributorId}';
      if (!ruleKeys.add(key)) {
        throw StateError('Duplicate Ashtakavarga subject/contributor rule: $key.');
      }
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final List<AshtakavargaContributor> contributors;
  final List<AshtakavargaRule> rules;
}

final class AshtakavargaResult {
  const AshtakavargaResult({
    required this.ruleSetId,
    required this.ruleSetVersion,
    required this.ruleSetSourceId,
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.bhinnaBindusBySubject,
    required this.sarvaBindusByRashi,
  });

  final String ruleSetId;
  final String ruleSetVersion;
  final String ruleSetSourceId;
  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final Map<AstroBody, List<int>> bhinnaBindusBySubject;
  final List<int> sarvaBindusByRashi;
}

/// RC-0119 Ashtakavarga calculation boundary.
///
/// No disputed classical table is silently embedded here. A caller must supply
/// an explicit versioned/source-tagged rule set. The engine evaluates Bhinna
/// bindus per subject and derives Sarvashtakavarga totals deterministically from
/// the same sidereal Rashi chart used by the rest of the independent Vedic core.
abstract final class VedicAshtakavargaEngine {
  static AshtakavargaResult evaluate({
    required VedicRashiChart chart,
    required AshtakavargaRuleSet ruleSet,
  }) {
    _validateChart(chart);
    final placements = <AstroBody, int>{
      for (final placement in chart.placements)
        placement.placement.body: placement.rashiIndex,
    };
    final contributorRashis = <String, int>{};
    for (final contributor in ruleSet.contributors) {
      switch (contributor.kind) {
        case AshtakavargaContributorKind.lagna:
          contributorRashis[contributor.id] = chart.lagnaRashiIndex;
        case AshtakavargaContributorKind.graha:
          final rashi = placements[contributor.body];
          if (rashi == null) {
            throw StateError('Ashtakavarga chart is missing contributor ${contributor.id}.');
          }
          contributorRashis[contributor.id] = rashi;
      }
    }

    final rows = <AstroBody, List<int>>{};
    for (final rule in ruleSet.rules) {
      final contributorRashi = contributorRashis[rule.contributorId]!;
      final row = rows.putIfAbsent(rule.subject, () => List<int>.filled(12, 0));
      for (var targetRashi = 0; targetRashi < 12; targetRashi++) {
        final relativeHouse = ((targetRashi - contributorRashi + 12) % 12) + 1;
        if (rule.favorableRelativeHouses.contains(relativeHouse)) {
          row[targetRashi] += 1;
        }
      }
    }
    if (rows.isEmpty) {
      throw StateError('Ashtakavarga evaluation produced no Bhinna rows.');
    }

    final sarva = List<int>.filled(12, 0);
    for (final row in rows.values) {
      for (var i = 0; i < 12; i++) {
        sarva[i] += row[i];
      }
    }
    final immutableRows = <AstroBody, List<int>>{
      for (final entry in rows.entries) entry.key: List<int>.unmodifiable(entry.value),
    };
    return AshtakavargaResult(
      ruleSetId: ruleSet.id,
      ruleSetVersion: ruleSet.version,
      ruleSetSourceId: ruleSet.sourceId,
      jdTt: chart.jdTt,
      ephemerisSourceId: chart.ephemerisSourceId,
      ephemerisDataVersion: chart.ephemerisDataVersion,
      ayanamshaId: chart.ayanamshaId,
      ayanamshaDataVersion: chart.ayanamshaDataVersion,
      bhinnaBindusBySubject: Map<AstroBody, List<int>>.unmodifiable(immutableRows),
      sarvaBindusByRashi: List<int>.unmodifiable(sarva),
    );
  }

  static void _validateChart(VedicRashiChart chart) {
    if (!chart.jdTt.isFinite ||
        chart.ephemerisSourceId.trim().isEmpty ||
        chart.ephemerisDataVersion.trim().isEmpty ||
        chart.ayanamshaId.trim().isEmpty ||
        chart.ayanamshaDataVersion.trim().isEmpty ||
        chart.lagnaRashiIndex < 0 ||
        chart.lagnaRashiIndex > 11 ||
        chart.placements.isEmpty) {
      throw StateError('Ashtakavarga requires a valid provenance-tagged Rashi chart.');
    }
    final bodies = <AstroBody>{};
    for (final placement in chart.placements) {
      if (!bodies.add(placement.placement.body) ||
          placement.rashiIndex < 0 ||
          placement.rashiIndex > 11) {
        throw StateError('Ashtakavarga chart contains invalid or duplicate placements.');
      }
    }
  }
}
