import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';

final class _SnapshotProvider implements EntitlementSnapshotProvider {
  _SnapshotProvider(this.snapshot);
  EntitlementSnapshot snapshot;

  @override
  Future<EntitlementSnapshot> load() async => snapshot;
}

final class _Clock implements EntitlementClock {
  _Clock(this.value);
  DateTime value;

  @override
  DateTime nowUtc() => value;
}

void main() {
  final now = DateTime.utc(2026, 8, 20, 12);

  test('catalog covers every canonical feature ID exactly once', () {
    expect(() => RuhFeatureCatalog.validate(), returnsNormally);
    expect(RuhFeatureCatalog.policies.keys.toSet(), RuhFeatureIds.all);
  });

  test('free feature stays usable without PRO', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(const EntitlementSnapshot(hasPro: false)),
      clock: _Clock(now),
    );

    expect(await service.canUse(RuhFeatureIds.todayOverview), isTrue);
    expect((await service.resolve(RuhFeatureIds.todayOverview)).tier, EntitlementTier.free);
  });

  test('locked PRO feature is denied without active temporary grant', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(const EntitlementSnapshot(hasPro: false)),
      clock: _Clock(now),
    );

    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isFalse);
  });

  test('PRO account can use all canonical features', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(const EntitlementSnapshot(hasPro: true)),
      clock: _Clock(now),
    );

    for (final id in RuhFeatureIds.all) {
      expect(await service.canUse(id), isTrue, reason: id);
      expect((await service.resolve(id)).tier, EntitlementTier.pro, reason: id);
    }
  });

  test('active temporary grant unlocks only eligible feature until exact UTC expiry', () async {
    final provider = _SnapshotProvider(
      EntitlementSnapshot(
        hasPro: false,
        temporaryGrants: <TemporaryFeatureGrant>[
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.pdfProfessionalExport,
            validUntilUtc: now.add(const Duration(hours: 2)),
          ),
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.professionalClients,
            validUntilUtc: now.add(const Duration(hours: 2)),
          ),
        ],
      ),
    );
    final clock = _Clock(now);
    final service = PolicyEntitlementService(snapshotProvider: provider, clock: clock);

    final temporary = await service.resolve(RuhFeatureIds.pdfProfessionalExport);
    expect(temporary.tier, EntitlementTier.temporary);
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isTrue);

    // professionalClients is deliberately not ad/temporary eligible.
    expect(await service.canUse(RuhFeatureIds.professionalClients), isFalse);

    clock.value = now.add(const Duration(hours: 2));
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isFalse);
  });

  test('unknown feature ID fails closed', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(const EntitlementSnapshot(hasPro: false)),
      clock: _Clock(now),
    );
    await expectLater(service.canUse('invented.feature'), throwsArgumentError);
  });

  test('temporary expiry must be UTC', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(
        EntitlementSnapshot(
          hasPro: false,
          temporaryGrants: <TemporaryFeatureGrant>[
            TemporaryFeatureGrant(
              featureId: RuhFeatureIds.pdfProfessionalExport,
              validUntilUtc: DateTime(2026, 8, 21),
            ),
          ],
        ),
      ),
      clock: _Clock(now),
    );
    await expectLater(
      service.resolve(RuhFeatureIds.pdfProfessionalExport),
      throwsFormatException,
    );
  });

  test('entitlement clock must return UTC', () async {
    final service = PolicyEntitlementService(
      snapshotProvider: _SnapshotProvider(const EntitlementSnapshot(hasPro: false)),
      clock: _Clock(DateTime(2026, 8, 20, 12)),
    );
    await expectLater(
      service.resolve(RuhFeatureIds.pdfProfessionalExport),
      throwsStateError,
    );
  });
}
