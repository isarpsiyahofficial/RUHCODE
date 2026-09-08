import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/entitlements/monetization_resilience.dart';

void main() {
  test('failed purchase cannot mutate entitlement state or user data', () {
    const policy = MonetizationResiliencePolicy();
    const attempt = MonetizationAttempt(
      operation: MonetizationOperation.purchase,
      outcome: MonetizationOutcome.failed,
      entitlementStateChanged: false,
    );
    final before = <String, Object?>{
      'clientName': 'Ada',
      'note': 'private note',
      'recordCount': 7,
    };
    final after = policy.preserveUserData(before: before, attempt: attempt);
    expect(after, before);
    expect(after, isNot(same(before)));
  });

  test('ad unavailable cannot change an otherwise valid free calculation', () {
    const policy = MonetizationResiliencePolicy();
    const attempt = MonetizationAttempt(
      operation: MonetizationOperation.rewardedAd,
      outcome: MonetizationOutcome.unavailable,
      entitlementStateChanged: false,
    );
    const calculated = 23.75;
    expect(
      policy.preserveCalculation(calculatedValue: calculated, attempt: attempt),
      calculated,
    );
  });

  test('cancelled or failed monetization that claims state mutation fails closed', () {
    const policy = MonetizationResiliencePolicy();
    for (final outcome in <MonetizationOutcome>[
      MonetizationOutcome.cancelled,
      MonetizationOutcome.unavailable,
      MonetizationOutcome.failed,
    ]) {
      expect(
        () => policy.validateAttempt(
          MonetizationAttempt(
            operation: MonetizationOperation.rewardedAd,
            outcome: outcome,
            entitlementStateChanged: true,
          ),
        ),
        throwsStateError,
      );
    }
  });

  test('already-entitled local PRO capability remains usable offline', () {
    const decision = OfflineCapabilityDecision(
      featureId: 'pdf.professional_export',
      isLocalFeature: true,
      isEntitled: true,
    );
    expect(decision.usableOffline, isTrue);
  });

  test('network-only or non-entitled feature is not invented as offline access', () {
    const remote = OfflineCapabilityDecision(
      featureId: 'external.network.operation',
      isLocalFeature: false,
      isEntitled: true,
    );
    const locked = OfflineCapabilityDecision(
      featureId: 'pro.local.feature',
      isLocalFeature: true,
      isEntitled: false,
    );
    expect(remote.usableOffline, isFalse);
    expect(locked.usableOffline, isFalse);
  });
}
