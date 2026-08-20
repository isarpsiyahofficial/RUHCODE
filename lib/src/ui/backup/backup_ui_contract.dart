import '../../backup/backup_application_service.dart';
import '../../backup/backup_import_coordinator.dart';

enum RuhLocale { tr, en }

enum BackupUiPhase {
  idle,
  exporting,
  saved,
  sharing,
  shared,
  picking,
  previewReady,
  restoring,
  restored,
  cancelled,
  invalidBackup,
  rollbackRestored,
  shareUnavailable,
  failed,
}

enum BackupUiAction {
  saveFullBackup,
  shareFullBackup,
  chooseBackup,
  restoreMerge,
  restoreReplace,
  cancelRestore,
}

final class BackupUiCopy {
  const BackupUiCopy({
    required this.title,
    required this.description,
    required this.saveLabel,
    required this.shareLabel,
    required this.chooseLabel,
    required this.mergeLabel,
    required this.replaceLabel,
    required this.cancelLabel,
    required this.statusMessages,
  });

  final String title;
  final String description;
  final String saveLabel;
  final String shareLabel;
  final String chooseLabel;
  final String mergeLabel;
  final String replaceLabel;
  final String cancelLabel;
  final Map<BackupUiPhase, String> statusMessages;

  String status(BackupUiPhase phase) => statusMessages[phase] ?? '';
}

const backupUiCopy = <RuhLocale, BackupUiCopy>{
  RuhLocale.tr: BackupUiCopy(
    title: 'Yedekleme ve Aktarma',
    description: 'Tüm Ruh Code verilerini tek bir taşınabilir yedek dosyasında sakla veya geri yükle.',
    saveLabel: 'Tam Yedek Oluştur',
    shareLabel: 'Yedeği Paylaş',
    chooseLabel: 'Yedek Dosyası Seç',
    mergeLabel: 'Mevcut Verilerle Birleştir',
    replaceLabel: 'Mevcut Verileri Değiştir',
    cancelLabel: 'Vazgeç',
    statusMessages: {
      BackupUiPhase.idle: '',
      BackupUiPhase.exporting: 'Yedek hazırlanıyor…',
      BackupUiPhase.saved: 'Yedek kaydedildi.',
      BackupUiPhase.sharing: 'Paylaşım hazırlanıyor…',
      BackupUiPhase.shared: 'Yedek paylaşım ekranına gönderildi.',
      BackupUiPhase.picking: 'Yedek dosyası seçiliyor…',
      BackupUiPhase.previewReady: 'Yedek doğrulandı. İçeriği kontrol edip geri yükleme yöntemini seçebilirsin.',
      BackupUiPhase.restoring: 'Veriler geri yükleniyor…',
      BackupUiPhase.restored: 'Yedek başarıyla geri yüklendi.',
      BackupUiPhase.cancelled: 'İşlem iptal edildi. Verilerinde değişiklik yapılmadı.',
      BackupUiPhase.invalidBackup: 'Bu yedek doğrulanamadı. Mevcut verilerinde değişiklik yapılmadı.',
      BackupUiPhase.rollbackRestored: 'Geri yükleme tamamlanamadı. Güvenlik kopyası geri yüklendi.',
      BackupUiPhase.shareUnavailable: 'Bu cihazda paylaşım kullanılamıyor. Yedeği cihazına kaydedebilirsin.',
      BackupUiPhase.failed: 'İşlem tamamlanamadı. Mevcut veriler korundu.',
    },
  ),
  RuhLocale.en: BackupUiCopy(
    title: 'Backup & Transfer',
    description: 'Save or restore all Ruh Code data in one portable backup file.',
    saveLabel: 'Create Full Backup',
    shareLabel: 'Share Backup',
    chooseLabel: 'Choose Backup File',
    mergeLabel: 'Merge With Existing Data',
    replaceLabel: 'Replace Existing Data',
    cancelLabel: 'Cancel',
    statusMessages: {
      BackupUiPhase.idle: '',
      BackupUiPhase.exporting: 'Preparing backup…',
      BackupUiPhase.saved: 'Backup saved.',
      BackupUiPhase.sharing: 'Preparing share…',
      BackupUiPhase.shared: 'Backup sent to the share sheet.',
      BackupUiPhase.picking: 'Choosing backup file…',
      BackupUiPhase.previewReady: 'Backup verified. Review its contents and choose how to restore it.',
      BackupUiPhase.restoring: 'Restoring data…',
      BackupUiPhase.restored: 'Backup restored successfully.',
      BackupUiPhase.cancelled: 'Operation cancelled. Your data was not changed.',
      BackupUiPhase.invalidBackup: 'This backup could not be verified. Your existing data was not changed.',
      BackupUiPhase.rollbackRestored: 'Restore could not finish. The safety snapshot was restored.',
      BackupUiPhase.shareUnavailable: 'Sharing is unavailable on this device. You can save the backup instead.',
      BackupUiPhase.failed: 'The operation could not be completed. Your existing data was preserved.',
    },
  ),
};

final class BackupUiState {
  const BackupUiState({
    this.phase = BackupUiPhase.idle,
    this.selection,
    this.detail,
  });

  final BackupUiPhase phase;
  final BackupRestoreSelection? selection;
  final String? detail;

  bool get canApplyRestore => phase == BackupUiPhase.previewReady && selection != null;
}

BackupUiPhase phaseForSaveResult(BackupSaveResult result) {
  return result.status == BackupUserOperationStatus.cancelled
      ? BackupUiPhase.cancelled
      : BackupUiPhase.saved;
}

BackupUiPhase phaseForShareResult(BackupShareResult result) {
  if (result.status == BackupUserOperationStatus.cancelled) {
    return BackupUiPhase.cancelled;
  }
  final shareStatus = result.shareStatus?.name;
  if (shareStatus == 'unavailable') {
    return BackupUiPhase.shareUnavailable;
  }
  return BackupUiPhase.shared;
}

BackupUiState stateForPickResult(BackupPickResult result) {
  if (result.status == BackupUserOperationStatus.cancelled) {
    return const BackupUiState(phase: BackupUiPhase.cancelled);
  }
  final selection = result.selection;
  if (selection == null) {
    return const BackupUiState(phase: BackupUiPhase.failed);
  }
  if (!selection.preview.isValid) {
    return BackupUiState(
      phase: BackupUiPhase.invalidBackup,
      selection: selection,
      detail: selection.preview.issues.map((issue) => issue.message).join('\n'),
    );
  }
  return BackupUiState(phase: BackupUiPhase.previewReady, selection: selection);
}

BackupUiPhase phaseForImportResult(BackupImportResult result) {
  if (result.isSuccess) {
    return BackupUiPhase.restored;
  }
  if (result.rollbackRestored) {
    return BackupUiPhase.rollbackRestored;
  }
  return BackupUiPhase.failed;
}
