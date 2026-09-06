import '../ephemeris/ephemeris.dart';

enum ShadbalaComponent {
  sthana,
  dig,
  kala,
  cheshta,
  naisargika,
  drik,
}

final class ShadbalaComponentValue {
  ShadbalaComponentValue({
    required this.component,
    required this.rupa,
    required this.methodId,
    required this.methodVersion,
    required this.sourceId,
  }) {
    if (!rupa.isFinite || rupa < 0) {
      throw RangeError('Shadbala component strength must be finite and non-negative.');
    }
    if (methodId.trim().isEmpty ||
        methodVersion.trim().isEmpty ||
        sourceId.trim().isEmpty) {
      throw ArgumentError('Shadbala component values require method/source provenance.');
    }
  }

  final ShadbalaComponent component;
  final double rupa;
  final String methodId;
  final String methodVersion;
  final String sourceId;
}

final class PlanetShadbala {
  PlanetShadbala({
    required this.body,
    required Iterable<ShadbalaComponentValue> components,
  }) : components = List<ShadbalaComponentValue>.unmodifiable(components) {
    final byType = <ShadbalaComponent, ShadbalaComponentValue>{};
    for (final value in this.components) {
      if (byType.putIfAbsent(value.component, () => value) != value) {
        throw StateError('Duplicate Shadbala component: ${value.component.name}.');
      }
    }
    final missing = ShadbalaComponent.values.where((type) => !byType.containsKey(type));
    if (missing.isNotEmpty || byType.length != ShadbalaComponent.values.length) {
      throw StateError('Shadbala requires exactly the six canonical component groups.');
    }
    totalRupa = this.components.fold<double>(0, (sum, value) => sum + value.rupa);
  }

  final AstroBody body;
  final List<ShadbalaComponentValue> components;
  late final double totalRupa;

  ShadbalaComponentValue component(ShadbalaComponent type) =>
      components.singleWhere((value) => value.component == type);
}

final class ShadbalaSnapshot {
  ShadbalaSnapshot({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required Iterable<PlanetShadbala> planets,
  }) : planets = List<PlanetShadbala>.unmodifiable(planets) {
    if (!jdTt.isFinite ||
        ephemerisSourceId.trim().isEmpty ||
        ephemerisDataVersion.trim().isEmpty ||
        ayanamshaId.trim().isEmpty ||
        ayanamshaDataVersion.trim().isEmpty ||
        this.planets.isEmpty) {
      throw StateError('Shadbala snapshots require explicit calculation provenance.');
    }
    final bodies = <AstroBody>{};
    for (final planet in this.planets) {
      if (!bodies.add(planet.body)) {
        throw StateError('Shadbala snapshot contains duplicate planets.');
      }
    }
  }

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final List<PlanetShadbala> planets;
}

/// RC-0120 professional Shadbala boundary.
///
/// The six classical strength groups are kept separate and provenance-tagged.
/// This layer deliberately does not invent formulas or silently collapse an
/// incomplete component set into a professional score. Formula providers can be
/// added independently once their exact classical/source and golden evidence is
/// versioned.
abstract final class VedicShadbalaEngine {
  static ShadbalaSnapshot assemble({
    required double jdTt,
    required String ephemerisSourceId,
    required String ephemerisDataVersion,
    required String ayanamshaId,
    required String ayanamshaDataVersion,
    required Iterable<PlanetShadbala> planets,
  }) =>
      ShadbalaSnapshot(
        jdTt: jdTt,
        ephemerisSourceId: ephemerisSourceId,
        ephemerisDataVersion: ephemerisDataVersion,
        ayanamshaId: ayanamshaId,
        ayanamshaDataVersion: ayanamshaDataVersion,
        planets: planets,
      );
}
