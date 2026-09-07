enum TimelineWindow { next30Days, next3Months, next1Year }
enum TimelineTopic { relationship, career, general }
enum TimelineImportance { low, medium, high }
enum TimelinePlanet { sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto, node }

final class TimelineEvent {
  TimelineEvent({
    required this.id,
    required this.startsAtUtc,
    required this.importance,
    required this.planet,
    required Iterable<TimelineTopic> topics,
    required this.resultRef,
    required this.sourceId,
    required this.version,
  }) : topics = Set.unmodifiable(topics) {
    if ([id, resultRef, sourceId, version].any((value) => value.trim().isEmpty)) {
      throw ArgumentError('timeline event id/result/source/version required');
    }
    if (!startsAtUtc.isUtc) throw ArgumentError('startsAtUtc must be UTC');
  }

  final String id;
  final DateTime startsAtUtc;
  final TimelineImportance importance;
  final TimelinePlanet planet;
  final Set<TimelineTopic> topics;
  final String resultRef;
  final String sourceId;
  final String version;
}

final class TimelineFilter {
  const TimelineFilter({
    required this.window,
    this.highImportanceOnly = false,
    this.planet,
    this.topic,
  });

  final TimelineWindow window;
  final bool highImportanceOnly;
  final TimelinePlanet? planet;
  final TimelineTopic? topic;
}

final class TimelineFilterPreset {
  TimelineFilterPreset({required this.id, required this.name, required this.filter}) {
    if (id.trim().isEmpty || name.trim().isEmpty) throw ArgumentError('preset id/name required');
  }

  final String id;
  final String name;
  final TimelineFilter filter;
}

final class ProfessionalTimeline {
  ProfessionalTimeline({required this.anchorUtc, required Iterable<TimelineEvent> events})
      : events = List.unmodifiable(events) {
    if (!anchorUtc.isUtc) throw ArgumentError('anchorUtc must be UTC');
    final ids = this.events.map((event) => event.id).toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('duplicate timeline event id');
  }

  final DateTime anchorUtc;
  final List<TimelineEvent> events;

  Duration _windowDuration(TimelineWindow window) => switch (window) {
        TimelineWindow.next30Days => const Duration(days: 30),
        TimelineWindow.next3Months => const Duration(days: 92),
        TimelineWindow.next1Year => const Duration(days: 366),
      };

  List<TimelineEvent> apply(TimelineFilter filter) {
    final end = anchorUtc.add(_windowDuration(filter.window));
    final selected = events.where((event) {
      if (event.startsAtUtc.isBefore(anchorUtc) || event.startsAtUtc.isAfter(end)) return false;
      if (filter.highImportanceOnly && event.importance != TimelineImportance.high) return false;
      if (filter.planet != null && event.planet != filter.planet) return false;
      if (filter.topic != null && !event.topics.contains(filter.topic)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));
    return List.unmodifiable(selected);
  }
}

final class TimelineLanguagePolicy {
  const TimelineLanguagePolicy();
  String disclaimer({required String locale}) => switch (locale) {
        'tr' => 'Bu filtreler kesin olay tahmini değildir; danışmanlık için seçilmiş zamanlama göstergeleridir.',
        'en' => 'These filters are not certain event predictions; they are selected timing indicators for consultation.',
        _ => throw ArgumentError('unsupported locale'),
      };
}

final class TimelinePresetLibrary {
  TimelinePresetLibrary(Iterable<TimelineFilterPreset> presets) : presets = List.unmodifiable(presets) {
    final ids = this.presets.map((preset) => preset.id).toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('duplicate preset id');
  }

  final List<TimelineFilterPreset> presets;
}
