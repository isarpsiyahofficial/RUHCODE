final class PorphyryHouseCusps {
  PorphyryHouseCusps._({
    required this.ascendantLongitude,
    required this.midheavenLongitude,
    required List<double> cusps,
  }) : cusps = List<double>.unmodifiable(cusps) {
    if (cusps.length != 12) {
      throw ArgumentError.value(cusps.length, 'cusps.length', 'Expected 12 house cusps.');
    }
    for (final cusp in cusps) {
      _requireLongitude(cusp, 'cusp');
    }
  }

  final double ascendantLongitude;
  final double midheavenLongitude;
  final List<double> cusps;

  double cusp(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw RangeError.range(houseNumber, 1, 12, 'houseNumber');
    }
    return cusps[houseNumber - 1];
  }

  int houseForLongitude(double longitude) {
    _requireLongitude(longitude, 'longitude');
    for (var index = 0; index < 12; index++) {
      final start = cusps[index];
      final end = cusps[(index + 1) % 12];
      final span = _forwardArc(start, end);
      final offset = _forwardArc(start, longitude);
      if (offset < span) {
        return index + 1;
      }
    }
    // A valid longitude must belong to one of the twelve non-degenerate arcs.
    throw StateError('Longitude could not be assigned to a Porphyry house.');
  }
}

/// Porphyry divides each ecliptic quadrant between the four angles into
/// three equal ecliptic arcs. It is intentionally isolated from Placidus:
/// callers must make any fallback decision explicitly instead of silently
/// changing house systems.
abstract final class PorphyryHouses {
  static PorphyryHouseCusps calculate({
    required double ascendantLongitude,
    required double midheavenLongitude,
  }) {
    _requireLongitude(ascendantLongitude, 'ascendantLongitude');
    _requireLongitude(midheavenLongitude, 'midheavenLongitude');

    final descendant = _normalize(ascendantLongitude + 180.0);
    final imumCoeli = _normalize(midheavenLongitude + 180.0);

    final q1 = _forwardArc(ascendantLongitude, imumCoeli);
    final q2 = _forwardArc(imumCoeli, descendant);
    final q3 = _forwardArc(descendant, midheavenLongitude);
    final q4 = _forwardArc(midheavenLongitude, ascendantLongitude);

    for (final entry in <String, double>{
      'ASC→IC': q1,
      'IC→DSC': q2,
      'DSC→MC': q3,
      'MC→ASC': q4,
    }.entries) {
      if (entry.value <= 0.0 || entry.value >= 180.0) {
        throw ArgumentError(
          'Degenerate angular geometry for Porphyry quadrant ${entry.key}: ${entry.value}°.',
        );
      }
    }

    final cusps = <double>[
      ascendantLongitude,
      _normalize(ascendantLongitude + q1 / 3.0),
      _normalize(ascendantLongitude + 2.0 * q1 / 3.0),
      imumCoeli,
      _normalize(imumCoeli + q2 / 3.0),
      _normalize(imumCoeli + 2.0 * q2 / 3.0),
      descendant,
      _normalize(descendant + q3 / 3.0),
      _normalize(descendant + 2.0 * q3 / 3.0),
      midheavenLongitude,
      _normalize(midheavenLongitude + q4 / 3.0),
      _normalize(midheavenLongitude + 2.0 * q4 / 3.0),
    ];

    return PorphyryHouseCusps._(
      ascendantLongitude: ascendantLongitude,
      midheavenLongitude: midheavenLongitude,
      cusps: cusps,
    );
  }
}

double _forwardArc(double start, double end) => _normalize(end - start);

double _normalize(double degrees) {
  final normalized = degrees % 360.0;
  return normalized < 0 ? normalized + 360.0 : normalized;
}

void _requireLongitude(double value, String name) {
  if (!value.isFinite || value < 0.0 || value >= 360.0) {
    throw ArgumentError.value(value, name, 'Expected longitude in [0, 360).');
  }
}
