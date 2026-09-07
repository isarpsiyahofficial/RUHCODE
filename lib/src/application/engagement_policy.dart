enum MonetizationSurface {
  calculationInput,
  calculationResult,
  dailyMessageCard,
  discoveryCard,
  profile,
}

enum AdPresentation { prohibited, userInitiatedRewarded, passiveEligible }

abstract final class MonetizationPlacementPolicy {
  static AdPresentation presentationFor(MonetizationSurface surface) {
    return switch (surface) {
      MonetizationSurface.calculationInput => AdPresentation.prohibited,
      MonetizationSurface.calculationResult => AdPresentation.prohibited,
      MonetizationSurface.dailyMessageCard => AdPresentation.userInitiatedRewarded,
      MonetizationSurface.discoveryCard => AdPresentation.passiveEligible,
      MonetizationSurface.profile => AdPresentation.prohibited,
    };
  }
}

enum NotificationCategory {
  dailyMessage,
  planetaryHour,
  importantTransit,
  retrogradeBoundary,
  moonPhase,
}

final class NotificationPreferences {
  NotificationPreferences({
    required this.permissionGranted,
    Map<NotificationCategory, bool> categoryEnabled = const {},
  }) : categoryEnabled = Map.unmodifiable({
          for (final category in NotificationCategory.values)
            category: categoryEnabled[category] ?? false,
        });

  final bool permissionGranted;
  final Map<NotificationCategory, bool> categoryEnabled;

  bool enabled(NotificationCategory category) =>
      permissionGranted && (categoryEnabled[category] ?? false);

  NotificationPreferences withCategory(
    NotificationCategory category,
    bool enabled,
  ) =>
      NotificationPreferences(
        permissionGranted: permissionGranted,
        categoryEnabled: {...categoryEnabled, category: enabled},
      );

  NotificationPreferences withPermission(bool granted) => NotificationPreferences(
        permissionGranted: granted,
        categoryEnabled: categoryEnabled,
      );
}

final class NotificationCandidate {
  NotificationCandidate({
    required this.id,
    required this.category,
    required this.scheduledAtUtc,
    required this.title,
    required this.body,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty || body.trim().isEmpty) {
      throw ArgumentError('notification content/provenance cannot be blank');
    }
    if (!scheduledAtUtc.isUtc) throw ArgumentError('scheduledAtUtc must be UTC');
  }

  final String id;
  final NotificationCategory category;
  final DateTime scheduledAtUtc;
  final String title;
  final String body;
}

final class NotificationPolicy {
  const NotificationPolicy({this.minimumGap = const Duration(minutes: 30)});

  final Duration minimumGap;

  List<NotificationCandidate> eligible(
    NotificationPreferences preferences,
    Iterable<NotificationCandidate> candidates,
  ) {
    if (!preferences.permissionGranted) return const [];
    final sorted = candidates
        .where((candidate) => preferences.enabled(candidate.category))
        .toList()
      ..sort((a, b) => a.scheduledAtUtc.compareTo(b.scheduledAtUtc));
    final accepted = <NotificationCandidate>[];
    for (final candidate in sorted) {
      if (accepted.isEmpty ||
          candidate.scheduledAtUtc.difference(accepted.last.scheduledAtUtc) >=
              minimumGap) {
        accepted.add(candidate);
      }
    }
    return List.unmodifiable(accepted);
  }
}
