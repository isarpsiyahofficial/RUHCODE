import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_application_service.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/backup/backup_settings_page.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

void main() {
  testWidgets('backup export share and import controls expose semantics and 48dp targets', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    final actions = _RecordingBackupActions();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr', 'TR'),
        theme: RuhAppTheme.light(),
        home: BackupSettingsPage(backupActions: actions),
      ),
    );
    await tester.pumpAndSettle();

    final export = find.byKey(const ValueKey(RuhActionIds.backupExport));
    final share = find.byKey(const ValueKey(RuhActionIds.backupShare));
    final import = find.byKey(const ValueKey(RuhActionIds.backupImport));

    expect(export, findsOneWidget);
    expect(share, findsOneWidget);
    expect(import, findsOneWidget);
    expect(find.bySemanticsLabel('Tam Yedek Oluştur'), findsOneWidget);
    expect(find.bySemanticsLabel('Yedeği Paylaş'), findsOneWidget);
    expect(find.bySemanticsLabel('Yedek Dosyası Seç'), findsOneWidget);
    expect(tester.getSize(export).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(share).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(import).height, greaterThanOrEqualTo(48));

    await tester.tap(share);
    await tester.pumpAndSettle();
    expect(actions.shareCalls, 1);
    expect(actions.lastShareFileName, endsWith('.ruhcode.zip'));
    expect(find.text('İşlem iptal edildi. Verilerinde değişiklik yapılmadı.'), findsOneWidget);
  });
}

final class _RecordingBackupActions implements BackupApplicationActions {
  int shareCalls = 0;
  String lastShareFileName = '';

  @override
  Future<BackupSaveResult> exportAndSave({
    required String suggestedFileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) async => const BackupSaveResult(status: BackupUserOperationStatus.cancelled);

  @override
  Future<BackupShareResult> exportAndShare({
    required String fileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
    String? title,
    String? text,
  }) async {
    shareCalls += 1;
    lastShareFileName = fileName;
    return const BackupShareResult(status: BackupUserOperationStatus.cancelled);
  }

  @override
  Future<BackupPickResult> pickAndPreviewRestore() async =>
      const BackupPickResult(status: BackupUserOperationStatus.cancelled);

  @override
  Future<BackupImportResult> applyRestore({
    required BackupRestoreSelection selection,
    required BackupImportMode mode,
  }) => throw UnimplementedError('not used by accessibility surface test');
}
