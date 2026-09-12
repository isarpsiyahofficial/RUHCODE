/// Binding runtime primitives for RC-1421..RC-1423, RC-1428 and RC-1435.
///
/// This layer deliberately contains no network, AI, random-message or device-
/// ambient-time dependency. Callers must provide the active local instant and
/// IANA timezone explicitly, so "Today" can be reproduced in tests and offline.
final class TodayTemporalContext {
  TodayTemporalContext({
    required this.localDateTime,
    required this.timezoneId,
    this.latitude,
    this.longitude,
  }) {
    if (timezoneId.trim().isEmpty) {
      throw ArgumentError('timezoneId must be an explicit IANA timezone id.');
    }
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('latitude and longitude must be provided together.');
    }
    if (latitude != null && (latitude! < -90 || latitude! > 90)) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (longitude != null && (longitude! < -180 || longitude! > 180)) {
      throw ArgumentError.value(longitude, 'longitude');
    }
  }

  final DateTime localDateTime;
  final String timezoneId;
  final double? latitude;
  final double? longitude;

  String get isoDate =>
      '${localDateTime.year.toString().padLeft(4, '0')}-'
      '${localDateTime.month.toString().padLeft(2, '0')}-'
      '${localDateTime.day.toString().padLeft(2, '0')}';
}

abstract final class GregorianCalendarPolicy {
  static bool isLeapYear(int year) =>
      year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);

  /// ISO weekday from the Gregorian calendar engine: Monday=1 ... Sunday=7.
  static int weekday({required int year, required int month, required int day}) {
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw ArgumentError('Invalid Gregorian date: $year-$month-$day');
    }
    return date.weekday;
  }

  static void validateDate({required int year, required int month, required int day}) {
    weekday(year: year, month: month, day: day);
  }
}

final class RuhSupportedDateRange {
  const RuhSupportedDateRange._();

  static const int minimumYear = 1890;
  static const int maximumYear = 2110;

  static bool contains(DateTime value) =>
      value.year >= minimumYear && value.year <= maximumYear;

  static void requireSupported(DateTime value) {
    if (!contains(value)) {
      throw RangeError(
        'Ruh Code supported calculation date range is '
        '$minimumYear-$maximumYear; requested year=${value.year}.',
      );
    }
  }
}

/// Date-keyed editorial message bundled with the application.
final class StockDailyMessage {
  StockDailyMessage({
    required this.isoDate,
    required this.localeTag,
    required this.title,
    required this.body,
  }) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(isoDate)) {
      throw ArgumentError('Stock daily-message key must be YYYY-MM-DD.');
    }
    if (localeTag != 'tr' && localeTag != 'en') {
      throw ArgumentError('Stock daily-message locale must be tr or en.');
    }
    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('Stock daily-message content must not be empty.');
    }
  }

  final String isoDate;
  final String localeTag;
  final String title;
  final String body;
}

/// Calculation-core output for the active date/time/timezone/location.
final class PersonalTodayEffects {
  PersonalTodayEffects({
    required this.calculationVersion,
    required Map<String, Object?> facts,
  }) : facts = Map.unmodifiable(facts) {
    if (calculationVersion.trim().isEmpty) {
      throw ArgumentError('calculationVersion is required.');
    }
  }

  final String calculationVersion;
  final Map<String, Object?> facts;
}

/// Keeps the editorial stock message and personalized calculated effects
/// structurally separate. No runtime AI generation or random fallback exists.
final class TodayContentBundle {
  TodayContentBundle({
    required this.context,
    required this.stockMessage,
    required this.personalEffects,
  }) {
    RuhSupportedDateRange.requireSupported(context.localDateTime);
    if (stockMessage.isoDate != context.isoDate) {
      throw StateError(
        'Stock message date ${stockMessage.isoDate} does not match active date ${context.isoDate}.',
      );
    }
  }

  final TodayTemporalContext context;
  final StockDailyMessage stockMessage;
  final PersonalTodayEffects personalEffects;
}
