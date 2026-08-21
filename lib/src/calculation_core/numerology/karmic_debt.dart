import 'personal_day.dart';
import 'pythagorean_profile.dart';

enum KarmicDebtMetric {
  birthday,
  lifePath,
  expression,
  soulUrge,
  personality,
  maturity,
  personalYear,
  personalMonth,
  personalDay,
}

final class KarmicDebtObservation {
  const KarmicDebtObservation({
    required this.metric,
    required this.compoundValue,
    required this.reducedValue,
    required this.provenance,
  });

  final KarmicDebtMetric metric;
  final int compoundValue;
  final int reducedValue;
  final String provenance;
}

final class KarmicDebtFinding {
  const KarmicDebtFinding({
    required this.metric,
    required this.compoundValue,
    required this.reducedValue,
    required this.provenance,
  });

  final KarmicDebtMetric metric;
  final int compoundValue;
  final int reducedValue;
  final String provenance;
}

abstract final class PythagoreanKarmicDebtEngine {
  static const String engineId = 'numerology.pythagorean.karmic-debt';
  static const String engineVersion = '2';

  /// Canonical Pythagorean karmic-debt compounds supported by Ruh Code.
  ///
  /// A reduced value alone never proves a debt. For example, a final value of
  /// 4 does not imply 13/4 unless the upstream calculation preserved 13 as the
  /// exact compound that reduced to 4.
  static const Map<int, int> supportedCompounds = <int, int>{
    13: 4,
    14: 5,
    16: 7,
    19: 1,
  };

  /// Creates exact observations from the reduction traces produced by the
  /// canonical Pythagorean profile engine.
  ///
  /// This is intentionally one-way: a profile final value is never used to
  /// reverse-infer a debt. Only a debt-bearing compound that actually appears
  /// in the metric's preserved reduction trace becomes an observation.
  static List<KarmicDebtObservation> observationsFromProfile(
    PythagoreanProfileResult profile,
  ) {
    final traces = <KarmicDebtMetric, PythagoreanReductionTrace>{
      KarmicDebtMetric.lifePath: profile.lifePathTrace,
      KarmicDebtMetric.expression: profile.expressionTrace,
      KarmicDebtMetric.soulUrge: profile.soulUrgeTrace,
      KarmicDebtMetric.personality: profile.personalityTrace,
      KarmicDebtMetric.birthday: profile.birthdayTrace,
      KarmicDebtMetric.maturity: profile.maturityTrace,
    };

    final observations = <KarmicDebtObservation>[];
    for (final entry in traces.entries) {
      final trace = entry.value;
      int? debtCompound;
      for (final compound in trace.observedCompounds) {
        if (supportedCompounds.containsKey(compound)) {
          debtCompound = compound;
          break;
        }
      }
      if (debtCompound == null) continue;

      observations.add(
        KarmicDebtObservation(
          metric: entry.key,
          compoundValue: debtCompound,
          reducedValue: trace.reducedValue,
          provenance: trace.provenance,
        ),
      );
    }
    return List<KarmicDebtObservation>.unmodifiable(observations);
  }

  static List<KarmicDebtFinding> detect(
    Iterable<KarmicDebtObservation> observations,
  ) {
    final findings = <KarmicDebtFinding>[];
    final seenMetrics = <KarmicDebtMetric>{};

    for (final observation in observations) {
      if (!seenMetrics.add(observation.metric)) {
        throw ArgumentError.value(
          observation.metric,
          'observations',
          'Each metric may provide at most one exact compound observation.',
        );
      }
      if (observation.compoundValue <= 0 || observation.reducedValue <= 0) {
        throw RangeError('Karmic Debt observations must be positive.');
      }
      if (observation.provenance.trim().isEmpty) {
        throw const FormatException(
          'Karmic Debt observation provenance cannot be blank.',
        );
      }

      final expectedReduced = PythagoreanPersonalDayEngine.reduce(
        observation.compoundValue,
        policy: PersonalCycleReductionPolicy.singleDigit,
      );
      if (expectedReduced != observation.reducedValue) {
        throw StateError(
          'Compound ${observation.compoundValue} does not reduce to '
          '${observation.reducedValue}.',
        );
      }

      final debtReduced = supportedCompounds[observation.compoundValue];
      if (debtReduced == null) continue;
      if (debtReduced != observation.reducedValue) {
        throw StateError('Canonical Karmic Debt mapping is inconsistent.');
      }

      findings.add(
        KarmicDebtFinding(
          metric: observation.metric,
          compoundValue: observation.compoundValue,
          reducedValue: observation.reducedValue,
          provenance: observation.provenance,
        ),
      );
    }

    return List<KarmicDebtFinding>.unmodifiable(findings);
  }
}