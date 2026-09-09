import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/location/city_catalog.dart';
import 'package:ruh_code/src/data/location/location_input_policy.dart';

void main() {
  test('TR and EN date/time presentation is explicit and unknown time stays null', () {
    final unknown = BirthDateTimeInput(
      date: DateTime(2002, 6, 23),
      timePrecision: BirthTimePrecision.unknown,
    );
    unknown.validate();
    expect(unknown.hour, isNull);
    expect(unknown.minute, isNull);
    expect(unknown.dateLabel(SupportedInputLocale.tr), '23.06.2002');
    expect(unknown.dateLabel(SupportedInputLocale.en), '2002-06-23');
    expect(unknown.timeLabel(SupportedInputLocale.tr), 'Doğum saati bilinmiyor');
    expect(unknown.timeLabel(SupportedInputLocale.en), 'Birth time unknown');
  });

  test('approximate/exact times require real local clock values', () {
    expect(
      () => BirthDateTimeInput(
        date: DateTime(2000),
        timePrecision: BirthTimePrecision.exact,
      ).validate(),
      throwsStateError,
    );
    final approximate = BirthDateTimeInput(
      date: DateTime(2000, 1, 1),
      timePrecision: BirthTimePrecision.approximate,
      hour: 9,
      minute: 5,
    );
    approximate.validate();
    expect(approximate.timeLabel(SupportedInputLocale.tr), '09:05 (yaklaşık)');
    expect(approximate.timeLabel(SupportedInputLocale.en), '09:05 (approx.)');
  });

  test('100k indexed city records do not require a full scan for prefix search', () {
    final records = <CityRecord>[
      for (var i = 0; i < 100000; i++)
        CityRecord(
          id: 'fixture-$i',
          name: 'Fixturetown$i',
          countryCode: 'ZZ',
          countryName: 'Fixtureland',
          adminArea: 'Region${i % 100}',
          latitude: 0,
          longitude: 0,
          ianaTimeZoneId: 'Etc/UTC',
        ),
      const CityRecord(
        id: 'tr-istanbul',
        name: 'İstanbul',
        countryCode: 'TR',
        countryName: 'Türkiye',
        adminArea: 'İstanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        ianaTimeZoneId: 'Europe/Istanbul',
        aliases: <String>['Istanbul', 'Constantinople'],
      ),
    ];
    final catalog = CityCatalog(records);
    final stopwatch = Stopwatch()..start();
    final result = catalog.search('istan');
    stopwatch.stop();
    expect(result.single.city.id, 'tr-istanbul');
    expect(stopwatch.elapsedMilliseconds, lessThan(1500));
  });

  test('Istanbul/İstanbul and English aliases resolve to canonical city', () {
    final catalog = CityCatalog(const <CityRecord>[
      CityRecord(
        id: 'tr-istanbul',
        name: 'İstanbul',
        countryCode: 'TR',
        countryName: 'Türkiye',
        adminArea: 'İstanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        ianaTimeZoneId: 'Europe/Istanbul',
        aliases: <String>['Istanbul', 'Constantinople'],
      ),
    ]);
    expect(catalog.search('Istanbul').single.city.id, 'tr-istanbul');
    expect(catalog.search('İstanbul').single.city.id, 'tr-istanbul');
    expect(catalog.search('Constantinople').single.city.name, 'İstanbul');
  });

  test('same-name cities expose region/country and remain separate', () {
    final catalog = CityCatalog(const <CityRecord>[
      CityRecord(
        id: 'springfield-il',
        name: 'Springfield',
        countryCode: 'US',
        countryName: 'United States',
        adminArea: 'Illinois',
        latitude: 39.7817,
        longitude: -89.6501,
        ianaTimeZoneId: 'America/Chicago',
      ),
      CityRecord(
        id: 'springfield-ma',
        name: 'Springfield',
        countryCode: 'US',
        countryName: 'United States',
        adminArea: 'Massachusetts',
        latitude: 42.1015,
        longitude: -72.5898,
        ianaTimeZoneId: 'America/New_York',
      ),
    ]);
    final results = catalog.search('Springfield');
    expect(results, hasLength(2));
    expect(results.map((e) => e.city.disambiguationLabel).toSet(), {
      'Springfield, Illinois, United States',
      'Springfield, Massachusetts, United States',
    });
  });

  test('recent locations are bounded, stable-id based, and most-recent first', () {
    final recent = RecentLocationStore(capacity: 3);
    recent.record('istanbul');
    recent.record('ankara');
    recent.record('izmir');
    recent.record('istanbul');
    expect(recent.ids, <String>['istanbul', 'izmir', 'ankara']);
    recent.record('antalya');
    expect(recent.ids, <String>['antalya', 'istanbul', 'izmir']);
  });

  test('GPS denial always leaves manual city selection usable', () {
    const policy = LocationInputPolicy();
    expect(policy.gpsRequiredForBirthPlace, isFalse);
    expect(policy.manualCitySelectionAvailable, isTrue);
    for (final state in LocationPermissionState.values) {
      expect(policy.canUseManualSelection(state), isTrue);
    }
    expect(policy.shouldOfferManualFallback(LocationPermissionState.denied), isTrue);
    expect(policy.permissionMessage(LocationPermissionState.denied, SupportedInputLocale.tr), contains('manuel'));
    expect(policy.permissionMessage(LocationPermissionState.denied, SupportedInputLocale.en), contains('manually'));
  });
}
