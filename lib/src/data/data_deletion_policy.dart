import 'dart:collection';

enum DeletableRecordKind {
  client,
  profile,
  consultation,
  report,
  calculation,
  note,
  journal,
}

enum ClientDeletionMode {
  deleteRelatedData,
  archiveReports,
}

enum RestoreDeletedRecordPolicy {
  keepDeleted,
  restoreExplicitly,
}

final class LinkedRecordRef {
  const LinkedRecordRef({
    required this.id,
    required this.kind,
    required this.clientId,
  });

  final String id;
  final DeletableRecordKind kind;
  final String clientId;
}

final class ClientDeletionPreview {
  ClientDeletionPreview({
    required this.clientId,
    required Iterable<LinkedRecordRef> linkedRecords,
  }) : linkedRecords = List.unmodifiable(linkedRecords);

  final String clientId;
  final List<LinkedRecordRef> linkedRecords;

  Map<DeletableRecordKind, int> get countsByKind {
    final result = <DeletableRecordKind, int>{};
    for (final record in linkedRecords) {
      result.update(record.kind, (value) => value + 1, ifAbsent: () => 1);
    }
    return UnmodifiableMapView(result);
  }
}

final class ClientDeletionPlan {
  ClientDeletionPlan({
    required this.clientId,
    required this.mode,
    required Iterable<String> deleteIds,
    required Iterable<String> archiveIds,
  })  : deleteIds = Set.unmodifiable(deleteIds),
        archiveIds = Set.unmodifiable(archiveIds) {
    if (clientId.trim().isEmpty) {
      throw ArgumentError('Client deletion requires a stable client id');
    }
    if (deleteIds.intersection(archiveIds).isNotEmpty) {
      throw StateError('A record cannot be deleted and archived in the same plan');
    }
  }

  final String clientId;
  final ClientDeletionMode mode;
  final Set<String> deleteIds;
  final Set<String> archiveIds;

  bool get requiresExplicitConfirmation => true;
}

final class DeleteAllPlan {
  const DeleteAllPlan._();

  static const instance = DeleteAllPlan._();

  bool get eraseAllApplicationData => true;
  bool get requiresExplicitConfirmation => true;
}

/// Records deleted after a backup was created remain suppressed on restore unless
/// the user explicitly asks to restore deleted records.
final class DeletionTombstoneLedger {
  DeletionTombstoneLedger([Iterable<String> deletedRecordIds = const []])
      : _deletedRecordIds = {...deletedRecordIds};

  final Set<String> _deletedRecordIds;

  Set<String> get deletedRecordIds => Set.unmodifiable(_deletedRecordIds);

  void record(Iterable<String> ids) {
    for (final id in ids) {
      if (id.trim().isEmpty) {
        throw ArgumentError('Tombstone id must not be empty');
      }
      _deletedRecordIds.add(id);
    }
  }

  List<LinkedRecordRef> filterRestore(
    Iterable<LinkedRecordRef> backupRecords, {
    required RestoreDeletedRecordPolicy policy,
  }) {
    if (policy == RestoreDeletedRecordPolicy.restoreExplicitly) {
      return List.unmodifiable(backupRecords);
    }
    return List.unmodifiable(
      backupRecords.where((record) => !_deletedRecordIds.contains(record.id)),
    );
  }
}

final class DataDeletionPolicy {
  const DataDeletionPolicy();

  static const Set<DeletableRecordKind> _cascadeDeleteKinds = {
    DeletableRecordKind.profile,
    DeletableRecordKind.consultation,
    DeletableRecordKind.calculation,
    DeletableRecordKind.note,
    DeletableRecordKind.journal,
  };

  ClientDeletionPreview previewClientDeletion({
    required String clientId,
    required Iterable<LinkedRecordRef> allRecords,
  }) {
    _validateClientId(clientId);
    return ClientDeletionPreview(
      clientId: clientId,
      linkedRecords: allRecords.where((record) => record.clientId == clientId),
    );
  }

  ClientDeletionPlan planClientDeletion({
    required String clientId,
    required Iterable<LinkedRecordRef> allRecords,
    required ClientDeletionMode mode,
  }) {
    _validateClientId(clientId);
    final ownRecords = allRecords.where((record) => record.clientId == clientId).toList(growable: false);
    final deleteIds = <String>{clientId};
    final archiveIds = <String>{};

    for (final record in ownRecords) {
      if (record.kind == DeletableRecordKind.report && mode == ClientDeletionMode.archiveReports) {
        archiveIds.add(record.id);
        continue;
      }
      if (record.kind == DeletableRecordKind.report || _cascadeDeleteKinds.contains(record.kind)) {
        deleteIds.add(record.id);
      }
    }

    return ClientDeletionPlan(
      clientId: clientId,
      mode: mode,
      deleteIds: deleteIds,
      archiveIds: archiveIds,
    );
  }

  DeleteAllPlan planDeleteAll() => DeleteAllPlan.instance;

  Set<DeletableRecordKind> get cascadeDeleteKinds => Set.unmodifiable(_cascadeDeleteKinds);

  void _validateClientId(String clientId) {
    if (clientId.trim().isEmpty) {
      throw ArgumentError('Client deletion requires a stable client id');
    }
  }
}
