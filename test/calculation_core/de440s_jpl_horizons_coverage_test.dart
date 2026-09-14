import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s stays within explicit DE440/DE441 cross-model Horizons budget', () async {
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

    // Horizons currently uses the long-range DE441 solution for these major
    // bodies, while Ruh Code intentionally packages DE440s. JPL documents that
    // DE440 and DE441 are different fitted solutions and that their Moon states
    // diverge more than planetary states. Therefore Horizons is retained as an
    // authoritative cross-model sanity/provenance check, not the centimetre
    // evaluator oracle. The strict same-kernel oracle lives in
    // de440s_naif_spice_oracle_test.dart and keeps the release accuracy contract.
    const maxCrossModelPositionAxisErrorKm = 0.020; // 20 m
    const maxCrossModelVelocityAxisErrorKmPerSecond = 0.000001; // 1 mm/s

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
      final expected = <double>[
        finiteNumber(stateMap, 'xKm'),
        finiteNumber(stateMap, 'yKm'),
        finiteNumber(stateMap, 'zKm'),
        finiteNumber(stateMap, 'vxKmPerSecond'),
        finiteNumber(stateMap, 'vyKmPerSecond'),
        finiteNumber(stateMap, 'vzKmPerSecond'),
      ];
      final actualState = graph.evaluate(
        targetId: target,
        observerId: 0,
        etSeconds: etSeconds,
      );
      final actual = <double>[
        actualState.xKm,
        actualState.yKm,
        actualState.zKm,
        actualState.vxKmPerSecond,
        actualState.vyKmPerSecond,
        actualState.vzKmPerSecond,
      ];
      var positionError = 0.0;
      var velocityError = 0.0;
      for (var i = 0; i < 3; i++) {
        positionError = math.max(positionError, (actual[i] - expected[i]).abs());
      }
      for (var i = 3; i < 6; i++) {
        velocityError = math.max(velocityError, (actual[i] - expected[i]).abs());
      }
      expect(
        positionError,
        lessThanOrEqualTo(maxCrossModelPositionAxisErrorKm),
        reason: '$id exceeded explicit DE440s-vs-Horizons(DE441) cross-model position budget.',
      );
      expect(
        velocityError,
        lessThanOrEqualTo(maxCrossModelVelocityAxisErrorKmPerSecond),
        reason: '$id exceeded explicit DE440s-vs-Horizons(DE441) cross-model velocity budget.',
      );
    }

    expect(targets, containsAll(<int>[399, 10, 301]));
    expect(epochs, containsAll(<double>[2415020.5, 2451545.0, 2488069.5]));
  });
}
