import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'civil_calendar.dart';

enum AmbiguousLocalTimePolicy { earlier, later, reject }

enum NonexistentLocalTimePolicy { reject, shiftForward }

enum LocalTimeResolutionKind { unique, ambiguousEarlier, ambiguousLater, shiftedForward }

final class WallClockDateTime {
  WallClockDateTime({
    required this.date,
    required this.hour,
    required this.minute,
    this.second = 0,
    this.millisecond = 0,
    this.microsecond = 0,
  }) {
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }
    if (second < 0 || second > 59) {
      throw RangeError.range(second, 0, 59, 'second');
    }
    if (millisecond < 0 || millisecond > 999) {
      throw RangeError.range(millisecond, 0, 999, 'millisecond');
    }
    if (microsecond < 0 || microsecond > 999) {
      throw RangeError.range(microsecond, 0, 999, 'microsecond');
    }
  }

  final CivilDate date;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;

  DateTime get naiveUtc => DateTime.utc(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  WallClockDateTime addMinutes(int minutes) {
    final shifted = naiveUtc.add(Duration(minutes: minutes));
    return WallClockDateTime(
      date: CivilDate(shifted.year, shifted.month, shifted.day),
      hour: shifted.hour,
      minute: shifted.minute,
      second: shifted.second,
      millisecond: shifted.millisecond,
      microsecond: shifted.microsecond,
    );
  }

  bool matches(tz.TZDateTime value) {
    return date.year == value.year &&
        date.month == value.month &&
        date.day == value.day &&
        hour == value.hour &&
        minute == value.minute &&
        second == value.second &&
        millisecond == value.millisecond &&
        microsecond == value.microsecond;
  }
}

final class ZonedInstant {
  const ZonedInstant({
    required this.utc,
    required this.zoneId,
    required this.offset,
    required this.kind,
    this.shiftedBy = Duration.zero,
  });

  final DateTime utc;
  final String zoneId;
  final Duration offset;
  final LocalTimeResolutionKind kind;
  final Duration shiftedBy;
}

final class AmbiguousLocalTimeException implements Exception {
  const AmbiguousLocalTimeException(this.zoneId, this.wallClock);

  final String zoneId;
  final WallClockDateTime wallClock;
}

final class NonexistentLocalTimeException implements Exception {
  const NonexistentLocalTimeException(this.zoneId, this.wallClock);

  final String zoneId;
  final WallClockDateTime wallClock;
}

abstract final class TimeZoneRuntime {
  static const String databaseVersion = '2025c';
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  static Set<String> get availableZoneIds {
    _requireInitialized();
    return Set.unmodifiable(tz.timeZoneDatabase.locations.keys);
  }

  static tz.Location location(String zoneId) {
    _requireInitialized();
    return tz.getLocation(zoneId);
  }

  static ZonedInstant resolveLocal(
    WallClockDateTime wallClock,
    String zoneId, {
    AmbiguousLocalTimePolicy ambiguousPolicy = AmbiguousLocalTimePolicy.reject,
    NonexistentLocalTimePolicy nonexistentPolicy = NonexistentLocalTimePolicy.reject,
  }) {
    final zone = location(zoneId);
    final candidates = _candidates(wallClock, zone);

    if (candidates.length == 1) {
      return _toResult(candidates.single, zoneId, LocalTimeResolutionKind.unique);
    }

    if (candidates.length > 1) {
      candidates.sort((a, b) => a.compareTo(b));
      switch (ambiguousPolicy) {
        case AmbiguousLocalTimePolicy.earlier:
          return _toResult(
            candidates.first,
            zoneId,
            LocalTimeResolutionKind.ambiguousEarlier,
          );
        case AmbiguousLocalTimePolicy.later:
          return _toResult(
            candidates.last,
            zoneId,
            LocalTimeResolutionKind.ambiguousLater,
          );
        case AmbiguousLocalTimePolicy.reject:
          throw AmbiguousLocalTimeException(zoneId, wallClock);
      }
    }

    if (nonexistentPolicy == NonexistentLocalTimePolicy.reject) {
      throw NonexistentLocalTimeException(zoneId, wallClock);
    }

    for (var minute = 1; minute <= 36 * 60; minute += 1) {
      final shiftedWallClock = wallClock.addMinutes(minute);
      final shiftedCandidates = _candidates(shiftedWallClock, zone);
      if (shiftedCandidates.isEmpty) continue;
      shiftedCandidates.sort((a, b) => a.compareTo(b));
      final chosen = shiftedCandidates.first;
      final resolved = _toResult(
        chosen,
        zoneId,
        LocalTimeResolutionKind.shiftedForward,
      );
      return ZonedInstant(
        utc: resolved.utc,
        zoneId: resolved.zoneId,
        offset: resolved.offset,
        kind: resolved.kind,
        shiftedBy: Duration(minutes: minute),
      );
    }

    throw NonexistentLocalTimeException(zoneId, wallClock);
  }

  static CivilDate civilDateAtUtc(DateTime utcInstant, String zoneId) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected a UTC instant.');
    }
    final zone = location(zoneId);
    final local = tz.TZDateTime.from(utcInstant, zone);
    return CivilDate(local.year, local.month, local.day);
  }

  static Duration offsetAtUtc(DateTime utcInstant, String zoneId) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected a UTC instant.');
    }
    final zone = location(zoneId);
    return zone.timeZone(utcInstant.millisecondsSinceEpoch).offset;
  }

  static List<DateTime> _candidates(WallClockDateTime wallClock, tz.Location zone) {
    final naive = wallClock.naiveUtc;
    final offsets = <Duration>{};
    const sampleDays = <int>[-400, -200, -2, 0, 2, 200, 400];

    for (final days in sampleDays) {
      final sample = naive.add(Duration(days: days));
      offsets.add(zone.timeZone(sample.millisecondsSinceEpoch).offset);
    }

    final candidates = <DateTime>[];
    for (final offset in offsets) {
      final candidate = naive.subtract(offset);
      final mapped = tz.TZDateTime.from(candidate, zone);
      if (wallClock.matches(mapped)) {
        candidates.add(candidate);
      }
    }

    return candidates.toSet().toList();
  }

  static ZonedInstant _toResult(
    DateTime utc,
    String zoneId,
    LocalTimeResolutionKind kind,
  ) {
    return ZonedInstant(
      utc: utc,
      zoneId: zoneId,
      offset: offsetAtUtc(utc, zoneId),
      kind: kind,
    );
  }

  static void _requireInitialized() {
    if (!_initialized) {
      throw StateError('TimeZoneRuntime.initialize() must be called first.');
    }
  }
}
