import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

import '../calculation_core/ephemeris/ephemeris.dart';
import '../calculation_core/western/natal_aspects.dart';

const int persistedWesternNatalSnapshotSchemaVersion = 1;
const String persistedWesternNatalCalculationType = 'western.natal';

final class PersistedWesternNatalPlacement {
  const PersistedWesternNatalPlacement({
    required this.body,
    required this.longitudeDeg,
    required this.houseNumber,
    required this.motion,
  });

  final String body;
  final double longitudeDeg;
  final int houseNumber;
  final String motion;

  Map<String, Object> toJson() => <String, Object>{
        'body': body,
        'longitudeDeg': longitudeDeg,
        'houseNumber': houseNumber,
        'motion': motion,
      };
}

final class PersistedWesternNatalAspect {
  const PersistedWesternNatalAspect({
    required this.bodyA,
    required this.bodyB,
    required this.type,
    required this.exactAngleDeg,
    required this.separationDeg,
    required this.deltaFromExactDeg,
    required this.allowedOrbDeg,
  });

  final String bodyA;
  final String bodyB;
  final String type;
  final double exactAngleDeg;
  final double separationDeg;
  final double deltaFromExactDeg;
  final double allowedOrbDeg;

  Map<String, Object> toJson() => <String, Object>{
        'bodyA': bodyA,
        'bodyB': bodyB,
        'type': type,
        'exactAngleDeg': exactAngleDeg,
        'separationDeg': separationDeg,
        'deltaFromExactDeg': deltaFromExactDeg,
        'allowedOrbDeg': allowedOrbDeg,
      };
}

/// Stable persisted projection of a Western natal calculation.
///
/// This is deliberately not a serializer for the live house-engine classes.
/// Placidus, Porphyry, Whole Sign and Equal House have different runtime
/// result types, while a persisted report only needs the exact resolved house
/// system and its twelve cusp longitudes. PDF/UI consumers must read this
/// snapshot instead of recalculating a historical chart.
final class PersistedWesternNatalSnapshot {
  PersistedWesternNatalSnapshot({
    required this.engineVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.ttJulianDay,
    required this.sourceId,
    required this.requestedHouseSystem,
    required this.effectiveHouseSystem,
    required List<double> houseCuspsDeg,
    required List<PersistedWesternNatalPlacement> placements,
    required List<PersistedWesternNatalAspect> aspects,
    this.schemaVersion = persistedWesternNatalSnapshotSchemaVersion,
  })  : houseCuspsDeg = List<double>.unmodifiable(houseCuspsDeg),
        placements = List<PersistedWesternNatalPlacement>.unmodifiable(placements),
        aspects = List<PersistedWesternNatalAspect>.unmodifiable(aspects) {
    _validate();
  }

  final int schemaVersion;
  final String engineVersion;
  final String algorithmVersion;
  final String dataVersion;
  final double ttJulianDay;
  final String sourceId;
  final String requestedHouseSystem;
  final String effectiveHouseSystem;
  final List<double> houseCuspsDeg;
  final List<PersistedWesternNatalPlacement> placements;
  final List<PersistedWesternNatalAspect> aspects;

  Map<String, Object> toJson() => <String, Object>{
        'schemaVersion': schemaVersion,
        'engineVersion': engineVersion,
        'algorithmVersion': algorithmVersion,
        'dataVersion': dataVersion,
        'ttJulianDay': ttJulianDay,
        'sourceId': sourceId,
        'requestedHouseSystem': requestedHouseSystem,
        'effectiveHouseSystem': effectiveHouseSystem,
        'houseCuspsDeg': houseCuspsDeg,
        'placements': placements.map((value) => value.toJson()).toList(growable: false),
        'aspects': aspects.map((value) => value.toJson()).toList(growable: false),
      };

  String get canonicalJson => jsonEncode(_canonicalize(toJson()));

  String get sha256Hex => sha256.convert(utf8.encode(canonicalJson)).toString();

  static PersistedWesternNatalSnapshot fromJson(Map<String, dynamic> json) {
    final schemaVersion = _int(json, 'schemaVersion');
    if (schemaVersion != persistedWesternNatalSnapshotSchemaVersion) {
      throw FormatException('Unsupported Western snapshot schema version: $schemaVersion');
    }

    final placementsRaw = _list(json, 'placements');
    final aspectsRaw = _list(json, 'aspects');
    final cuspsRaw = _list(json, 'houseCuspsDeg');

    return PersistedWesternNatalSnapshot(
      schemaVersion: schemaVersion,
      engineVersion: _string(json, 'engineVersion'),
      algorithmVersion: _string(json, 'algorithmVersion'),
      dataVersion: _string(json, 'dataVersion'),
      ttJulianDay: _double(json, 'ttJulianDay'),
      sourceId: _string(json, 'sourceId'),
      requestedHouseSystem: _string(json, 'requestedHouseSystem'),
      effectiveHouseSystem: _string(json, 'effectiveHouseSystem'),
      houseCuspsDeg: cuspsRaw.map(_asDouble).toList(growable: false),
      placements: placementsRaw.map((raw) {
        final item = _map(raw, 'placement');
        return PersistedWesternNatalPlacement(
          body: _string(item, 'body'),
          longitudeDeg: _double(item, 'longitudeDeg'),
          houseNumber: _int(item, 'houseNumber'),
          motion: _string(item, 'motion'),
        );
      }).toList(growable: false),
      aspects: aspectsRaw.map((raw) {
        final item = _map(raw, 'aspect');
        return PersistedWesternNatalAspect(
          bodyA: _string(item, 'bodyA'),
          bodyB: _string(item, 'bodyB'),
          type: _string(item, 'type'),
          exactAngleDeg: _double(item, 'exactAngleDeg'),
          separationDeg: _double(item, 'separationDeg'),
          deltaFromExactDeg: _double(item, 'deltaFromExactDeg'),
          allowedOrbDeg: _double(item, 'allowedOrbDeg'),
        );
      }).toList(growable: false),
    );
  }

  void _validate() {
    if (schemaVersion != persistedWesternNatalSnapshotSchemaVersion) {
      throw ArgumentError.value(schemaVersion, 'schemaVersion');
    }
    for (final entry in <String, String>{
      'engineVersion': engineVersion,
      'algorithmVersion': algorithmVersion,
      'dataVersion': dataVersion,
      'sourceId': sourceId,
      'requestedHouseSystem': requestedHouseSystem,
      'effectiveHouseSystem': effectiveHouseSystem,
    }.entries) {
      if (entry.value.trim().isEmpty) {
        throw ArgumentError.value(entry.value, entry.key, 'Must not be empty.');
      }
    }
    if (!ttJulianDay.isFinite || ttJulianDay <= 0) {
      throw ArgumentError.value(ttJulianDay, 'ttJulianDay', 'Expected a finite positive TT Julian Day.');
    }
    if (houseCuspsDeg.length != 12) {
      throw ArgumentError.value(houseCuspsDeg.length, 'houseCuspsDeg.length', 'Expected exactly 12 cusps.');
    }
    var totalHouseArc = 0.0;
    for (var index = 0; index < houseCuspsDeg.length; index++) {
      final cusp = houseCuspsDeg[index];
      _requireLongitude(cusp, 'houseCuspDeg');
      final span = _forwardArc(cusp, houseCuspsDeg[(index + 1) % 12]);
      if (!span.isFinite || span <= 0 || span >= 180) {
        throw ArgumentError('Persisted Western house cusps must form twelve non-degenerate forward arcs.');
      }
      totalHouseArc += span;
    }
    if ((totalHouseArc - 360.0).abs() > 1e-7) {
      throw ArgumentError('Persisted Western house cusps must close one exact 360° cycle.');
    }

    final bodies = <String>{};
    final placementLongitudeByBody = <String, double>{};
    final supportedBodies = AstroBody.values.map((value) => value.name).toSet();
    for (final placement in placements) {
      if (!supportedBodies.contains(placement.body)) {
        throw ArgumentError.value(placement.body, 'placement.body', 'Unsupported AstroBody.');
      }
      if (!bodies.add(placement.body)) {
        throw ArgumentError('Western persisted placements must have unique bodies.');
      }
      _requireLongitude(placement.longitudeDeg, 'placement.longitudeDeg');
      if (placement.houseNumber < 1 || placement.houseNumber > 12) {
        throw ArgumentError.value(placement.houseNumber, 'placement.houseNumber');
      }
      final expectedHouse = _houseForLongitude(houseCuspsDeg, placement.longitudeDeg);
      if (expectedHouse != placement.houseNumber) {
        throw ArgumentError(
          'Persisted Western placement house mismatch for ${placement.body}: '
          'stored=${placement.houseNumber}, geometry=$expectedHouse.',
        );
      }
      if (!const {'direct', 'stationary', 'retrograde'}.contains(placement.motion)) {
        throw ArgumentError.value(placement.motion, 'placement.motion');
      }
      placementLongitudeByBody[placement.body] = placement.longitudeDeg;
    }

    final aspectPairs = <String>{};
    for (final aspect in aspects) {
      if (!bodies.contains(aspect.bodyA) || !bodies.contains(aspect.bodyB)) {
        throw ArgumentError('Persisted aspect references a body absent from placements.');
      }
      if (aspect.bodyA == aspect.bodyB) {
        throw ArgumentError('Persisted aspect cannot be a self-aspect.');
      }
      final ordered = <String>[aspect.bodyA, aspect.bodyB]..sort();
      final pairKey = '${ordered[0]}|${ordered[1]}';
      if (!aspectPairs.add(pairKey)) {
        throw ArgumentError('Duplicate persisted aspect pair: $pairKey');
      }
      for (final value in <double>[
        aspect.exactAngleDeg,
        aspect.separationDeg,
        aspect.deltaFromExactDeg,
        aspect.allowedOrbDeg,
      ]) {
        if (!value.isFinite || value < 0) {
          throw ArgumentError.value(value, 'aspectValue', 'Expected finite non-negative value.');
        }
      }
      final type = _majorAspectByName(aspect.type);
      if ((type.exactAngleDegrees - aspect.exactAngleDeg).abs() > 1e-12) {
        throw ArgumentError('Persisted aspect exact angle does not match its aspect type.');
      }
      if (aspect.exactAngleDeg > 180 || aspect.separationDeg > 180) {
        throw ArgumentError('Persisted aspect angles must be within 0..180 degrees.');
      }
      final geometricSeparation = _shortestArc(
        placementLongitudeByBody[aspect.bodyA]!,
        placementLongitudeByBody[aspect.bodyB]!,
      );
      if ((geometricSeparation - aspect.separationDeg).abs() > 1e-9) {
        throw ArgumentError('Persisted aspect separation disagrees with placement geometry.');
      }
      final geometricDelta = (aspect.separationDeg - aspect.exactAngleDeg).abs();
      if ((geometricDelta - aspect.deltaFromExactDeg).abs() > 1e-9) {
        throw ArgumentError('Persisted aspect delta disagrees with separation/exact angle.');
      }
      if (aspect.deltaFromExactDeg > aspect.allowedOrbDeg + 1e-12) {
        throw ArgumentError('Persisted aspect delta exceeds its allowed orb.');
      }
    }
  }
}

final class PersistedWesternNatalEnvelope {
  const PersistedWesternNatalEnvelope({required this.snapshot, required this.snapshotSha256});

  final PersistedWesternNatalSnapshot snapshot;
  final String snapshotSha256;

  Map<String, Object> toCalculationResult() => <String, Object>{
        'snapshotSchemaVersion': snapshot.schemaVersion,
        'snapshot': snapshot.toJson(),
        'snapshotSha256': snapshotSha256,
      };

  static PersistedWesternNatalEnvelope fromCalculationResult(Map<String, dynamic> result) {
    final declaredSchema = _int(result, 'snapshotSchemaVersion');
    if (declaredSchema != persistedWesternNatalSnapshotSchemaVersion) {
      throw FormatException('Unsupported Western result snapshot schema: $declaredSchema');
    }
    final snapshot = PersistedWesternNatalSnapshot.fromJson(_map(result['snapshot'], 'snapshot'));
    final declaredSha = _string(result, 'snapshotSha256').toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(declaredSha)) {
      throw const FormatException('Western snapshot SHA-256 must be lowercase hex.');
    }
    if (snapshot.sha256Hex != declaredSha) {
      throw const FormatException('Western persisted snapshot SHA-256 mismatch.');
    }
    return PersistedWesternNatalEnvelope(snapshot: snapshot, snapshotSha256: declaredSha);
  }

  factory PersistedWesternNatalEnvelope.seal(PersistedWesternNatalSnapshot snapshot) =>
      PersistedWesternNatalEnvelope(snapshot: snapshot, snapshotSha256: snapshot.sha256Hex);
}

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final entries = value.entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return <String, Object?>{
      for (final entry in entries) entry.key: _canonicalize(entry.value),
    };
  }
  if (value is List) return value.map(_canonicalize).toList(growable: false);
  return value;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) throw FormatException('Expected non-empty string: $key');
  return value;
}

int _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || value.toInt() != value) throw FormatException('Expected integer: $key');
  return value.toInt();
}

double _double(Map<String, dynamic> json, String key) => _asDouble(json[key]);

double _asDouble(Object? value) {
  if (value is! num) throw const FormatException('Expected numeric value.');
  final result = value.toDouble();
  if (!result.isFinite) throw const FormatException('Expected finite numeric value.');
  return result;
}

List<dynamic> _list(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('Expected list: $key');
  return value;
}

Map<String, dynamic> _map(Object? value, String key) {
  if (value is! Map) throw FormatException('Expected object: $key');
  return value.map((rawKey, rawValue) => MapEntry(rawKey.toString(), rawValue));
}

MajorAspect _majorAspectByName(String name) {
  for (final value in MajorAspect.values) {
    if (value.name == name) return value;
  }
  throw ArgumentError.value(name, 'aspect.type', 'Unsupported MajorAspect.');
}

int _houseForLongitude(List<double> cusps, double longitude) {
  for (var index = 0; index < 12; index++) {
    final span = _forwardArc(cusps[index], cusps[(index + 1) % 12]);
    if (_forwardArc(cusps[index], longitude) < span) return index + 1;
  }
  throw StateError('Persisted longitude could not be assigned to a house.');
}

double _forwardArc(double start, double end) {
  final value = (end - start) % 360.0;
  return value < 0 ? value + 360.0 : value;
}

double _shortestArc(double a, double b) {
  final delta = _forwardArc(a, b);
  return math.min(delta, 360.0 - delta);
}

void _requireLongitude(double value, String name) {
  if (!value.isFinite || value < 0 || value >= 360) {
    throw ArgumentError.value(value, name, 'Expected longitude in [0, 360).');
  }
}
