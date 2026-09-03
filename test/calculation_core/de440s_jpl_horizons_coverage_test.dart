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

  test('packaged DE440s matches official multi-epoch/multi-body Horizons coverage', () async {
    final evidenceFile = File(
      'evidence/rc1436/jpl_horizons_de440s_coverage.json',
    );
    expect(
      evidenceFile.existsSync(),
      isTrue,
      reason: 'Canonical multi-vector NASA/JPL Horizons evidence must be materialized first.',
    );

    final decoded = jsonDecode(evidenceFile.readAsStringSync());
    expect(decoded, isA<Map<String, dynamic>>());
    final evidence = decoded as Map<String, dynamic>;
    expect(evidence['status'], 'OFFICIAL_GOLDEN_COVERAGE_CAPTURED');
    expect(evidence['provider'], 'NASA/JPL Horizons API');
    expect(evidence['endpoint'], 'https://ssd.jpl.nasa.gov/api/horizons.api');
    expect(evidence['observerNaifId'], 0);

    final vectors = evidence['vectors'];
    expect(vectors, isA<List<dynamic>>());
    final vectorList = vectors as List<dynamic>;
    expect(vectorList.length, greaterThanOrEqualTo(5));

    final ids = <String>{};
    final epochs = <double>{};
    final targets = <int>{};

    final kernel = await const De440sAssetLoader().loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);
    final graph = SpkBodyGraphEvaluator(SpkType2Evaluator(kernel.bytes, index));
    const contract = SpkStateAccuracyContract();

    double finiteNumber(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value is! num || !value.toDouble().isFinite) {
        throw FormatException('Golden field $key must be finite.');
      }
      return value.toDouble();
    }

    for (final raw in vectorList) {
      expect(raw, isA<Map<String, dynamic>>());
      final vector = raw as Map<String, dynamic>;
      final id = vector['id'];
      final target = vector['targetNaifId'];
      expect(id, isA<String>());
      expect(target, isA<int>());
      expect(vector['centerNaifId'], 0);
      expect(vector['referenceSystem'], 'ICRF');
      expect(vector['referencePlane'], 'FRAME');
      expect(vector['corrections'], 'NONE');
      expect(vector['units'], 'KM-S');
      expect(ids.add(id as String), isTrue, reason: 'coverage IDs must be unique');
      targets.add(target as int);

      final epoch = vector['epoch'];
      expect(epoch, isA<Map<String, dynamic>>());
      final epochMap = epoch as Map<String, dynamic>;
      final jdTdb = finiteNumber(epochMap, 'jdTdb');
      final etSeconds = finiteNumber(epochMap, 'etSecondsFromJ2000');
      epochs.add(jdTdb);

      final source = vector['source'];
      expect(source, isA<Map<String, dynamic>>());
      final sourceMap = source as Map<String, dynamic>;
      final signature = sourceMap['apiSignature'];
      expect(signature, isA<Map<String, dynamic>>());
      expect((signature as Map<String, dynamic>)['source'], 'NASA/JPL Horizons API');
      expect(sourceMap['rawResponseSha256'], matches(RegExp(r'^[0-9a-f]{64}$')));
      final query = sourceMap['query'];
      expect(query, isA<Map<String, dynamic>>());
      final queryMap = query as Map<String, dynamic>;
      expect(queryMap['COMMAND'], "'$target'");
      expect(queryMap['CENTER'], "'@0'");
      expect(queryMap['TLIST'], "'${jdTdb.toStringAsFixed(1)}'");
      expect(queryMap['TLIST_TYPE'], "'JD'");
      expect(queryMap['TIME_TYPE'], "'TDB'");
      expect(queryMap['REF_SYSTEM'], "'ICRF'");
      expect(queryMap['REF_PLANE'], "'FRAME'");
      expect(queryMap['VEC_TABLE'], "'2'");
      expect(queryMap['VEC_CORR'], "'NONE'");
      expect(queryMap['OUT_UNITS'], "'KM-S'");

      final state = vector['state'];
      expect(state, isA<Map<String, dynamic>>());
      final stateMap = state as Map<String, dynamic>;
      final expected = SpkCartesianState(
        xKm: finiteNumber(stateMap, 'xKm'),
        yKm: finiteNumber(stateMap, 'yKm'),
        zKm: finiteNumber(stateMap, 'zKm'),
        vxKmPerSecond: finiteNumber(stateMap, 'vxKmPerSecond'),
        vyKmPerSecond: finiteNumber(stateMap, 'vyKmPerSecond'),
        vzKmPerSecond: finiteNumber(stateMap, 'vzKmPerSecond'),
      );
      final actual = graph.evaluate(
        targetId: target,
        observerId: 0,
        etSeconds: etSeconds,
      );
      final result = contract.compare(actual: actual, expected: expected);
      expect(
        result.passed,
        isTrue,
        reason: '$id failed official Horizons accuracy: '
            'position=${result.maxPositionAxisErrorKm} km, '
            'velocity=${result.maxVelocityAxisErrorKmPerSecond} km/s.',
      );
      contract.requireWithinTolerance(actual: actual, expected: expected);
    }

    expect(targets, containsAll(<int>[399, 10, 301]));
    expect(epochs, containsAll(<double>[2415020.5, 2451545.0, 2488069.5]));
  });
}
