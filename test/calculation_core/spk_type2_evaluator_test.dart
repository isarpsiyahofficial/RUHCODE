import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  De440sDafIndex indexFor(SpkSegmentDescriptor segment) => De440sDafIndex(
        internalName: 'SYNTHETIC TYPE2',
        binaryFormat: 'LTL-IEEE',
        nd: 2,
        ni: 6,
        firstSummaryRecord: 1,
        lastSummaryRecord: 1,
        firstFreeAddress: 13,
        segments: [segment],
      );

  Uint8List syntheticType2() {
    // One Type-2 record. RSIZE=8 => MID,RADIUS + 2 coefficients for each axis.
    // X=1+2*tau, Y=3+4*tau, Z=5+6*tau where tau=(ET-MID)/RADIUS.
    // Directory trailer: INIT=-10, INTLEN=20, RSIZE=8, N=1.
    final words = <double>[
      0,
      10,
      1,
      2,
      3,
      4,
      5,
      6,
      -10,
      20,
      8,
      1,
    ];
    final bytes = Uint8List(words.length * 8);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < words.length; i++) {
      data.setFloat64(i * 8, words[i], Endian.little);
    }
    return bytes;
  }

  const type2 = SpkSegmentDescriptor(
    startEtSeconds: -10,
    endEtSeconds: 10,
    targetId: 399,
    centerId: 0,
    frameId: 1,
    dataType: 2,
    startAddress: 1,
    endAddress: 12,
    name: 'SYNTHETIC EARTH',
  );

  test('Type-2 evaluator computes Chebyshev position and derivative velocity', () {
    final bytes = syntheticType2();
    final evaluator = SpkType2Evaluator(bytes, indexFor(type2));

    final middle = evaluator.evaluateDirect(targetId: 399, centerId: 0, etSeconds: 0);
    expect(middle.xKm, closeTo(1, 1e-12));
    expect(middle.yKm, closeTo(3, 1e-12));
    expect(middle.zKm, closeTo(5, 1e-12));
    expect(middle.vxKmPerSecond, closeTo(0.2, 1e-12));
    expect(middle.vyKmPerSecond, closeTo(0.4, 1e-12));
    expect(middle.vzKmPerSecond, closeTo(0.6, 1e-12));

    final quarter = evaluator.evaluateDirect(targetId: 399, centerId: 0, etSeconds: 5);
    expect(quarter.xKm, closeTo(2, 1e-12));
    expect(quarter.yKm, closeTo(5, 1e-12));
    expect(quarter.zKm, closeTo(8, 1e-12));
  });

  test('exact segment right endpoint maps to final Type-2 record', () {
    final evaluator = SpkType2Evaluator(syntheticType2(), indexFor(type2));
    final state = evaluator.evaluateDirect(targetId: 399, centerId: 0, etSeconds: 10);
    expect(state.xKm, closeTo(3, 1e-12));
    expect(state.yKm, closeTo(7, 1e-12));
    expect(state.zKm, closeTo(11, 1e-12));
  });

  test('Type-2 evaluator fails closed outside coverage or for unsupported type', () {
    final bytes = syntheticType2();
    final evaluator = SpkType2Evaluator(bytes, indexFor(type2));
    expect(
      () => evaluator.evaluateDirect(targetId: 399, centerId: 0, etSeconds: 11),
      throwsRangeError,
    );

    const unsupported = SpkSegmentDescriptor(
      startEtSeconds: -10,
      endEtSeconds: 10,
      targetId: 399,
      centerId: 0,
      frameId: 1,
      dataType: 3,
      startAddress: 1,
      endAddress: 12,
      name: 'UNSUPPORTED',
    );
    final unsupportedEvaluator = SpkType2Evaluator(bytes, indexFor(unsupported));
    expect(
      () => unsupportedEvaluator.evaluateDirect(targetId: 399, centerId: 0, etSeconds: 0),
      throwsUnsupportedError,
    );
  });
}
