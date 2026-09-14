import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/bundled_lahiri_ayanamsha.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged Lahiri ayanamsha stays inside canonical 0.02 degree budget', () async {
    final evidence = jsonDecode(
      File('evidence/rc1436/lahiri_ayanamsha_swiss_oracle.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final manifest = jsonDecode(
      File('requirements/reference_manifests/astronomy_accuracy_budgets.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final budget = ((manifest['budgets'] as Map<String, dynamic>)[
            'ayanamshaLongitudeMaxAbsErrorDegrees'] as num)
        .toDouble();
    expect(budget, 0.02);
    expect(evidence['status'], 'INDEPENDENT_LAHIRI_AYANAMSHA_ORACLE_CAPTURED');

    final provider = await BundledLahiriAyanamsha.load();
    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, greaterThanOrEqualTo(5));

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final actual = provider.degreesAt((item['julianDayTt'] as num).toDouble());
      final expected = (item['lahiriAyanamshaDegrees'] as num).toDouble();
      final error = _circularError(actual, expected);
      expect(
        error,
        lessThanOrEqualTo(budget),
        reason: '${item['id']} Lahiri error $error exceeds $budget degrees',
      );
    }
  });
}

double _circularError(double actual, double expected) {
  final delta = ((actual - expected + 180.0) % 360.0) - 180.0;
  return delta.abs();
}
