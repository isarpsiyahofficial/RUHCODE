import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_platform_gateway.dart';

void main() {
  group('BackupPlatformPolicy', () {
    const policy = BackupPlatformPolicy(maxBackupBytes: 8);

    test('accepts canonical .ruhcode.zip name case-insensitively', () {
      expect(policy.validateFileName('ruh-code-2026.ruhcode.zip'), 'ruh-code-2026.ruhcode.zip');
      expect(policy.validateFileName('BACKUP.RUHCODE.ZIP'), 'BACKUP.RUHCODE.ZIP');
    });

    test('rejects wrong extension and path injection', () {
      expect(() => policy.validateFileName('backup.zip'), throwsFormatException);
      expect(() => policy.validateFileName('../backup.ruhcode.zip'), throwsFormatException);
      expect(() => policy.validateFileName('folder\\backup.ruhcode.zip'), throwsFormatException);
      expect(() => policy.validateFileName('   '), throwsFormatException);
    });

    test('copies accepted bytes into immutable-length typed data', () {
      final source = <int>[1, 2, 3, 4];
      final validated = policy.validateBytes(source);
      expect(validated, isA<Uint8List>());
      expect(validated, orderedEquals(source));
      source[0] = 9;
      expect(validated.first, 1);
    });

    test('rejects empty and oversized payloads', () {
      expect(() => policy.validateBytes(const []), throwsFormatException);
      expect(() => policy.validateBytes(List<int>.filled(9, 0)), throwsFormatException);
    });

    test('rejects invalid size-limit configuration', () {
      const invalid = BackupPlatformPolicy(maxBackupBytes: 0);
      expect(() => invalid.validateBytes(const [1]), throwsStateError);
    });
  });
}