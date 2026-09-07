import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('RC-0127..RC-0134 planetary-hour structure', () {
    final result = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 17), // Monday
      latitudeDegrees: 41.0082,
      longitudeDegrees: 28.9784,
    );

    test('RC-0127/0128 day arc equals sunset minus sunrise and is split by 12', () {
      expect(result.isAvailable, isTrue);
      final sunrise = result.slots.first.startUtc;
      final sunset = result.slots[11].endUtc;
      final dayArcMicros = sunset.difference(sunrise).inMicroseconds;
      final expectedHourMicros = dayArcMicros / 12.0;

      for (final slot in result.slots.take(12)) {
        final slotMicros = slot.endUtc.difference(slot.startUtc).inMicroseconds;
        expect(
          (slotMicros - expectedHourMicros).abs(),
          lessThanOrEqualTo(1.0),
        );
      }
    });

    test('RC-0129/0130 night arc equals next sunrise minus sunset and is split by 12', () {
      final sunset = result.slots[12].startUtc;
      final nextSunrise = result.slots.last.endUtc;
      final nightArcMicros = nextSunrise.difference(sunset).inMicroseconds;
      final expectedHourMicros = nightArcMicros / 12.0;

      for (final slot in result.slots.skip(12)) {
        final slotMicros = slot.endUtc.difference(slot.startUtc).inMicroseconds;
        expect(
          (slotMicros - expectedHourMicros).abs(),
          lessThanOrEqualTo(1.0),
        );
      }
    });

    test('RC-0131/0132 first hour uses the civil weekday classical ruler', () {
      expect(result.slots.first.ruler, ClassicalPlanet.moon);
    });

    test('RC-0133 every subsequent hour advances in Chaldean order', () {
      final order = PlanetaryHours.chaldeanOrder;
      for (var i = 1; i < result.slots.length; i++) {
        final previous = order.indexOf(result.slots[i - 1].ruler);
        expect(result.slots[i].ruler, order[(previous + 1) % order.length]);
      }
    });

    test('RC-0134 exposes a contiguous ordered 24-slot list', () {
      expect(result.slots, hasLength(24));
      for (var i = 0; i < result.slots.length; i++) {
        expect(result.slots[i].index, i + 1);
        expect(result.slots[i].startUtc.isBefore(result.slots[i].endUtc), isTrue);
        if (i > 0) {
          expect(result.slots[i - 1].endUtc, result.slots[i].startUtc);
        }
      }
    });
  });
}
