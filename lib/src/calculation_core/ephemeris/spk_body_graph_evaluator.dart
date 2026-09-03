import 'de440s_daf_parser.dart';
import 'spk_type2_evaluator.dart';

/// Resolves states through the packaged DE440s target/center graph.
///
/// The implementation is intentionally strict:
/// - NAIF ID 0 (solar-system barycenter) is the only implicit zero-state root.
/// - every traversed edge must be covered at the requested ET;
/// - every traversed edge must use J2000 (frame ID 1) and SPK Type 2;
/// - missing centers, graph cycles and unsupported frames/types fail closed.
///
/// Segment priority follows the single packaged-kernel rule already used by
/// [SpkType2Evaluator]: the last matching segment in file order wins.
final class SpkBodyGraphEvaluator {
  SpkBodyGraphEvaluator(this.segmentEvaluator);

  final SpkType2Evaluator segmentEvaluator;

  /// Returns target relative to observer, expressed in the packaged J2000 frame.
  SpkCartesianState evaluate({
    required int targetId,
    required int observerId,
    required double etSeconds,
  }) {
    if (!etSeconds.isFinite) {
      throw ArgumentError.value(etSeconds, 'etSeconds', 'must be finite');
    }
    if (targetId == observerId) {
      return _zero;
    }
    final targetToSsb = _toSolarSystemBarycenter(targetId, etSeconds);
    final observerToSsb = _toSolarSystemBarycenter(observerId, etSeconds);
    return targetToSsb + (-observerToSsb);
  }

  SpkCartesianState _toSolarSystemBarycenter(int bodyId, double etSeconds) {
    if (bodyId == 0) {
      return _zero;
    }

    final visited = <int>{};
    var current = bodyId;
    var accumulated = _zero;

    while (current != 0) {
      if (!visited.add(current)) {
        throw StateError(
          'SPK target/center cycle detected while resolving NAIF body $bodyId: '
          '${visited.join(' -> ')} -> $current.',
        );
      }

      final segment = _selectHighestPrioritySegment(current, etSeconds);
      if (segment.frameId != 1) {
        throw UnsupportedError(
          'SPK frame ${segment.frameId} is unsupported for body ${segment.targetId}; '
          'J2000 frame ID 1 is required.',
        );
      }
      if (segment.dataType != 2) {
        throw UnsupportedError(
          'SPK data type ${segment.dataType} is unsupported for body ${segment.targetId}; '
          'Type 2 is required.',
        );
      }

      accumulated = accumulated + segmentEvaluator.evaluateSegment(segment, etSeconds);
      current = segment.centerId;
    }

    return accumulated;
  }

  SpkSegmentDescriptor _selectHighestPrioritySegment(int targetId, double etSeconds) {
    SpkSegmentDescriptor? selected;
    for (final segment in segmentEvaluator.index.segments) {
      if (segment.targetId == targetId && segment.containsEt(etSeconds)) {
        selected = segment;
      }
    }
    if (selected == null) {
      throw RangeError(
        'No packaged SPK path edge covers target=$targetId at ET=$etSeconds.',
      );
    }
    return selected;
  }

  static const SpkCartesianState _zero = SpkCartesianState(
    xKm: 0,
    yKm: 0,
    zKm: 0,
    vxKmPerSecond: 0,
    vyKmPerSecond: 0,
    vzKmPerSecond: 0,
  );
}
