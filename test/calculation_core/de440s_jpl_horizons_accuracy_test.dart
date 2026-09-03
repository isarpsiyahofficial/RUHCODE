import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_accuracy_contract.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s Earth/SSB J2000 state matches official JPL Horizons golden', () async {
    final evidenceFile = File(
      'evidence/rc1436/jpl_horizons_earth_ssb_j2000.json',
    );
    expect(
      evidenceFile.existsSync(),
      isTrue,
      reason: 'Canonical NASA/JPL Horizons evidence must be materialized first.',
    );

    final document = jsonDecode(evidenceFile.readAsStringSync());
    expect(document, isA<Map<String, dynamic>>());
    final evidence = document as Map<String, dynamic>;
    expect(evidence['status'], 'OFFICIAL_GOLDEN_CAPTURED');

    final source = evidence['source'];
    expect(source, isA<Map<String, dynamic>>());
    final sourceMap = source as Map<String, dynamic>;
    expect(sourceMap['provider'], 'NASA/JPL Horizons API');
    expect(sourceMap['endpoint'], 'https://ssd.jpl.nasa.gov/api/horizons.api');

    final query = sourceMap['query'];
    expect(query, isA<Map<String, dynamic>>());
    final queryMap = query as Map<String, dynamic>;
    expect(queryMap['COMMAND'], "'399'");
    expect(queryMap['CENTER'], "'@0'");
    expect(queryMap['TLIST'], "'2451545.0'");
    expect(queryMap['TLIST_TYPE'], "'JD'");
    expect(queryMap['TIME_TYPE'], "'TDB'");
    expect(queryMap['REF_SYSTEM'], "'ICRF'");
    expect(queryMap['REF_PLANE'], "'FRAME'");
    expect(queryMap['VEC_TABLE'], "'2'");
    expect(queryMap['VEC_CORR'], "'NONE'");
    expect(queryMap['OUT_UNITS'], "'KM-S'");

    final vector = evidence['vector'];
    expect(vector, isA<Map<String, dynamic>>());
    final vectorMap = vector as Map<String, dynamic>;
    double number(String key) {
      final value = vectorMap[key];
      if (value is! num || !value.toDouble().isFinite) {
        throw FormatException('JPL golden vector field $key must be finite.');
      }
      return value.toDouble();
    }

    final expected = SpkCartesianState(
      xKm: number('xKm'),
      yKm: number('yKm'),
      zKm: number('zKm'),
      vxKmPerSecond: number('vxKmPerSecond'),
      vyKmPerSecond: number('vyKmPerSecond'),
      vzKmPerSecond: number('vzKmPerSecond'),
    );

    final kernel = await const De440sAssetLoader().loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);
    final graph = SpkBodyGraphEvaluator(SpkType2Evaluator(kernel.bytes, index));
    final actual = graph.evaluate(
      targetId: 399,
      observerId: 0,
      etSeconds: 0,
    );

    const contract = SpkStateAccuracyContract();
    final result = contract.compare(actual: actual, expected: expected);
    expect(
      result.passed,
      isTrue,
      reason: 'DE440s must match independent NASA/JPL Horizons: '
          'max position axis error=${result.maxPositionAxisErrorKm} km; '
          'max velocity axis error=${result.maxVelocityAxisErrorKmPerSecond} km/s.',
    );
    contract.requireWithinTolerance(actual: actual, expected: expected);
  });
}
