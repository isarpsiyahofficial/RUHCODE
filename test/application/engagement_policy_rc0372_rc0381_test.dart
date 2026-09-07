import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/engagement_policy.dart';

void main() {
  test('ads cannot interrupt calculation input or result surfaces', () {
    expect(
      MonetizationPlacementPolicy.presentationFor(MonetizationSurface.calculationInput),
      AdPresentation.prohibited,
    );
    expect(
      MonetizationPlacementPolicy.presentationFor(MonetizationSurface.calculationResult),
      AdPresentation.prohibited,
    );
    expect(
      MonetizationPlacementPolicy.presentationFor(MonetizationSurface.dailyMessageCard),
      AdPresentation.userInitiatedRewarded,
    );
  });

  test('all notification categories default off and require platform permission', () {
    final prefs = NotificationPreferences(permissionGranted: false);
    for (final category in NotificationCategory.values) {
      expect(prefs.enabled(category), isFalse);
    }
    final opted = prefs.withCategory(NotificationCategory.dailyMessage, true);
    expect(opted.enabled(NotificationCategory.dailyMessage), isFalse);
    expect(opted.withPermission(true).enabled(NotificationCategory.dailyMessage), isTrue);
  });

  test('daily message planetary hour transit retrograde and moon phase are independent toggles', () {
    expect(NotificationCategory.values.toSet(), {
      NotificationCategory.dailyMessage,
      NotificationCategory.planetaryHour,
      NotificationCategory.importantTransit,
      NotificationCategory.retrogradeBoundary,
      NotificationCategory.moonPhase,
    });
    final prefs = NotificationPreferences(
      permissionGranted: true,
      categoryEnabled: const {NotificationCategory.planetaryHour: true},
    );
    expect(prefs.enabled(NotificationCategory.planetaryHour), isTrue);
    expect(prefs.enabled(NotificationCategory.dailyMessage), isFalse);
  });

  test('spam guard suppresses opted-in notifications that are too close together', () {
    final prefs = NotificationPreferences(
      permissionGranted: true,
      categoryEnabled: const {
        NotificationCategory.dailyMessage: true,
        NotificationCategory.planetaryHour: true,
      },
    );
    NotificationCandidate c(String id, int minute, NotificationCategory category) =>
        NotificationCandidate(
          id: id,
          category: category,
          scheduledAtUtc: DateTime.utc(2026, 9, 7, 12, minute),
          title: id,
          body: 'body',
        );
    final result = const NotificationPolicy(minimumGap: Duration(minutes: 30)).eligible(
      prefs,
      [
        c('a', 0, NotificationCategory.dailyMessage),
        c('b', 10, NotificationCategory.planetaryHour),
        c('c', 40, NotificationCategory.planetaryHour),
      ],
    );
    expect(result.map((item) => item.id).toList(), ['a', 'c']);
  });
}
