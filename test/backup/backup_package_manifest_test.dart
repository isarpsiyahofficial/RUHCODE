import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_manifest.dart';

void main() {
  const builder = BackupPackageManifestBuilder();

  test('computes deterministic SHA-256, byte length and record count', () {
    final bytes = utf8.encode('id,name\r\n1,İbrahim\r\n');
    final entry = builder.fileEntry(fileName: 'profiles.csv', utf8Bytes: bytes, recordCount: 1);

    expect(entry.fileName, 'profiles.csv');
    expect(entry.recordCount, 1);
    expect(entry.byteLength, bytes.length);
    expect(entry.sha256Hex, hasLength(64));
    expect(builder.verifyFile(entry, bytes), isTrue);
    expect(builder.verifyFile(entry, utf8.encode('tampered')), isFalse);
  });

  test('manifest ordering is deterministic regardless of input order', () {
    final first = builder.fileEntry(fileName: 'profiles.csv', utf8Bytes: utf8.encode('a'), recordCount: 1);
    final second = builder.fileEntry(fileName: 'clients.csv', utf8Bytes: utf8.encode('b'), recordCount: 1);
    final timestamp = DateTime.utc(2026, 8, 19, 18);

    final manifest = builder.build(
      schemaVersion: 1,
      appVersion: '0.1.0+1',
      engineVersion: '1',
      exportedAtUtc: timestamp,
      localeTag: 'tr',
      files: <BackupFileManifestEntry>[first, second],
    );

    expect(manifest.files.map((entry) => entry.fileName), <String>['clients.csv', 'profiles.csv']);
    expect(manifest.toCanonicalJson(), contains('2026-08-19T18:00:00.000Z'));
  });

  test('rejects duplicate file entries and non-UTC export time', () {
    final entry = builder.fileEntry(fileName: 'profiles.csv', utf8Bytes: utf8.encode('a'), recordCount: 1);

    expect(
      () => builder.build(
        schemaVersion: 1,
        appVersion: '1',
        engineVersion: '1',
        exportedAtUtc: DateTime.utc(2026, 8, 19),
        localeTag: 'en',
        files: <BackupFileManifestEntry>[entry, entry],
      ),
      throwsArgumentError,
    );

    expect(
      () => builder.build(
        schemaVersion: 1,
        appVersion: '1',
        engineVersion: '1',
        exportedAtUtc: DateTime(2026, 8, 19),
        localeTag: 'en',
        files: <BackupFileManifestEntry>[entry],
      ),
      throwsArgumentError,
    );
  });
}
