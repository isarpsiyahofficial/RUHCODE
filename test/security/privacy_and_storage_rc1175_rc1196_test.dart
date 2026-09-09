import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/security/privacy_and_storage_policy.dart';

void main() {
  test('notification denial is isolated from core application usage', () {
    const policy = PermissionIsolationPolicy();
    expect(
      policy.coreUsageAllowed(
        deniedPermission: PermissionKind.notifications,
        decision: PermissionDecision.denied,
      ),
      isTrue,
    );
    expect(policy.notificationFeaturesAllowed(PermissionDecision.denied), isFalse);
    expect(policy.manualLocationAllowed(PermissionDecision.deniedPermanently), isTrue);
  });

  test('export never requires remote upload or arbitrary root storage', () {
    const policy = ExportPrivacyPolicy();
    expect(policy.requiresRemoteUpload, isFalse);
    expect(policy.writesToArbitraryRootFolder, isFalse);
    expect(
      policy.canSendToThirdParty(userExplicitlyInitiated: false, localArtifactReady: true),
      isFalse,
    );
    expect(
      policy.canSendToThirdParty(userExplicitlyInitiated: true, localArtifactReady: true),
      isTrue,
    );
  });

  test('local encryption policy forbids embedded fixed application keys', () {
    const platform = EncryptionPolicy(
      databaseEncryptionEnabled: true,
      keyOrigin: SecureKeyOrigin.platformKeystore,
    );
    platform.validate();
    expect(platform.fixedApplicationStringKeyAllowed, isFalse);
    expect(platform.serverRoundTripRequired, isFalse);

    const userDerived = EncryptionPolicy(
      databaseEncryptionEnabled: true,
      keyOrigin: SecureKeyOrigin.userDerived,
    );
    userDerived.validate();
    expect(userDerived.fixedApplicationStringKeyAllowed, isFalse);
  });

  test('biometric lock requires secure PIN fallback and unlock gates export', () {
    expect(
      () => const AppLockPolicy(
        method: AppLockMethod.biometric,
        hasPinFallback: false,
      ).validate(),
      throwsStateError,
    );
    const lock = AppLockPolicy(
      method: AppLockMethod.biometric,
      hasPinFallback: true,
    );
    lock.validate();
    expect(lock.exportAllowedAfterSuccessfulUnlock(unlocked: false), isFalse);
    expect(lock.exportAllowedAfterSuccessfulUnlock(unlocked: true), isTrue);
  });

  test('production logging rejects client names, birth dates and consultation notes', () {
    const policy = ProductionLogPolicy();
    for (final key in <String>['customerName', 'fullBirthDate', 'consultationNotes']) {
      expect(
        () => policy.validatePayload(<String, Object?>{key: 'sensitive'}),
        throwsStateError,
      );
    }
    expect(
      () => policy.validatePayload(<String, Object?>{
        'code': TechnicalLogCode.storageOpenFailed.name,
        'component': 'local-db',
      }),
      returnsNormally,
    );
    expect(policy.analyticsRequiredForCoreUsage, isFalse);
    expect(policy.telemetryRequiredForCoreUsage, isFalse);
    expect(policy.debugLogsAllowedInRelease, isFalse);
  });

  test('technical log event contains only anonymous technical fields', () {
    final event = PrivacySafeLogEvent(
      code: TechnicalLogCode.exportFailed,
      timestampUtc: DateTime.utc(2026, 9, 9),
      component: 'pdf-export',
    ).toMap();
    expect(event.keys.toSet(), <String>{'code', 'timestampUtc', 'component'});
    expect(event.values.join(' '), isNot(contains('customer')));
  });
}
