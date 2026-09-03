import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/spk_type2_evaluator.dart';

void main() {
  Uint8List twoSegments() {
    List<double> record(double x, double y, double z) => <double>[
          0,
          10,
          x,
          0,
          y,
          0,
          z,
          0,
          -10,
          20,
          8,
          1,
        ];

    final words = <double>[
      ...record(1, 2, 3),
      ...record(10, 20, 30),
    ];
    final bytes = Uint8List(words.length * 8);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < words.length; i++) {
      data.setFloat64(i * 8, words[i], Endian.little);
    }
    return bytes;
  }

  De440sDafIndex index(List<SpkSegmentDescriptor> segments) => De440sDafIndex(
        internalName: 'SYNTHETIC GRAPH',
        binaryFormat: 'LTL-IEEE',
        nd: 2,
        ni: 6,
        firstSummaryRecord: 1,
        lastSummaryRecord: 1,
        firstFreeAddress: 25,
        segments: segments,
      );

  const earthRelativeEmb = SpkSegmentDescriptor(
    startEtSeconds: -10,
    endEtSeconds: 10,
    targetId: 399,
    centerId: 3,
    frameId: 1,
    dataType: 2,
    startAddress: 1,
    endAddress: 12,
    name: 'EARTH REL EMB',
  );
  const embRelativeSsb = SpkSegmentDescriptor(
    startEtSeconds: -10,
    endEtSeconds: 10,
    targetId: 3,
    centerId: 0,
    frameId: 1,
    dataType: 2,
    startAddress: 13,
    endAddress: 24,
    name: 'EMB REL SSB',
  );

  test('chains target-center edges to SSB and subtracts observer path', () {
    final bytes = twoSegments();
    final type2 = SpkType2Evaluator(bytes, index([earthRelativeEmb, embRelativeSsb]));
    final graph = SpkBodyGraphEvaluator(type2);

    final earthFromSsb = graph.evaluate(targetId: 399, observerId: 0, etSeconds: 0);
    expect(earthFromSsb.xKm, closeTo(11, 1e-12));
    expect(earthFromSsb.yKm, closeTo(22, 1e-12));
    expect(earthFromSsb.zKm, closeTo(33, 1e-12));

    final earthFromEmb = graph.evaluate(targetId: 399, observerId: 3, etSeconds: 0);
    expect(earthFromEmb.xKm, closeTo(1, 1e-12));
    expect(earthFromEmb.yKm, closeTo(2, 1e-12));
    expect(earthFromEmb.zKm, closeTo(3, 1e-12));

    final embFromEarth = graph.evaluate(targetId: 3, observerId: 399, etSeconds: 0);
    expect(embFromEarth.xKm, closeTo(-1, 1e-12));
    expect(embFromEarth.yKm, closeTo(-2, 1e-12));
    expect(embFromEarth.zKm, closeTo(-3, 1e-12));
  });

  test('fails closed when a center path is missing', () {
    final bytes = twoSegments();
    final graph = SpkBodyGraphEvaluator(
      SpkType2Evaluator(bytes, index([earthRelativeEmb])),
    );
    expect(
      () => graph.evaluate(targetId: 399, observerId: 0, etSeconds: 0),
      throwsRangeError,
    );
  });

  test('fails closed on target-center cycles', () {
    const first = SpkSegmentDescriptor(
      startEtSeconds: -10,
      endEtSeconds: 10,
      targetId: 399,
      centerId: 3,
      frameId: 1,
      dataType: 2,
      startAddress: 1,
      endAddress: 12,
      name: 'A',
    );
    const second = SpkSegmentDescriptor(
      startEtSeconds: -10,
      endEtSeconds: 10,
      targetId: 3,
      centerId: 399,
      frameId: 1,
      dataType: 2,
      startAddress: 13,
      endAddress: 24,
      name: 'B',
    );
    final graph = SpkBodyGraphEvaluator(
      SpkType2Evaluator(twoSegments(), index([first, second])),
    );
    expect(
      () => graph.evaluate(targetId: 399, observerId: 0, etSeconds: 0),
      throwsStateError,
    );
  });

  test('fails closed on unsupported frame or SPK data type', () {
    const unsupportedFrame = SpkSegmentDescriptor(
      startEtSeconds: -10,
      endEtSeconds: 10,
      targetId: 399,
      centerId: 0,
      frameId: 17,
      dataType: 2,
      startAddress: 1,
      endAddress: 12,
      name: 'FRAME17',
    );
    final frameGraph = SpkBodyGraphEvaluator(
      SpkType2Evaluator(twoSegments(), index([unsupportedFrame])),
    );
    expect(
      () => frameGraph.evaluate(targetId: 399, observerId: 0, etSeconds: 0),
      throwsUnsupportedError,
    );

    const unsupportedType = SpkSegmentDescriptor(
      startEtSeconds: -10,
      endEtSeconds: 10,
      targetId: 399,
      centerId: 0,
      frameId: 1,
      dataType: 3,
      startAddress: 1,
      endAddress: 12,
      name: 'TYPE3',
    );
    final typeGraph = SpkBodyGraphEvaluator(
      SpkType2Evaluator(twoSegments(), index([unsupportedType])),
    );
    expect(
      () => typeGraph.evaluate(targetId: 399, observerId: 0, etSeconds: 0),
      throwsUnsupportedError,
    );
  });
}
