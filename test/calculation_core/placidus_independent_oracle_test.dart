import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/asc_mc.dart';
import 'package:ruh_code/src/calculation_core/western/placidus_houses.dart';

void main() {
  test('Placidus cusps stay inside canonical budget against independent oracle', () {
    final evidenceFile = File('evidence/rc1436/placidus_swiss_oracle.json');
    final budgetFile = File(
      'requirements/reference_manifests/astronomy_accuracy_budgets.json',
    );
    expect(evidenceFile.existsSync(), isTrue);
    expect(budgetFile.existsSync(), isTrue);

    final evidence = jsonDecode(evidenceFile.readAsStringSync())
        as Map<String, dynamic>;
    final budget = jsonDecode(budgetFile.readAsStringSync())
        as Map<String, dynamic>;

    expect(evidence['status'], 'INDEPENDENT_PLACIDUS_ORACLE_CAPTURED');
    expect(evidence['provider'], 'Swiss Ephemeris via pyswisseph');
    expect(evidence['providerVersion'], isNotEmpty);
    expect(
      (evidence['providerBinary'] as Map<String, dynamic>)['sha256'],
      matches(RegExp(r'^[0-9a-f]{64}$')),
    );

    final canonicalBudgets = budget['budgets'] as Map<String, dynamic>;
    final cuspBudget =
        (canonicalBudgets['houseCuspLongitudeMaxAbsErrorDegrees'] as num)
            .toDouble();
    final evidenceBudget = evidence['accuracyBudget'] as Map<String, dynamic>;
    expect(
      (evidenceBudget['houseCuspLongitudeMaxAbsErrorDegrees'] as num)
          .toDouble(),
      cuspBudget,
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

      final angles = WesternAscMc.calculate(
        julianDayUt1: (item['julianDayUt1'] as num).toDouble(),
        julianDayTt: (item['julianDayTt'] as num).toDouble(),
        longitudeDegreesEast: longitude,
        latitudeDegreesNorth: latitude,
      );
      final actual = PlacidusHouses.calculate(
        angles: angles,
        latitudeDegreesNorth: latitude,
      );
      expect(
        actual.status,
        PlacidusResultStatus.success,
        reason: '$id must produce strict Placidus cusps without fallback.',
      );
      expect(actual.effectiveSystem, 'PLACIDUS');
      final actualCusps = actual.placidus!.cusps;
      final oracle = item['oracle'] as Map<String, dynamic>;
      final expectedCusps = (oracle['cuspsDegrees'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
      expect(actualCusps.length, 12);
      expect(expectedCusps.length, 12);

      for (var index = 0; index < 12; index++) {
        final error = _circularErrorDegrees(actualCusps[index], expectedCusps[index]);
        expect(
          error,
          lessThanOrEqualTo(cuspBudget),
          reason:
              '$id house ${index + 1} cusp error $error exceeds $cuspBudget degrees.',
        );
      }
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
