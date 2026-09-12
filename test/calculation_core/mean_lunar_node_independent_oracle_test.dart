import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/lunar_node_calculator.dart';

void main() {
  test('mean lunar node satisfies the RC1436 independent 0.02 degree budget', () {
    final evidence = jsonDecode(
      File('evidence/rc1436/mean_lunar_node_swiss_oracle.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(evidence['status'], 'INDEPENDENT_MEAN_LUNAR_NODE_ORACLE_CAPTURED');
    expect(evidence['body'], 'MEAN_NODE');

    final budgets = jsonDecode(
      File('requirements/reference_manifests/astronomy_accuracy_budgets.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final budget = ((budgets['budgets'] as Map<String, dynamic>)[
            'nodeLongitudeMaxAbsErrorDegrees'] as num)
        .toDouble();
    expect(budget, 0.02);

    const calculator = LunarNodeCalculator();
    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, 5);
    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final jdTt = (item['jdTt'] as num).toDouble();
      final expected = (item['longitudeDegrees'] as num).toDouble();
      final actual = calculator.meanAscendingNodeDegrees(jdTt: jdTt);
      final difference = _angularDifference(actual, expected);
      expect(
        difference,
        lessThanOrEqualTo(budget),
        reason: '${item['id']} mean-node error $difference° exceeds $budget°. '
            'actual=$actual oracle=$expected',
      );
    }
  });
}

double _angularDifference(double a, double b) {
  var difference = (a - b).abs() % 360.0;
  if (difference > 180.0) difference = 360.0 - difference;
  return difference;
}
