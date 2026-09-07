import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/runtime_capability_policy.dart';

void main() {
  test('app launch has no implicit network allow-list', () {
    expect(RuntimeCapabilityPolicy.launchNetworkAllowList, isEmpty);
  });

  test('core product capabilities are explicitly offline', () {
    for (final capability in <RuntimeCapability>[
      RuntimeCapability.westernCalculation,
      RuntimeCapability.vedicCalculation,
      RuntimeCapability.chineseCalculation,
      RuntimeCapability.baziCalculation,
      RuntimeCapability.numerologyCalculation,
      RuntimeCapability.planetaryHoursCalculation,
      RuntimeCapability.profileReadWrite,
      RuntimeCapability.pdfGeneration,
      RuntimeCapability.backupExport,
    ]) {
      expect(RuntimeCapabilityPolicy.worksOffline(capability), isTrue,
          reason: capability.name);
    }
  });

  test('remote concerns remain separate explicit services', () {
    expect(
      RuntimeCapabilityPolicy.worksOffline(RuntimeCapability.premiumVerification),
      isFalse,
    );
    expect(RuntimeCapabilityPolicy.worksOffline(RuntimeCapability.cloudSync), isFalse);
  });

  test('premium assertion requires verifier provenance and UTC validity window', () {
    final verified = VerifiedPremiumEntitlement(
      subjectId: 'user-1',
      verifiedAtUtc: DateTime.utc(2026, 9, 7, 12),
      expiresAtUtc: DateTime.utc(2026, 9, 8, 12),
      verifierId: 'store-verifier-v1',
      signedAssertionId: 'assertion-123',
    );
    expect(verified.isValidAt(DateTime.utc(2026, 9, 7, 15)), isTrue);
    expect(verified.isValidAt(DateTime.utc(2026, 9, 8, 12)), isFalse);
    expect(
      () => VerifiedPremiumEntitlement(
        subjectId: 'user-1',
        verifiedAtUtc: DateTime(2026, 9, 7),
        expiresAtUtc: DateTime.utc(2026, 9, 8),
        verifierId: 'v',
        signedAssertionId: 'a',
      ),
      throwsArgumentError,
    );
  });
}
