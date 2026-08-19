import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'backup_package_codec.dart';

/// Encodes/decodes a validated logical Ruh Code backup package as one portable
/// ZIP byte stream without weakening the logical package validation contract.
///
/// Security invariants:
/// - no directories or symbolic links;
/// - no absolute/relative traversal paths;
/// - no duplicate member names;
/// - bounded archive/member/count sizes;
/// - CRC verification on ZIP decode;
/// - logical package bytes are returned unchanged for downstream manifest,
///   checksum, schema and FK verification by [BackupPackageReader].
final class PortableZipBackupCodec {
  const PortableZipBackupCodec({
    this.maxArchiveBytes = 64 * 1024 * 1024,
    this.maxMemberBytes = 16 * 1024 * 1024,
    this.maxMemberCount = 64,
  });

  final int maxArchiveBytes;
  final int maxMemberBytes;
  final int maxMemberCount;

  Uint8List encode(BackupPackageBytes package) {
    _validateLimits();
    if (package.files.isEmpty) {
      throw const FormatException('Backup package cannot be empty.');
    }
    if (package.files.length > maxMemberCount) {
      throw FormatException(
        'Backup package has too many members: ${package.files.length} > $maxMemberCount.',
      );
    }

    final archive = Archive();
    final names = package.files.keys.toList()..sort();
    for (final name in names) {
      _validatePortableMemberName(name);
      final bytes = package.files[name]!;
      if (bytes.length > maxMemberBytes) {
        throw FormatException(
          'Backup member exceeds size limit: $name (${bytes.length} > $maxMemberBytes).',
        );
      }
      archive.add(ArchiveFile.bytes(name, bytes));
    }

    final encoded = ZipEncoder().encodeBytes(archive);
    if (encoded.length > maxArchiveBytes) {
      throw FormatException(
        'Encoded backup ZIP exceeds size limit: ${encoded.length} > $maxArchiveBytes.',
      );
    }
    return encoded;
  }

  BackupPackageBytes decode(List<int> zipBytes) {
    _validateLimits();
    if (zipBytes.isEmpty) {
      throw const FormatException('Backup ZIP cannot be empty.');
    }
    if (zipBytes.length > maxArchiveBytes) {
      throw FormatException(
        'Backup ZIP exceeds size limit: ${zipBytes.length} > $maxArchiveBytes.',
      );
    }

    final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    if (archive.length > maxMemberCount) {
      throw FormatException(
        'Backup ZIP has too many members: ${archive.length} > $maxMemberCount.',
      );
    }

    final members = <String, List<int>>{};
    var expandedBytes = 0;
    for (final entry in archive) {
      final name = entry.name;
      _validatePortableMemberName(name);
      if (!entry.isFile || entry.isDirectory || entry.isSymbolicLink) {
        throw FormatException('Backup ZIP contains a non-regular file: $name.');
      }
      if (members.containsKey(name)) {
        throw FormatException('Backup ZIP contains duplicate member: $name.');
      }
      if (entry.size < 0 || entry.size > maxMemberBytes) {
        throw FormatException(
          'Backup ZIP member exceeds size limit: $name (${entry.size} > $maxMemberBytes).',
        );
      }

      final bytes = entry.readBytes();
      if (bytes == null) {
        throw FormatException('Backup ZIP member cannot be read: $name.');
      }
      if (bytes.length > maxMemberBytes) {
        throw FormatException(
          'Expanded backup member exceeds size limit: $name (${bytes.length} > $maxMemberBytes).',
        );
      }
      expandedBytes += bytes.length;
      if (expandedBytes > maxArchiveBytes) {
        throw FormatException(
          'Expanded backup ZIP exceeds total size limit: $expandedBytes > $maxArchiveBytes.',
        );
      }
      members[name] = List<int>.unmodifiable(bytes);
    }

    if (!members.containsKey('manifest.json')) {
      throw const FormatException('Backup ZIP manifest.json is missing.');
    }

    final sorted = members.keys.toList()..sort();
    return BackupPackageBytes(
      files: Map.unmodifiable(<String, List<int>>{
        for (final key in sorted) key: members[key]!,
      }),
    );
  }

  void _validateLimits() {
    if (maxArchiveBytes <= 0 || maxMemberBytes <= 0 || maxMemberCount <= 0) {
      throw StateError('Portable ZIP limits must all be positive.');
    }
    if (maxMemberBytes > maxArchiveBytes) {
      throw StateError('Member size limit cannot exceed archive size limit.');
    }
  }

  void _validatePortableMemberName(String name) {
    if (name.isEmpty) {
      throw const FormatException('Backup ZIP member name cannot be empty.');
    }
    if (name.contains('\\')) {
      throw FormatException('Backup ZIP member uses non-portable separator: $name.');
    }
    if (name.startsWith('/') || name.startsWith('~') || _looksLikeDrivePath(name)) {
      throw FormatException('Backup ZIP member uses an absolute path: $name.');
    }
    if (name.endsWith('/')) {
      throw FormatException('Backup ZIP directories are not allowed: $name.');
    }

    final segments = name.split('/');
    if (segments.any((segment) => segment.isEmpty || segment == '.' || segment == '..')) {
      throw FormatException('Backup ZIP member contains unsafe path traversal: $name.');
    }

    // The canonical portable package is intentionally flat. Binary assets may
    // be introduced later only through a separately versioned allow-list.
    if (segments.length != 1) {
      throw FormatException('Backup ZIP member must be a flat portable name: $name.');
    }
  }

  bool _looksLikeDrivePath(String name) {
    return name.length >= 2 &&
        ((name.codeUnitAt(0) >= 65 && name.codeUnitAt(0) <= 90) ||
            (name.codeUnitAt(0) >= 97 && name.codeUnitAt(0) <= 122)) &&
        name.codeUnitAt(1) == 58;
  }
}
