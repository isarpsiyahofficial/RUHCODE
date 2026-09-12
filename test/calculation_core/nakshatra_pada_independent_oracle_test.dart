import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DE440s Vedic Moon stays inside Nakshatra/Pada canonical budget', () async {
    final evidenceFile = File('evidence/rc1436/nakshatra_pada_swiss_oracle.json');
    final budgetFile = File(
      'requirements/reference_manifests/astronomy_accuracy_budgets.json',
    );
    expect(evidenceFile.existsSync(), isTrue);
    expect(budgetFile.existsSync(), isTrue);

    final evidence = jsonDecode(evidenceFile.readAsStringSync()) as Map<String, dynamic>;
    final budgets = (jsonDecode(budgetFile.readAsStringSync())
        as Map<String, dynamic>)['budgets'] as Map<String, dynamic>;
    final nakBudget =
        (budgets['nakshatraLongitudeMaxAbsErrorDegrees'] as num).toDouble();
    final padaBudget =
        (budgets['padaLongitudeMaxAbsErrorDegrees'] as num).toDouble();
    expect(nakBudget, 0.02);
    expect(padaBudget, 0.02);
    expect(evidence['status'], 'INDEPENDENT_NAKSHATRA_PADA_ORACLE_CAPTURED');

    final ephemeris = await De440sEphemerisProvider.loadPackaged();
    final cases = evidence['cases'] as List<dynamic>;
    expect(cases.length, greaterThanOrEqualTo(5));
    final years = <int>{};

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final calendar = item['calendarUtc'] as Map<String, dynamic>;
      years.add(calendar['year'] as int);
      final oracle = item['oracle'] as Map<String, dynamic>;
      final jdTt = (item['julianDayTt'] as num).toDouble();
      final oracleLongitude =
          (oracle['siderealMoonLongitudeDegrees'] as num).toDouble();
      final oracleAyanamsha =
          (oracle['lahiriAyanamshaDegrees'] as num).toDouble();

      // The independent oracle supplies only the ayanamsha value here so this
      // regression isolates DE440s + frame conversion + raw Nakshatra/Pada
      // classification. The production ayanamsha provider is gated separately.
      final snapshot = VedicCalculationEngine.calculate(
        jdTt: jdTt,
        bodies: const <AstroBody>[AstroBody.moon],
        ephemeris: ephemeris,
        ayanamsha: _FixedOracleAyanamsha(oracleAyanamsha),
      );
      final actualLongitude =
          snapshot.forBody(AstroBody.moon).siderealLongitudeDegrees;
      final longitudeError = _circularErrorDegrees(actualLongitude, oracleLongitude);
      expect(
        longitudeError,
        lessThanOrEqualTo(nakBudget),
        reason: '${item['id']} Moon sidereal error $longitudeError exceeds $nakBudget°',
      );
      // Pada uses the same raw longitude but has its own binding budget.
      expect(
        longitudeError,
        lessThanOrEqualTo(padaBudget),
        reason: '${item['id']} Pada longitude error $longitudeError exceeds $padaBudget°',
      );

      final actualClass = _classify(actualLongitude);
      expect(actualClass.$1, oracle['nakshatraIndexZeroBased'],
          reason: '${item['id']} Nakshatra classification drifted');
      expect(actualClass.$2, oracle['padaOneBased'],
          reason: '${item['id']} Pada classification drifted');
    }

    expect(years, containsAll(<int>[1900, 2000, 2026, 2050, 2100]));
  });
}

final class _FixedOracleAyanamsha implements VedicAyanamshaProvider {
  const _FixedOracleAyanamsha(this.value);
  final double value;

  @override
  String get id => 'independent-swiss-lahiri-test-oracle';

  @override
  String get dataVersion => 'pyswisseph-2.10.3.2';

  @override
  double degreesAt(double jdTt) => value;
}

(int, int) _classify(double siderealLongitudeDegrees) {
  const nakshatraSpan = 360.0 / 27.0;
  const padaSpan = nakshatraSpan / 4.0;
  final nakshatra = (siderealLongitudeDegrees / nakshatraSpan).floor().clamp(0, 26);
  final within = siderealLongitudeDegrees - (nakshatra * nakshatraSpan);
  final pada = (within / padaSpan).floor().clamp(0, 3) + 1;
  return (nakshatra, pada);
}

double _circularErrorDegrees(double actual, double expected) {
  final delta = ((actual - expected + 180.0) % 360.0) - 180.0;
  return delta.abs();
}
