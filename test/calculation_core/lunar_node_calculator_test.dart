import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/lunar_node_calculator.dart';

void main() {
  const calculator = LunarNodeCalculator();

  group('RC-0015 lunar nodes', () {
    test('J2000 mean ascending node matches the canonical polynomial epoch', () {
      final mean = calculator.meanAscendingNodeDegrees(jdTt: 2451545.0);
      expect(mean, closeTo(125.0445479, 1e-9));
    });

    test('J2000 true node applies periodic perturbations independently', () {
      final mean = calculator.meanAscendingNodeDegrees(jdTt: 2451545.0);
      final trueNode = calculator.trueAscendingNodeDegrees(jdTt: 2451545.0);
      expect(trueNode, closeTo(123.9261713684, 1e-9));
      expect((trueNode - mean).abs(), greaterThan(1.0));
    });

    test('mean and true nodes remain normalized across distant epochs', () {
      for (final jd in <double>[2415020.0, 2451545.0, 2460000.5, 2488070.0]) {
        final mean = calculator.meanAscendingNodeDegrees(jdTt: jd);
        final trueNode = calculator.trueAscendingNodeDegrees(jdTt: jd);
        expect(mean, inInclusiveRange(0.0, 360.0));
        expect(trueNode, inInclusiveRange(0.0, 360.0));
      }
    });

    test('descending node is exactly opposite the ascending node', () {
      expect(LunarNodeCalculator.descendingNodeDegrees(10.25), closeTo(190.25, 1e-12));
      expect(LunarNodeCalculator.descendingNodeDegrees(250.0), closeTo(70.0, 1e-12));
    });

    test('non-finite astronomical inputs fail closed', () {
      expect(
        () => calculator.meanAscendingNodeDegrees(jdTt: double.nan),
        throwsArgumentError,
      );
      expect(
        () => calculator.trueAscendingNodeDegrees(jdTt: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => LunarNodeCalculator.descendingNodeDegrees(double.nan),
        throwsArgumentError,
      );
    });
  });
}
