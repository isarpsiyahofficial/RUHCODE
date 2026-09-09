import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/data_deletion_policy.dart';

void main() {
  const policy = DataDeletionPolicy();

  LinkedRecordRef record(String id, DeletableRecordKind kind, String clientId) =>
      LinkedRecordRef(id: id, kind: kind, clientId: clientId);

  final records = <LinkedRecordRef>[
    record('profile-a', DeletableRecordKind.profile, 'client-a'),
    record('consult-a', DeletableRecordKind.consultation, 'client-a'),
    record('report-a', DeletableRecordKind.report, 'client-a'),
    record('calc-a', DeletableRecordKind.calculation, 'client-a'),
    record('note-a', DeletableRecordKind.note, 'client-a'),
    record('profile-b', DeletableRecordKind.profile, 'client-b'),
    record('note-b', DeletableRecordKind.note, 'client-b'),
  ];

  test('delete all is a single explicit destructive operation', () {
    final plan = policy.planDeleteAll();
    expect(plan.eraseAllApplicationData, isTrue);
    expect(plan.requiresExplicitConfirmation, isTrue);
  });

  test('single client delete previews every linked record before mutation', () {
    final preview = policy.previewClientDeletion(clientId: 'client-a', allRecords: records);
    expect(preview.linkedRecords.map((e) => e.id), containsAll(['profile-a', 'consult-a', 'report-a', 'calc-a', 'note-a']));
    expect(preview.countsByKind[DeletableRecordKind.note], 1);
    expect(preview.linkedRecords.any((e) => e.clientId != 'client-a'), isFalse);
  });

  test('cascade delete rules are explicit and unrelated clients are untouched', () {
    final plan = policy.planClientDeletion(
      clientId: 'client-a',
      allRecords: records,
      mode: ClientDeletionMode.deleteRelatedData,
    );
    expect(plan.deleteIds, containsAll(['client-a', 'profile-a', 'consult-a', 'report-a', 'calc-a', 'note-a']));
    expect(plan.deleteIds, isNot(contains('profile-b')));
    expect(plan.deleteIds, isNot(contains('note-b')));
    expect(policy.cascadeDeleteKinds, contains(DeletableRecordKind.note));
  });

  test('profile can be deleted while consultation reports are archived', () {
    final plan = policy.planClientDeletion(
      clientId: 'client-a',
      allRecords: records,
      mode: ClientDeletionMode.archiveReports,
    );
    expect(plan.deleteIds, contains('client-a'));
    expect(plan.deleteIds, contains('note-a'));
    expect(plan.archiveIds, contains('report-a'));
    expect(plan.deleteIds, isNot(contains('report-a')));
    expect(plan.requiresExplicitConfirmation, isTrue);
  });

  test('restore keeps previously deleted records deleted by default', () {
    final ledger = DeletionTombstoneLedger(['note-a', 'report-a']);
    final restored = ledger.filterRestore(
      records,
      policy: RestoreDeletedRecordPolicy.keepDeleted,
    );
    expect(restored.any((e) => e.id == 'note-a'), isFalse);
    expect(restored.any((e) => e.id == 'report-a'), isFalse);
    expect(restored.any((e) => e.id == 'profile-b'), isTrue);
  });

  test('restore may reintroduce deleted records only after explicit user choice', () {
    final ledger = DeletionTombstoneLedger(['note-a']);
    final restored = ledger.filterRestore(
      records,
      policy: RestoreDeletedRecordPolicy.restoreExplicitly,
    );
    expect(restored.any((e) => e.id == 'note-a'), isTrue);
  });

  test('invalid empty client identity fails closed', () {
    expect(
      () => policy.previewClientDeletion(clientId: '   ', allRecords: records),
      throwsArgumentError,
    );
  });
}
