enum NumerologySystemId { pythagorean, chaldean, loShu, kabbalistic }

final class NumerologyYearPeriod {
  NumerologyYearPeriod({
    required this.year,
    required this.personalYear,
    required this.months,
    required this.sourceId,
    required this.version,
  }) {
    if (year < 1 || year > 9999) throw ArgumentError('year outside supported range');
    if (personalYear < 1 || personalYear > 33) throw ArgumentError('personalYear outside supported range');
    if (months.length != 12) throw ArgumentError('exactly 12 monthly periods are required');
    if (sourceId.trim().isEmpty || version.trim().isEmpty) throw ArgumentError('period provenance required');
  }
  final int year;
  final int personalYear;
  final List<int> months;
  final String sourceId;
  final String version;
}

abstract interface class NumerologyPeriodProvider {
  NumerologyYearPeriod buildYear({required int year, required NumerologySystemId system});
}

final class FiveYearNumerologyTimeline {
  FiveYearNumerologyTimeline({required Iterable<NumerologyYearPeriod> years})
      : years = List.unmodifiable(years) {
    if (this.years.length != 5) throw ArgumentError('timeline must contain exactly five years');
    for (var i = 1; i < this.years.length; i++) {
      if (this.years[i].year != this.years[i - 1].year + 1) {
        throw ArgumentError('five-year timeline must be contiguous');
      }
    }
  }
  final List<NumerologyYearPeriod> years;
}

abstract final class NumerologyTimelineAssembler {
  static FiveYearNumerologyTimeline buildFiveYears({
    required int startYear,
    required NumerologySystemId system,
    required NumerologyPeriodProvider provider,
  }) => FiveYearNumerologyTimeline(
        years: List.generate(5, (index) => provider.buildYear(year: startYear + index, system: system)),
      );
}

enum NumerologyAnalysisKind { personName, businessName, brandName }

final class SavedNumerologyAnalysis {
  SavedNumerologyAnalysis({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.inputName,
    required this.system,
    required this.resultId,
    required this.createdAtUtc,
  }) {
    if ([id, subjectId, inputName, resultId].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('analysis identity fields are required');
    }
    if (!createdAtUtc.isUtc) throw ArgumentError('createdAtUtc must be UTC');
  }
  final String id;
  final String subjectId;
  final NumerologyAnalysisKind kind;
  final String inputName;
  final NumerologySystemId system;
  final String resultId;
  final DateTime createdAtUtc;
}

final class NameAnalysisComparison {
  NameAnalysisComparison({required this.previous, required this.current}) {
    if (previous.subjectId != current.subjectId || previous.kind != current.kind) {
      throw ArgumentError('only analyses of the same subject and kind can be compared');
    }
    if (previous.inputName == current.inputName) throw ArgumentError('name comparison requires a changed name');
  }
  final SavedNumerologyAnalysis previous;
  final SavedNumerologyAnalysis current;
}

final class NumerologyWorkspacePreferences {
  const NumerologyWorkspacePreferences({required this.defaultSystem});
  final NumerologySystemId defaultSystem;
}

final class NumerologyPairComparison {
  NumerologyPairComparison({required this.leftAnalysisId, required this.rightAnalysisId, required this.system}) {
    if (leftAnalysisId.trim().isEmpty || rightAnalysisId.trim().isEmpty) throw ArgumentError('comparison ids required');
    if (leftAnalysisId == rightAnalysisId) throw ArgumentError('two distinct analyses are required');
  }
  final String leftAnalysisId;
  final String rightAnalysisId;
  final NumerologySystemId system;
}

enum SpiritualSessionMethod { tarot, oracle, otherSymbolic }

final class SpiritualCardRecord {
  SpiritualCardRecord({required this.cardId, required this.positionId, required this.order}) {
    if (cardId.trim().isEmpty || positionId.trim().isEmpty) throw ArgumentError('card and position are required');
    if (order < 0) throw ArgumentError('card order cannot be negative');
  }
  final String cardId;
  final String positionId;
  final int order;
}

final class SpiritualConsultationSession {
  SpiritualConsultationSession({
    required this.id,
    required this.clientId,
    required this.method,
    required this.spreadId,
    required Iterable<SpiritualCardRecord> cards,
    required this.professionalInterpretation,
    required this.occurredAtUtc,
    required this.disclosurePolicyId,
  }) : cards = List.unmodifiable(cards) {
    if ([id, clientId, spreadId, disclosurePolicyId].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('session identity and disclosure are required');
    }
    if (!occurredAtUtc.isUtc) throw ArgumentError('occurredAtUtc must be UTC');
    if (professionalInterpretation.trim().isEmpty) throw ArgumentError('professional interpretation required');
    final orders = this.cards.map((c) => c.order).toSet();
    final cardIds = this.cards.map((c) => c.cardId).toSet();
    if (orders.length != this.cards.length || cardIds.length != this.cards.length) {
      throw ArgumentError('duplicate card or order is not allowed');
    }
  }
  final String id;
  final String clientId;
  final SpiritualSessionMethod method;
  final String spreadId;
  final List<SpiritualCardRecord> cards;
  final String professionalInterpretation;
  final DateTime occurredAtUtc;
  final String disclosurePolicyId;
}

final class SpiritualSessionHistory {
  SpiritualSessionHistory({required Iterable<SpiritualConsultationSession> sessions})
      : sessions = List.unmodifiable(sessions);
  final List<SpiritualConsultationSession> sessions;

  List<SpiritualConsultationSession> forClient(String clientId) {
    final id = clientId.trim();
    if (id.isEmpty) return const [];
    final found = sessions.where((s) => s.clientId == id).toList()
      ..sort((a, b) => a.occurredAtUtc.compareTo(b.occurredAtUtc));
    return List.unmodifiable(found);
  }

  List<SpiritualConsultationSession> comparable({required String clientId, required String spreadId}) =>
      List.unmodifiable(forClient(clientId).where((s) => s.spreadId == spreadId));
}
