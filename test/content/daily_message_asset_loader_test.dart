import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_asset_loader.dart';

final class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

const _header = 'date,locale,title,teaser,full_text,theme_tag\n';
const _legacyHeader = 'date,title,teaser,message,theme\n';

void main() {
  test('packaged shard loader resolves exact date and locale without fallback', () async {
    const trPath = 'assets/content/daily_messages/tr/2026-09.csv';
    const enPath = 'assets/content/daily_messages/en/2026-09.csv';
    final bundle = _MemoryAssetBundle({
      trPath:
          '${_header}"2026-09-01","tr","Başlık","Kısa, ama net","Metin","theme"\n',
      enPath:
          '${_header}"2026-09-01","en","Title","Short, but clear","Text","theme"\n',
    });

    final catalog = await DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(
      const [trPath, enPath],
    );

    expect(catalog.length, 2);
    expect(
      catalog.require(date: CivilDate(2026, 9, 1), localeTag: 'tr').title,
      'Başlık',
    );
    expect(
      catalog.require(date: CivilDate(2026, 9, 1), localeTag: 'en').teaser,
      'Short, but clear',
    );
    expect(catalog.find(date: CivilDate(2026, 9, 2), localeTag: 'tr'), isNull);
  });

  test('legacy shard is normalized with locale from its exact asset path', () async {
    const path = 'assets/content/daily_messages/tr/2030-07.csv';
    final bundle = _MemoryAssetBundle({
      path:
          '${_legacyHeader}"2030-07-01","Sessiz Öncelik","Bugün gerçekten gerekli olana dön.","Tam mesaj","focus"\n',
    });

    final catalog = await DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(
      const [path],
    );
    final entry = catalog.require(date: CivilDate(2030, 7, 1), localeTag: 'tr');
    expect(entry.title, 'Sessiz Öncelik');
    expect(entry.fullText, 'Tam mesaj');
    expect(entry.themeTag, 'focus');
    expect(catalog.find(date: CivilDate(2030, 7, 1), localeTag: 'en'), isNull);
  });

  test('legacy shard still rejects empty required message content', () async {
    const path = 'assets/content/daily_messages/en/2030-07.csv';
    final bundle = _MemoryAssetBundle({
      path: '${_legacyHeader}"2030-07-01","Title","Teaser","","focus"\n',
    });

    await expectLater(
      DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(const [path]),
      throwsArgumentError,
    );
  });

  test('CSV parser preserves quoted commas and escaped quotes', () async {
    const path = 'assets/content/daily_messages/en/2026-09.csv';
    final bundle = _MemoryAssetBundle({
      path:
          '${_header}"2026-09-01","en","A ""quoted"" title","One, two","Line one, line two","theme"\n',
    });

    final catalog = await DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(
      const [path],
    );
    final entry = catalog.require(date: CivilDate(2026, 9, 1), localeTag: 'en');
    expect(entry.title, 'A "quoted" title');
    expect(entry.teaser, 'One, two');
    expect(entry.fullText, 'Line one, line two');
  });

  test('locale mismatch between path and row is rejected', () async {
    const path = 'assets/content/daily_messages/tr/2026-09.csv';
    final bundle = _MemoryAssetBundle({
      path: '${_header}"2026-09-01","en","Title","Teaser","Text","theme"\n',
    });

    await expectLater(
      DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(const [path]),
      throwsA(isA<FormatException>()),
    );
  });

  test('unknown shard schema is rejected instead of guessed', () async {
    const path = 'assets/content/daily_messages/tr/2030-07.csv';
    final bundle = _MemoryAssetBundle({
      path: 'date,title,text\n2030-07-01,A,B\n',
    });
    await expectLater(
      DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(const [path]),
      throwsA(isA<FormatException>()),
    );
  });

  test('duplicate exact date-locale rows across packaged shards are rejected', () async {
    const first = 'assets/content/daily_messages/tr/2026.csv';
    const second = 'assets/content/daily_messages/tr/2026-09.csv';
    final bundle = _MemoryAssetBundle({
      first: '${_header}"2026-09-01","tr","A","B","C","theme"\n',
      second: '${_header}"2026-09-01","tr","D","E","F","theme"\n',
    });

    await expectLater(
      DailyMessageAssetLoader(bundle: bundle).loadFromAssetPaths(const [first, second]),
      throwsArgumentError,
    );
  });
}
