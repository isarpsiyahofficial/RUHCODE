import '../../domain/models/numerology_compatibility_models.dart';
export '../../domain/models/numerology_compatibility_models.dart';

import 'pythagorean_profile.dart';

abstract final class PythagoreanCompatibilityEngine {
  static const String engineId = 'numerology.pythagorean.compatibility';
  static const String engineVersion = '1';

  /// Compares two already-calculated Pythagorean profiles without inventing a
  /// synthetic percentage or hidden weighting system.
  ///
  /// Ruh Code exposes the six compared core numbers, their exact-match state,
  /// and the transparent absolute numeric difference. Interpretation is a
  /// separate content concern and must not alter these calculation values.
  static PythagoreanCompatibilityResult compare({
    required PythagoreanProfileResult left,
    required PythagoreanProfileResult right,
  }) {
    if (left.policy != right.policy) {
      throw ArgumentError(
        'Compatibility profiles must use the same reduction policy.',
      );
    }

    final comparisons = <NumerologyMetricComparison>[
      _comparison(NumerologyCompatibilityMetric.lifePath, left.lifePath, right.lifePath),
      _comparison(NumerologyCompatibilityMetric.expression, left.expression, right.expression),
      _comparison(NumerologyCompatibilityMetric.soulUrge, left.soulUrge, right.soulUrge),
      _comparison(NumerologyCompatibilityMetric.personality, left.personality, right.personality),
      _comparison(NumerologyCompatibilityMetric.birthday, left.birthday, right.birthday),
      _comparison(NumerologyCompatibilityMetric.maturity, left.maturity, right.maturity),
    ];

    return PythagoreanCompatibilityResult(
      comparisons: List<NumerologyMetricComparison>.unmodifiable(comparisons),
      exactMatchCount: comparisons.where((item) => item.exactMatch).length,
    );
  }

  static NumerologyMetricComparison _comparison(
    NumerologyCompatibilityMetric metric,
    int left,
    int right,
  ) {
    final delta = left - right;
    return NumerologyMetricComparison(
      metric: metric,
      leftValue: left,
      rightValue: right,
      absoluteDifference: delta < 0 ? -delta : delta,
      exactMatch: left == right,
    );
  }
}
