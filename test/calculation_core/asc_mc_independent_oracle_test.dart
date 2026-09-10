import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/asc_mc.dart';

void main() {
  test('ASC and MC stay inside canonical budgets against independent oracle', () {
    final evidenceFile = File('evidence/rc1436/asc_mc_swiss_oracle.json');
    final budgetFile = File(
      'requirements/reference_manifests/astronomy_accuracy_budgets.json',
    );
    expect(evidenceFile.existsSync(), isTrue);
    expect(budgetFile.existsSync(), isTrue);

    final evidence = jsonDecode(evidenceFile.readAsStringSync())
        as Map<String, dynamic>;
    final budget = jsonDecode(budgetFile.readAsStringSync())
        as Map<String, dynamic>;

    expect(evidence['status'], 'INDEPENDENT_ASC_MC_ORACLE_CAPTURED');
    expect(evidence['provider'], 'Swiss Ephemeris via pyswisseph');
    expect(evidence['providerVersion'], isNotEmpty);
    expect(
      (evidence['providerBinary'] as Map<String, dynamic>)['sha256'],
      matches(RegExp(r'^[0-9a-f]{64}$')),
    );

    final canonicalBudgets = budget['budgets'] as Map<String, dynamic>;
    final ascBudget =
        (canonicalBudgets['ascendantLongitudeMaxAbsErrorDegrees'] as num)
            .toDouble();
    final mcBudget = (canonicalBudgets['mcLongitudeMaxAbsErrorDegrees'] as num)
        .toDouble();
    final evidenceBudget = evidence['accuracyBudget'] as Map<String, dynamic>;
    expect(
      (evidenceBudget['ascendantLongitudeMaxAbsErrorDegrees'] as num)
          .toDouble(),
      ascBudget,
    );
    expect(
      (evidenceBudget['mcLongitudeMaxAbsErrorDegrees'] as num).toDouble(),
      mcBudget,
    );

    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, greaterThanOrEqualTo(5));
    final ids = <String>{};
    final years = <int>{};
    final latitudes = <double>[];
    final longitudes = <double>[];

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      expect(ids.add(id), isTrue, reason: 'Oracle case IDs must be unique.');
      final calendar = item['calendarUtc'] as Map<String, dynamic>;
      years.add(calendar['year'] as int);
      final latitude = (item['latitudeDegreesNorth'] as num).toDouble();
      final longitude = (item['longitudeDegreesEast'] as num).toDouble();
      latitudes.add(latitude);
      longitudes.add(longitude);

      final actual = WesternAscMc.calculate(
        julianDayUt1: (item['julianDayUt1'] as num).toDouble(),
        julianDayTt: (item['julianDayTt'] as num).toDouble(),
        longitudeDegreesEast: longitude,
        latitudeDegreesNorth: latitude,
      );
      final oracle = item['oracle'] as Map<String, dynamic>;
      final expectedAsc = (oracle['ascendantDegrees'] as num).toDouble();
      final expectedMc = (oracle['midheavenDegrees'] as num).toDouble();
      final ascError = _circularErrorDegrees(
        actual.ascendantDegrees,
        expectedAsc,
      );
      final mcError = _circularErrorDegrees(
        actual.midheavenDegrees,
        expectedMc,
      );

      expect(
        ascError,
        lessThanOrEqualTo(ascBudget),
        reason: '$id ASC error $ascError exceeds $ascBudget degrees.',
      );
      expect(
        mcError,
        lessThanOrEqualTo(mcBudget),
        reason: '$id MC error $mcError exceeds $mcBudget degrees.',
      );
    }

    expect(years, containsAll(<int>[1900, 2000, 2026, 2050, 2100]));
    expect(latitudes.any((value) => value < 0), isTrue);
    expect(latitudes.any((value) => value > 60), isTrue);
    expect(longitudes.any((value) => value < 0), isTrue);
    expect(longitudes.any((value) => value > 0), isTrue);
  });
}

double _circularErrorDegrees(double actual, double expected) {
  final delta = ((actual - expected + 180.0) % 360.0) - 180.0;
  return delta.abs();
}
