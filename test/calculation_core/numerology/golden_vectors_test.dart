import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/chaldean_name.dart';
import 'package:ruh_code/src/calculation_core/numerology/lo_shu_grid.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  final document = jsonDecode(
    File('evidence/numerology/golden_vectors_v1.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('golden fixture declares independent hand-calculated provenance', () {
    final provenance = document['provenance'] as Map<String, dynamic>;
    expect(provenance['type'], 'hand-calculated-independent-fixtures');
    expect((provenance['rule'] as String).trim(), isNotEmpty);
  });

  group('Pythagorean golden vectors', () {
    for (final raw in document['pythagorean'] as List<dynamic>) {
      final vector = raw as Map<String, dynamic>;
      test(vector['id'] as String, () {
        final policy = vector['policy'] == 'preserveMasterNumbers'
            ? PersonalCycleReductionPolicy.preserveMasterNumbers
            : PersonalCycleReductionPolicy.singleDigit;
        final result = PythagoreanProfileEngine.calculate(
          birthDate: CivilDate.parseIso(vector['birthDate'] as String),
          fullName: vector['fullName'] as String,
          policy: policy,
        );
        final expected = vector['expected'] as Map<String, dynamic>;

        expect(result.normalizedName, vector['normalizedName']);
        expect(result.lifePath, expected['lifePath']);
        expect(result.expression, expected['expression']);
        expect(result.soulUrge, expected['soulUrge']);
        expect(result.personality, expected['personality']);
        expect(result.birthday, expected['birthday']);
        expect(result.maturity, expected['maturity']);

        if (expected.containsKey('expressionTrace')) {
          expect(result.expressionTrace.steps, List<int>.from(expected['expressionTrace'] as List<dynamic>));
        }
        if (expected.containsKey('birthdayTrace')) {
          expect(result.birthdayTrace.steps, List<int>.from(expected['birthdayTrace'] as List<dynamic>));
        }
        if (expected.containsKey('maturityTrace')) {
          expect(result.maturityTrace.steps, List<int>.from(expected['maturityTrace'] as List<dynamic>));
        }
      });
    }
  });

  group('Chaldean golden vectors', () {
    for (final raw in document['chaldean'] as List<dynamic>) {
      final vector = raw as Map<String, dynamic>;
      test(vector['id'] as String, () {
        final result = ChaldeanNameEngine.calculate(
          fullName: vector['fullName'] as String,
        );
        final expected = vector['expected'] as Map<String, dynamic>;
        expect(result.normalizedName, vector['normalizedName']);
        expect(result.compoundTotal, expected['compoundTotal']);
        expect(result.reducedNumber, expected['reducedNumber']);
      });
    }
  });

  group('Lo Shu golden vectors', () {
    for (final raw in document['loShu'] as List<dynamic>) {
      final vector = raw as Map<String, dynamic>;
      test(vector['id'] as String, () {
        final result = LoShuGridEngine.calculate(
          CivilDate.parseIso(vector['birthDate'] as String),
        );
        final expected = vector['expectedCounts'] as Map<String, dynamic>;
        for (var value = 1; value <= 9; value++) {
          expect(result.countOf(value), expected['$value']);
        }
      });
    }
  });
}
