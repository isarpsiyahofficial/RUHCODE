import 'dart:math' as math;

import '../ephemeris/ephemeris.dart';

final class GeographicPoint {
  const GeographicPoint({required this.latitudeDegrees, required this.longitudeDegrees});

  final double latitudeDegrees;
  final double longitudeDegrees;

  void validate() {
    if (!latitudeDegrees.isFinite || latitudeDegrees < -90 || latitudeDegrees > 90) {
      throw RangeError('Latitude must be finite within [-90, 90].');
    }
    if (!longitudeDegrees.isFinite || longitudeDegrees < -180 || longitudeDegrees > 180) {
      throw RangeError('Longitude must be finite within [-180, 180].');
    }
  }
}

final class WesternDavisonChart {
  WesternDavisonChart({
    required this.personAJdTt,
    required this.personBJdTt,
    required this.jdTt,
    required this.location,
    required this.sourceId,
    required this.dataVersion,
    required List<EclipticState> states,
  }) : states = List<EclipticState>.unmodifiable(states);

  final double personAJdTt;
  final double personBJdTt;
  final double jdTt;
  final GeographicPoint location;
  final String sourceId;
  final String dataVersion;
  final List<EclipticState> states;

  EclipticState forBody(AstroBody body) => states.singleWhere((state) => state.body == body);
}

/// Builds the astronomical core of a Davison relationship chart.
///
/// Unlike a midpoint composite, planetary longitudes are not averaged. The two
/// birth TT instants are averaged to one real TT instant, the two geographic
/// coordinates are reduced to their spherical midpoint, and every requested
/// body is freshly evaluated by the supplied versioned ephemeris at that TT.
/// Houses/angles remain outside this machine proof until a separately verified
/// UT/sidereal-time house pipeline consumes [location].
abstract final class WesternDavisonChartBuilder {
  static WesternDavisonChart build({
    required double personAJdTt,
    required GeographicPoint personALocation,
    required double personBJdTt,
    required GeographicPoint personBLocation,
    required EphemerisProvider ephemeris,
    required List<AstroBody> bodies,
  }) {
    if (!personAJdTt.isFinite || !personBJdTt.isFinite) {
      throw ArgumentError('Davison birth TT instants must be finite.');
    }
    personALocation.validate();
    personBLocation.validate();
    if (bodies.isEmpty || bodies.toSet().length != bodies.length) {
      throw StateError('Davison body set must be non-empty and unique.');
    }

    final midpointJdTt = personAJdTt + (personBJdTt - personAJdTt) / 2.0;
    ephemeris.coverage.requireContains(midpointJdTt);
    final midpointLocation = _sphericalMidpoint(personALocation, personBLocation);

    final states = <EclipticState>[];
    for (final body in bodies) {
      final state = ephemeris.stateAt(body: body, jdTt: midpointJdTt);
      if ((state.jdTt - midpointJdTt).abs() > 1e-12 ||
          state.sourceId != ephemeris.coverage.sourceId ||
          state.dataVersion != ephemeris.coverage.dataVersion) {
        throw StateError('Davison ephemeris result provenance/instant mismatch.');
      }
      states.add(state);
    }
    states.sort((a, b) => a.body.index.compareTo(b.body.index));

    return WesternDavisonChart(
      personAJdTt: personAJdTt,
      personBJdTt: personBJdTt,
      jdTt: midpointJdTt,
      location: midpointLocation,
      sourceId: ephemeris.coverage.sourceId,
      dataVersion: ephemeris.coverage.dataVersion,
      states: states,
    );
  }

  static GeographicPoint _sphericalMidpoint(GeographicPoint a, GeographicPoint b) {
    const toRad = math.pi / 180.0;
    const toDeg = 180.0 / math.pi;
    final lat1 = a.latitudeDegrees * toRad;
    final lon1 = a.longitudeDegrees * toRad;
    final lat2 = b.latitudeDegrees * toRad;
    final lon2 = b.longitudeDegrees * toRad;

    final x = math.cos(lat1) * math.cos(lon1) + math.cos(lat2) * math.cos(lon2);
    final y = math.cos(lat1) * math.sin(lon1) + math.cos(lat2) * math.sin(lon2);
    final z = math.sin(lat1) + math.sin(lat2);
    final norm = math.sqrt(x * x + y * y + z * z);
    if (norm < 1e-12) {
      throw StateError('Davison geographic midpoint is undefined for antipodal locations.');
    }

    final latitude = math.atan2(z, math.sqrt(x * x + y * y)) * toDeg;
    var longitude = math.atan2(y, x) * toDeg;
    if (longitude > 180) longitude -= 360;
    if (longitude < -180) longitude += 360;
    return GeographicPoint(latitudeDegrees: latitude, longitudeDegrees: longitude);
  }
}
