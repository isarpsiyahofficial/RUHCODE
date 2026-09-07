enum InterpretationSystem { western, vedic, bazi, numerology, dailyMessage }

enum InterpretationAudience { normal, detailed, professional }

final class InterpretationEntry {
  InterpretationEntry({
    required this.id,
    required this.system,
    required this.conditionId,
    required this.summary,
    required this.technical,
    required this.sourceId,
    required this.version,
  }) {
    if (id.trim().isEmpty || conditionId.trim().isEmpty) {
      throw ArgumentError('interpretation id and condition are required');
    }
    if (summary.trim().isEmpty || technical.trim().isEmpty) {
      throw ArgumentError('summary and technical interpretation are required');
    }
    if (sourceId.trim().isEmpty || version.trim().isEmpty) {
      throw ArgumentError('source provenance is required');
    }
  }

  final String id;
  final InterpretationSystem system;
  final String conditionId;
  final String summary;
  final String technical;
  final String sourceId;
  final String version;
}

final class InterpretationCatalog {
  InterpretationCatalog({
    required this.system,
    required Iterable<InterpretationEntry> entries,
  }) : entries = List.unmodifiable(entries) {
    if (this.entries.any((entry) => entry.system != system)) {
      throw ArgumentError('catalog cannot mix interpretation systems');
    }
    final ids = this.entries.map((entry) => entry.id).toSet();
    if (ids.length != this.entries.length) {
      throw ArgumentError('duplicate interpretation id');
    }
    final conditions = this.entries.map((entry) => entry.conditionId).toSet();
    if (conditions.length != this.entries.length) {
      throw ArgumentError('ambiguous duplicate interpretation condition');
    }
  }

  final InterpretationSystem system;
  final List<InterpretationEntry> entries;

  InterpretationEntry? resolve(String conditionId) {
    for (final entry in entries) {
      if (entry.conditionId == conditionId) return entry;
    }
    return null;
  }
}

final class InterpretationRegistry {
  InterpretationRegistry(Iterable<InterpretationCatalog> catalogs)
      : _catalogs = Map.unmodifiable({
          for (final catalog in catalogs) catalog.system: catalog,
        }) {
    if (_catalogs.length != catalogs.length) {
      throw ArgumentError('each interpretation system must have one catalog');
    }
  }

  final Map<InterpretationSystem, InterpretationCatalog> _catalogs;

  InterpretationEntry? resolve({
    required InterpretationSystem system,
    required String conditionId,
  }) =>
      _catalogs[system]?.resolve(conditionId);
}

final class InterpretationPresentation {
  const InterpretationPresentation({
    required this.summary,
    required this.technical,
    required this.rawCalculation,
    required this.preparedInterpretationVisible,
  });

  final String summary;
  final String? technical;
  final Map<String, Object?>? rawCalculation;
  final bool preparedInterpretationVisible;
}

abstract final class InterpretationPresenter {
  static InterpretationPresentation compose({
    required InterpretationEntry entry,
    required InterpretationAudience audience,
    required Map<String, Object?> rawCalculation,
    bool professionalPreparedInterpretationEnabled = true,
  }) {
    return switch (audience) {
      InterpretationAudience.normal => InterpretationPresentation(
          summary: entry.summary,
          technical: null,
          rawCalculation: null,
          preparedInterpretationVisible: true,
        ),
      InterpretationAudience.detailed => InterpretationPresentation(
          summary: entry.summary,
          technical: entry.technical,
          rawCalculation: Map.unmodifiable(rawCalculation),
          preparedInterpretationVisible: true,
        ),
      InterpretationAudience.professional => InterpretationPresentation(
          summary: professionalPreparedInterpretationEnabled ? entry.summary : '',
          technical:
              professionalPreparedInterpretationEnabled ? entry.technical : null,
          rawCalculation: Map.unmodifiable(rawCalculation),
          preparedInterpretationVisible: professionalPreparedInterpretationEnabled,
        ),
    };
  }
}
