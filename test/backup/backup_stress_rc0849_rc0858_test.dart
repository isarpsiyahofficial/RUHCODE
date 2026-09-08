import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';

void main() {
  test('thousands of mixed Unicode records survive export/import preview', () {
    const writer = BackupPackageWriter();
    const reader = BackupPackageReader();

    final profiles = <List<String?>>[];
    final clients = <List<String?>>[];
    final notes = <List<String?>>[];

    for (var i = 0; i < 1500; i++) {
      final sameName = i.isEven ? 'İbrahim Şahin' : 'Alex Smith';
      profiles.add(<String?>[
        'profile-$i',
        sameName,
        '1990-05-12',
        i % 3 == 0 ? 'unknown' : 'exact',
        i % 3 == 0 ? null : '14:30:00',
        'Antalya, Türkiye',
        'TR',
        '36.8969',
        '30.7133',
        'Europe/Istanbul',
        '2026-09-08T09:00:00.000Z',
        '2026-09-08T09:00:00.000Z',
      ]);
      clients.add(<String?>[
        'client-$i',
        '$sameName 😀',
        null,
        '["danışan","VIP"]',
        '2026-09-08T09:00:00.000Z',
        '2026-09-08T09:00:00.000Z',
      ]);
      notes.add(<String?>[
        'note-$i',
        'client-$i',
        'Türkçe: ç, ğ, ı, İ, ö, ş, ü. English text. Emoji 😀✨.\n'
            '${'Uzun not, virgül ve "tırnak" içerir. ' * 40}',
        '2026-09-08T09:00:00.000Z',
        '2026-09-08T09:00:00.000Z',
      ]);
    }

    final package = writer.write(
      rowsByTable: <String, List<List<String?>>>{
        'profiles.csv': profiles,
        'clients.csv': clients,
        'notes.csv': notes,
      },
      appVersion: '1.0.0',
      engineVersion: 'engine-1',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 9, 8, 9),
    );

    final preview = reader.preview(package);
    expect(preview.valid, isTrue, reason: preview.issues.map((e) => e.message).join('\n'));
    expect(preview.recordCounts['profiles.csv'], 1500);
    expect(preview.recordCounts['clients.csv'], 1500);
    expect(preview.recordCounts['notes.csv'], 1500);
    expect(preview.totalRecords, greaterThanOrEqualTo(4500));

    final restoredProfiles = preview.rowsByTable['profiles.csv']!;
    final restoredClients = preview.rowsByTable['clients.csv']!;
    final restoredNotes = preview.rowsByTable['notes.csv']!;
    expect(restoredProfiles.first[1], 'İbrahim Şahin');
    expect(restoredProfiles.first[3], 'unknown');
    expect(restoredProfiles.first[4], isNull);
    expect(restoredClients.first[1], contains('😀'));
    expect(restoredNotes.first[2], contains('ç, ğ, ı, İ, ö, ş, ü'));
    expect(restoredNotes.first[2], contains('\n'));
    expect(restoredNotes.first[2], contains('"tırnak"'));
  });
}
