import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/portable_zip_backup_codec.dart';

void main() {
  const codec = PortableZipBackupCodec(
    maxArchiveBytes: 1024 * 1024,
    maxMemberBytes: 256 * 1024,
    maxMemberCount: 32,
  );

  test('round-trips a flat logical package byte-for-byte', () {
    final logical = BackupPackageBytes(files: <String, List<int>>{
      'manifest.json': <int>[123, 125],
      'profiles.csv': <int>[105, 100, 10, 49, 10],
      'notes.csv': <int>[105, 100, 44, 116, 101, 120, 116, 10],
    });

    final zip = codec.encode(logical);
    final decoded = codec.decode(zip);

    expect(decoded.files.keys.toList(), <String>['manifest.json', 'notes.csv', 'profiles.csv']);
    expect(decoded.file('manifest.json'), logical.file('manifest.json'));
    expect(decoded.file('profiles.csv'), logical.file('profiles.csv'));
    expect(decoded.file('notes.csv'), logical.file('notes.csv'));
  });

  test('rejects unsafe traversal member on encode', () {
    final logical = BackupPackageBytes(files: <String, List<int>>{
      'manifest.json': <int>[123, 125],
      '../profiles.csv': <int>[49],
    });

    expect(() => codec.encode(logical), throwsFormatException);
  });

  test('rejects unsafe traversal member on decode', () {
    final archive = Archive()
      ..add(ArchiveFile.bytes('manifest.json', <int>[123, 125]))
      ..add(ArchiveFile.bytes('../profiles.csv', <int>[49]));
    final zip = ZipEncoder().encodeBytes(archive);

    expect(() => codec.decode(zip), throwsFormatException);
  });

  test('rejects directory members', () {
    final archive = Archive()
      ..add(ArchiveFile.bytes('manifest.json', <int>[123, 125]))
      ..add(ArchiveFile.directory('payload/'));
    final zip = ZipEncoder().encodeBytes(archive);

    expect(() => codec.decode(zip), throwsFormatException);
  });

  test('rejects missing manifest', () {
    final archive = Archive()..add(ArchiveFile.bytes('profiles.csv', <int>[49]));
    final zip = ZipEncoder().encodeBytes(archive);

    expect(() => codec.decode(zip), throwsFormatException);
  });

  test('rejects member count above configured maximum', () {
    const small = PortableZipBackupCodec(
      maxArchiveBytes: 1024 * 1024,
      maxMemberBytes: 256 * 1024,
      maxMemberCount: 2,
    );
    final logical = BackupPackageBytes(files: <String, List<int>>{
      'manifest.json': <int>[123, 125],
      'a.csv': <int>[49],
      'b.csv': <int>[50],
    });

    expect(() => small.encode(logical), throwsFormatException);
  });

  test('rejects expanded member above configured maximum', () {
    final archive = Archive()
      ..add(ArchiveFile.bytes('manifest.json', <int>[123, 125]))
      ..add(ArchiveFile.bytes('profiles.csv', List<int>.filled(300, 65)));
    final zip = ZipEncoder().encodeBytes(archive);
    const small = PortableZipBackupCodec(
      maxArchiveBytes: 1024,
      maxMemberBytes: 128,
      maxMemberCount: 8,
    );

    expect(() => small.decode(zip), throwsFormatException);
  });

  test('rejects invalid configured limits', () {
    const invalid = PortableZipBackupCodec(
      maxArchiveBytes: 10,
      maxMemberBytes: 20,
      maxMemberCount: 1,
    );
    final logical = BackupPackageBytes(files: <String, List<int>>{
      'manifest.json': <int>[123, 125],
    });

    expect(() => invalid.encode(logical), throwsStateError);
  });
}
