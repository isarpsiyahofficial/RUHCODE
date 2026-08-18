final class CityRecord {
  const CityRecord({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.ianaTimeZoneId,
    this.adminArea,
    this.aliases = const <String>[],
  });

  final String id;
  final String name;
  final String countryCode;
  final String countryName;
  final String? adminArea;
  final double latitude;
  final double longitude;
  final String ianaTimeZoneId;
  final List<String> aliases;

  String get disambiguationLabel {
    final region = adminArea?.trim();
    if (region == null || region.isEmpty) {
      return '$name, $countryName';
    }
    return '$name, $region, $countryName';
  }
}

final class CitySearchResult {
  const CitySearchResult({required this.city, required this.score});
  final CityRecord city;
  final int score;
}

final class CityCatalog {
  CityCatalog(Iterable<CityRecord> records)
      : _records = List<CityRecord>.unmodifiable(records) {
    final ids = <String>{};
    for (final record in _records) {
      if (record.id.trim().isEmpty) {
        throw ArgumentError('City id must not be empty.');
      }
      if (!ids.add(record.id)) {
        throw ArgumentError('Duplicate city id: ${record.id}');
      }
      if (record.latitude < -90 || record.latitude > 90) {
        throw RangeError.range(record.latitude, -90, 90, 'latitude');
      }
      if (record.longitude < -180 || record.longitude > 180) {
        throw RangeError.range(record.longitude, -180, 180, 'longitude');
      }
      if (record.ianaTimeZoneId.trim().isEmpty) {
        throw ArgumentError('IANA timezone id must not be empty.');
      }
    }
  }

  final List<CityRecord> _records;

  int get length => _records.length;

  List<CitySearchResult> search(String query, {int limit = 30}) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero.');
    }
    final normalizedQuery = normalizeCitySearchText(query);
    if (normalizedQuery.isEmpty) return const <CitySearchResult>[];

    final results = <CitySearchResult>[];
    for (final city in _records) {
      final score = _score(city, normalizedQuery);
      if (score != null) {
        results.add(CitySearchResult(city: city, score: score));
      }
    }

    results.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) return scoreOrder;
      final nameOrder = a.city.name.compareTo(b.city.name);
      if (nameOrder != 0) return nameOrder;
      final countryOrder = a.city.countryCode.compareTo(b.city.countryCode);
      if (countryOrder != 0) return countryOrder;
      return a.city.id.compareTo(b.city.id);
    });

    return List<CitySearchResult>.unmodifiable(results.take(limit));
  }

  int? _score(CityRecord city, String query) {
    final candidates = <String>{
      city.name,
      city.countryName,
      city.countryCode,
      if (city.adminArea != null) city.adminArea!,
      ...city.aliases,
      city.disambiguationLabel,
    }.map(normalizeCitySearchText);

    var best = -1;
    for (final candidate in candidates) {
      if (candidate == query) {
        best = best < 1000 ? 1000 : best;
      } else if (candidate.startsWith(query)) {
        best = best < 800 ? 800 : best;
      } else if (candidate.split(' ').any((part) => part.startsWith(query))) {
        best = best < 650 ? 650 : best;
      } else if (candidate.contains(query)) {
        best = best < 400 ? 400 : best;
      }
    }
    return best < 0 ? null : best;
  }
}

String normalizeCitySearchText(String value) {
  final lower = value.trim().toLowerCase();
  final buffer = StringBuffer();
  var previousWasSpace = false;

  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final replacement = switch (char) {
      'ı' || 'i' => 'i',
      'ş' => 's',
      'ç' => 'c',
      'ğ' => 'g',
      'ö' => 'o',
      'ü' => 'u',
      'â' || 'ä' || 'á' || 'à' || 'ã' => 'a',
      'é' || 'è' || 'ê' || 'ë' => 'e',
      'ó' || 'ò' || 'ô' || 'õ' => 'o',
      'ú' || 'ù' || 'û' => 'u',
      _ => char,
    };

    final isSpace = RegExp(r'\s').hasMatch(replacement);
    if (isSpace) {
      if (!previousWasSpace && buffer.isNotEmpty) {
        buffer.write(' ');
      }
      previousWasSpace = true;
      continue;
    }

    buffer.write(replacement);
    previousWasSpace = false;
  }

  return buffer.toString().trim();
}
