import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/solar/solar_events.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  test('sunrise and sunset stay inside canonical independent-oracle budget', () {
    final evidenceFile = File('evidence/rc1436/solar_events_swiss_oracle.json');
    final budgetFile = File(
      'requirements/reference_manifests/astronomy_accuracy_budgets.json',
    );
    expect(evidenceFile.existsSync(), isTrue);
    expect(budgetFile.existsSync(), isTrue);

    final evidence =
        jsonDecode(evidenceFile.readAsStringSync()) as Map<String, dynamic>;
    final budget =
        jsonDecode(budgetFile.readAsStringSync()) as Map<String, dynamic>;

    expect(evidence['status'], 'INDEPENDENT_SOLAR_EVENTS_ORACLE_CAPTURED');
    expect(evidence['provider'], 'Swiss Ephemeris via pyswisseph');
    expect(evidence['providerVersion'], isNotEmpty);
    expect(
      (evidence['providerBinary'] as Map<String, dynamic>)['sha256'],
      matches(RegExp(r'^[0-9a-f]{64}$')),
    );

    final canonicalBudgets = budget['budgets'] as Map<String, dynamic>;
    final secondsBudget =
        (canonicalBudgets['sunriseSunsetMaxAbsErrorSeconds'] as num).toDouble();
    final evidenceBudget = evidence['accuracyBudget'] as Map<String, dynamic>;
    expect(
      (evidenceBudget['sunriseSunsetMaxAbsErrorSeconds'] as num).toDouble(),
      secondsBudget,
    );

    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, greaterThanOrEqualTo(5));
    final years = <int>{};
    final offsets = <int>{};
    final latitudes = <double>[];
    final longitudes = <double>[];

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      final date = item['civilDate'] as Map<String, dynamic>;
      final year = date['year'] as int;
      years.add(year);
      offsets.add(item['utcOffsetMinutesForCivilDateSelection'] as int);
      final latitude = (item['latitudeDegreesNorth'] as num).toDouble();
      final longitude = (item['longitudeDegreesEast'] as num).toDouble();
      latitudes.add(latitude);
      longitudes.add(longitude);

      final result = SolarEvents.forDate(
        date: CivilDate(year, date['month'] as int, date['day'] as int),
        latitudeDegrees: latitude,
        longitudeDegrees: longitude,
      );
      expect(
        result.state,
        SolarDayState.normal,
        reason: '$id is a non-polar accuracy case.',
      );
      expect(result.sunriseUtcMinutes, isNotNull);
      expect(result.sunsetUtcMinutes, isNotNull);

      final oracle = item['oracle'] as Map<String, dynamic>;
      final expectedRise =
          (oracle['sunriseUtcMinutesFromCivilDateMidnight'] as num).toDouble();
      final expectedSet =
          (oracle['sunsetUtcMinutesFromCivilDateMidnight'] as num).toDouble();
      final riseErrorSeconds =
          (result.sunriseUtcMinutes! - expectedRise).abs() * 60.0;
      final setErrorSeconds =
          (result.sunsetUtcMinutes! - expectedSet).abs() * 60.0;

      expect(
        riseErrorSeconds,
        lessThanOrEqualTo(secondsBudget),
        reason:
            '$id sunrise error $riseErrorSeconds seconds exceeds $secondsBudget.',
      );
      expect(
        setErrorSeconds,
        lessThanOrEqualTo(secondsBudget),
        reason:
            '$id sunset error $setErrorSeconds seconds exceeds $secondsBudget.',
      );
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
