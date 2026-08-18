import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/daily_date_context.dart';
import 'package:ruh_code/src/calculation_core/time/time_zone_runtime.dart';

void main() {
  setUpAll(TimeZoneRuntime.initialize);

  test('same UTC instant can belong to different civil dates', () {
    final instant = DateTime.utc(2026, 1, 1, 10);

    final kiritimati = DailyDateResolver.atUtc(
      utcInstant: instant,
      zoneId: 'Pacific/Kiritimati',
    );
    final honolulu = DailyDateResolver.atUtc(
      utcInstant: instant,
      zoneId: 'Pacific/Honolulu',
    );

    expect(kiritimati.dateKey, '2026-01-02');
    expect(honolulu.dateKey, '2026-01-01');
    expect(kiritimati.cachePartitionKey, '2026-01-02|Pacific/Kiritimati');
    expect(honolulu.cachePartitionKey, '2026-01-01|Pacific/Honolulu');
  });

  test('Istanbul daily key rolls over exactly at local midnight', () {
    final beforeMidnight = DailyDateResolver.atUtc(
      utcInstant: DateTime.utc(2026, 8, 18, 20, 59, 59),
      zoneId: 'Europe/Istanbul',
    );
    final midnight = DailyDateResolver.atUtc(
      utcInstant: DateTime.utc(2026, 8, 18, 21),
      zoneId: 'Europe/Istanbul',
    );

    expect(beforeMidnight.dateKey, '2026-08-18');
    expect(midnight.dateKey, '2026-08-19');
  });

  test('same month and day in different years never share a daily key', () {
    final in2026 = DailyDateResolver.atUtc(
      utcInstant: DateTime.utc(2026, 8, 16, 9),
      zoneId: 'Europe/Istanbul',
    );
    final in2027 = DailyDateResolver.atUtc(
      utcInstant: DateTime.utc(2027, 8, 16, 9),
      zoneId: 'Europe/Istanbul',
    );

    expect(in2026.dateKey, '2026-08-16');
    expect(in2027.dateKey, '2027-08-16');
    expect(in2026.dateKey, isNot(in2027.dateKey));
  });

  test('leap day remains an exact daily key', () {
    final leapDay = DailyDateResolver.atUtc(
      utcInstant: DateTime.utc(2028, 2, 29, 12),
      zoneId: 'Europe/Istanbul',
    );
    expect(leapDay.dateKey, '2028-02-29');
  });

  test('daily date resolution rejects non-UTC source instants', () {
    expect(
      () => DailyDateResolver.atUtc(
        utcInstant: DateTime(2026, 8, 18, 12),
        zoneId: 'Europe/Istanbul',
      ),
      throwsArgumentError,
    );
  });
}
