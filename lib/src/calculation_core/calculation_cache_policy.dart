enum CalculationCacheKind {
  natal,
  daily,
  planetaryHour,
  transit,
  solarReturn,
}

final class CalculationCacheKey {
  const CalculationCacheKey({
    required this.subjectId,
    required this.inputFingerprint,
    required this.engineVersion,
    required this.kind,
  });

  final String subjectId;
  final String inputFingerprint;
  final String engineVersion;
  final CalculationCacheKind kind;

  String get stableId => '${kind.name}|$subjectId|$engineVersion|$inputFingerprint';

  void validate() {
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('Cache key requires subjectId');
    }
    if (inputFingerprint.trim().isEmpty) {
      throw ArgumentError('Cache key requires canonical inputFingerprint');
    }
    if (engineVersion.trim().isEmpty) {
      throw ArgumentError('Cache key requires engineVersion');
    }
  }

  bool matches(CalculationCacheKey other) =>
      subjectId == other.subjectId &&
      inputFingerprint == other.inputFingerprint &&
      engineVersion == other.engineVersion &&
      kind == other.kind;
}

/// Runtime context that may invalidate current/daily calculations but must not
/// silently mutate natal identity.
final class CalculationCacheContext {
  const CalculationCacheContext({
    required this.calculationTimezoneId,
    required this.localDayId,
    required this.planetaryHourWindowId,
    required this.natalLocationId,
    this.currentLocationId,
    this.solarReturnLocationId,
  });

  final String calculationTimezoneId;
  final String localDayId;
  final String planetaryHourWindowId;
  final String natalLocationId;
  final String? currentLocationId;
  final String? solarReturnLocationId;

  void validateFor(CalculationCacheKind kind) {
    if (calculationTimezoneId.trim().isEmpty) {
      throw ArgumentError('Calculation timezone must be explicit');
    }
    if (natalLocationId.trim().isEmpty) {
      throw ArgumentError('Natal location must be explicit');
    }
    if ((kind == CalculationCacheKind.daily || kind == CalculationCacheKind.planetaryHour) &&
        localDayId.trim().isEmpty) {
      throw ArgumentError('Daily calculation requires a local day identity');
    }
    if (kind == CalculationCacheKind.planetaryHour && planetaryHourWindowId.trim().isEmpty) {
      throw ArgumentError('Planetary-hour cache requires a window identity');
    }
    if (kind == CalculationCacheKind.transit &&
        (currentLocationId == null || currentLocationId!.trim().isEmpty)) {
      throw ArgumentError('Transit context requires an explicit current location');
    }
    if (kind == CalculationCacheKind.solarReturn &&
        (solarReturnLocationId == null || solarReturnLocationId!.trim().isEmpty)) {
      throw ArgumentError('Solar Return requires an explicit technique location');
    }
  }
}

final class CalculationManifestOverrides {
  CalculationManifestOverrides(Map<String, String> values)
      : values = Map.unmodifiable(Map.of(values)) {
    for (final entry in this.values.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) {
        throw ArgumentError('Calculation Manifest override keys and values must be non-empty');
      }
    }
  }

  final Map<String, String> values;

  bool get hasOverrides => values.isNotEmpty;
}

final class CalculationCacheRecord<T> {
  const CalculationCacheRecord({
    required this.key,
    required this.value,
    required this.generatedAtUtc,
    required this.context,
    required this.manifestOverrides,
  });

  final CalculationCacheKey key;
  final T value;
  final DateTime generatedAtUtc;
  final CalculationCacheContext context;
  final CalculationManifestOverrides manifestOverrides;
}

abstract interface class CalculationCacheStore<T> {
  CalculationCacheRecord<T>? read(String stableId);
  void write(CalculationCacheRecord<T> record);
  void remove(String stableId);
  void clear();
}

final class InMemoryCalculationCacheStore<T> implements CalculationCacheStore<T> {
  final Map<String, CalculationCacheRecord<T>> _records = {};

  @override
  CalculationCacheRecord<T>? read(String stableId) => _records[stableId];

  @override
  void write(CalculationCacheRecord<T> record) {
    record.key.validate();
    _records[record.key.stableId] = record;
  }

  @override
  void remove(String stableId) => _records.remove(stableId);

  @override
  void clear() => _records.clear();
}

final class CalculationCachePolicy {
  const CalculationCachePolicy();

  bool isReusable<T>({
    required CalculationCacheRecord<T> record,
    required CalculationCacheKey expectedKey,
    required CalculationCacheContext currentContext,
  }) {
    expectedKey.validate();
    currentContext.validateFor(expectedKey.kind);

    // Subject, canonical input and engineVersion are part of the identity. An
    // engine upgrade or another person's record can never be reused.
    if (!record.key.matches(expectedKey)) {
      return false;
    }

    switch (expectedKey.kind) {
      case CalculationCacheKind.natal:
        // Travel/current timezone changes do not alter a natal calculation.
        return record.context.natalLocationId == currentContext.natalLocationId;
      case CalculationCacheKind.daily:
        return record.context.calculationTimezoneId == currentContext.calculationTimezoneId &&
            record.context.localDayId == currentContext.localDayId;
      case CalculationCacheKind.planetaryHour:
        return record.context.calculationTimezoneId == currentContext.calculationTimezoneId &&
            record.context.localDayId == currentContext.localDayId &&
            record.context.planetaryHourWindowId == currentContext.planetaryHourWindowId;
      case CalculationCacheKind.transit:
        return record.context.currentLocationId == currentContext.currentLocationId &&
            record.context.calculationTimezoneId == currentContext.calculationTimezoneId;
      case CalculationCacheKind.solarReturn:
        return record.context.solarReturnLocationId == currentContext.solarReturnLocationId;
    }
  }
}

final class CalculationCacheCoordinator<T> {
  const CalculationCacheCoordinator({
    required this.store,
    this.policy = const CalculationCachePolicy(),
  });

  final CalculationCacheStore<T> store;
  final CalculationCachePolicy policy;

  T getOrCompute({
    required CalculationCacheKey key,
    required CalculationCacheContext context,
    required CalculationManifestOverrides manifestOverrides,
    required DateTime generatedAtUtc,
    required T Function() computeFromSource,
  }) {
    key.validate();
    context.validateFor(key.kind);
    final cached = store.read(key.stableId);
    if (cached != null &&
        policy.isReusable(record: cached, expectedKey: key, currentContext: context)) {
      return cached.value;
    }

    // Cache is derivative only: missing/stale cache always rebuilds from the
    // authoritative source/calculation callback.
    final rebuilt = computeFromSource();
    store.write(
      CalculationCacheRecord<T>(
        key: key,
        value: rebuilt,
        generatedAtUtc: generatedAtUtc.toUtc(),
        context: context,
        manifestOverrides: manifestOverrides,
      ),
    );
    return rebuilt;
  }
}
