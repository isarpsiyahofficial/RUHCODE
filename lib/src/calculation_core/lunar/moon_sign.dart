import '../ephemeris/ephemeris.dart';

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

final class MoonSignResult {
  const MoonSignResult({
    required this.jdTt,
    required this.sign,
    required this.longitudeDegrees,
    required this.degreeWithinSign,
    required this.sourceId,
    required this.dataVersion,
  });

  final double jdTt;
  final TropicalZodiacSign sign;
  final double longitudeDegrees;
  final double degreeWithinSign;
  final String sourceId;
  final String dataVersion;
}

final class MoonSignEngine {
  const MoonSignEngine(this.ephemeris);

  final EphemerisProvider ephemeris;

  MoonSignResult calculate(double jdTt) {
    ephemeris.coverage.requireContains(jdTt);
    final moon = ephemeris.stateAt(body: AstroBody.moon, jdTt: jdTt);
    if ((moon.jdTt - jdTt).abs() > 1e-9) {
      throw StateError('Moon sign requires the exact requested TT instant.');
    }
    final index = (moon.longitudeDegrees / 30.0).floor();
    if (index < 0 || index >= TropicalZodiacSign.values.length) {
      throw StateError('Normalized Moon longitude produced an invalid tropical sign index.');
    }
    return MoonSignResult(
      jdTt: jdTt,
      sign: TropicalZodiacSign.values[index],
      longitudeDegrees: moon.longitudeDegrees,
      degreeWithinSign: moon.longitudeDegrees - index * 30.0,
      sourceId: moon.sourceId,
      dataVersion: moon.dataVersion,
    );
  }
}
