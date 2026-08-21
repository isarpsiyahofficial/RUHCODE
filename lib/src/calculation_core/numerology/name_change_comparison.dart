import 'personal_day.dart';
import 'pythagorean_profile.dart';

enum NumerologyNameMetric {
  expression,
  soulUrge,
  personality,
  maturity,
}

final class NumerologyNameMetricChange {
  const NumerologyNameMetricChange({
    required this.metric,
    required this.before,
    required this.after,
    required this.changed,
  });

  final NumerologyNameMetric metric;
  final int before;
  final int after;
  final bool changed;
}

final class PythagoreanNameChangeComparison {
  const PythagoreanNameChangeComparison({
    required this.oldNormalizedName,
    required this.newNormalizedName,
    required this.policy,
    required this.unchangedBirthDateIdentity,
    required this.changes,
  });

  final String oldNormalizedName;
  final String newNormalizedName;
  final PersonalCycleReductionPolicy policy;
  final String unchangedBirthDateIdentity;
  final List<NumerologyNameMetricChange> changes;

  int get changedMetricCount => changes.where((item) => item.changed).length;
}

abstract final class PythagoreanNameChangeComparisonEngine {
  static const String engineId = 'numerology.pythagorean.name-change-comparison';
  static const String engineVersion = '1';

  /// Compares only metrics that are name-dependent.
  ///
  /// Birth-date-derived Life Path and Birthday are intentionally excluded from
  /// the change list because a name edit must never mutate or imply a change in
  /// the user's birth date. Maturity is included because it depends on the
  /// unchanged Life Path plus the name-dependent Expression value.
  static PythagoreanNameChangeComparison compare({
    required PythagoreanProfileResult before,
    required PythagoreanProfileResult after,
  }) {
    if (before.birthDate != after.birthDate) {
      throw ArgumentError(
        'Name-change comparison requires the exact same birth date.',
      );
    }
    if (before.policy != after.policy) {
      throw ArgumentError(
        'Name-change comparison requires the same reduction policy.',
      );
    }
    if (before.normalizedName == after.normalizedName) {
      throw ArgumentError(
        'Name-change comparison requires two different normalized names.',
      );
    }

    final changes = <NumerologyNameMetricChange>[
      _change(
        NumerologyNameMetric.expression,
        before.expression,
        after.expression,
      ),
      _change(
        NumerologyNameMetric.soulUrge,
        before.soulUrge,
        after.soulUrge,
      ),
      _change(
        NumerologyNameMetric.personality,
        before.personality,
        after.personality,
      ),
      _change(
        NumerologyNameMetric.maturity,
        before.maturity,
        after.maturity,
      ),
    ];

    return PythagoreanNameChangeComparison(
      oldNormalizedName: before.normalizedName,
      newNormalizedName: after.normalizedName,
      policy: before.policy,
      unchangedBirthDateIdentity: before.birthDate.isoKey,
      changes: List<NumerologyNameMetricChange>.unmodifiable(changes),
    );
  }

  static NumerologyNameMetricChange _change(
    NumerologyNameMetric metric,
    int before,
    int after,
  ) =>
      NumerologyNameMetricChange(
        metric: metric,
        before: before,
        after: after,
        changed: before != after,
      );
}
