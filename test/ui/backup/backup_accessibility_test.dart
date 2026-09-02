import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_application_service.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/backup/backup_settings_page.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

const _supportedLocales = <Locale>[Locale('tr'), Locale('en')];
const _delegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  testWidgets('backup export share and import controls expose semantics and 48dp targets', (tester) async {
    final semantics = tester.ensureSemantics();
    final actions = _RecordingBackupActions();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr', 'TR'),
        supportedLocales: _supportedLocales,
        localizationsDelegates: _delegates,
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
    semantics.dispose();
  });

  testWidgets('valid restore preview exposes canonical merge replace semantics and deterministic focus order',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final preview = const BackupPackageReader().preview(
      const BackupPackageWriter().write(
        rowsByTable: <String, List<List<String?>>>{},
        appVersion: 'test',
        engineVersion: 'test',
        localeTag: 'tr-TR',
        exportedAtUtc: DateTime.utc(2026, 8, 23),
      ),
    );
    expect(preview.valid, isTrue);
    final actions = _RecordingBackupActions(preview: preview);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr', 'TR'),
        supportedLocales: _supportedLocales,
        localizationsDelegates: _delegates,
        theme: RuhAppTheme.light(),
        home: BackupSettingsPage(backupActions: actions),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey(RuhActionIds.backupImport)));
    await tester.pumpAndSettle();

    final merge = find.byKey(const ValueKey(RuhActionIds.backupRestoreMerge));
    final replace = find.byKey(const ValueKey(RuhActionIds.backupRestoreReplace));

    await tester.ensureVisible(merge);
    await tester.pumpAndSettle();
    expect(merge, findsOneWidget);
    expect(find.bySemanticsLabel('Mevcut Verilerle Birleştir'), findsOneWidget);
    expect(tester.getSize(merge).height, greaterThanOrEqualTo(48));
    final mergeOrder = tester.widget<FocusTraversalOrder>(
      find.ancestor(of: merge, matching: find.byType(FocusTraversalOrder)).first,
    );
    expect((mergeOrder.order as NumericFocusOrder).order, 1);

    await tester.ensureVisible(replace);
    await tester.pumpAndSettle();
    expect(replace, findsOneWidget);
    expect(find.bySemanticsLabel('Mevcut Verileri Değiştir'), findsOneWidget);
    expect(tester.getSize(replace).height, greaterThanOrEqualTo(48));
    final replaceOrder = tester.widget<FocusTraversalOrder>(
      find.ancestor(of: replace, matching: find.byType(FocusTraversalOrder)).first,
    );
    expect((replaceOrder.order as NumericFocusOrder).order, 2);

    await tester.ensureVisible(merge);
    await tester.pumpAndSettle();
    await tester.tap(merge);
    await tester.pumpAndSettle();
    expect(actions.appliedModes, <BackupImportMode>[BackupImportMode.merge]);

    final importAgain = find.byKey(const ValueKey(RuhActionIds.backupImport));
    await tester.ensureVisible(importAgain);
    await tester.pumpAndSettle();
    await tester.tap(importAgain);
    await tester.pumpAndSettle();
    final replaceAgain = find.byKey(const ValueKey(RuhActionIds.backupRestoreReplace));
    await tester.ensureVisible(replaceAgain);
    await tester.pumpAndSettle();
    await tester.tap(replaceAgain);
    await tester.pumpAndSettle();
    expect(
      actions.appliedModes,
      <BackupImportMode>[BackupImportMode.merge, BackupImportMode.replace],
    );
    semantics.dispose();
  });
}

final class _RecordingBackupActions implements BackupApplicationActions {
  _RecordingBackupActions({this.preview});

  final BackupImportPreview? preview;
  int shareCalls = 0;
  String lastShareFileName = '';
  final List<BackupImportMode> appliedModes = <BackupImportMode>[];

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
  Future<BackupPickResult> pickAndPreviewRestore() async {
    final value = preview;
    if (value == null) {
      return const BackupPickResult(status: BackupUserOperationStatus.cancelled);
    }
    return BackupPickResult(
      status: BackupUserOperationStatus.completed,
      selection: BackupRestoreSelection(fileName: 'valid.ruhcode.zip', preview: value),
    );
  }

  @override
  Future<BackupImportResult> applyRestore({
    required BackupRestoreSelection selection,
    required BackupImportMode mode,
  }) async {
    appliedModes.add(mode);
    return BackupImportResult(
      mode: mode,
      importedRecordCount: selection.preview.totalRecords,
      safetySnapshotCreated: mode == BackupImportMode.replace,
    );
  }
}