import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

const List<String> canonicalNakshatraIds = <String>[
  'ashwini',
  'bharani',
  'krittika',
  'rohini',
  'mrigashirsha',
  'ardra',
  'punarvasu',
  'pushya',
  'ashlesha',
  'magha',
  'purva_phalguni',
  'uttara_phalguni',
  'hasta',
  'chitra',
  'swati',
  'vishakha',
  'anuradha',
  'jyeshtha',
  'mula',
  'purva_ashadha',
  'uttara_ashadha',
  'shravana',
  'dhanishtha',
  'shatabhisha',
  'purva_bhadrapada',
  'uttara_bhadrapada',
  'revati',
];

final class VedicNakshatraPosition {
  const VedicNakshatraPosition({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.siderealMoonLongitudeDegrees,
    required this.nakshatraIndex,
    required this.nakshatraId,
    required this.pada,
    required this.degreesIntoNakshatra,
  });

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final double siderealMoonLongitudeDegrees;

  /// Zero-based canonical index in the 27-fold sidereal Nakshatra cycle.
  final int nakshatraIndex;
  final String nakshatraId;

  /// One-based quarter within the selected Nakshatra (1..4).
  final int pada;
  final double degreesIntoNakshatra;
}

abstract final class VedicNakshatra {
  static const int nakshatraCount = 27;
  static const int padaCountPerNakshatra = 4;
  static const double nakshatraSpanDegrees = 360.0 / nakshatraCount;
  static const double padaSpanDegrees =
      nakshatraSpanDegrees / padaCountPerNakshatra;

  /// Calculates RC-0088 Nakshatra and RC-0089 Pada from the sidereal Moon.
  ///
  /// The Moon placement must already come from the independent Vedic engine,
  /// so ayanamsha and ephemeris provenance remain explicit. This layer only
  /// partitions the normalized sidereal longitude; it does not recompute or
  /// silently alter the astronomical position.
  static VedicNakshatraPosition fromSnapshot(
    VedicCalculationSnapshot snapshot,
  ) {
    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty) {
      throw StateError('Nakshatra calculation requires explicit provenance.');
    }

    final moons = snapshot.placements
        .where((placement) => placement.body == AstroBody.moon)
        .toList(growable: false);
    if (moons.length != 1) {
      throw StateError(
        'Nakshatra calculation requires exactly one sidereal Moon placement.',
      );
    }

    final longitude = moons.single.siderealLongitudeDegrees;
    if (!longitude.isFinite || longitude < 0 || longitude >= 360) {
      throw StateError('Sidereal Moon longitude must be normalized to [0, 360).');
    }

    var nakshatraIndex = (longitude / nakshatraSpanDegrees).floor();
    if (nakshatraIndex < 0 || nakshatraIndex >= nakshatraCount) {
      throw StateError('Nakshatra index escaped the canonical 27-fold cycle.');
    }

    final degreesIntoNakshatra =
        longitude - (nakshatraIndex * nakshatraSpanDegrees);
    var pada = (degreesIntoNakshatra / padaSpanDegrees).floor() + 1;
    if (pada < 1) pada = 1;
    if (pada > padaCountPerNakshatra) pada = padaCountPerNakshatra;

    return VedicNakshatraPosition(
      jdTt: snapshot.jdTt,
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
      siderealMoonLongitudeDegrees: longitude,
      nakshatraIndex: nakshatraIndex,
      nakshatraId: canonicalNakshatraIds[nakshatraIndex],
      pada: pada,
      degreesIntoNakshatra: degreesIntoNakshatra,
    );
  }
}
