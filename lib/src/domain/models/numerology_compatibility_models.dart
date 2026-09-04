enum NumerologyCompatibilityMetric {
  lifePath,
  expression,
  soulUrge,
  personality,
  birthday,
  maturity,
}

final class NumerologyMetricComparison {
  const NumerologyMetricComparison({
    required this.metric,
    required this.leftValue,
    required this.rightValue,
    required this.absoluteDifference,
    required this.exactMatch,
  });

  final NumerologyCompatibilityMetric metric;
  final int leftValue;
  final int rightValue;
  final int absoluteDifference;
  final bool exactMatch;
}

final class PythagoreanCompatibilityResult {
  const PythagoreanCompatibilityResult({
    required this.comparisons,
    required this.exactMatchCount,
  });

  final List<NumerologyMetricComparison> comparisons;
  final int exactMatchCount;
}
