import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/location/city_catalog.dart';

void main() {
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
    CityRecord(
      id: 'us-springfield-il',
      name: 'Springfield',
      countryCode: 'US',
      countryName: 'United States',
      adminArea: 'Illinois',
      latitude: 39.7817,
      longitude: -89.6501,
      ianaTimeZoneId: 'America/Chicago',
    ),
    CityRecord(
      id: 'us-springfield-ma',
      name: 'Springfield',
      countryCode: 'US',
      countryName: 'United States',
      adminArea: 'Massachusetts',
      latitude: 42.1015,
      longitude: -72.5898,
      ianaTimeZoneId: 'America/New_York',
    ),
  ]);

  test('Turkish diacritics and ASCII aliases find the same city', () {
    final turkish = catalog.search('İstanbul');
    final ascii = catalog.search('istanbul');
    final prefix = catalog.search('istan');

    expect(turkish.single.city.id, 'tr-istanbul');
    expect(ascii.single.city.id, 'tr-istanbul');
    expect(prefix.single.city.id, 'tr-istanbul');
  });

  test('aliases are searchable without changing canonical display name', () {
    final result = catalog.search('Constantinople').single;
    expect(result.city.id, 'tr-istanbul');
    expect(result.city.name, 'İstanbul');
    expect(result.city.ianaTimeZoneId, 'Europe/Istanbul');
  });

  test('same-name cities remain separate and visibly disambiguated', () {
    final results = catalog.search('Springfield');
    expect(results, hasLength(2));
    expect(
      results.map((result) => result.city.disambiguationLabel).toSet(),
      <String>{
        'Springfield, Illinois, United States',
        'Springfield, Massachusetts, United States',
      },
    );
    expect(
      results.map((result) => result.city.ianaTimeZoneId).toSet(),
      <String>{'America/Chicago', 'America/New_York'},
    );
  });

  test('search is deterministic and respects result limit', () {
    final first = catalog.search('spring', limit: 1);
    final second = catalog.search('spring', limit: 1);
    expect(first, hasLength(1));
    expect(second.single.city.id, first.single.city.id);
  });

  test('invalid coordinates and duplicate ids are rejected', () {
    expect(
      () => CityCatalog(const <CityRecord>[
        CityRecord(
          id: 'bad',
          name: 'Bad',
          countryCode: 'XX',
          countryName: 'Example',
          latitude: 91,
          longitude: 0,
          ianaTimeZoneId: 'Etc/UTC',
        ),
      ]),
      throwsRangeError,
    );

    expect(
      () => CityCatalog(const <CityRecord>[
        CityRecord(
          id: 'same',
          name: 'One',
          countryCode: 'XX',
          countryName: 'Example',
          latitude: 0,
          longitude: 0,
          ianaTimeZoneId: 'Etc/UTC',
        ),
        CityRecord(
          id: 'same',
          name: 'Two',
          countryCode: 'XX',
          countryName: 'Example',
          latitude: 1,
          longitude: 1,
          ianaTimeZoneId: 'Etc/UTC',
        ),
      ]),
      throwsArgumentError,
    );
  });
}
