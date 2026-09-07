enum GrowthReferenceSystem { westernAstrology, vedicAstrology, numerology, bazi, chineseAstrology }

final class OptionalGrowthReference {
  const OptionalGrowthReference({required this.system, required this.resultId, required this.sourceId, required this.version});
  final GrowthReferenceSystem system;
  final String resultId;
  final String sourceId;
  final String version;
}

final class CoachGoal {
  CoachGoal({required this.id, required this.title, required this.progressPercent}) {
    if (id.trim().isEmpty || title.trim().isEmpty) throw ArgumentError('goal id/title required');
    if (progressPercent < 0 || progressPercent > 100) throw ArgumentError('progress must be 0..100');
  }
  final String id;
  final String title;
  final int progressPercent;
}

final class BetweenSessionAction {
  BetweenSessionAction({required this.id, required this.description, required this.dueLocalDate}) {
    if (id.trim().isEmpty || description.trim().isEmpty) throw ArgumentError('action id/description required');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dueLocalDate)) throw ArgumentError('dueLocalDate must be YYYY-MM-DD');
  }
  final String id;
  final String description;
  final String dueLocalDate;
}

final class WeeklyGrowthReview {
  WeeklyGrowthReview({required this.weekId, required this.summary, required this.createdAtUtc}) {
    if (weekId.trim().isEmpty || summary.trim().isEmpty) throw ArgumentError('weekly review fields required');
    if (!createdAtUtc.isUtc) throw ArgumentError('createdAtUtc must be UTC');
  }
  final String weekId;
  final String summary;
  final DateTime createdAtUtc;
}

final class CoachClientWorkspace {
  CoachClientWorkspace({
    required this.clientId,
    required Iterable<CoachGoal> goals,
    required Iterable<String> meetingNotes,
    required Iterable<BetweenSessionAction> actions,
    required Iterable<WeeklyGrowthReview> weeklyReviews,
    this.reference,
  })  : goals = List.unmodifiable(goals),
        meetingNotes = List.unmodifiable(meetingNotes.map((e) => e.trim()).where((e) => e.isNotEmpty)),
        actions = List.unmodifiable(actions),
        weeklyReviews = List.unmodifiable(weeklyReviews) {
    if (clientId.trim().isEmpty) throw ArgumentError('clientId required');
    if (reference != null && [reference!.resultId, reference!.sourceId, reference!.version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('optional reference requires result/source/version provenance');
    }
  }
  final String clientId;
  final List<CoachGoal> goals;
  final List<String> meetingNotes;
  final List<BetweenSessionAction> actions;
  final List<WeeklyGrowthReview> weeklyReviews;
  final OptionalGrowthReference? reference;
}

enum ConsultationWorkMethod { astrology, numerology, bazi, chineseAstrology, spiritual, coaching }

enum SingleScreenSection { clientName, workMethod, primaryData, importantPoints, notes }

final class SingleScreenConsultationModel {
  SingleScreenConsultationModel({
    required this.clientName,
    required this.method,
    required this.primaryDataRef,
    required Iterable<String> importantPoints,
    required this.notes,
  }) : importantPoints = List.unmodifiable(importantPoints.map((e) => e.trim()).where((e) => e.isNotEmpty)) {
    if (clientName.trim().isEmpty || primaryDataRef.trim().isEmpty) throw ArgumentError('client/data required');
  }
  final String clientName;
  final ConsultationWorkMethod method;
  final String primaryDataRef;
  final List<String> importantPoints;
  final String notes;

  static const visibleSections = <SingleScreenSection>{
    SingleScreenSection.clientName,
    SingleScreenSection.workMethod,
    SingleScreenSection.primaryData,
    SingleScreenSection.importantPoints,
    SingleScreenSection.notes,
  };

  bool get usesReducedNavigation => true;
}
