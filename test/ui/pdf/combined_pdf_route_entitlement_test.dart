import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_catalog.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/ui/navigation/main_navigation_shell.dart';
import 'package:ruh_code/src/ui/pdf/combined_pdf_builder_page.dart';

final class _FreeOnlyEntitlements implements EntitlementService {
  const _FreeOnlyEntitlements();

  @override
  Future<bool> canUse(String featureId) async =>
      RuhFeatureCatalog.policyFor(featureId).baseAccess == FeatureBaseAccess.free;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.free);
}

final class _ProEntitlements implements EntitlementService {
  const _ProEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

Widget _app(EntitlementService entitlements) {
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
    routes: <String, WidgetBuilder>{
      '/pdf/combined': (_) => const CombinedProfessionalPdfBuilderPage(),
    },
    home: MainNavigationShell(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      dailyMessages: DailyMessageCatalog(<DailyMessageEntry>[]),
    ),
  );
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ayarlar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Free user cannot enter combined professional PDF route', (tester) async {
    await tester.pumpWidget(_app(const _FreeOnlyEntitlements()));
    await _openSettings(tester);

    expect(find.text('Kombine PDF Raporu'), findsOneWidget);
    await tester.tap(find.text('Kombine PDF Raporu'));
    await tester.pumpAndSettle();

    expect(find.text('Kombine PDF raporu PRO kullanıcılar içindir.'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Kombine PDF Raporu'), findsNothing);
  });

  testWidgets('PRO user can enter combined professional PDF route', (tester) async {
    await tester.pumpWidget(_app(const _ProEntitlements()));
    await _openSettings(tester);

    await tester.tap(find.text('Kombine PDF Raporu'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Kombine PDF Raporu'), findsOneWidget);
    expect(find.textContaining('production runtime'), findsOneWidget);
  });
}
