import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s resolves Earth through its real center graph at J2000', () async {
    final kernel = await const De440sAssetLoader().loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);
    final graph = SpkBodyGraphEvaluator(SpkType2Evaluator(kernel.bytes, index));

    final earthFromSsb = graph.evaluate(targetId: 399, observerId: 0, etSeconds: 0);
    final embFromSsb = graph.evaluate(targetId: 3, observerId: 0, etSeconds: 0);
    final earthFromEmb = graph.evaluate(targetId: 399, observerId: 3, etSeconds: 0);

    for (final state in <SpkCartesianState>[earthFromSsb, embFromSsb, earthFromEmb]) {
      for (final value in <double>[
        state.xKm,
        state.yKm,
        state.zKm,
        state.vxKmPerSecond,
        state.vyKmPerSecond,
        state.vzKmPerSecond,
      ]) {
        expect(value.isFinite, isTrue);
      }
    }

    expect(
      earthFromSsb.xKm,
      closeTo(embFromSsb.xKm + earthFromEmb.xKm, 1e-6),
    );
    expect(
      earthFromSsb.yKm,
      closeTo(embFromSsb.yKm + earthFromEmb.yKm, 1e-6),
    );
    expect(
      earthFromSsb.zKm,
      closeTo(embFromSsb.zKm + earthFromEmb.zKm, 1e-6),
    );
    expect(
      earthFromSsb.vxKmPerSecond,
      closeTo(embFromSsb.vxKmPerSecond + earthFromEmb.vxKmPerSecond, 1e-12),
    );
    expect(
      earthFromSsb.vyKmPerSecond,
      closeTo(embFromSsb.vyKmPerSecond + earthFromEmb.vyKmPerSecond, 1e-12),
    );
    expect(
      earthFromSsb.vzKmPerSecond,
      closeTo(embFromSsb.vzKmPerSecond + earthFromEmb.vzKmPerSecond, 1e-12),
    );

    // Runtime integrity only: independent NAIF/JPL golden vectors are still
    // required before RC-1437 planetaryEphemeris can be marked proven.
    expect(
      earthFromSsb.xKm.abs() + earthFromSsb.yKm.abs() + earthFromSsb.zKm.abs(),
      greaterThan(0),
    );
  });
}
