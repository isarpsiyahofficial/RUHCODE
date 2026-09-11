import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/lunar_node_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('true lunar node satisfies the RC1436 independent 0.02 degree budget', () async {
    final evidence = jsonDecode(
      File('evidence/rc1436/true_lunar_node_swiss_oracle.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(evidence['status'], 'INDEPENDENT_TRUE_LUNAR_NODE_ORACLE_CAPTURED');
    expect(evidence['body'], 'TRUE_NODE');

    final budgets = jsonDecode(
      File('requirements/reference_manifests/astronomy_accuracy_budgets.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final budget = ((budgets['budgets'] as Map<String, dynamic>)[
            'nodeLongitudeMaxAbsErrorDegrees'] as num)
        .toDouble();
    expect(budget, 0.02);

    final kernel = File('assets/data/ephemeris/de440s.bsp').readAsBytesSync();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key != 'assets/data/ephemeris/de440s.bsp') return null;
        return ByteData.sublistView(Uint8List.fromList(kernel));
      },
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    final ephemeris = await De440sEphemerisProvider.loadPackaged();
    const calculator = LunarNodeCalculator();
    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, 5);
    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final jdTt = (item['jdTt'] as num).toDouble();
      final expected = (item['longitudeDegrees'] as num).toDouble();
      final actual = calculator.trueAscendingNodeFromEphemerisDegrees(
        jdTt: jdTt,
        ephemeris: ephemeris,
      );
      final difference = _angularDifference(actual, expected);
      expect(
        difference,
        lessThanOrEqualTo(budget),
        reason: '${item['id']} true-node error $difference° exceeds $budget°. '
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
