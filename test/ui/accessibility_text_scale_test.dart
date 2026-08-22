import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
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
    theme: RuhAppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2),
      ),
      child: child!,
    ),
    home: const MainNavigationShell(featureAccess: guard),
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

      await tester.tap(find.text('Araçlar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Kişisel Gelişim'), findsOneWidget);

      await tester.tap(find.text('Kayıtlar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Profillerim'), findsOneWidget);
      expect(find.text('Danışanlarım'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ayarlar'), findsOneWidget);

      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('PDF Raporları'), findsOneWidget);

      await tester.ensureVisible(find.text('PDF Raporları'));
      await tester.tap(find.text('PDF Raporları'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Örnek PDF Önizle'), findsOneWidget);
      expect(find.text('Profesyonel PDF Oluştur'), findsOneWidget);
    },
  );
}
