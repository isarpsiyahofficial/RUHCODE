enum NumerologySystemId { pythagorean, chaldean, loShuGrid }

extension NumerologySystemLabel on NumerologySystemId {
  String get displayName => switch (this) {
        NumerologySystemId.pythagorean => 'Pythagorean',
        NumerologySystemId.chaldean => 'Chaldean',
        NumerologySystemId.loShuGrid => 'Lo Shu Grid',
      };
}

abstract interface class NumerologySystem<I, O> {
  NumerologySystemId get systemId;
  String get version;
  String get sourceId;

  O calculate(I input);
}

/// RC-0162 marker: Pythagorean numerology remains an independently identifiable
/// calculation system and cannot silently fall back to Chaldean mappings.
abstract interface class PythagoreanNumerologySystem<I, O>
    implements NumerologySystem<I, O> {}

/// RC-0163 marker: Chaldean numerology remains an independently identifiable
/// calculation system and cannot reuse Pythagorean mappings by accident.
abstract interface class ChaldeanNumerologySystem<I, O>
    implements NumerologySystem<I, O> {}

/// RC-0164 marker: Lo Shu Grid is a separate grid-oriented calculation system,
/// not an output mode of either name-number system.
abstract interface class LoShuGridSystem<I, O> implements NumerologySystem<I, O> {}

final class NumerologyResultEnvelope<T> {
  NumerologyResultEnvelope({
    required this.systemId,
    required this.version,
    required this.sourceId,
    required this.value,
  }) {
    if (version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Numerology result provenance must not be empty.');
    }
  }

  final NumerologySystemId systemId;
  final String version;
  final String sourceId;
  final T value;

  /// RC-0165: the selected system identity remains visible to product/UI layers.
  String get systemDisplayName => systemId.displayName;
}

final class NumerologySystemRegistry {
  NumerologySystemRegistry(Iterable<NumerologySystem<dynamic, dynamic>> systems)
      : systems = Map.unmodifiable(_index(systems));

  final Map<NumerologySystemId, NumerologySystem<dynamic, dynamic>> systems;

  static Map<NumerologySystemId, NumerologySystem<dynamic, dynamic>> _index(
    Iterable<NumerologySystem<dynamic, dynamic>> input,
  ) {
    final result = <NumerologySystemId, NumerologySystem<dynamic, dynamic>>{};
    for (final system in input) {
      if (system.version.trim().isEmpty || system.sourceId.trim().isEmpty) {
        throw StateError('Numerology system provenance must not be empty.');
      }
      if (result.containsKey(system.systemId)) {
        throw StateError('Duplicate numerology system: ${system.systemId.name}');
      }
      result[system.systemId] = system;
    }
    return result;
  }
}
