import 'dart:math' as math;

import 'de440s_asset_loader.dart';
import 'de440s_daf_parser.dart';
import 'ephemeris.dart';
import 'spk_body_graph_evaluator.dart';
import 'spk_type2_evaluator.dart';

/// Production offline ephemeris provider backed by the packaged NASA/JPL
/// DE440s SPK kernel.
///
/// The provider deliberately exposes geometric geocentric J2000-ecliptic
/// states. Apparent/topocentric corrections and lunar nodes are separate
/// calculation layers and must not be silently mixed into this contract.
final class De440sEphemerisProvider implements EphemerisProvider {
  De440sEphemerisProvider._({
    required SpkBodyGraphEvaluator graph,
    required this.coverage,
  }) : _graph = graph;

  static const double _j2000Jd = 2451545.0;
  static const double _secondsPerDay = 86400.0;
  static const double _kilometresPerAu = 149597870.7;
  static const double _j2000ObliquityDegrees = 23.439291111;

  static const Map<AstroBody, int> _naifTargetByBody = <AstroBody, int>{
    AstroBody.sun: 10,
    AstroBody.moon: 301,
    AstroBody.mercury: 1,
    AstroBody.venus: 2,
    AstroBody.mars: 4,
    AstroBody.jupiter: 5,
    AstroBody.saturn: 6,
    AstroBody.uranus: 7,
    AstroBody.neptune: 8,
    AstroBody.pluto: 9,
  };

  static const int _earthNaifId = 399;

  final SpkBodyGraphEvaluator _graph;

  /// Loads and byte-verifies the packaged kernel before constructing the
  /// synchronous provider used by calculation engines.
  static Future<De440sEphemerisProvider> loadPackaged({
    De440sAssetLoader loader = const De440sAssetLoader(),
  }) async {
    final kernel = await loader.loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);
    final evaluator = SpkType2Evaluator(kernel.bytes, index);
    final graph = SpkBodyGraphEvaluator(evaluator);

    final commonEt = _commonCoverage(index);
    // SPK ET is TDB seconds past J2000. Converting the endpoints directly to
    // a JD and shrinking by one second avoids accepting a TT request whose
    // small periodic TDB-TT correction could cross the physical SPK edge.
    final startJd = _j2000Jd + ((commonEt.$1 + 1.0) / _secondsPerDay);
    final endJd = _j2000Jd + ((commonEt.$2 - 1.0) / _secondsPerDay);
    final coverage = EphemerisCoverage(
      startJdTt: startJd,
      endJdTt: endJd,
      sourceId: 'NASA/JPL DE440s',
      dataVersion: 'DE440s',
      checksumSha256: kernel.sha256,
    )..validate();

    return De440sEphemerisProvider._(graph: graph, coverage: coverage);
  }

  @override
  final EphemerisCoverage coverage;

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    coverage.requireContains(jdTt);
    final targetId = _naifTargetByBody[body];
    if (targetId == null) {
      throw UnsupportedError(
        '$body is not a physical DE440s body target. Lunar nodes are calculated by the dedicated node engine.',
      );
    }

    final etSeconds = _ttJulianDayToTdbEtSeconds(jdTt);
    final cartesian = _graph.evaluate(
      targetId: targetId,
      observerId: _earthNaifId,
      etSeconds: etSeconds,
    );
    return _toJ2000Ecliptic(body: body, jdTt: jdTt, state: cartesian);
  }

  static (double, double) _commonCoverage(De440sDafIndex index) {
    const requiredTargets = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 301, 399};
    var commonStart = double.negativeInfinity;
    var commonEnd = double.infinity;

    for (final target in requiredTargets) {
      final segments = index.segments.where((segment) => segment.targetId == target).toList();
      if (segments.isEmpty) {
        throw StateError('Packaged DE440s is missing required NAIF target $target.');
      }
      final targetStart = segments.map((segment) => segment.startEtSeconds).reduce(math.min);
      final targetEnd = segments.map((segment) => segment.endEtSeconds).reduce(math.max);
      commonStart = math.max(commonStart, targetStart);
      commonEnd = math.min(commonEnd, targetEnd);
    }
    if (!commonStart.isFinite || !commonEnd.isFinite || commonStart >= commonEnd) {
      throw StateError('Packaged DE440s has no common physical coverage for required bodies.');
    }
    return (commonStart, commonEnd);
  }

  /// Low-order Fairhead/Bretagnon-style periodic approximation sufficient for
  /// converting TT input to the DE kernel's TDB independent variable. The
  /// maximum correction is millisecond-scale and is never replaced by UTC.
  static double _ttJulianDayToTdbEtSeconds(double jdTt) {
    final days = jdTt - _j2000Jd;
    final meanAnomalyDegrees = 357.53 + (0.9856003 * days);
    final g = meanAnomalyDegrees * math.pi / 180.0;
    final tdbMinusTtSeconds =
        (0.001657 * math.sin(g)) + (0.000022 * math.sin(2.0 * g));
    return (days * _secondsPerDay) + tdbMinusTtSeconds;
  }

  static EclipticState _toJ2000Ecliptic({
    required AstroBody body,
    required double jdTt,
    required SpkCartesianState state,
  }) {
    final epsilon = _j2000ObliquityDegrees * math.pi / 180.0;
    final cosE = math.cos(epsilon);
    final sinE = math.sin(epsilon);

    // Rotate J2000 equatorial ICRF coordinates about +X into the J2000
    // ecliptic plane. Apply the identical rotation to velocity so angular
    // speed is obtained from the physical state rather than finite differencing.
    final x = state.xKm;
    final y = (state.yKm * cosE) + (state.zKm * sinE);
    final z = (-state.yKm * sinE) + (state.zKm * cosE);
    final vx = state.vxKmPerSecond;
    final vy = (state.vyKmPerSecond * cosE) + (state.vzKmPerSecond * sinE);

    final planarSquared = (x * x) + (y * y);
    final distanceKm = math.sqrt(planarSquared + (z * z));
    if (!distanceKm.isFinite || distanceKm <= 0 || planarSquared <= 0) {
      throw StateError('DE440s produced a non-physical geocentric state for $body.');
    }

    var longitude = math.atan2(y, x) * 180.0 / math.pi;
    if (longitude < 0) longitude += 360.0;
    final latitude = math.atan2(z, math.sqrt(planarSquared)) * 180.0 / math.pi;
    final longitudeRateRadiansPerSecond = ((x * vy) - (y * vx)) / planarSquared;
    final longitudeSpeedDegreesPerDay =
        longitudeRateRadiansPerSecond * 180.0 / math.pi * _secondsPerDay;

    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: latitude,
      distanceAu: distanceKm / _kilometresPerAu,
      longitudeSpeedDegreesPerDay: longitudeSpeedDegreesPerDay,
      sourceId: 'NASA/JPL DE440s',
      dataVersion: 'DE440s',
    );
  }
}
