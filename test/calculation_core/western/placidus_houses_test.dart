import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/asc_mc.dart';
import 'package:ruh_code/src/calculation_core/western/placidus_houses.dart';

void main() {
  group('PlacidusHouses', () {
    test('converges for ordinary latitude and preserves angular/opposite cusps', () {
      final angles = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 120.0,
        latitudeDegreesNorth: 41.0,
        meanObliquityDegrees: 23.4393,
      );

      final result = PlacidusHouses.calculate(
        angles: angles,
        latitudeDegreesNorth: 41.0,
      );

      expect(result.status, PlacidusResultStatus.success);
      expect(result.effectiveSystem, 'PLACIDUS');
      expect(result.reason, isNull);
      final houses = result.placidus!;
      expect(houses.cusps, hasLength(12));
      expect(houses.iterationsUsed, inInclusiveRange(1, PlacidusHouses.maxIterations));
      expect(_angularError(houses.cusp(1), angles.ascendantDegrees), lessThan(1e-9));
      expect(_angularError(houses.cusp(10), angles.midheavenDegrees), lessThan(1e-9));
      for (var house = 1; house <= 6; house++) {
        expect(
          _angularError(houses.cusp(house + 6), _normalize(houses.cusp(house) + 180.0)),
          lessThan(1e-8),
        );
      }
    });

    test('exact cusp belongs to the house beginning at that cusp', () {
      final angles = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 15.0,
        latitudeDegreesNorth: -33.9,
        meanObliquityDegrees: 23.4393,
      );
      final result = PlacidusHouses.calculate(
        angles: angles,
        latitudeDegreesNorth: -33.9,
      );
      expect(result.status, PlacidusResultStatus.success);
      final houses = result.placidus!;
      for (var house = 1; house <= 12; house++) {
        expect(houses.houseForLongitude(houses.cusp(house)), house);
      }
    });

    test('polar-circle geometry is unavailable without explicit fallback', () {
      final angles = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 80.0,
        latitudeDegreesNorth: 70.0,
        meanObliquityDegrees: 23.4393,
      );
      final result = PlacidusHouses.calculate(
        angles: angles,
        latitudeDegreesNorth: 70.0,
      );

      expect(result.status, PlacidusResultStatus.unavailable);
      expect(result.effectiveSystem, 'UNAVAILABLE');
      expect(result.placidus, isNull);
      expect(result.porphyry, isNull);
      expect(result.reason, contains('polar circle'));
    });

    test('Porphyry fallback is explicit and visible in metadata', () {
      final angles = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 80.0,
        latitudeDegreesNorth: 70.0,
        meanObliquityDegrees: 23.4393,
      );
      final result = PlacidusHouses.calculate(
        angles: angles,
        latitudeDegreesNorth: 70.0,
        fallbackPolicy: PlacidusFallbackPolicy.explicitPorphyry,
      );

      expect(result.status, PlacidusResultStatus.fallback);
      expect(result.requestedSystem, 'PLACIDUS');
      expect(result.effectiveSystem, 'PORPHYRY');
      expect(result.placidus, isNull);
      expect(result.porphyry, isNotNull);
      expect(result.reason, isNotNull);
    });

    test('invalid latitude is rejected instead of silently normalized', () {
      final angles = WesternAscMc.calculateFromLocalSidereal(
        localMeanSiderealDegrees: 0.0,
        latitudeDegreesNorth: 0.0,
        meanObliquityDegrees: 23.4393,
      );
      expect(
        () => PlacidusHouses.calculate(angles: angles, latitudeDegreesNorth: 90.0),
        throwsRangeError,
      );
    });
  });
}

double _normalize(double value) {
  final n = value % 360.0;
  return n < 0 ? n + 360.0 : n;
}

double _angularError(double a, double b) {
  final d = (_normalize(a) - _normalize(b)).abs();
  return d > 180.0 ? 360.0 - d : d;
}
