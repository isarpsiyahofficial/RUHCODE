import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/backup_schema_validator.dart';

void main() {
  group('BackupSchemaRegistry', () {
    test('has unique filenames and primary keys', () {
      final names = BackupSchemaRegistry.tables.map((table) => table.fileName).toList();
      expect(names.toSet().length, names.length);
      for (final table in BackupSchemaRegistry.tables) {
        final columnNames = table.columns.map((column) => column.name).toList();
        expect(columnNames.toSet().length, columnNames.length, reason: table.fileName);
        expect(columnNames, contains(table.primaryKey), reason: table.fileName);
      }
    });

    test('contains required portable backup tables', () {
      final names = BackupSchemaRegistry.tables.map((table) => table.fileName).toSet();
      expect(names, containsAll(<String>{
        'profiles.csv',
        'clients.csv',
        'consultations.csv',
        'notes.csv',
        'calculations.csv',
        'calculation_manifests.csv',
        'journal_entries.csv',
        'goals.csv',
        'habits.csv',
        'tarot_sessions.csv',
        'tarot_cards.csv',
        'favorites.csv',
        'settings.csv',
        'professional_presets.csv',
        'interpretation_templates.csv',
      }));
    });

    test('tarot card rows are normalized and linked to a session', () {
      final schema = BackupSchemaRegistry.table('tarot_cards.csv');
      expect(schema.primaryKey, 'id');
      expect(schema.column('session_id').foreignKey?.table, 'tarot_sessions.csv');
      expect(schema.column('session_id').foreignKey?.column, 'id');
      expect(schema.column('orientation').enumValues, <String>{'upright', 'reversed'});
    });

    test('enum ids are locale independent', () {
      expect(
        BackupSchemaRegistry.table('profiles.csv').column('birth_time_knowledge').enumValues,
        <String>{'exact', 'approximate', 'unknown'},
      );
      expect(
        BackupSchemaRegistry.table('calculation_manifests.csv').column('validity').enumValues,
        <String>{'valid', 'partial', 'unavailable', 'error'},
      );
    });
  });

  group('BackupSchemaValidator', () {
    const validator = BackupSchemaValidator();

    test('accepts valid profile row and rejects locale-formatted decimal', () {
      final schema = BackupSchemaRegistry.table('profiles.csv');
      final header = schema.columns.map((column) => column.name).toList();
      final valid = validator.validateTable(schema: schema, header: header, rows: <List<String?>>[
        <String?>[
          'profile-1', 'İbrahim', '2002-06-23', 'exact', '09:41', 'Antalya, Türkiye', 'TR',
          '36.8969', '30.7133', 'Europe/Istanbul', '2026-08-19T17:00:00Z', '2026-08-19T17:00:00Z',
        ],
      ]);
      expect(valid.valid, isTrue);

      final invalid = validator.validateTable(schema: schema, header: header, rows: <List<String?>>[
        <String?>[
          'profile-1', 'İbrahim', '2002-06-23', 'exact', '09:41', 'Antalya, Türkiye', 'TR',
          '36,8969', '30.7133', 'Europe/Istanbul', '2026-08-19T17:00:00Z', '2026-08-19T17:00:00Z',
        ],
      ]);
      expect(invalid.valid, isFalse);
    });

    test('rejects unknown enum and non-UTC timestamp', () {
      final schema = BackupSchemaRegistry.table('profiles.csv');
      final header = schema.columns.map((column) => column.name).toList();
      final result = validator.validateTable(schema: schema, header: header, rows: <List<String?>>[
        <String?>[
          'profile-1', 'Test', '2000-01-01', 'kesin', null, 'Antalya', 'TR',
          '36.8', '30.7', 'Europe/Istanbul', '2026-08-19T20:00:00+03:00', '2026-08-19T17:00:00Z',
        ],
      ]);
      expect(result.valid, isFalse);
      expect(result.issues.map((issue) => issue.message).join(' '), contains('unknown enum id'));
      expect(result.issues.map((issue) => issue.message).join(' '), contains('UTC ISO-8601'));
    });

    test('rejects duplicate primary key', () {
      final schema = BackupSchemaRegistry.table('settings.csv');
      final header = schema.columns.map((column) => column.name).toList();
      final result = validator.validateTable(schema: schema, header: header, rows: const <List<String?>>[
        <String?>['language', 'tr'],
        <String?>['language', 'en'],
      ]);
      expect(result.valid, isFalse);
      expect(result.issues.single.message, contains('Duplicate primary key'));
    });

    test('validates declared foreign keys across tables', () {
      final issues = validator.validateForeignKeys(rowsByTable: <String, List<List<String?>>>{
        'clients.csv': <List<String?>>[
          <String?>['client-1', 'Ayşe', null, '[]', '2026-08-19T17:00:00Z', '2026-08-19T17:00:00Z'],
        ],
        'consultations.csv': <List<String?>>[
          <String?>['consultation-1', 'missing-client', '2026-08-19T17:00:00Z', null, '2026-08-19T17:00:00Z', '2026-08-19T17:00:00Z'],
        ],
      });
      expect(issues, hasLength(1));
      expect(issues.single.message, contains('unresolved foreign key'));
    });

    test('rejects tarot card row whose session does not exist', () {
      final issues = validator.validateForeignKeys(rowsByTable: <String, List<List<String?>>>{
        'tarot_sessions.csv': const <List<String?>>[],
        'tarot_cards.csv': const <List<String?>>[
          <String?>['card-row-1', 'missing-session', '0', 'major.00', 'upright'],
        ],
      });
      expect(issues, hasLength(1));
      expect(issues.single.message, contains('unresolved foreign key'));
    });
  });
}
