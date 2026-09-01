import 'package:flutter/services.dart';

import '../../calculation_core/time/civil_calendar.dart';
import 'daily_message_catalog.dart';

/// Loads the pre-authored Daily Message catalog from Flutter assets.
///
/// No network or runtime generation path is used. Asset discovery is taken from
/// Flutter's packaged AssetManifest and every CSV row is converted to an exact
/// YYYY-MM-DD + locale catalog entry.
final class DailyMessageAssetLoader {
  const DailyMessageAssetLoader({AssetBundle? bundle}) : _bundle = bundle;

  static const String _root = 'assets/content/daily_messages/';
  static const Set<String> _supportedLocales = {'tr', 'en'};
  static const List<String> _canonicalHeader = <String>[
    'date',
    'locale',
    'title',
    'teaser',
    'full_text',
    'theme_tag',
  ];
  static const List<String> _legacyHeader = <String>[
    'date',
    'title',
    'teaser',
    'message',
    'theme',
  ];

  final AssetBundle? _bundle;

  Future<DailyMessageCatalog> loadPackaged() async {
    final bundle = _bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final paths = manifest
        .listAssets()
        .where(_isDailyMessageShard)
        .toList(growable: false)
      ..sort();
    return loadFromAssetPaths(paths, bundle: bundle);
  }

  Future<DailyMessageCatalog> loadFromAssetPaths(
    Iterable<String> assetPaths, {
    AssetBundle? bundle,
  }) async {
    final effectiveBundle = bundle ?? _bundle ?? rootBundle;
    final paths = assetPaths.where(_isDailyMessageShard).toList(growable: false)
      ..sort();
    if (paths.isEmpty) {
      throw StateError('No packaged daily-message CSV shards were found.');
    }

    final entries = <DailyMessageEntry>[];
    for (final path in paths) {
      final localeFromPath = _localeFromPath(path);
      final csv = await effectiveBundle.loadString(path, cache: false);
      final rows = _parseCsv(csv);
      if (rows.isEmpty) {
        throw FormatException('Daily-message shard has no header: $path');
      }
      final canonical = _sameRow(rows.first, _canonicalHeader);
      final legacy = _sameRow(rows.first, _legacyHeader);
      if (!canonical && !legacy) {
        throw FormatException(
          'Daily-message shard must use a supported canonical or legacy header: $path',
        );
      }
      for (var index = 1; index < rows.length; index++) {
        final row = rows[index];
        if (row.length == 1 && row.first.trim().isEmpty) {
          continue;
        }
        final expectedColumns = canonical ? _canonicalHeader.length : _legacyHeader.length;
        if (row.length != expectedColumns) {
          throw FormatException(
            'Daily-message shard row ${index + 1} has ${row.length} columns, expected $expectedColumns: $path',
          );
        }

        final locale = canonical ? row[1].trim().toLowerCase() : localeFromPath;
        if (locale != localeFromPath) {
          throw FormatException(
            'Daily-message locale $locale does not match asset path locale $localeFromPath: $path row ${index + 1}',
          );
        }

        final titleIndex = canonical ? 2 : 1;
        final teaserIndex = canonical ? 3 : 2;
        final fullTextIndex = canonical ? 4 : 3;
        final themeIndex = canonical ? 5 : 4;
        entries.add(
          DailyMessageEntry(
            date: CivilDate.parseIso(row[0].trim()),
            localeTag: locale,
            title: row[titleIndex],
            teaser: row[teaserIndex],
            fullText: row[fullTextIndex],
            themeTag: row[themeIndex],
          ),
        );
      }
    }

    return DailyMessageCatalog(entries);
  }

  static bool _isDailyMessageShard(String path) {
    if (!path.startsWith(_root) || !path.endsWith('.csv')) {
      return false;
    }
    final remainder = path.substring(_root.length);
    final slash = remainder.indexOf('/');
    if (slash <= 0 || slash == remainder.length - 1) {
      return false;
    }
    final locale = remainder.substring(0, slash);
    return _supportedLocales.contains(locale) &&
        !remainder.substring(slash + 1).contains('/');
  }

  static String _localeFromPath(String path) {
    final remainder = path.substring(_root.length);
    return remainder.substring(0, remainder.indexOf('/'));
  }

  static bool _sameRow(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i].trim().toLowerCase() != right[i]) return false;
    }
    return true;
  }

  /// RFC 4180-style parser for the supported Daily Message shard schemas.
  /// Supports commas/newlines inside quoted fields and doubled quote escapes.
  static List<List<String>> _parseCsv(String source) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;

    void finishField() {
      row.add(field.toString());
      field.clear();
    }

    void finishRow() {
      finishField();
      rows.add(row);
      row = <String>[];
    }

    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if (quoted) {
        if (char == '"') {
          if (i + 1 < source.length && source[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(char);
        }
        continue;
      }

      switch (char) {
        case '"':
          if (field.isNotEmpty) {
            throw const FormatException('Unexpected quote inside unquoted CSV field.');
          }
          quoted = true;
        case ',':
          finishField();
        case '\n':
          finishRow();
        case '\r':
          if (i + 1 < source.length && source[i + 1] == '\n') {
            i++;
          }
          finishRow();
        default:
          field.write(char);
      }
    }

    if (quoted) {
      throw const FormatException('Unterminated quoted CSV field.');
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      finishRow();
    }
    return rows;
  }
}
