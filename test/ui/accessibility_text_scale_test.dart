import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_catalog.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/navigation/main_navigation_shell.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

final class _AllowAllEntitlements implements EntitlementService {
  const _AllowAllEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

Widget _scaledApp() {
  const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: RuhAppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2),
      ),
      child: child!,
    ),
    home: MainNavigationShell(
      featureAccess: guard,
      dailyMessages: DailyMessageCatalog(<DailyMessageEntry>[]),
    ),
  );
}

void main() {
  testWidgets(
    'canonical Tools Records Profile and PDF paths stay usable at 2.0x text scale',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 800));
      await tester.pumpWidget(_scaledApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey(RuhActionIds.navigationTools)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final personalGrowth = find.byKey(const ValueKey(RuhActionIds.toolsGrowth));
      final toolsScroll = find.ancestor(
        of: find.byKey(const ValueKey(RuhActionIds.toolsAstrology)),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        personalGrowth,
        180,
        scrollable: toolsScroll.first,
      );
      expect(find.text('Kişisel Gelişim'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey(RuhActionIds.navigationRecords)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final profiles = find.byKey(const ValueKey(RuhActionIds.recordsProfiles));
      final clients = find.byKey(const ValueKey(RuhActionIds.recordsClients));
      expect(profiles, findsOneWidget);
      final recordsScroll = find.ancestor(
        of: profiles,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        clients,
        180,
        scrollable: recordsScroll.first,
      );
      expect(find.text('Profillerim'), findsOneWidget);
      expect(find.text('Danışanlarım'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey(RuhActionIds.navigationProfile)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ayarlar'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey(RuhActionIds.profileSettings)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final pdfReports = find.byKey(const ValueKey(RuhActionIds.settingsPdf));
      await tester.ensureVisible(pdfReports);
      await tester.pumpAndSettle();
      expect(find.text('PDF Raporları'), findsOneWidget);

      await tester.tap(pdfReports);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Örnek PDF Önizle'), findsOneWidget);
      expect(find.text('Profesyonel PDF Oluştur'), findsOneWidget);
    },
  );
}
