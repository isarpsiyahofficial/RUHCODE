import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';

enum TropicalZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

final class NatalPlacement {
  const NatalPlacement({
    required this.body,
    required this.longitudeDegrees,
    required this.longitudeSpeedDegreesPerDay,
    required this.sign,
    required this.degreeInSign,
    required this.houseNumber,
    required this.motion,
  });

  final AstroBody body;
  final double longitudeDegrees;
  final double longitudeSpeedDegreesPerDay;
  final TropicalZodiacSign sign;
  final double degreeInSign;
  final int houseNumber;
  final ApparentMotion motion;
}

final class NatalPlacementSet {
  NatalPlacementSet({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<NatalPlacement> placements,
  }) : placements = List<NatalPlacement>.unmodifiable(placements);

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final List<NatalPlacement> placements;

  NatalPlacement forBody(AstroBody body) =>
      placements.singleWhere((placement) => placement.body == body);
}

abstract final class WesternNatalPlacements {
  static NatalPlacementSet build({
    required List<EclipticState> states,
    required HouseCusps houses,
    double stationaryThresholdDegreesPerDay = 1e-4,
  }) {
    if (states.isEmpty) {
      throw ArgumentError.value(states, 'states', 'At least one ephemeris state is required.');
    }
    if (!stationaryThresholdDegreesPerDay.isFinite ||
        stationaryThresholdDegreesPerDay <= 0) {
      throw RangeError('Stationary threshold must be positive and finite.');
    }

    final first = states.first;
    first.validate();
    final seenBodies = <AstroBody>{};
    final placements = <NatalPlacement>[];

    for (final state in states) {
      state.validate();
      if (!seenBodies.add(state.body)) {
        throw StateError('Duplicate ephemeris body in natal placement input: ${state.body.name}.');
      }
      if ((state.jdTt - first.jdTt).abs() > 1e-12) {
        throw StateError('All natal ephemeris states must use the same TT instant.');
      }
      if (state.sourceId != first.sourceId || state.dataVersion != first.dataVersion) {
        throw StateError('All natal ephemeris states must share source/version provenance.');
      }

      final signIndex = (state.longitudeDegrees / 30.0).floor();
      final degreeInSign = state.longitudeDegrees - signIndex * 30.0;
      placements.add(
        NatalPlacement(
          body: state.body,
          longitudeDegrees: state.longitudeDegrees,
          longitudeSpeedDegreesPerDay: state.longitudeSpeedDegreesPerDay,
          sign: TropicalZodiacSign.values[signIndex],
          degreeInSign: degreeInSign,
          houseNumber: houses.houseForLongitude(state.longitudeDegrees),
          motion: state.motion(
            stationaryThresholdDegreesPerDay: stationaryThresholdDegreesPerDay,
          ),
        ),
      );
    }

    placements.sort((a, b) => a.body.index.compareTo(b.body.index));
    return NatalPlacementSet(
      jdTt: first.jdTt,
      sourceId: first.sourceId,
      dataVersion: first.dataVersion,
      placements: placements,
    );
  }
}
