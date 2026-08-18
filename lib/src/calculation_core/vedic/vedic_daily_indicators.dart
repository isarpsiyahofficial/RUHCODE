import 'ayanamsha.dart';

enum VedicPaksha { shukla, krishna }

final class VedicDailyIndicators {
  const VedicDailyIndicators({
    required this.siderealSunLongitudeDegrees,
    required this.siderealMoonLongitudeDegrees,
    required this.nakshatraIndex,
    required this.pada,
    required this.tithiIndex,
    required this.tithiInPaksha,
    required this.paksha,
    required this.sourceId,
    required this.sourceVersion,
    required this.ayanamshaId,
    required this.ayanamshaVersion,
  });

  final double siderealSunLongitudeDegrees;
  final double siderealMoonLongitudeDegrees;

  /// One-based index in the canonical 27-nakshatra sequence.
  final int nakshatraIndex;

  /// One-based pada index within the selected nakshatra.
  final int pada;

  /// One-based tithi index across the full synodic month (1..30).
  final int tithiIndex;

  /// One-based tithi index inside the active paksha (1..15).
  final int tithiInPaksha;
  final VedicPaksha paksha;

  /// Physical ephemeris provenance used to obtain tropical Sun/Moon states.
  final String sourceId;
  final String sourceVersion;

  /// Ayanamsha provenance is kept separate from ephemeris provenance.
  final String ayanamshaId;
  final String ayanamshaVersion;
}

abstract final class VedicDailyIndicatorsEngine {
  static const double _nakshatraSpanDegrees = 360.0 / 27.0;
  static const double _padaSpanDegrees = _nakshatraSpanDegrees / 4.0;
  static const double _tithiSpanDegrees = 12.0;

  static VedicDailyIndicators calculateWithProvider({
    required double julianDayTt,
    required double tropicalSunLongitudeDegrees,
    required double tropicalMoonLongitudeDegrees,
    required String sourceId,
    required String sourceVersion,
    required AyanamshaProvider ayanamshaProvider,
  }) {
    if (!julianDayTt.isFinite) {
      throw ArgumentError.value(julianDayTt, 'julianDayTt', 'Value must be finite.');
    }
    final ayanamsha = ayanamshaProvider.atJulianDayTt(julianDayTt);
    return calculate(
      tropicalSunLongitudeDegrees: tropicalSunLongitudeDegrees,
      tropicalMoonLongitudeDegrees: tropicalMoonLongitudeDegrees,
      ayanamshaDegrees: ayanamsha.degrees,
      sourceId: sourceId,
      sourceVersion: sourceVersion,
      ayanamshaId: ayanamsha.sourceId,
      ayanamshaVersion: ayanamsha.sourceVersion,
    );
  }

  static VedicDailyIndicators calculate({
    required double tropicalSunLongitudeDegrees,
    required double tropicalMoonLongitudeDegrees,
    required double ayanamshaDegrees,
    required String sourceId,
    required String sourceVersion,
    required String ayanamshaId,
    required String ayanamshaVersion,
  }) {
    _validateFinite(tropicalSunLongitudeDegrees, 'tropicalSunLongitudeDegrees');
    _validateFinite(tropicalMoonLongitudeDegrees, 'tropicalMoonLongitudeDegrees');
    _validateFinite(ayanamshaDegrees, 'ayanamshaDegrees');
    _validateProvenance(sourceId, 'sourceId');
    _validateProvenance(sourceVersion, 'sourceVersion');
    _validateProvenance(ayanamshaId, 'ayanamshaId');
    _validateProvenance(ayanamshaVersion, 'ayanamshaVersion');

    final siderealSun = _normalize360(
      tropicalSunLongitudeDegrees - ayanamshaDegrees,
    );
    final siderealMoon = _normalize360(
      tropicalMoonLongitudeDegrees - ayanamshaDegrees,
    );

    var nakshatraIndex = (siderealMoon / _nakshatraSpanDegrees).floor() + 1;
    if (nakshatraIndex > 27) nakshatraIndex = 27;

    final nakshatraStart = (nakshatraIndex - 1) * _nakshatraSpanDegrees;
    var pada = ((siderealMoon - nakshatraStart) / _padaSpanDegrees).floor() + 1;
    if (pada < 1) pada = 1;
    if (pada > 4) pada = 4;

    final elongation = _normalize360(siderealMoon - siderealSun);
    var tithiIndex = (elongation / _tithiSpanDegrees).floor() + 1;
    if (tithiIndex > 30) tithiIndex = 30;

    final paksha = tithiIndex <= 15 ? VedicPaksha.shukla : VedicPaksha.krishna;
    final tithiInPaksha = ((tithiIndex - 1) % 15) + 1;

    return VedicDailyIndicators(
      siderealSunLongitudeDegrees: siderealSun,
      siderealMoonLongitudeDegrees: siderealMoon,
      nakshatraIndex: nakshatraIndex,
      pada: pada,
      tithiIndex: tithiIndex,
      tithiInPaksha: tithiInPaksha,
      paksha: paksha,
      sourceId: sourceId.trim(),
      sourceVersion: sourceVersion.trim(),
      ayanamshaId: ayanamshaId.trim(),
      ayanamshaVersion: ayanamshaVersion.trim(),
    );
  }

  static double _normalize360(double value) {
    final normalized = value % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }

  static void _validateFinite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'Value must be finite.');
    }
  }

  static void _validateProvenance(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Provenance must not be empty.');
    }
  }
}
