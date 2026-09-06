enum VedicVara {
  ravivara,
  somavara,
  mangalavara,
  budhavara,
  guruvara,
  shukravara,
  shanivara,
}

final class SunriseBoundary {
  const SunriseBoundary({
    required this.jdUt1,
    required this.sourceId,
    required this.dataVersion,
  });

  final double jdUt1;
  final String sourceId;
  final String dataVersion;
}

abstract interface class SunriseBoundaryProvider {
  SunriseBoundary previousSunrise({
    required double queryJdUt1,
    required double latitudeDegrees,
    required double longitudeDegrees,
  });
}

final class VedicVaraResult {
  const VedicVaraResult({
    required this.vara,
    required this.sunriseJdUt1,
    required this.sourceId,
    required this.dataVersion,
  });

  final VedicVara vara;
  final double sunriseJdUt1;
  final String sourceId;
  final String dataVersion;
}

/// RC-0114: Panchanga Vara is sunrise-boundary based, not civil-midnight based.
abstract final class VedicVaraCalculator {
  static VedicVaraResult calculate({
    required double queryJdUt1,
    required double latitudeDegrees,
    required double longitudeDegrees,
    required SunriseBoundaryProvider sunriseProvider,
  }) {
    if (!queryJdUt1.isFinite ||
        !latitudeDegrees.isFinite ||
        latitudeDegrees < -90 ||
        latitudeDegrees > 90 ||
        !longitudeDegrees.isFinite ||
        longitudeDegrees < -180 ||
        longitudeDegrees > 180) {
      throw ArgumentError('Vara requires finite UT1 and valid coordinates.');
    }

    final sunrise = sunriseProvider.previousSunrise(
      queryJdUt1: queryJdUt1,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
    );
    if (!sunrise.jdUt1.isFinite ||
        sunrise.jdUt1 > queryJdUt1 ||
        queryJdUt1 - sunrise.jdUt1 >= 2.0 ||
        sunrise.sourceId.trim().isEmpty ||
        sunrise.dataVersion.trim().isEmpty) {
      throw StateError('Vara requires a valid previous-sunrise boundary with provenance.');
    }

    // Julian weekday: floor(JD + 1.5) % 7 gives Sunday=0 ... Saturday=6.
    final weekdayIndex = (sunrise.jdUt1 + 1.5).floor() % 7;
    return VedicVaraResult(
      vara: VedicVara.values[weekdayIndex],
      sunriseJdUt1: sunrise.jdUt1,
      sourceId: sunrise.sourceId.trim(),
      dataVersion: sunrise.dataVersion.trim(),
    );
  }
}
