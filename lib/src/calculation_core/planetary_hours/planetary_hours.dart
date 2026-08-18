import '../solar/solar_events.dart';
import '../time/civil_calendar.dart';

enum ClassicalPlanet { saturn, jupiter, mars, sun, venus, mercury, moon }

final class PlanetaryHourSlot {
  const PlanetaryHourSlot({
    required this.index,
    required this.ruler,
    required this.startUtc,
    required this.endUtc,
    required this.isDaylight,
  });

  final int index;
  final ClassicalPlanet ruler;
  final DateTime startUtc;
  final DateTime endUtc;
  final bool isDaylight;

  Duration get duration => endUtc.difference(startUtc);
}

final class PlanetaryHoursResult {
  const PlanetaryHoursResult._({
    required this.date,
    required this.slots,
    this.unavailableReason,
  });

  final CivilDate date;
  final List<PlanetaryHourSlot> slots;
  final String? unavailableReason;

  bool get isAvailable => unavailableReason == null;

  factory PlanetaryHoursResult.unavailable(CivilDate date, String reason) =>
      PlanetaryHoursResult._(date: date, slots: const [], unavailableReason: reason);
}

final class PlanetaryHours {
  PlanetaryHours._();

  static const List<ClassicalPlanet> chaldeanOrder = [
    ClassicalPlanet.saturn,
    ClassicalPlanet.jupiter,
    ClassicalPlanet.mars,
    ClassicalPlanet.sun,
    ClassicalPlanet.venus,
    ClassicalPlanet.mercury,
    ClassicalPlanet.moon,
  ];

  static PlanetaryHoursResult forDate({
    required CivilDate date,
    required double latitudeDegrees,
    required double longitudeDegrees,
  }) {
    final current = SolarEvents.forDate(
      date: date,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
    );
    final nextDate = date.addDays(1);
    final next = SolarEvents.forDate(
      date: nextDate,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
    );

    if (!current.hasSunriseAndSunset || next.sunriseUtcMinutes == null) {
      return PlanetaryHoursResult.unavailable(
        date,
        'Planetary hours require a real sunrise, sunset, and next sunrise; polar-day/night boundaries are not fabricated.',
      );
    }

    final dayBase = DateTime.utc(date.year, date.month, date.day);
    final nextBase = DateTime.utc(nextDate.year, nextDate.month, nextDate.day);
    final sunrise = _fromUtcMinutes(dayBase, current.sunriseUtcMinutes!);
    final sunset = _fromUtcMinutes(dayBase, current.sunsetUtcMinutes!);
    final nextSunrise = _fromUtcMinutes(nextBase, next.sunriseUtcMinutes!);

    if (!sunrise.isBefore(sunset) || !sunset.isBefore(nextSunrise)) {
      throw StateError('Solar boundaries are not strictly increasing.');
    }

    final firstRulerIndex = chaldeanOrder.indexOf(_weekdayRuler(date.weekday));
    final slots = <PlanetaryHourSlot>[];
    _appendTwelve(
      slots: slots,
      start: sunrise,
      end: sunset,
      firstRulerIndex: firstRulerIndex,
      offset: 0,
      isDaylight: true,
    );
    _appendTwelve(
      slots: slots,
      start: sunset,
      end: nextSunrise,
      firstRulerIndex: firstRulerIndex,
      offset: 12,
      isDaylight: false,
    );

    return PlanetaryHoursResult._(date: date, slots: List.unmodifiable(slots));
  }

  static void _appendTwelve({
    required List<PlanetaryHourSlot> slots,
    required DateTime start,
    required DateTime end,
    required int firstRulerIndex,
    required int offset,
    required bool isDaylight,
  }) {
    final totalMicros = end.difference(start).inMicroseconds;
    for (var i = 0; i < 12; i++) {
      final slotStart = start.add(Duration(microseconds: (totalMicros * i / 12).round()));
      final slotEnd = start.add(Duration(microseconds: (totalMicros * (i + 1) / 12).round()));
      slots.add(
        PlanetaryHourSlot(
          index: offset + i + 1,
          ruler: chaldeanOrder[(firstRulerIndex + offset + i) % chaldeanOrder.length],
          startUtc: slotStart,
          endUtc: slotEnd,
          isDaylight: isDaylight,
        ),
      );
    }
  }

  static DateTime _fromUtcMinutes(DateTime baseUtc, double minutes) =>
      baseUtc.add(Duration(microseconds: (minutes * 60 * Duration.microsecondsPerSecond).round()));

  static ClassicalPlanet _weekdayRuler(CivilWeekday weekday) => switch (weekday) {
        CivilWeekday.monday => ClassicalPlanet.moon,
        CivilWeekday.tuesday => ClassicalPlanet.mars,
        CivilWeekday.wednesday => ClassicalPlanet.mercury,
        CivilWeekday.thursday => ClassicalPlanet.jupiter,
        CivilWeekday.friday => ClassicalPlanet.venus,
        CivilWeekday.saturday => ClassicalPlanet.saturn,
        CivilWeekday.sunday => ClassicalPlanet.sun,
      };
}
