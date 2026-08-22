import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/src/backup/backup_application_service.dart';
import '../../../lib/src/backup/backup_import_coordinator.dart';
import '../../../lib/src/backup/backup_service.dart';
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

final class _FakeBackupActions implements BackupApplicationActions {
  BackupUserOperationStatus saveStatus = BackupUserOperationStatus.cancelled;
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
  Future<BackupPickResult> pickAndPreviewRestore() async =>
      const BackupPickResult(status: BackupUserOperationStatus.cancelled);

  @override
  Future<BackupImportResult> applyRestore({
    required BackupRestoreSelection selection,
    required BackupImportMode mode,
  }) {
    throw UnimplementedError();
  }
}

Widget _app(_FakeBackupActions backup, {Locale locale = const Locale('tr')}) {
  const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
  return MaterialApp(
    locale: locale,
    home: MainNavigationShell(
      featureAccess: guard,
      backupActions: backup,
    ),
  );
}

Future<void> _openBackupPage(WidgetTester tester, {bool english = false}) async {
  await tester.tap(find.text(english ? 'Profil' : 'Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ayarlar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Yedekleme ve Aktarma'));
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