import '../../domain/ids/entity_id.dart';
import '../time/civil_calendar.dart';

final class DailySnapshotIdentity {
  const DailySnapshotIdentity({
    required this.profileId,
    required this.civilDate,
    required this.ianaTimeZoneId,
    required this.latitude,
    required this.longitude,
    required this.engineVersion,
    required this.timezoneDatabaseVersion,
  });

  final EntityId profileId;
  final CivilDate civilDate;
  final String ianaTimeZoneId;
  final double latitude;
  final double longitude;
  final String engineVersion;
  final String timezoneDatabaseVersion;

  String get dateKey => civilDate.isoKey;

  String get cacheKey => <String>[
        'daily',
        profileId.value,
        dateKey,
        ianaTimeZoneId,
        _coordinateKey(latitude),
        _coordinateKey(longitude),
        engineVersion,
        timezoneDatabaseVersion,
      ].join('|');

  static String _coordinateKey(double value) => value.toStringAsFixed(6);

  @override
  bool operator ==(Object other) =>
      other is DailySnapshotIdentity &&
      profileId == other.profileId &&
      civilDate == other.civilDate &&
      ianaTimeZoneId == other.ianaTimeZoneId &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      engineVersion == other.engineVersion &&
      timezoneDatabaseVersion == other.timezoneDatabaseVersion;

  @override
  int get hashCode => Object.hash(
        profileId,
        civilDate,
        ianaTimeZoneId,
        latitude,
        longitude,
        engineVersion,
        timezoneDatabaseVersion,
      );
}

enum DailyFactorKind {
  moonSign,
  moonPhase,
  transit,
  planetaryHour,
  personalDay,
  vedicIndicator,
}

final class DailyFactorReference {
  const DailyFactorReference({
    required this.kind,
    required this.sourceEngineId,
    required this.sourceEngineVersion,
    required this.resultId,
  });

  final DailyFactorKind kind;
  final String sourceEngineId;
  final String sourceEngineVersion;
  final String resultId;
}

final class DailySnapshot {
  const DailySnapshot({
    required this.identity,
    required this.generatedAtUtc,
    required this.factors,
  });

  final DailySnapshotIdentity identity;
  final DateTime generatedAtUtc;
  final List<DailyFactorReference> factors;

  bool get isEmpty => factors.isEmpty;
}

abstract final class DailySnapshotAssembler {
  static const List<DailyFactorKind> factorOrder = <DailyFactorKind>[
    DailyFactorKind.moonSign,
    DailyFactorKind.moonPhase,
    DailyFactorKind.transit,
    DailyFactorKind.planetaryHour,
    DailyFactorKind.personalDay,
    DailyFactorKind.vedicIndicator,
  ];

  static DailySnapshot assemble({
    required DailySnapshotIdentity identity,
    required DateTime generatedAtUtc,
    required Iterable<DailyFactorReference> factors,
  }) {
    if (!generatedAtUtc.isUtc) {
      throw ArgumentError.value(
        generatedAtUtc,
        'generatedAtUtc',
        'DailySnapshot generation time must be UTC.',
      );
    }

    final byKind = <DailyFactorKind, DailyFactorReference>{};
    for (final factor in factors) {
      _validateFactor(factor);
      if (byKind.containsKey(factor.kind)) {
        throw StateError(
          'Duplicate daily factor kind is not allowed: ${factor.kind.name}',
        );
      }
      byKind[factor.kind] = factor;
    }

    final ordered = <DailyFactorReference>[];
    for (final kind in factorOrder) {
      final factor = byKind[kind];
      if (factor != null) {
        ordered.add(factor);
      }
    }

    return DailySnapshot(
      identity: identity,
      generatedAtUtc: generatedAtUtc,
      factors: List<DailyFactorReference>.unmodifiable(ordered),
    );
  }

  static void _validateFactor(DailyFactorReference factor) {
    if (factor.sourceEngineId.trim().isEmpty) {
      throw StateError('Daily factor sourceEngineId must not be empty.');
    }
    if (factor.sourceEngineVersion.trim().isEmpty) {
      throw StateError('Daily factor sourceEngineVersion must not be empty.');
    }
    if (factor.resultId.trim().isEmpty) {
      throw StateError('Daily factor resultId must not be empty.');
    }
  }
}
