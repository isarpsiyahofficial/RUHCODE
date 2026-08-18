import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  test('Monday starts with Moon and follows Chaldean sequence', () {
    final result = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 17),
      latitudeDegrees: 41.0082,
      longitudeDegrees: 28.9784,
    );

    expect(result.isAvailable, isTrue);
    expect(result.slots, hasLength(24));
    expect(result.slots[0].ruler, ClassicalPlanet.moon);
    expect(result.slots[1].ruler, ClassicalPlanet.saturn);
    expect(result.slots[2].ruler, ClassicalPlanet.jupiter);
    expect(result.slots[3].ruler, ClassicalPlanet.mars);
  });

  test('day and night are each divided into exactly twelve contiguous slots', () {
    final result = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 18),
      latitudeDegrees: 41.0082,
      longitudeDegrees: 28.9784,
    );

    expect(result.isAvailable, isTrue);
    for (var i = 0; i < 23; i++) {
      expect(result.slots[i].endUtc, result.slots[i + 1].startUtc);
    }
    expect(result.slots.take(12).every((slot) => slot.isDaylight), isTrue);
    expect(result.slots.skip(12).every((slot) => !slot.isDaylight), isTrue);

    final dayDurations = result.slots.take(12).map((slot) => slot.duration.inMicroseconds).toList();
    final nightDurations = result.slots.skip(12).map((slot) => slot.duration.inMicroseconds).toList();
    expect(dayDurations.reduce((a, b) => a > b ? a : b) - dayDurations.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(1));
    expect(nightDurations.reduce((a, b) => a > b ? a : b) - nightDurations.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(1));
  });

  test('weekday ruler advances naturally to the next civil date', () {
    final monday = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 17),
      latitudeDegrees: 0,
      longitudeDegrees: 0,
    );
    final tuesday = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 18),
      latitudeDegrees: 0,
      longitudeDegrees: 0,
    );

    expect(monday.slots.first.ruler, ClassicalPlanet.moon);
    expect(tuesday.slots.first.ruler, ClassicalPlanet.mars);
  });

  test('polar boundaries return unavailable instead of fabricated planetary hours', () {
    final result = PlanetaryHours.forDate(
      date: CivilDate(2026, 6, 21),
      latitudeDegrees: 89,
      longitudeDegrees: 0,
    );

    expect(result.isAvailable, isFalse);
    expect(result.slots, isEmpty);
    expect(result.unavailableReason, contains('not fabricated'));
  });
}
