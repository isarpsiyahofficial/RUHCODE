import 'julian_day.dart';
import 'time_scales.dart';

final class EarthOrientationSample {
  const EarthOrientationSample({
    required this.utcInstant,
    required this.ut1MinusUtcSeconds,
    required this.sourceId,
    required this.dataVersion,
  });

  final DateTime utcInstant;
  final double ut1MinusUtcSeconds;
  final String sourceId;
  final String dataVersion;

  void validateFor(DateTime requestedUtcInstant) {
    if (!utcInstant.isUtc || !requestedUtcInstant.isUtc) {
      throw ArgumentError('Earth-orientation instants must be UTC.');
    }
    if (utcInstant != requestedUtcInstant) {
      throw StateError('Earth-orientation sample does not match requested UTC instant.');
    }
    if (!ut1MinusUtcSeconds.isFinite || ut1MinusUtcSeconds.abs() >= 0.9) {
      throw RangeError('UT1-UTC must be finite and within the UTC steering bound.');
    }
    if (sourceId.trim().isEmpty || dataVersion.trim().isEmpty) {
      throw StateError('Earth-orientation provenance is required.');
    }
  }
}

abstract interface class EarthOrientationProvider {
  /// Returns a versioned, offline-resolvable UT1-UTC sample for [utcInstant].
  ///
  /// Implementations must throw when the requested instant is outside their
  /// packaged data coverage. They must never silently substitute UTC for UT1.
  EarthOrientationSample sampleAt(DateTime utcInstant);
}

final class AstronomicalTimeContext {
  AstronomicalTimeContext._({
    required this.utcInstant,
    required this.jdUtc,
    required this.jdTt,
    required this.jdUt1,
    required this.ut1MinusUtcSeconds,
    required this.earthOrientationSourceId,
    required this.earthOrientationDataVersion,
  });

  final DateTime utcInstant;
  final double jdUtc;
  final double jdTt;
  final double jdUt1;
  final double ut1MinusUtcSeconds;
  final String earthOrientationSourceId;
  final String earthOrientationDataVersion;

  factory AstronomicalTimeContext.fromUtc({
    required DateTime utcInstant,
    required EarthOrientationProvider earthOrientationProvider,
  }) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected UTC.');
    }
    final sample = earthOrientationProvider.sampleAt(utcInstant);
    sample.validateFor(utcInstant);
    final jdUtc = JulianDay.fromUtc(utcInstant);
    return AstronomicalTimeContext._(
      utcInstant: utcInstant,
      jdUtc: jdUtc,
      jdTt: TimeScales.ttJulianDayFromUtc(utcInstant),
      jdUt1: jdUtc + sample.ut1MinusUtcSeconds / TimeScales.secondsPerDay,
      ut1MinusUtcSeconds: sample.ut1MinusUtcSeconds,
      earthOrientationSourceId: sample.sourceId,
      earthOrientationDataVersion: sample.dataVersion,
    );
  }
}
