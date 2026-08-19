import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/portable_backup_file_store.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ruh_code_backup_file_store_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('atomically saves and opens portable backup bytes', () async {
    const store = PortableBackupFileStore(maxFileBytes: 1024 * 1024);
    final path = '${tempDir.path}/sample.ruhcode.zip';
    final bytes = <int>[80, 75, 3, 4, 1, 2, 3, 4];

    await store.save(path: path, zipBytes: bytes);

    expect(await File(path).readAsBytes(), bytes);
    expect(await store.open(path), bytes);
    expect(await File('$path.tmp').exists(), isFalse);
  });

  test('replaces an existing target without leaving temp bytes', () async {
    const store = PortableBackupFileStore(maxFileBytes: 1024 * 1024);
    final path = '${tempDir.path}/replace.ruhcode.zip';
    await File(path).writeAsBytes(<int>[1, 2, 3]);

    await store.save(path: path, zipBytes: <int>[9, 8, 7, 6]);

    expect(await store.open(path), <int>[9, 8, 7, 6]);
    expect(await File('$path.tmp').exists(), isFalse);
  });

  test('rejects non-canonical extension', () async {
    const store = PortableBackupFileStore();
    final path = '${tempDir.path}/backup.zip';

    await expectLater(
      store.save(path: path, zipBytes: <int>[1]),
      throwsFormatException,
    );
  });

  test('rejects missing destination directory', () async {
    const store = PortableBackupFileStore();
    final path = '${tempDir.path}/missing/backup.ruhcode.zip';

    await expectLater(
      store.save(path: path, zipBytes: <int>[1]),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('rejects empty and oversized files', () async {
    const store = PortableBackupFileStore(maxFileBytes: 4);
    final empty = '${tempDir.path}/empty.ruhcode.zip';
    final large = '${tempDir.path}/large.ruhcode.zip';
    await File(empty).writeAsBytes(<int>[]);
    await File(large).writeAsBytes(<int>[1, 2, 3, 4, 5]);

    await expectLater(store.open(empty), throwsFormatException);
    await expectLater(store.open(large), throwsFormatException);
    await expectLater(
      store.save(path: large, zipBytes: <int>[1, 2, 3, 4, 5]),
      throwsFormatException,
    );
  });

  test('savePackage/openPackage preserves logical package members', () async {
    const store = PortableBackupFileStore(maxFileBytes: 1024 * 1024);
    final path = '${tempDir.path}/logical.ruhcode.zip';
    final package = BackupPackageBytes(files: <String, List<int>>{
      'manifest.json': <int>[123, 125],
      'profiles.csv': <int>[105, 100, 10],
    });

    await store.savePackage(path: path, package: package);
    final restored = await store.openPackage(path: path);

    expect(restored.files.keys.toList(), <String>['manifest.json', 'profiles.csv']);
    expect(restored.file('profiles.csv'), package.file('profiles.csv'));
  });
}
