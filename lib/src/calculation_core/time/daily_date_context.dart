import 'civil_calendar.dart';
import 'time_zone_runtime.dart';

final class DailyDateContext {
  const DailyDateContext({
    required this.utcInstant,
    required this.zoneId,
    required this.civilDate,
    required this.utcOffset,
  });

  final DateTime utcInstant;
  final String zoneId;
  final CivilDate civilDate;
  final Duration utcOffset;

  String get dateKey => civilDate.isoKey;

  String get cachePartitionKey => '$dateKey|$zoneId';
}

abstract final class DailyDateResolver {
  static DailyDateContext atUtc({
    required DateTime utcInstant,
    required String zoneId,
  }) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected a UTC instant.');
    }
    final date = TimeZoneRuntime.civilDateAtUtc(utcInstant, zoneId);
    final offset = TimeZoneRuntime.offsetAtUtc(utcInstant, zoneId);
    return DailyDateContext(
      utcInstant: utcInstant,
      zoneId: zoneId,
      civilDate: date,
      utcOffset: offset,
    );
  }
}
