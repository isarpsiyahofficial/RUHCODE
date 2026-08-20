import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_application_service.dart';
import 'package:ruh_code/src/backup/backup_platform_gateway.dart';
import 'package:ruh_code/src/ui/backup/backup_ui_contract.dart';

void main() {
  group('Backup UI copy', () {
    test('TR and EN expose the same complete action/state surface', () {
      expect(backupUiCopy.keys.toSet(), {RuhLocale.tr, RuhLocale.en});
      for (final copy in backupUiCopy.values) {
        expect(copy.title.trim(), isNotEmpty);
        expect(copy.description.trim(), isNotEmpty);
        expect(copy.saveLabel.trim(), isNotEmpty);
        expect(copy.shareLabel.trim(), isNotEmpty);
        expect(copy.chooseLabel.trim(), isNotEmpty);
        expect(copy.mergeLabel.trim(), isNotEmpty);
        expect(copy.replaceLabel.trim(), isNotEmpty);
        expect(copy.cancelLabel.trim(), isNotEmpty);
        expect(copy.statusMessages.keys.toSet(), BackupUiPhase.values.toSet());
        for (final phase in BackupUiPhase.values.where((phase) => phase != BackupUiPhase.idle)) {
          expect(copy.status(phase).trim(), isNotEmpty, reason: 'Missing copy for $phase');
        }
      }
    });

    test('portable backup actions are not mislabeled as single CSV import/export', () {
      final tr = backupUiCopy[RuhLocale.tr]!;
      final en = backupUiCopy[RuhLocale.en]!;
      final visible = <String>[
        tr.saveLabel,
        tr.chooseLabel,
        tr.description,
        en.saveLabel,
        en.chooseLabel,
        en.description,
      ].join(' ').toLowerCase();

      expect(visible, isNot(contains('csv dışa aktar')));
      expect(visible, isNot(contains('csv içe aktar')));
      expect(visible, isNot(contains('export csv')));
      expect(visible, isNot(contains('import csv')));
    });

    test('destructive replace and non-destructive merge are visibly distinct', () {
      for (final copy in backupUiCopy.values) {
        expect(copy.mergeLabel, isNot(copy.replaceLabel));
      }
    });
  });

  group('Backup UI state mapping', () {
    test('save cancellation is normal cancellation state', () {
      expect(
        phaseForSaveResult(const BackupSaveResult(status: BackupUserOperationStatus.cancelled)),
        BackupUiPhase.cancelled,
      );
    });

    test('completed save is saved state', () {
      expect(
        phaseForSaveResult(
          BackupSaveResult(
            status: BackupUserOperationStatus.completed,
            uri: Uri.file('/tmp/ruh-code.ruhcode.zip'),
          ),
        ),
        BackupUiPhase.saved,
      );
    });

    test('dismissed share remains cancellation rather than failure', () {
      expect(
        phaseForShareResult(
          const BackupShareResult(
            status: BackupUserOperationStatus.cancelled,
            shareStatus: BackupShareStatus.dismissed,
          ),
        ),
        BackupUiPhase.cancelled,
      );
    });

    test('unavailable share has a dedicated recoverable UI state', () {
      expect(
        phaseForShareResult(
          const BackupShareResult(
            status: BackupUserOperationStatus.completed,
            shareStatus: BackupShareStatus.unavailable,
          ),
        ),
        BackupUiPhase.shareUnavailable,
      );
    });

    test('cancelled picker cannot enable restore actions', () {
      final state = stateForPickResult(
        const BackupPickResult(status: BackupUserOperationStatus.cancelled),
      );
      expect(state.phase, BackupUiPhase.cancelled);
      expect(state.canApplyRestore, isFalse);
    });
  });
}
