enum ProfessionalMethod { western, vedic, numerology, chinese, bazi }

final class SharedClientProfile {
  SharedClientProfile({
    required this.clientId,
    required this.displayName,
    required this.birthProfileId,
  }) {
    if (clientId.trim().isEmpty || displayName.trim().isEmpty || birthProfileId.trim().isEmpty) {
      throw ArgumentError('client identity and shared birth profile are required');
    }
  }
  final String clientId;
  final String displayName;
  final String birthProfileId;
}

final class TechnicalTransit {
  TechnicalTransit({
    required this.id,
    required this.label,
    required this.orbArcMinutes,
    required this.applying,
    required this.importanceReason,
    required this.calculationResultId,
  }) {
    if (id.trim().isEmpty || label.trim().isEmpty || calculationResultId.trim().isEmpty) {
      throw ArgumentError('technical transit identity is required');
    }
    if (orbArcMinutes < 0 || orbArcMinutes > 3600) {
      throw ArgumentError('orbArcMinutes outside supported range');
    }
    if (importanceReason.trim().isEmpty) {
      throw ArgumentError('important transit requires technical reason');
    }
  }
  final String id;
  final String label;
  final int orbArcMinutes;
  final bool applying;
  final String importanceReason;
  final String calculationResultId;
}

final class ConsultationPreparation {
  const ConsultationPreparation({
    required this.client,
    required this.natalResultId,
    required this.importantTransits,
    required this.previousSessionNotes,
    required this.upcomingImportantDates,
  });
  final SharedClientProfile client;
  final String natalResultId;
  final List<TechnicalTransit> importantTransits;
  final List<String> previousSessionNotes;
  final List<DateTime> upcomingImportantDates;
}

abstract final class ConsultationPreparationAssembler {
  static ConsultationPreparation build({
    required SharedClientProfile client,
    required String natalResultId,
    required Iterable<TechnicalTransit> importantTransits,
    required Iterable<String> previousSessionNotes,
    required Iterable<DateTime> upcomingImportantDates,
  }) {
    if (natalResultId.trim().isEmpty) throw ArgumentError('natal result reference required');
    return ConsultationPreparation(
      client: client,
      natalResultId: natalResultId,
      importantTransits: List.unmodifiable(importantTransits),
      previousSessionNotes: List.unmodifiable(previousSessionNotes),
      upcomingImportantDates: List.unmodifiable(upcomingImportantDates),
    );
  }
}

final class ProfessionalInterpretationRecord {
  const ProfessionalInterpretationRecord({
    required this.conditionId,
    required this.systemText,
    required this.personalNote,
  });
  final String conditionId;
  final String? systemText;
  final String? personalNote;
}

final class InterpretationTemplate {
  InterpretationTemplate({required this.id, required this.conditionId, required this.text}) {
    if (id.trim().isEmpty || conditionId.trim().isEmpty || text.trim().isEmpty) {
      throw ArgumentError('template fields are required');
    }
  }
  final String id;
  final String conditionId;
  final String text;
}

final class KnowledgeLibrary {
  KnowledgeLibrary({required Iterable<InterpretationTemplate> templates})
      : templates = List.unmodifiable(templates);
  final List<InterpretationTemplate> templates;

  List<InterpretationTemplate> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return List.unmodifiable(templates.where((t) =>
        t.conditionId.toLowerCase().contains(q) || t.text.toLowerCase().contains(q)));
  }
}

final class ConsultationSession {
  ConsultationSession({
    required this.id,
    required this.clientId,
    required this.occurredAtUtc,
    required this.topics,
    required this.followUps,
    this.remindAtUtc,
  }) {
    if (!occurredAtUtc.isUtc || (remindAtUtc != null && !remindAtUtc!.isUtc)) {
      throw ArgumentError('session timestamps must be UTC');
    }
  }
  final String id;
  final String clientId;
  final DateTime occurredAtUtc;
  final List<String> topics;
  final List<String> followUps;
  final DateTime? remindAtUtc;
}

final class ClientWorkspace {
  ClientWorkspace({required this.client, required Set<ProfessionalMethod> enabledMethods})
      : enabledMethods = Set.unmodifiable(enabledMethods);
  final SharedClientProfile client;
  final Set<ProfessionalMethod> enabledMethods;

  bool shows(ProfessionalMethod method) => enabledMethods.contains(method);
}

final class NumerologyPreparation {
  const NumerologyPreparation({
    required this.lifePath,
    required this.personalYear,
    required this.personalMonth,
    required this.personalDay,
    required this.pinnacleLabels,
    required this.activePeriods,
  });
  final int lifePath;
  final int personalYear;
  final int personalMonth;
  final int personalDay;
  final List<String> pinnacleLabels;
  final List<String> activePeriods;
}
