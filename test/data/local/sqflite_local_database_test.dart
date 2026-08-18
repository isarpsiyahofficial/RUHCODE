import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('schema v1 persists records and passes integrity check', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    await db.transaction((tx) async {
      await tx.put(
        table: 'profiles',
        id: 'profile-1',
        value: <String, Object?>{
          'displayName': 'İbrahim',
          'localDateIso': '2002-06-23',
          'tags': <String>['Türkçe', 'offline'],
        },
      );
    });

    final stored = await db.transaction(
      (tx) => tx.get(table: 'profiles', id: 'profile-1'),
    );
    expect(stored?['displayName'], 'İbrahim');
    expect(stored?['localDateIso'], '2002-06-23');
    expect(stored?['tags'], <Object?>['Türkçe', 'offline']);

    final integrity = await db.integrityCheck();
    expect(integrity.ok, isTrue, reason: integrity.details.join('\n'));
    expect(db.schemaVersion, 1);
  });

  test('failed transaction rolls back every write', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    await expectLater(
      () => db.transaction<void>((tx) async {
        await tx.put(
          table: 'clients',
          id: 'client-rollback',
          value: const <String, Object?>{'displayName': 'Rollback'},
        );
        throw StateError('force rollback');
      }),
      throwsStateError,
    );

    final stored = await db.transaction(
      (tx) => tx.get(table: 'clients', id: 'client-rollback'),
    );
    expect(stored, isNull);
  });

  test('delete is transactional', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    await db.transaction((tx) => tx.put(
          table: 'notes',
          id: 'note-1',
          value: const <String, Object?>{'text': 'kalıcı not'},
        ));
    await db.transaction((tx) => tx.delete(table: 'notes', id: 'note-1'));

    final stored = await db.transaction(
      (tx) => tx.get(table: 'notes', id: 'note-1'),
    );
    expect(stored, isNull);
  });
}
