enum DailySystemId { western, vedic, numerology, planetaryHours, astronomy }
enum DailyCardAccess { free, rewarded, pro }

final class DailySourceEvidence {
  const DailySourceEvidence({required this.system, required this.sourceId, required this.version});
  final DailySystemId system;
  final String sourceId;
  final String version;
  void validate() {
    if (sourceId.trim().isEmpty || version.trim().isEmpty) {
      throw ArgumentError('Daily source/version must not be empty.');
    }
  }
}

final class DailySignal<T> {
  DailySignal({required this.value, required this.evidence}) { evidence.validate(); }
  final T value;
  final DailySourceEvidence evidence;
}

final class DailyTodaySnapshot {
  DailyTodaySnapshot({
    required this.localDate,
    required this.moonSign,
    required this.moonPhase,
    required this.currentPlanetaryHour,
    required this.nextPlanetaryHour,
    this.personalDay,
    this.personalTransits = const [],
    this.retrogrades = const [],
    this.astrologicalOutlook,
  }) {
    if (currentPlanetaryHour.value == nextPlanetaryHour.value &&
        currentPlanetaryHour.evidence.sourceId == nextPlanetaryHour.evidence.sourceId) {
      // Equal rulers may legitimately occur only if boundaries differ; callers must
      // encode the slot identity in the value. This catches accidental duplication.
      throw ArgumentError('Current and next planetary-hour slots must be distinct.');
    }
  }

  final DateTime localDate;
  final DailySignal<String> moonSign;
  final DailySignal<String> moonPhase;
  final DailySignal<String> currentPlanetaryHour;
  final DailySignal<String> nextPlanetaryHour;
  final DailySignal<int>? personalDay;
  final List<DailySignal<String>> personalTransits;
  final List<DailySignal<String>> retrogrades;
  final DailySignal<String>? astrologicalOutlook;

  bool get isPersonalized => personalDay != null || personalTransits.isNotEmpty;
  Set<DailySystemId> get systems => {
    moonSign.evidence.system, moonPhase.evidence.system,
    currentPlanetaryHour.evidence.system, nextPlanetaryHour.evidence.system,
    if (personalDay != null) personalDay!.evidence.system,
    ...personalTransits.map((e) => e.evidence.system),
    ...retrogrades.map((e) => e.evidence.system),
    if (astrologicalOutlook != null) astrologicalOutlook!.evidence.system,
  };
}

final class DailyMessageRecipe {
  DailyMessageRecipe({
    required this.id,
    required this.version,
    required this.sourceId,
    required this.systems,
    required this.build,
  }) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty || systems.isEmpty) {
      throw ArgumentError('Daily message recipe provenance/systems are required.');
    }
    if (systems.contains(DailySystemId.western) && systems.contains(DailySystemId.vedic)) {
      throw ArgumentError('Western and Vedic interpretation must not be fused into one truth recipe.');
    }
  }
  final String id;
  final String version;
  final String sourceId;
  final Set<DailySystemId> systems;
  final String Function(DailyTodaySnapshot snapshot) build;
}

final class DailyMessageResult {
  const DailyMessageResult({required this.text, required this.recipeId, required this.systems});
  final String text;
  final String recipeId;
  final Set<DailySystemId> systems;
}

abstract final class DailyMessageEngine {
  static DailyMessageResult generate(DailyTodaySnapshot snapshot, DailyMessageRecipe recipe) {
    if (!snapshot.systems.containsAll(recipe.systems)) {
      throw StateError('Snapshot does not contain all systems required by the message recipe.');
    }
    final text = recipe.build(snapshot).trim();
    if (text.isEmpty) throw StateError('Daily message recipe returned empty content.');
    return DailyMessageResult(text: text, recipeId: recipe.id, systems: Set.unmodifiable(recipe.systems));
  }
}

final class RewardedUnlockGrant {
  const RewardedUnlockGrant({required this.scope, required this.expiresAtUtc});
  final String scope;
  final DateTime expiresAtUtc;
  bool isValid(DateTime nowUtc, String requestedScope) =>
      scope == requestedScope && nowUtc.isBefore(expiresAtUtc);
}

final class DailyAccessPolicy {
  const DailyAccessPolicy({required this.pro, this.rewardedGrant});
  final bool pro;
  final RewardedUnlockGrant? rewardedGrant;

  DailyCardAccess resolve({required bool freeByDefault, required String scope, required DateTime nowUtc}) {
    if (pro) return DailyCardAccess.pro;
    if (freeByDefault) return DailyCardAccess.free;
    if (rewardedGrant?.isValid(nowUtc, scope) ?? false) return DailyCardAccess.rewarded;
    return DailyCardAccess.free;
  }

  bool canReadLocked({required String scope, required DateTime nowUtc}) =>
      pro || (rewardedGrant?.isValid(nowUtc, scope) ?? false);
}

final class DailyAdExperiencePolicy {
  const DailyAdExperiencePolicy({this.maxRewardPromptsPerSession = 1});
  final int maxRewardPromptsPerSession;
  bool mayPrompt({required int promptsAlreadyShown, required bool userInitiated}) =>
      userInitiated && promptsAlreadyShown < maxRewardPromptsPerSession;
}
