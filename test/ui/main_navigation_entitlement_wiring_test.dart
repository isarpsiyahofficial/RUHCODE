import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/domain/models/core_models.dart';
import '../../lib/src/entitlements/entitlement_service.dart';
import '../../lib/src/entitlements/feature_access_guard.dart';
import '../../lib/src/entitlements/feature_catalog.dart';
import '../../lib/src/ui/navigation/main_navigation_shell.dart';

final class _AllowAllEntitlements implements EntitlementService {
  const _AllowAllEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

final class _FreeOnlyEntitlements implements EntitlementService {
  const _FreeOnlyEntitlements();

  @override
  Future<bool> canUse(String featureId) async =>
      RuhFeatureCatalog.policyFor(featureId).baseAccess == FeatureBaseAccess.free;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.free);
}

void main() {
  testWidgets('bottom navigation exposes the four canonical destinations', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Araçlar'), findsOneWidget);
    expect(find.text('Kayıtlar'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('free tool route resolves through FeatureAccessGuard before opening', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Araçlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batı Astrolojisi'));
    await tester.pumpAndSettle();

    expect(find.text('Batı Astrolojisi ekranı'), findsOneWidget);
  });

  testWidgets('personal profiles action is live and remains free', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profillerim'));
    await tester.pumpAndSettle();

    expect(find.text('Profillerim ekranı'), findsOneWidget);
  });

  testWidgets('free user cannot enter advanced Western route', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Araçlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gelişmiş Batı Analizi'));
    await tester.pumpAndSettle();

    expect(find.text('Bu özellik için PRO erişimi gerekiyor.'), findsOneWidget);
    expect(find.text('Gelişmiş Batı Analizi ekranı'), findsNothing);
  });

  testWidgets('free user cannot enter professional clients workspace', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlarım'));
    await tester.pumpAndSettle();

    expect(find.text('Danışan çalışma alanı PRO kullanıcılar içindir.'), findsOneWidget);
    expect(find.text('Danışanlarım ekranı'), findsNothing);
  });

  testWidgets('PDF sample remains free while professional PDF is guarded', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PDF Rapor Önizleme'));
    await tester.pumpAndSettle();
    expect(find.text('PDF Rapor Önizleme ekranı'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profesyonel PDF Raporu'));
    await tester.pumpAndSettle();
    expect(find.text('Profesyonel PDF oluşturmak için PRO erişimi gerekiyor.'), findsOneWidget);
    expect(find.text('Profesyonel PDF Raporu ekranı'), findsNothing);
  });

  testWidgets('PRO user can enter professional clients and PDF routes', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell(featureAccess: guard)),
    );

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlarım'));
    await tester.pumpAndSettle();
    expect(find.text('Danışanlarım ekranı'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profesyonel PDF Raporu'));
    await tester.pumpAndSettle();
    expect(find.text('Profesyonel PDF Raporu ekranı'), findsOneWidget);
  });
}
