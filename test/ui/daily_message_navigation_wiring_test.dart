import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_catalog.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/ui/navigation/main_navigation_shell.dart';

final class _AllowAllEntitlements implements EntitlementService {
  const _AllowAllEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

void main() {
  testWidgets('production Today tab renders the injected exact EN date record', (
    tester,
  ) async {
    final now = DateTime.now();
    final date = CivilDate(now.year, now.month, now.day);
    final catalog = DailyMessageCatalog(<DailyMessageEntry>[
      DailyMessageEntry(
        date: date,
        localeTag: 'en',
        title: 'Navigation exact-date proof',
        teaser: 'Injected through the production navigation shell.',
        fullText: 'The Today tab must render this exact local-date record.',
        themeTag: 'contract',
      ),
    ]);
    const guard = FeatureAccessGuard(entitlements: _AllowAllEntitlements());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: MainNavigationShell(
          featureAccess: guard,
          dailyMessages: catalog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Message of the Day'), findsOneWidget);
    expect(find.text(date.isoKey), findsOneWidget);
    expect(find.text('Navigation exact-date proof'), findsOneWidget);
    expect(
      find.text('Injected through the production navigation shell.'),
      findsOneWidget,
    );
    expect(
      find.text('The Today tab must render this exact local-date record.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('daily-message-missing')), findsNothing);
  });
}
