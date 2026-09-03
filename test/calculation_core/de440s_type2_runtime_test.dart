import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s performs a real Type-2 numerical evaluation at J2000', () async {
    final kernel = await const De440sAssetLoader().loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);
    final segment = index.segments.firstWhere(
      (candidate) => candidate.dataType == 2 && candidate.containsEt(0),
    );
    final evaluator = SpkType2Evaluator(kernel.bytes, index);
    final state = evaluator.evaluateSegment(segment, 0);

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

    // A real planetary DE440s segment at J2000 must not collapse to the
    // forbidden zero/default state. This is a runtime-integrity assertion,
    // not an independent accuracy golden and therefore does not prove RC-1437.
    expect(
      state.xKm.abs() + state.yKm.abs() + state.zKm.abs(),
      greaterThan(0),
    );
  });
}
