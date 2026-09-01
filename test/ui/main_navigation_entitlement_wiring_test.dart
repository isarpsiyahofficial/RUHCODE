import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/content/daily_messages/daily_message_catalog.dart';
import '../../lib/src/domain/models/core_models.dart';
import '../../lib/src/entitlements/entitlement_service.dart';
import '../../lib/src/entitlements/feature_access_guard.dart';
import '../../lib/src/entitlements/feature_catalog.dart';
import '../../lib/src/ui/actions/ruh_action_ids.dart';
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

Widget _app(FeatureAccessGuard guard, {double textScale = 1}) {
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
    home: MainNavigationShell(
      featureAccess: guard,
      dailyMessages: DailyMessageCatalog(<DailyMessageEntry>[]),
    ),
  );
}

Future<void> _openAstrologyHub(WidgetTester tester) async {
  await tester.tap(find.text('Araçlar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Astroloji'));
  await tester.pumpAndSettle();
}

Future<void> _openPdfReports(WidgetTester tester) async {
  await tester.tap(find.text('Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ayarlar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('PDF Raporları'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom navigation exposes the four canonical destinations', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard));

    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Araçlar'), findsOneWidget);
    expect(find.text('Kayıtlar'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Hesapla'), findsNothing);
  });

  testWidgets('tools exposes four clear top-level categories', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard));

    await tester.tap(find.text('Araçlar'));
    await tester.pumpAndSettle();

    expect(find.text('Astroloji'), findsOneWidget);
    expect(find.text('Numeroloji'), findsOneWidget);
    expect(find.text('Spiritüel'), findsOneWidget);
    expect(find.text('Kişisel Gelişim'), findsOneWidget);
    expect(find.text('Batı Astrolojisi'), findsNothing);
  });

  testWidgets('Western route follows Tools to Astrology hierarchy and guard', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openAstrologyHub(tester);

    expect(find.text('Batı Astrolojisi'), findsOneWidget);
    expect(find.text('Vedik Astroloji'), findsOneWidget);
    expect(find.text('Çin Astrolojisi'), findsOneWidget);
    expect(find.text('BaZi'), findsOneWidget);
    expect(find.text('Gezegen Saatleri'), findsOneWidget);

    await tester.tap(find.text('Batı Astrolojisi'));
    await tester.pumpAndSettle();
    expect(find.text('Batı Astrolojisi ekranı'), findsOneWidget);
  });

  testWidgets('Chinese astrology remains Free while BaZi is PRO', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openAstrologyHub(tester);
    await tester.tap(find.text('Çin Astrolojisi'));
    await tester.pumpAndSettle();
    expect(find.text('Çin Astrolojisi ekranı'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('BaZi'));
    await tester.pumpAndSettle();
    expect(find.text('Bu özellik için PRO erişimi gerekiyor.'), findsOneWidget);
    expect(find.text('BaZi ekranı'), findsNothing);
  });

  testWidgets('personal profiles action is live and remains free', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profillerim'));
    await tester.pumpAndSettle();

    expect(find.text('Profillerim ekranı'), findsOneWidget);
  });

  testWidgets('free user cannot enter professional clients workspace', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlarım'));
    await tester.pumpAndSettle();

    expect(find.text('Danışan çalışma alanı PRO kullanıcılar içindir.'), findsOneWidget);
    expect(find.text('Danışanlarım ekranı'), findsNothing);
  });

  testWidgets('PRO user can enter professional clients workspace', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard));

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlarım'));
    await tester.pumpAndSettle();
    expect(find.text('Danışanlarım ekranı'), findsOneWidget);
  });

  testWidgets('profile settings exposes the PDF reports hub', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openPdfReports(tester);

    expect(find.widgetWithText(AppBar, 'PDF Raporları'), findsOneWidget);
    expect(find.byKey(const ValueKey(RuhActionIds.pdfPreview)), findsOneWidget);
    expect(find.byKey(const ValueKey(RuhActionIds.pdfBuild)), findsOneWidget);
  });

  testWidgets('Free user can inspect sample PDF preview', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openPdfReports(tester);
    await tester.tap(find.text('Örnek PDF Önizle'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Örnek PDF Önizleme'), findsOneWidget);
    expect(find.text('ÖRNEK RAPOR'), findsOneWidget);
    expect(find.textContaining('kişisel veri içermez'), findsOneWidget);
  });

  testWidgets('Free user cannot enter professional PDF builder', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _FreeOnlyEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openPdfReports(tester);
    await tester.tap(find.text('Profesyonel PDF Oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Profesyonel PDF oluşturma PRO kullanıcılar içindir.'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Profesyonel PDF Oluştur'), findsNothing);
  });

  testWidgets('PRO user can enter professional PDF builder', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard));

    await _openPdfReports(tester);
    await tester.tap(find.text('Profesyonel PDF Oluştur'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Profesyonel PDF Oluştur'), findsOneWidget);
    expect(find.text('Rapor Bölümleri'), findsOneWidget);
  });

  testWidgets('implemented action tiles expose semantics and 48dp minimum target', (tester) async {
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(_app(guard));
    await tester.tap(find.text('Araçlar'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Astroloji'), findsOneWidget);
    final astrologyTile = find.byKey(const ValueKey(RuhActionIds.toolsAstrology));
    expect(astrologyTile, findsOneWidget);
    expect(tester.getSize(astrologyTile).height, greaterThanOrEqualTo(48));

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('PDF Raporları'), findsOneWidget);
  });

  testWidgets('critical navigation remains usable at 2.0x text scale', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(360, 800));

    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
    await tester.pumpWidget(_app(guard, textScale: 2));

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Araçlar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Astroloji'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Batı Astrolojisi'), findsOneWidget);
  });
}
