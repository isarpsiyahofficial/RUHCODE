import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/calculation_core/time/time_zone_runtime.dart';

void main() {
  setUpAll(TimeZoneRuntime.initialize);

  WallClockDateTime wall(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) {
    return WallClockDateTime(
      date: CivilDate(year, month, day),
      hour: hour,
      minute: minute,
    );
  }

  test('bundled IANA database exposes required representative zones', () {
    expect(TimeZoneRuntime.databaseVersion, '2025c');
    expect(TimeZoneRuntime.availableZoneIds, contains('Europe/Istanbul'));
    expect(TimeZoneRuntime.availableZoneIds, contains('America/New_York'));
    expect(TimeZoneRuntime.availableZoneIds, contains('Asia/Kolkata'));
    expect(TimeZoneRuntime.availableZoneIds, contains('Asia/Kathmandu'));
    expect(TimeZoneRuntime.availableZoneIds, contains('Pacific/Kiritimati'));
    expect(TimeZoneRuntime.availableZoneIds, contains('Pacific/Apia'));
  });

  test('half-hour timezone is resolved exactly', () {
    final result = TimeZoneRuntime.resolveLocal(
      wall(2026, 8, 18, 12, 0),
      'Asia/Kolkata',
    );
    expect(result.offset, const Duration(hours: 5, minutes: 30));
    expect(result.utc, DateTime.utc(2026, 8, 18, 6, 30));
    expect(result.kind, LocalTimeResolutionKind.unique);
  });

  test('45-minute timezone is resolved exactly', () {
    final result = TimeZoneRuntime.resolveLocal(
      wall(2026, 8, 18, 12, 0),
      'Asia/Kathmandu',
    );
    expect(result.offset, const Duration(hours: 5, minutes: 45));
    expect(result.utc, DateTime.utc(2026, 8, 18, 6, 15));
  });

  test('UTC+14 timezone preserves the correct civil-day boundary', () {
    final instant = DateTime.utc(2026, 1, 1, 10);
    expect(
      TimeZoneRuntime.offsetAtUtc(instant, 'Pacific/Kiritimati'),
      const Duration(hours: 14),
    );
    expect(
      TimeZoneRuntime.civilDateAtUtc(instant, 'Pacific/Kiritimati'),
      CivilDate(2026, 1, 2),
    );
  });

  test('date-line zones can be on different civil dates at one instant', () {
    final instant = DateTime.utc(2026, 1, 1, 10);
    final kiritimati =
        TimeZoneRuntime.civilDateAtUtc(instant, 'Pacific/Kiritimati');
    final honolulu = TimeZoneRuntime.civilDateAtUtc(instant, 'Pacific/Honolulu');
    expect(kiritimati, CivilDate(2026, 1, 2));
    expect(honolulu, CivilDate(2026, 1, 1));
  });

  test('ambiguous fall-back time rejects unless a policy is explicit', () {
    final local = wall(2026, 11, 1, 1, 30);
    expect(
      () => TimeZoneRuntime.resolveLocal(local, 'America/New_York'),
      throwsA(isA<AmbiguousLocalTimeException>()),
    );

    final earlier = TimeZoneRuntime.resolveLocal(
      local,
      'America/New_York',
      ambiguousPolicy: AmbiguousLocalTimePolicy.earlier,
    );
    final later = TimeZoneRuntime.resolveLocal(
      local,
      'America/New_York',
      ambiguousPolicy: AmbiguousLocalTimePolicy.later,
    );

    expect(earlier.kind, LocalTimeResolutionKind.ambiguousEarlier);
    expect(later.kind, LocalTimeResolutionKind.ambiguousLater);
    expect(later.utc.difference(earlier.utc), const Duration(hours: 1));
  });

  test('nonexistent spring-forward time rejects by default', () {
    final local = wall(2026, 3, 8, 2, 30);
    expect(
      () => TimeZoneRuntime.resolveLocal(local, 'America/New_York'),
      throwsA(isA<NonexistentLocalTimeException>()),
    );
  });

  test('nonexistent spring-forward time can shift forward explicitly', () {
    final result = TimeZoneRuntime.resolveLocal(
      wall(2026, 3, 8, 2, 30),
      'America/New_York',
      nonexistentPolicy: NonexistentLocalTimePolicy.shiftForward,
    );
    expect(result.kind, LocalTimeResolutionKind.shiftedForward);
    expect(result.shiftedBy, const Duration(minutes: 30));
    expect(result.utc, DateTime.utc(2026, 3, 8, 7));
  });

  test('historical skipped civil day is not silently treated as valid', () {
    final local = wall(2011, 12, 30, 12, 0);
    expect(
      () => TimeZoneRuntime.resolveLocal(local, 'Pacific/Apia'),
      throwsA(isA<NonexistentLocalTimeException>()),
    );

    final shifted = TimeZoneRuntime.resolveLocal(
      local,
      'Pacific/Apia',
      nonexistentPolicy: NonexistentLocalTimePolicy.shiftForward,
    );
    expect(shifted.kind, LocalTimeResolutionKind.shiftedForward);
    // shiftForward means the first valid wall-clock instant after the requested
    // local time. Because Apia skipped all of 2011-12-30, noon reaches the
    // first valid instant at 2011-12-31 00:00 after twelve wall-clock hours.
    expect(shifted.shiftedBy, const Duration(hours: 12));
  });

  test('timezone conversion requires an actual UTC instant', () {
    expect(
      () => TimeZoneRuntime.civilDateAtUtc(DateTime(2026, 8, 18), 'Etc/UTC'),
      throwsArgumentError,
    );
  });
}
