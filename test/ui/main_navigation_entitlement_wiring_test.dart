import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/domain/models/core_models.dart';
import '../../lib/src/entitlements/entitlement_service.dart';
import '../../lib/src/entitlements/feature_access_guard.dart';
import '../../lib/src/ui/navigation/main_navigation_shell.dart';

final class _AllowAllEntitlements implements EntitlementService {
  const _AllowAllEntitlements();

  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
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

  testWidgets('tool route resolves through FeatureAccessGuard before opening', (tester) async {
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
}
