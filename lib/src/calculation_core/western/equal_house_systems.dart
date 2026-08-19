enum EqualHouseSystem {
  wholeSign,
  equal,
}

final class HouseCusps {
  HouseCusps._({
    required this.system,
    required this.ascendantLongitude,
    required List<double> cusps,
  }) : cusps = List<double>.unmodifiable(cusps) {
    if (cusps.length != 12) {
      throw ArgumentError.value(cusps.length, 'cusps.length', 'Expected 12 house cusps.');
    }
    for (final cusp in cusps) {
      _requireLongitude(cusp, 'cusp');
    }
  }

  final EqualHouseSystem system;
  final double ascendantLongitude;
  final List<double> cusps;

  double cusp(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw RangeError.range(houseNumber, 1, 12, 'houseNumber');
    }
    return cusps[houseNumber - 1];
  }

  int houseForLongitude(double longitude) {
    _requireLongitude(longitude, 'longitude');
    final offset = _normalize(longitude - cusps.first);
    return (offset / 30.0).floor() + 1;
  }
}

abstract final class EqualHouseSystems {
  static HouseCusps wholeSign({required double ascendantLongitude}) {
    _requireLongitude(ascendantLongitude, 'ascendantLongitude');
    final firstCusp = (ascendantLongitude / 30.0).floor() * 30.0;
    return _build(
      system: EqualHouseSystem.wholeSign,
      ascendantLongitude: ascendantLongitude,
      firstCusp: firstCusp,
    );
  }

  static HouseCusps equal({required double ascendantLongitude}) {
    _requireLongitude(ascendantLongitude, 'ascendantLongitude');
    return _build(
      system: EqualHouseSystem.equal,
      ascendantLongitude: ascendantLongitude,
      firstCusp: ascendantLongitude,
    );
  }

  static HouseCusps _build({
    required EqualHouseSystem system,
    required double ascendantLongitude,
    required double firstCusp,
  }) {
    final cusps = List<double>.generate(
      12,
      (index) => _normalize(firstCusp + index * 30.0),
      growable: false,
    );
    return HouseCusps._(
      system: system,
      ascendantLongitude: ascendantLongitude,
      cusps: cusps,
    );
  }
}

double _normalize(double degrees) {
  final normalized = degrees % 360.0;
  return normalized < 0 ? normalized + 360.0 : normalized;
}

void _requireLongitude(double value, String name) {
  if (!value.isFinite || value < 0.0 || value >= 360.0) {
    throw ArgumentError.value(value, name, 'Expected longitude in [0, 360).');
  }
}
