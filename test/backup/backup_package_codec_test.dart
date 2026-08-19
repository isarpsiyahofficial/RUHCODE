import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';

void main() {
  const writer = BackupPackageWriter();
  const reader = BackupPackageReader();

  test('writer emits manifest plus every registered UTF-8 CSV table deterministically', () {
    final package = writer.write(
      rowsByTable: const <String, List<List<String?>>>{},
      appVersion: '0.1.0+1',
      engineVersion: 'engine-1',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
    );

    expect(package.files.keys.first, 'calculations.csv');
    expect(package.files.containsKey('manifest.json'), isTrue);
    expect(package.files.length, BackupSchemaRegistry.tables.length + 1);

    final preview = reader.preview(package);
    expect(preview.valid, isTrue);
    expect(preview.totalRecords, 0);
    expect(preview.recordCounts.length, BackupSchemaRegistry.tables.length);
    expect(preview.manifest.localeTag, 'tr');
  });

  test('round-trips Unicode profile data and exact record counts', () {
    final profileSchema = BackupSchemaRegistry.table('profiles.csv');
    final profileRow = <String?>[
      'profile-1',
      'İbrahim 🌙',
      '2000-02-29',
      'exact',
      '09:41',
      'İstanbul, Türkiye',
      'TR',
      '41.0082',
      '28.9784',
      'Europe/Istanbul',
      '2026-08-19T17:00:00.000Z',
      '2026-08-19T17:00:00.000Z',
    ];
    expect(profileRow.length, profileSchema.columns.length);

    final package = writer.write(
      rowsByTable: <String, List<List<String?>>>{
        'profiles.csv': <List<String?>>[profileRow],
      },
      appVersion: '0.1.0+1',
      engineVersion: 'engine-1',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
    );

    final preview = reader.preview(package);
    expect(preview.valid, isTrue);
    expect(preview.recordCounts['profiles.csv'], 1);
    expect(preview.rowsByTable['profiles.csv']!.single[1], 'İbrahim 🌙');
  });

  test('rejects a tampered CSV before schema or storage mutation', () {
    final package = writer.write(
      rowsByTable: const <String, List<List<String?>>>{},
      appVersion: '0.1.0+1',
      engineVersion: 'engine-1',
      localeTag: 'en',
      exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
    );
    final tampered = Map<String, List<int>>.from(package.files);
    tampered['profiles.csv'] = utf8.encode('tampered');

    expect(
      () => reader.preview(BackupPackageBytes(files: Map.unmodifiable(tampered))),
      throwsA(isA<FormatException>()),
    );
  });

  test('returns unresolved foreign keys as preview issues without mutating storage', () {
    final journalSchema = BackupSchemaRegistry.table('journal_entries.csv');
    final journalRow = <String?>[
      'journal-1',
      'missing-profile',
      '2026-08-19',
      'Bugünkü not',
      '2026-08-19T17:00:00.000Z',
      '2026-08-19T17:00:00.000Z',
    ];
    expect(journalRow.length, journalSchema.columns.length);

    final package = writer.write(
      rowsByTable: <String, List<List<String?>>>{
        'journal_entries.csv': <List<String?>>[journalRow],
      },
      appVersion: '0.1.0+1',
      engineVersion: 'engine-1',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
    );

    final preview = reader.preview(package);
    expect(preview.valid, isFalse);
    expect(
      preview.issues.any((issue) => issue.message.contains('unresolved foreign key')),
      isTrue,
    );
  });
}
