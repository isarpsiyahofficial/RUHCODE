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

  test('packaged DE440s evaluator matches independent NAIF SPICE oracle', () async {
    final evidenceFile = File('evidence/rc1436/de440s_naif_spice_oracle.json');
    expect(
      evidenceFile.existsSync(),
      isTrue,
      reason: 'Independent NAIF SPICE DE440s oracle evidence must be materialized first.',
    );

    final evidence = jsonDecode(evidenceFile.readAsStringSync()) as Map<String, dynamic>;
    expect(evidence['status'], 'INDEPENDENT_DE440S_ORACLE_CAPTURED');
    expect(evidence['provider'], 'NAIF CSPICE via SpiceyPy');
    final kernelEvidence = evidence['kernel'] as Map<String, dynamic>;
    expect(kernelEvidence['path'], 'assets/data/ephemeris/de440s.bsp');
    expect(kernelEvidence['sha256'], matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(kernelEvidence['sizeBytes'], greaterThan(1000000));

    final packaged = await const De440sAssetLoader().loadPackaged();
    expect(packaged.sha256, kernelEvidence['sha256']);
    final index = De440sDafIndex.parse(packaged.bytes);
    final graph = SpkBodyGraphEvaluator(SpkType2Evaluator(packaged.bytes, index));
    const contract = SpkStateAccuracyContract();

    final vectors = evidence['vectors'] as List<dynamic>;
    expect(vectors.length, greaterThanOrEqualTo(5));
    final ids = <String>{};
    final targets = <int>{};
    final epochs = <double>{};

    double finite(Map<String, dynamic> map, String key) {
      final value = map[key];
      expect(value, isA<num>(), reason: '$key must be numeric');
      final result = (value as num).toDouble();
      expect(result.isFinite, isTrue, reason: '$key must be finite');
      return result;
    }

    for (final raw in vectors) {
      final vector = raw as Map<String, dynamic>;
      final id = vector['id'] as String;
      expect(ids.add(id), isTrue, reason: 'oracle vector IDs must be unique');
      final target = vector['targetNaifId'] as int;
      targets.add(target);
      expect(vector['observerNaifId'], 0);
      expect(vector['frame'], 'J2000');
      expect(vector['corrections'], 'NONE');
      expect(vector['units'], 'KM-S');

      final epoch = vector['epoch'] as Map<String, dynamic>;
      final jdTdb = finite(epoch, 'jdTdb');
      epochs.add(jdTdb);
      final etSeconds = finite(epoch, 'etSecondsFromJ2000');
      final state = vector['state'] as Map<String, dynamic>;
      final expected = SpkCartesianState(
        xKm: finite(state, 'xKm'),
        yKm: finite(state, 'yKm'),
        zKm: finite(state, 'zKm'),
        vxKmPerSecond: finite(state, 'vxKmPerSecond'),
        vyKmPerSecond: finite(state, 'vyKmPerSecond'),
        vzKmPerSecond: finite(state, 'vzKmPerSecond'),
      );
      final actual = graph.evaluate(targetId: target, observerId: 0, etSeconds: etSeconds);
      final result = contract.compare(actual: actual, expected: expected);
      expect(
        result.passed,
        isTrue,
        reason: '$id failed independent NAIF SPICE DE440s accuracy: '
            'position=${result.maxPositionAxisErrorKm} km, '
            'velocity=${result.maxVelocityAxisErrorKmPerSecond} km/s.',
      );
      contract.requireWithinTolerance(actual: actual, expected: expected);
    }

    expect(targets, containsAll(<int>[399, 10, 301]));
    expect(epochs, containsAll(<double>[2415020.5, 2451545.0, 2488069.5]));
  });
}
