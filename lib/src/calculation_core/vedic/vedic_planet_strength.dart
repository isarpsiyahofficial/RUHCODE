import '../ephemeris/ephemeris.dart';
import 'vedic_shadbala.dart';

final class VedicStrengthMetric {
  VedicStrengthMetric({
    required this.id,
    required this.value,
    required this.unit,
    required this.methodId,
    required this.methodVersion,
    required this.sourceId,
  }) {
    if (id.trim().isEmpty ||
        unit.trim().isEmpty ||
        methodId.trim().isEmpty ||
        methodVersion.trim().isEmpty ||
        sourceId.trim().isEmpty) {
      throw ArgumentError('Vedic strength metrics require explicit identity and provenance.');
    }
    if (!value.isFinite) {
      throw RangeError('Vedic strength metric values must be finite.');
    }
  }

  final String id;
  final double value;
  final String unit;
  final String methodId;
  final String methodVersion;
  final String sourceId;
}

final class VedicPlanetStrengthProfile {
  VedicPlanetStrengthProfile({
    required this.body,
    required Iterable<VedicStrengthMetric> metrics,
  }) : metrics = List<VedicStrengthMetric>.unmodifiable(metrics) {
    if (this.metrics.isEmpty) {
      throw ArgumentError('Planet strength profiles require at least one explicit metric.');
    }
    final ids = <String>{};
    for (final metric in this.metrics) {
      if (!ids.add(metric.id)) {
        throw StateError('Duplicate Vedic planet-strength metric id: ${metric.id}.');
      }
    }
  }

  final AstroBody body;
  final List<VedicStrengthMetric> metrics;

  VedicStrengthMetric metric(String id) =>
      metrics.singleWhere((metric) => metric.id == id);
}

final class VedicPlanetStrengthSnapshot {
  VedicPlanetStrengthSnapshot({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required Iterable<VedicPlanetStrengthProfile> profiles,
  }) : profiles = List<VedicPlanetStrengthProfile>.unmodifiable(profiles) {
    if (!jdTt.isFinite ||
        ephemerisSourceId.trim().isEmpty ||
        ephemerisDataVersion.trim().isEmpty ||
        ayanamshaId.trim().isEmpty ||
        ayanamshaDataVersion.trim().isEmpty ||
        this.profiles.isEmpty) {
      throw StateError('Vedic planet-strength snapshots require calculation provenance.');
    }
    final bodies = <AstroBody>{};
    for (final profile in this.profiles) {
      if (!bodies.add(profile.body)) {
        throw StateError('Duplicate planet strength profile for ${profile.body.name}.');
      }
    }
  }

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final List<VedicPlanetStrengthProfile> profiles;
}

/// RC-0121 keeps Vedic planet-strength assessment separate from RC-0120.
///
/// The layer can expose Shadbala as one provenance-tagged metric without
/// pretending that Shadbala is the only possible Vedic strength doctrine. Other
/// strength metrics may be added only with their own versioned method/source.
/// No hidden weighting or synthetic combined score is created here.
abstract final class VedicPlanetStrengthEngine {
  static VedicStrengthMetric shadbalaMetric(PlanetShadbala shadbala) =>
      VedicStrengthMetric(
        id: 'shadbala.totalRupa',
        value: shadbala.totalRupa,
        unit: 'rupa',
        methodId: 'shadbala-six-component-sum',
        methodVersion: '1',
        sourceId: shadbala.components.map((value) => value.sourceId).toSet().join('|'),
      );

  static VedicPlanetStrengthSnapshot assemble({
    required double jdTt,
    required String ephemerisSourceId,
    required String ephemerisDataVersion,
    required String ayanamshaId,
    required String ayanamshaDataVersion,
    required Iterable<VedicPlanetStrengthProfile> profiles,
  }) =>
      VedicPlanetStrengthSnapshot(
        jdTt: jdTt,
        ephemerisSourceId: ephemerisSourceId,
        ephemerisDataVersion: ephemerisDataVersion,
        ayanamshaId: ayanamshaId,
        ayanamshaDataVersion: ayanamshaDataVersion,
        profiles: profiles,
      );
}
