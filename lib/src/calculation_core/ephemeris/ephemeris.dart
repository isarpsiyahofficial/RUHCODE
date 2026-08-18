enum AstroBody {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
  meanNode,
  trueNode,
}

enum ApparentMotion { direct, stationary, retrograde }

final class EphemerisCoverage {
  const EphemerisCoverage({
    required this.startJdTt,
    required this.endJdTt,
    required this.sourceId,
    required this.dataVersion,
    required this.checksumSha256,
  });

  final double startJdTt;
  final double endJdTt;
  final String sourceId;
  final String dataVersion;
  final String checksumSha256;

  void validate() {
    if (!startJdTt.isFinite || !endJdTt.isFinite || startJdTt >= endJdTt) {
      throw StateError('Ephemeris coverage must be a finite increasing TT range.');
    }
    if (sourceId.trim().isEmpty || dataVersion.trim().isEmpty) {
      throw StateError('Ephemeris source/version provenance is required.');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(checksumSha256)) {
      throw StateError('Ephemeris SHA-256 must be a lowercase 64-character hex digest.');
    }
  }

  void requireContains(double jdTt) {
    validate();
    if (!jdTt.isFinite || jdTt < startJdTt || jdTt > endJdTt) {
      throw RangeError('Requested TT instant is outside packaged ephemeris coverage.');
    }
  }
}

final class EclipticState {
  EclipticState({
    required this.body,
    required this.jdTt,
    required this.longitudeDegrees,
    required this.latitudeDegrees,
    required this.distanceAu,
    required this.longitudeSpeedDegreesPerDay,
    required this.sourceId,
    required this.dataVersion,
  }) {
    validate();
  }

  final AstroBody body;
  final double jdTt;
  final double longitudeDegrees;
  final double latitudeDegrees;
  final double distanceAu;
  final double longitudeSpeedDegreesPerDay;
  final String sourceId;
  final String dataVersion;

  void validate() {
    if (!jdTt.isFinite) {
      throw StateError('Ephemeris TT Julian Day must be finite.');
    }
    if (!longitudeDegrees.isFinite || longitudeDegrees < 0 || longitudeDegrees >= 360) {
      throw RangeError('Ecliptic longitude must be normalized to [0, 360).');
    }
    if (!latitudeDegrees.isFinite || latitudeDegrees < -90 || latitudeDegrees > 90) {
      throw RangeError('Ecliptic latitude must be within [-90, 90].');
    }
    if (!distanceAu.isFinite || distanceAu <= 0) {
      throw RangeError('Distance must be a positive finite AU value.');
    }
    if (!longitudeSpeedDegreesPerDay.isFinite) {
      throw StateError('Longitude speed must be finite.');
    }
    if (sourceId.trim().isEmpty || dataVersion.trim().isEmpty) {
      throw StateError('Ephemeris sample provenance is required.');
    }
  }

  ApparentMotion motion({double stationaryThresholdDegreesPerDay = 1e-4}) {
    if (!stationaryThresholdDegreesPerDay.isFinite || stationaryThresholdDegreesPerDay <= 0) {
      throw RangeError('Station threshold must be positive and finite.');
    }
    final speed = longitudeSpeedDegreesPerDay;
    if (speed.abs() <= stationaryThresholdDegreesPerDay) {
      return ApparentMotion.stationary;
    }
    return speed < 0 ? ApparentMotion.retrograde : ApparentMotion.direct;
  }
}

abstract interface class EphemerisProvider {
  EphemerisCoverage get coverage;

  /// Returns an exact, versioned geocentric ecliptic state at TT Julian Day.
  ///
  /// Implementations must reject requests outside packaged coverage and must
  /// never silently use network data, a different body, a nearby date, or a
  /// zero/default position as a fallback.
  EclipticState stateAt({required AstroBody body, required double jdTt});
}
