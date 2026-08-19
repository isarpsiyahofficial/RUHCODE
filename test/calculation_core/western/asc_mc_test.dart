import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/asc_mc.dart';

void main() {
  group('WesternAscMc.calculateFromLocalSidereal', () {
    const epsilon = 23.439291111;

    test('equator cardinal sidereal angles preserve expected quadrants', () {
      final zero = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 0,
        latitudeDegreesNorth: 0,
        meanObliquityDegrees: epsilon,
      );
      expect(zero.midheavenDegrees, closeTo(0, 1e-10));
      expect(zero.ascendantDegrees, closeTo(90, 1e-10));

      final ninety = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 90,
        latitudeDegreesNorth: 0,
        meanObliquityDegrees: epsilon,
      );
      expect(ninety.midheavenDegrees, closeTo(90, 1e-10));
      expect(ninety.ascendantDegrees, closeTo(180, 1e-10));

      final oneEighty = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 180,
        latitudeDegreesNorth: 0,
        meanObliquityDegrees: epsilon,
      );
      expect(oneEighty.midheavenDegrees, closeTo(180, 1e-10));
      expect(oneEighty.ascendantDegrees, closeTo(270, 1e-10));

      final twoSeventy = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 270,
        latitudeDegreesNorth: 0,
        meanObliquityDegrees: epsilon,
      );
      expect(twoSeventy.midheavenDegrees, closeTo(270, 1e-10));
      expect(twoSeventy.ascendantDegrees, closeTo(0, 1e-10));
    });

    test('normalizes negative and >360 local sidereal inputs', () {
      final negative = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: -1,
        latitudeDegreesNorth: 41,
        meanObliquityDegrees: epsilon,
      );
      final wrapped = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 359,
        latitudeDegreesNorth: 41,
        meanObliquityDegrees: epsilon,
      );
      expect(negative.ascendantDegrees, closeTo(wrapped.ascendantDegrees, 1e-12));
      expect(negative.midheavenDegrees, closeTo(wrapped.midheavenDegrees, 1e-12));
    });

    test('rejects exact geographic poles and invalid obliquity', () {
      expect(
        () => WesternAscMc.calculateFromLocalSidereal(
          localMeanSiderealDegrees: 10,
          latitudeDegreesNorth: 90,
          meanObliquityDegrees: epsilon,
        ),
        throwsRangeError,
      );
      expect(
        () => WesternAscMc.calculateFromLocalSidereal(
          localMeanSiderealDegrees: 10,
          latitudeDegreesNorth: 0,
          meanObliquityDegrees: 0,
        ),
        throwsRangeError,
      );
    });
  });

  group('mean obliquity', () {
    test('IAU 2006 J2000 value is 84381.406 arcsec', () {
      final epsilon = WesternAscMc.meanObliquityIau2006(2451545.0);
      expect(epsilon, closeTo(84381.406 / 3600.0, 1e-12));
    });
  });
}
