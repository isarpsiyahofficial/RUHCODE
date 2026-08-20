import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/backup_schema_validator.dart';
import 'package:ruh_code/src/backup/backup_service.dart';

void main() {
  test('merge is idempotent by primary key when the same backup is imported twice', () async {
    final store = _MemoryBackupImportStore();
    final coordinator = BackupImportCoordinator(store: store);
    final preview = _validProfilePreview();

    await coordinator.apply(preview: preview, mode: BackupImportMode.merge);
    await coordinator.apply(preview: preview, mode: BackupImportMode.merge);

    expect(store.rows['profiles.csv'], hasLength(1));
    expect(store.rows['profiles.csv']!.single.first, 'profile-1');
    expect(store.snapshotCount, 0);
  });

  test('replace creates safety snapshot and replaces old table contents', () async {
    final store = _MemoryBackupImportStore(
      initialRows: <String, List<List<String?>>>{
        'profiles.csv': <List<String?>>[
          _profileRow(id: 'old-profile', name: 'Eski'),
        ],
      },
    );
    final coordinator = BackupImportCoordinator(store: store);

    final result = await coordinator.apply(
      preview: _validProfilePreview(),
      mode: BackupImportMode.replace,
    );

    expect(result.safetySnapshotCreated, isTrue);
    expect(store.snapshotCount, 1);
    expect(store.rows['profiles.csv'], hasLength(1));
    expect(store.rows['profiles.csv']!.single.first, 'profile-1');
  });

  test('replace failure restores the pre-import safety snapshot and reports it', () async {
    final original = _profileRow(id: 'old-profile', name: 'Korunacak');
    final store = _MemoryBackupImportStore(
      initialRows: <String, List<List<String?>>>{
        'profiles.csv': <List<String?>>[original],
      },
      failOnTable: 'clients.csv',
    );
    final coordinator = BackupImportCoordinator(store: store);

    Object? captured;
    try {
      await coordinator.apply(preview: _validProfilePreview(), mode: BackupImportMode.replace);
    } catch (error) {
      captured = error;
    }

    expect(captured, isA<BackupRestoreException>());
    final failure = captured! as BackupRestoreException;
    expect(failure.rollbackRestored, isTrue);
    expect(failure.cause, isA<StateError>());
    expect(failure.rollbackFailure, isNull);
    expect(store.restoreCount, 1);
    expect(store.rows['profiles.csv']!.single.first, 'old-profile');
    expect(store.rows['profiles.csv']!.single[1], 'Korunacak');
  });

  test('rollback failure is never falsely reported as restored', () async {
    final store = _MemoryBackupImportStore(
      initialRows: <String, List<List<String?>>>{
        'profiles.csv': <List<String?>>[
          _profileRow(id: 'old-profile', name: 'Korunacak'),
        ],
      },
      failOnTable: 'clients.csv',
      failRollback: true,
    );
    final coordinator = BackupImportCoordinator(store: store);

    Object? captured;
    try {
      await coordinator.apply(preview: _validProfilePreview(), mode: BackupImportMode.replace);
    } catch (error) {
      captured = error;
    }

    expect(captured, isA<BackupRestoreException>());
    final failure = captured! as BackupRestoreException;
    expect(failure.rollbackRestored, isFalse);
    expect(failure.rollbackFailure, isA<StateError>());
  });

  test('invalid preview is rejected before transaction or snapshot creation', () async {
    final store = _MemoryBackupImportStore();
    final coordinator = BackupImportCoordinator(store: store);
    final invalidPreview = BackupImportPreview(
      manifest: _validProfilePreview().manifest,
      rowsByTable: const <String, List<List<String?>>>{},
      recordCounts: const <String, int>{},
      issues: const <BackupValidationIssue>[
        BackupValidationIssue(table: 'profiles.csv', message: 'invalid'),
      ],
    );

    await expectLater(
      coordinator.apply(preview: invalidPreview, mode: BackupImportMode.replace),
      throwsStateError,
    );
    expect(store.transactionCount, 0);
    expect(store.snapshotCount, 0);
  });
}

BackupImportPreview _validProfilePreview() {
  const writer = BackupPackageWriter();
  const reader = BackupPackageReader();
  final package = writer.write(
    rowsByTable: <String, List<List<String?>>>{
      'profiles.csv': <List<String?>>[
        _profileRow(id: 'profile-1', name: 'İbrahim'),
      ],
    },
    appVersion: '0.1.0+1',
    engineVersion: 'engine-1',
    localeTag: 'tr',
    exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
  );
  return reader.preview(package);
}

List<String?> _profileRow({required String id, required String name}) => <String?>[
      id,
      name,
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

final class _MemoryBackupImportStore implements BackupImportStore {
  _MemoryBackupImportStore({
    Map<String, List<List<String?>>>? initialRows,
    this.failOnTable,
    this.failRollback = false,
  }) : rows = _clone(initialRows ?? const <String, List<List<String?>>>{});

  Map<String, List<List<String?>>> rows;
  final String? failOnTable;
  final bool failRollback;
  int snapshotCount = 0;
  int restoreCount = 0;
  int transactionCount = 0;
  final Map<int, Map<String, List<List<String?>>>> _snapshots = {};

  @override
  Future<Object> createSafetySnapshot() async {
    snapshotCount++;
    _snapshots[snapshotCount] = _clone(rows);
    return snapshotCount;
  }

  @override
  Future<void> restoreSafetySnapshot(Object snapshotToken) async {
    restoreCount++;
    if (failRollback) {
      throw StateError('Synthetic safety-snapshot restore failure');
    }
    final id = snapshotToken as int;
    rows = _clone(_snapshots[id]!);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(BackupImportTransaction transaction) action) async {
    transactionCount++;
    final working = _clone(rows);
    final transaction = _MemoryTransaction(working, failOnTable: failOnTable);
    final result = await action(transaction);
    rows = working;
    return result;
  }

  static Map<String, List<List<String?>>> _clone(Map<String, List<List<String?>>> source) =>
      <String, List<List<String?>>>{
        for (final entry in source.entries)
          entry.key: entry.value.map((row) => List<String?>.of(row)).toList(growable: true),
      };
}

final class _MemoryTransaction implements BackupImportTransaction {
  _MemoryTransaction(this.rows, {this.failOnTable});

  final Map<String, List<List<String?>>> rows;
  final String? failOnTable;

  void _maybeFail(String fileName) {
    if (fileName == failOnTable) {
      throw StateError('Synthetic import failure for $fileName');
    }
  }

  @override
  Future<void> replaceTable(String fileName, List<List<String?>> incoming) async {
    _maybeFail(fileName);
    rows[fileName] = incoming.map((row) => List<String?>.of(row)).toList(growable: true);
  }

  @override
  Future<void> upsertTable({
    required String fileName,
    required int primaryKeyIndex,
    required List<List<String?>> rows,
  }) async {
    _maybeFail(fileName);
    final current = this.rows.putIfAbsent(fileName, () => <List<String?>>[]);
    final indexById = <String, int>{};
    for (var index = 0; index < current.length; index++) {
      final id = current[index][primaryKeyIndex];
      if (id != null) indexById[id] = index;
    }
    for (final incoming in rows) {
      final id = incoming[primaryKeyIndex];
      if (id == null || id.isEmpty) throw StateError('Incoming primary key is empty.');
      final existingIndex = indexById[id];
      final copy = List<String?>.of(incoming);
      if (existingIndex == null) {
        indexById[id] = current.length;
        current.add(copy);
      } else {
        current[existingIndex] = copy;
      }
    }
  }
}
