import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/src/backup/backup_application_service.dart';
import '../../../lib/src/backup/backup_import_coordinator.dart';
import '../../../lib/src/backup/backup_package_codec.dart';
import '../../../lib/src/backup/backup_package_manifest.dart';
import '../../../lib/src/content/daily_messages/daily_message_catalog.dart';
import '../../../lib/src/domain/models/core_models.dart';
import '../../../lib/src/entitlements/entitlement_service.dart';
import '../../../lib/src/entitlements/feature_access_guard.dart';
import '../../../lib/src/ui/actions/ruh_action_ids.dart';
import '../../../lib/src/ui/navigation/main_navigation_shell.dart';

final class _AllowAllEntitlements implements EntitlementService {
  const _AllowAllEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

BackupRestoreSelection _validSelection() {
  return BackupRestoreSelection(
    fileName: 'fixture.ruhcode.zip',
    preview: BackupImportPreview(
      manifest: BackupPackageManifestV1(
        schemaVersion: 1,
        appVersion: '0.1.0+1',
        engineVersion: 'ruh-core.v1',
        exportedAtUtc: DateTime.utc(2026, 8, 22),
        localeTag: 'tr',
        files: const [],
      ),
      rowsByTable: const {},
      recordCounts: const {
        'profiles.csv': 2,
        'clients.csv': 3,
        'consultations.csv': 4,
        'journal_entries.csv': 5,
        'calculations.csv': 6,
      },
      issues: const [],
    ),
  );
}

final class _FakeBackupActions implements BackupApplicationActions {
  BackupUserOperationStatus saveStatus = BackupUserOperationStatus.cancelled;
  BackupPickResult pickResult = const BackupPickResult(
    status: BackupUserOperationStatus.cancelled,
  );
  Object? applyError;
  BackupImportMode? appliedMode;
  String? suggestedFileName;
  String? appVersion;
  String? engineVersion;
  String? localeTag;
  DateTime? exportedAtUtc;

  @override
  Future<BackupSaveResult> exportAndSave({
    required String suggestedFileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) async {
    this.suggestedFileName = suggestedFileName;
    this.appVersion = appVersion;
    this.engineVersion = engineVersion;
    this.localeTag = localeTag;
    this.exportedAtUtc = exportedAtUtc;
    return BackupSaveResult(
      status: saveStatus,
      uri: saveStatus == BackupUserOperationStatus.completed
          ? Uri.parse('file:///ruh_code_test.ruhcode.zip')
          : null,
    );
  }

  @override
  Future<BackupShareResult> exportAndShare({
    required String fileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
    String? title,
    String? text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<BackupPickResult> pickAndPreviewRestore() async => pickResult;

  @override
  Future<BackupImportResult> applyRestore({
    required BackupRestoreSelection selection,
    required BackupImportMode mode,
  }) async {
    final error = applyError;
    if (error != null) throw error;
    appliedMode = mode;
    return BackupImportResult(
      mode: mode,
      importedRecordCount: selection.preview.totalRecords,
      safetySnapshotCreated: mode == BackupImportMode.replace,
    );
  }
}

Widget _app(_FakeBackupActions backup, {Locale locale = const Locale('tr')}) {
  const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: MainNavigationShell(
      featureAccess: guard,
      dailyMessages: DailyMessageCatalog(<DailyMessageEntry>[]),
      backupActions: backup,
    ),
  );
}

Future<void> _openBackupPage(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey(RuhActionIds.navigationProfile)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey(RuhActionIds.profileSettings)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey(RuhActionIds.settingsBackup)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings exposes the real backup runtime actions', (tester) async {
    final backup = _FakeBackupActions();
    await tester.pumpWidget(_app(backup));

    await _openBackupPage(tester);

    expect(find.widgetWithText(AppBar, 'Yedekleme ve Aktarma'), findsOneWidget);
    expect(find.byKey(const ValueKey(RuhActionIds.backupExport)), findsOneWidget);
    expect(find.byKey(const ValueKey(RuhActionIds.backupImport)), findsOneWidget);
    expect(find.text('Tam Yedek Oluştur'), findsOneWidget);
    expect(find.text('Yedek Dosyası Seç'), findsOneWidget);
    expect(find.text('CSV Dışa Aktar'), findsNothing);
    expect(find.text('CSV İçe Aktar'), findsNothing);
  });

  testWidgets('cancelled Save As is a normal result and preserves portable metadata', (tester) async {
    final backup = _FakeBackupActions();
    await tester.pumpWidget(_app(backup));

    await _openBackupPage(tester);
    await tester.tap(find.text('Tam Yedek Oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('İşlem iptal edildi. Verilerinde değişiklik yapılmadı.'), findsOneWidget);
    expect(backup.suggestedFileName, endsWith('.ruhcode.zip'));
    expect(backup.appVersion, '0.1.0+1');
    expect(backup.engineVersion, 'ruh-core.v1');
    expect(backup.localeTag, isNotEmpty);
    expect(backup.exportedAtUtc!.isUtc, isTrue);
  });

  testWidgets('cancelled restore picker does not present merge or replace controls', (tester) async {
    final backup = _FakeBackupActions();
    await tester.pumpWidget(_app(backup));

    await _openBackupPage(tester);
    await tester.tap(find.text('Yedek Dosyası Seç'));
    await tester.pumpAndSettle();

    expect(find.text('İşlem iptal edildi. Verilerinde değişiklik yapılmadı.'), findsOneWidget);
    expect(find.text('Mevcut Verilerle Birleştir'), findsNothing);
    expect(find.text('Mevcut Verileri Değiştir'), findsNothing);
  });

  testWidgets('valid preview exposes the five required record counts before mutation', (tester) async {
    final backup = _FakeBackupActions()
      ..pickResult = BackupPickResult(
        status: BackupUserOperationStatus.completed,
        selection: _validSelection(),
      );
    await tester.pumpWidget(_app(backup));

    await _openBackupPage(tester);
    await tester.tap(find.text('Yedek Dosyası Seç'));
    await tester.pumpAndSettle();

    expect(find.text('Profiller'), findsOneWidget);
    expect(find.text('Danışanlar'), findsOneWidget);
    expect(find.text('Danışmanlıklar'), findsOneWidget);
    expect(find.text('Günlük Kayıtları'), findsOneWidget);
    expect(find.text('Hesaplamalar'), findsOneWidget);
    expect(find.text('Mevcut Verilerle Birleştir'), findsOneWidget);
    expect(find.text('Mevcut Verileri Değiştir'), findsOneWidget);
    expect(backup.appliedMode, isNull);
  });

  testWidgets('failed replace rollback surfaces critical integrity state', (tester) async {
    final backup = _FakeBackupActions()
      ..pickResult = BackupPickResult(
        status: BackupUserOperationStatus.completed,
        selection: _validSelection(),
      )
      ..applyError = BackupRestoreException(
        cause: StateError('replace failed'),
        rollbackRestored: false,
        rollbackFailure: StateError('snapshot restore failed'),
      );
    await tester.pumpWidget(_app(backup));

    await _openBackupPage(tester);
    await tester.tap(find.text('Yedek Dosyası Seç'));
    await tester.pumpAndSettle();
    final replace = find.byKey(const ValueKey(RuhActionIds.backupRestoreReplace));
    await tester.ensureVisible(replace);
    await tester.pumpAndSettle();
    await tester.tap(replace);
    await tester.pumpAndSettle();

    expect(find.textContaining('Veri bütünlüğü kontrol edilmeli'), findsOneWidget);
    expect(find.textContaining('Veriler korundu'), findsNothing);
  });

  testWidgets('English locale uses the independent English backup copy', (tester) async {
    final backup = _FakeBackupActions();
    await tester.pumpWidget(_app(backup, locale: const Locale('en')));

    await _openBackupPage(tester);

    expect(find.widgetWithText(AppBar, 'Backup & Transfer'), findsOneWidget);
    expect(find.text('Create Full Backup'), findsOneWidget);
    expect(find.text('Choose Backup File'), findsOneWidget);
    expect(find.text('Tam Yedek Oluştur'), findsNothing);
  });
}
