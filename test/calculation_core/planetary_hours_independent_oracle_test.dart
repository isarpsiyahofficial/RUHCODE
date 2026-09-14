import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  test('all planetary-hour boundaries stay inside canonical oracle budget', () {
    final evidenceFile = File('evidence/rc1436/planetary_hours_swiss_oracle.json');
    final budgetFile = File(
      'requirements/reference_manifests/astronomy_accuracy_budgets.json',
    );
    expect(evidenceFile.existsSync(), isTrue);
    expect(budgetFile.existsSync(), isTrue);

    final evidence = jsonDecode(evidenceFile.readAsStringSync()) as Map<String, dynamic>;
    final budget = jsonDecode(budgetFile.readAsStringSync()) as Map<String, dynamic>;
    expect(evidence['status'], 'INDEPENDENT_PLANETARY_HOUR_BOUNDARY_ORACLE_CAPTURED');
    expect(evidence['provider'], 'Swiss Ephemeris via pyswisseph');
    expect(
      (evidence['providerBinary'] as Map<String, dynamic>)['sha256'],
      matches(RegExp(r'^[0-9a-f]{64}$')),
    );

    final secondsBudget = ((budget['budgets'] as Map<String, dynamic>)[
            'planetaryHourBoundaryMaxAbsErrorSeconds'] as num)
        .toDouble();
    expect(
      ((evidence['accuracyBudget'] as Map<String, dynamic>)[
              'planetaryHourBoundaryMaxAbsErrorSeconds'] as num)
          .toDouble(),
      secondsBudget,
    );

    final years = <int>{};
    final offsets = <int>{};
    final latitudes = <double>[];
    final longitudes = <double>[];
    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, greaterThanOrEqualTo(5));

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      final date = item['civilDate'] as Map<String, dynamic>;
      final civilDate = CivilDate(date['year'] as int, date['month'] as int, date['day'] as int);
      years.add(civilDate.year);
      offsets.add(item['utcOffsetMinutesForCivilDateSelection'] as int);
      final latitude = (item['latitudeDegreesNorth'] as num).toDouble();
      final longitude = (item['longitudeDegreesEast'] as num).toDouble();
      latitudes.add(latitude);
      longitudes.add(longitude);

      final result = PlanetaryHours.forDate(
        date: civilDate,
        latitudeDegrees: latitude,
        longitudeDegrees: longitude,
      );
      expect(result.isAvailable, isTrue, reason: '$id must be a non-polar accuracy case.');
      expect(result.slots.length, 24);

      final productionBoundaries = <DateTime>[result.slots.first.startUtc];
      for (final slot in result.slots) {
        productionBoundaries.add(slot.endUtc);
      }
      expect(productionBoundaries.length, 25);

      final oracle = item['oracle'] as Map<String, dynamic>;
      final expectedMinutes = (oracle['boundaryUtcMinutesFromCivilDateMidnight'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
      expect(expectedMinutes.length, 25);
      final base = DateTime.utc(civilDate.year, civilDate.month, civilDate.day);

      for (var index = 0; index < 25; index++) {
        final actualSeconds = productionBoundaries[index].difference(base).inMicroseconds / 1000000.0;
        final expectedSeconds = expectedMinutes[index] * 60.0;
        final errorSeconds = (actualSeconds - expectedSeconds).abs();
        expect(
          errorSeconds,
          lessThanOrEqualTo(secondsBudget),
          reason: '$id boundary ${index + 1} error $errorSeconds seconds exceeds $secondsBudget.',
        );
        if (index > 0) {
          expect(productionBoundaries[index].isAfter(productionBoundaries[index - 1]), isTrue);
        }
      }
      expect(productionBoundaries[12], result.slots[11].endUtc);
      expect(productionBoundaries[12], result.slots[12].startUtc);
    }

    expect(years, containsAll(<int>[1900, 2000, 2026, 2050, 2100]));
    expect(offsets.length, greaterThanOrEqualTo(4));
    expect(offsets.any((value) => value < 0), isTrue);
    expect(offsets.any((value) => value > 0), isTrue);
    expect(latitudes.any((value) => value < 0), isTrue);
    expect(latitudes.any((value) => value > 60), isTrue);
    expect(longitudes.any((value) => value < 0), isTrue);
    expect(longitudes.any((value) => value > 0), isTrue);
  });
}
