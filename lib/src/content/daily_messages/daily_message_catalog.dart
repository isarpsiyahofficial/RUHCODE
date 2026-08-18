import '../../calculation_core/time/civil_calendar.dart';

final class DailyMessageEntry {
  DailyMessageEntry({
    required this.date,
    required this.localeTag,
    required this.title,
    required this.teaser,
    required this.fullText,
    required this.themeTag,
  }) {
    if (localeTag != 'tr' && localeTag != 'en') {
      throw ArgumentError.value(localeTag, 'localeTag', 'Only tr and en are supported.');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('Daily message title must not be empty.');
    }
    if (teaser.trim().isEmpty) {
      throw ArgumentError('Daily message teaser must not be empty.');
    }
    if (fullText.trim().isEmpty) {
      throw ArgumentError('Daily message fullText must not be empty.');
    }
    if (themeTag.trim().isEmpty) {
      throw ArgumentError('Daily message themeTag must not be empty.');
    }
  }

  final CivilDate date;
  final String localeTag;
  final String title;
  final String teaser;
  final String fullText;
  final String themeTag;

  String get key => '${date.isoKey}|$localeTag';
}

final class DailyMessageCatalog {
  DailyMessageCatalog(Iterable<DailyMessageEntry> entries)
      : _entries = <String, DailyMessageEntry>{} {
    for (final entry in entries) {
      if (_entries.containsKey(entry.key)) {
        throw ArgumentError('Duplicate daily message key: ${entry.key}');
      }
      _entries[entry.key] = entry;
    }
  }

  final Map<String, DailyMessageEntry> _entries;

  int get length => _entries.length;

  DailyMessageEntry? find({required CivilDate date, required String localeTag}) {
    return _entries['${date.isoKey}|$localeTag'];
  }

  DailyMessageEntry require({required CivilDate date, required String localeTag}) {
    final entry = find(date: date, localeTag: localeTag);
    if (entry == null) {
      throw StateError('Missing daily message: ${date.isoKey}|$localeTag');
    }
    return entry;
  }
}
