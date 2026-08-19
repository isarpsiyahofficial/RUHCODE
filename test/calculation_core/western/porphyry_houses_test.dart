import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/porphyry_houses.dart';

void main() {
  group('Porphyry houses', () {
    test('preserves ASC/IC/DSC/MC as angular cusps', () {
      final houses = PorphyryHouses.calculate(
        ascendantLongitude: 120.0,
        midheavenLongitude: 30.0,
      );

      expect(houses.cusp(1), 120.0);
      expect(houses.cusp(4), 210.0);
      expect(houses.cusp(7), 300.0);
      expect(houses.cusp(10), 30.0);
    });

    test('divides each quadrant into three equal ecliptic arcs', () {
      final houses = PorphyryHouses.calculate(
        ascendantLongitude: 120.0,
        midheavenLongitude: 30.0,
      );

      expect(houses.cusps, <double>[
        120.0,
        150.0,
        180.0,
        210.0,
        240.0,
        270.0,
        300.0,
        330.0,
        0.0,
        30.0,
        60.0,
        90.0,
      ]);
    });

    test('handles unequal quadrants and zodiac wrap deterministically', () {
      final houses = PorphyryHouses.calculate(
        ascendantLongitude: 350.0,
        midheavenLongitude: 260.0,
      );

      expect(houses.cusp(1), 350.0);
      expect(houses.cusp(4), 80.0);
      expect(houses.cusp(7), 170.0);
      expect(houses.cusp(10), 260.0);
      expect(houses.cusp(2), closeTo(20.0, 1e-12));
      expect(houses.cusp(12), closeTo(320.0, 1e-12));
    });

    test('assigns an exact cusp to that cusp house', () {
      final houses = PorphyryHouses.calculate(
        ascendantLongitude: 120.0,
        midheavenLongitude: 30.0,
      );

      expect(houses.houseForLongitude(149.999999), 1);
      expect(houses.houseForLongitude(150.0), 2);
      expect(houses.houseForLongitude(0.0), 9);
      expect(houses.houseForLongitude(119.999999), 12);
      expect(houses.houseForLongitude(120.0), 1);
    });

    test('rejects invalid and degenerate angular geometry', () {
      expect(
        () => PorphyryHouses.calculate(
          ascendantLongitude: double.nan,
          midheavenLongitude: 30.0,
        ),
        throwsArgumentError,
      );
      expect(
        () => PorphyryHouses.calculate(
          ascendantLongitude: 120.0,
          midheavenLongitude: 300.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
