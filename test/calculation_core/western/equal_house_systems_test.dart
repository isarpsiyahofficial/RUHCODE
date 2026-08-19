import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';

void main() {
  group('Whole Sign', () {
    test('starts first house at beginning of ascendant sign', () {
      final houses = EqualHouseSystems.wholeSign(ascendantLongitude: 125.5);
      expect(houses.cusp(1), 120.0);
      expect(houses.cusp(2), 150.0);
      expect(houses.cusp(12), 90.0);
    });

    test('assigns exact cusp to the next house', () {
      final houses = EqualHouseSystems.wholeSign(ascendantLongitude: 29.999999);
      expect(houses.houseForLongitude(29.999999), 1);
      expect(houses.houseForLongitude(30.0), 2);
      expect(houses.houseForLongitude(359.999999), 12);
    });

    test('wraps Aries boundary without losing house numbering', () {
      final houses = EqualHouseSystems.wholeSign(ascendantLongitude: 359.999999);
      expect(houses.cusp(1), 330.0);
      expect(houses.cusp(2), 0.0);
      expect(houses.houseForLongitude(0.0), 2);
    });
  });

  group('Equal House', () {
    test('uses exact ascendant as first cusp', () {
      final houses = EqualHouseSystems.equal(ascendantLongitude: 125.5);
      expect(houses.cusp(1), 125.5);
      expect(houses.cusp(2), 155.5);
      expect(houses.cusp(9), 5.5);
    });

    test('uses deterministic 30 degree sectors', () {
      final houses = EqualHouseSystems.equal(ascendantLongitude: 350.0);
      expect(houses.houseForLongitude(349.999999), 12);
      expect(houses.houseForLongitude(350.0), 1);
      expect(houses.houseForLongitude(19.999999), 1);
      expect(houses.houseForLongitude(20.0), 2);
    });
  });

  test('rejects invalid longitude instead of normalizing bad input silently', () {
    expect(
      () => EqualHouseSystems.equal(ascendantLongitude: 360.0),
      throwsArgumentError,
    );
    expect(
      () => EqualHouseSystems.wholeSign(ascendantLongitude: double.nan),
      throwsArgumentError,
    );
  });
}
