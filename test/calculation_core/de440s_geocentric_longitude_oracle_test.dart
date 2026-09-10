import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s geocentric longitudes satisfy RC1436 budgets', () async {
    final evidenceFile = File(
      'evidence/rc1436/de440s_geocentric_longitude_spice_oracle.json',
    );
    expect(
      evidenceFile.existsSync(),
      isTrue,
      reason: 'Independent NAIF longitude oracle must be materialized first.',
    );

    final evidence =
        jsonDecode(evidenceFile.readAsStringSync()) as Map<String, dynamic>;
    expect(
      evidence['status'],
      'INDEPENDENT_DE440S_GEOCENTRIC_LONGITUDE_ORACLE_CAPTURED',
    );
    expect(evidence['provider'], 'NAIF CSPICE via SpiceyPy');
    final coverage = evidence['coverage'] as Map<String, dynamic>;
    expect(coverage['bodyCount'], 10);
    expect(coverage['epochCount'], 5);
    expect(coverage['caseCount'], 50);

    final budgets = jsonDecode(
      File('requirements/reference_manifests/astronomy_accuracy_budgets.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final budgetMap = budgets['budgets'] as Map<String, dynamic>;
    final sunBudget =
        (budgetMap['sunGeocentricLongitudeMaxAbsErrorDegrees'] as num)
            .toDouble();
    final moonBudget =
        (budgetMap['moonGeocentricLongitudeMaxAbsErrorDegrees'] as num)
            .toDouble();
    final planetBudget =
        (budgetMap['planetGeocentricLongitudeMaxAbsErrorDegrees'] as num)
            .toDouble();
    expect(sunBudget, 0.01);
    expect(moonBudget, 0.02);
    expect(planetBudget, 0.02);

    final provider = await De440sEphemerisProvider.loadPackaged();
    final cases = evidence['cases'] as List<dynamic>;
    final seenBodies = <AstroBody>{};
    final seenEpochs = <double>{};

    for (final raw in cases) {
      final item = raw as Map<String, dynamic>;
      final body = _body(item['body'] as String);
      final jdTt = (item['jdTt'] as num).toDouble();
      final expectedLongitude =
          (item['longitudeDegrees'] as num).toDouble();
      final actual = provider.stateAt(body: body, jdTt: jdTt);

      expect(actual.referenceFrame, EclipticReferenceFrame.j2000Geometric);
      expect(actual.sourceId, 'NASA/JPL DE440s');
      final difference = _angularDifference(
        actual.longitudeDegrees,
        expectedLongitude,
      );
      final allowed = switch (body) {
        AstroBody.sun => sunBudget,
        AstroBody.moon => moonBudget,
        _ => planetBudget,
      };
      expect(
        difference,
        lessThanOrEqualTo(allowed),
        reason: '${item['id']} longitude error $difference° exceeds $allowed°. '
            'actual=${actual.longitudeDegrees}, oracle=$expectedLongitude',
      );
      seenBodies.add(body);
      seenEpochs.add(jdTt);
    }

    expect(seenBodies.length, 10);
    expect(
      seenBodies,
      containsAll(<AstroBody>[
        AstroBody.sun,
        AstroBody.moon,
        AstroBody.mercury,
        AstroBody.venus,
        AstroBody.mars,
        AstroBody.jupiter,
        AstroBody.saturn,
        AstroBody.uranus,
        AstroBody.neptune,
        AstroBody.pluto,
      ]),
    );
    expect(
      seenEpochs,
      containsAll(<double>[
        2415020.5,
        2451545.0,
        2461041.5,
        2469807.5,
        2488069.5,
      ]),
    );
  });
}

AstroBody _body(String value) => switch (value) {
      'sun' => AstroBody.sun,
      'moon' => AstroBody.moon,
      'mercury' => AstroBody.mercury,
      'venus' => AstroBody.venus,
      'mars' => AstroBody.mars,
      'jupiter' => AstroBody.jupiter,
      'saturn' => AstroBody.saturn,
      'uranus' => AstroBody.uranus,
      'neptune' => AstroBody.neptune,
      'pluto' => AstroBody.pluto,
      _ => throw StateError('Unknown physical DE440s oracle body: $value'),
    };

double _angularDifference(double a, double b) {
  var difference = (a - b).abs() % 360.0;
  if (difference > 180.0) difference = 360.0 - difference;
  return difference;
}
