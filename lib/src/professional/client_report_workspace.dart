enum ConsultationPane { chart, technicalDetails, notes }

enum ConsultationDeviceClass { phone, tablet }

enum ConsultationOrientation { portrait, landscape }

final class ConsultationLayoutPolicy {
  const ConsultationLayoutPolicy();

  Set<ConsultationPane> visiblePanes({
    required ConsultationDeviceClass deviceClass,
    required ConsultationOrientation orientation,
  }) {
    if (deviceClass == ConsultationDeviceClass.tablet && orientation == ConsultationOrientation.landscape) {
      return const {ConsultationPane.chart, ConsultationPane.technicalDetails, ConsultationPane.notes};
    }
    return const {ConsultationPane.chart, ConsultationPane.notes};
  }

  bool usesHorizontalChartTechnicalSplit({
    required ConsultationDeviceClass deviceClass,
    required ConsultationOrientation orientation,
  }) =>
      deviceClass == ConsultationDeviceClass.tablet && orientation == ConsultationOrientation.landscape;
}

enum ClientReportSectionType {
  chart,
  technicalDegreeTables,
  clientFriendlyInterpretation,
  professionalNotes,
  transitTimeline,
  numerologySummary,
  spiritualSessionSummary,
}

final class ClientReportSection {
  ClientReportSection({
    required this.id,
    required this.type,
    required this.title,
    required this.contentRef,
    this.enabled = true,
  }) {
    if ([id, title, contentRef].any((value) => value.trim().isEmpty)) {
      throw ArgumentError('report section id/title/contentRef required');
    }
  }

  final String id;
  final ClientReportSectionType type;
  final String title;
  final String contentRef;
  final bool enabled;
}

final class ProfessionalIdentity {
  ProfessionalIdentity({required this.displayName, this.logoAssetRef}) {
    if (displayName.trim().isEmpty) throw ArgumentError('professional displayName required');
    if (logoAssetRef != null && logoAssetRef!.trim().isEmpty) throw ArgumentError('logoAssetRef cannot be blank');
  }

  final String displayName;
  final String? logoAssetRef;
}

final class ClientReportDraft {
  ClientReportDraft({
    required this.reportId,
    required this.clientId,
    required this.professional,
    required Iterable<ClientReportSection> sections,
    required this.createdAtUtc,
    this.maxDetailedPageTarget = 30,
  }) : sections = List.unmodifiable(sections) {
    if (reportId.trim().isEmpty || clientId.trim().isEmpty) throw ArgumentError('report/client id required');
    if (!createdAtUtc.isUtc) throw ArgumentError('createdAtUtc must be UTC');
    if (maxDetailedPageTarget < 20 || maxDetailedPageTarget > 30) {
      throw ArgumentError('detailed report target must remain within 20..30 pages');
    }
    final ids = this.sections.map((section) => section.id).toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('duplicate report section id');
    if (this.sections.where((section) => section.enabled).isEmpty) throw ArgumentError('at least one enabled report section required');
  }

  final String reportId;
  final String clientId;
  final ProfessionalIdentity professional;
  final List<ClientReportSection> sections;
  final DateTime createdAtUtc;
  final int maxDetailedPageTarget;

  List<ClientReportSection> get enabledSections => List.unmodifiable(sections.where((section) => section.enabled));

  bool get canRenderChartAndNotesOnly {
    final enabledTypes = enabledSections.map((section) => section.type).toSet();
    return enabledTypes.difference(const {ClientReportSectionType.chart, ClientReportSectionType.professionalNotes}).isEmpty &&
        enabledTypes.contains(ClientReportSectionType.chart);
  }
}

final class ClientReportPreview {
  ClientReportPreview({required this.draft, required Iterable<String> orderedSectionIds})
      : orderedSectionIds = List.unmodifiable(orderedSectionIds) {
    final enabledIds = draft.enabledSections.map((section) => section.id).toSet();
    if (this.orderedSectionIds.toSet().length != this.orderedSectionIds.length) {
      throw ArgumentError('preview section order contains duplicates');
    }
    if (this.orderedSectionIds.toSet().difference(enabledIds).isNotEmpty ||
        enabledIds.difference(this.orderedSectionIds.toSet()).isNotEmpty) {
      throw ArgumentError('preview must contain each enabled report section exactly once');
    }
  }

  final ClientReportDraft draft;
  final List<String> orderedSectionIds;

  List<ClientReportSection> get orderedSections {
    final byId = {for (final section in draft.enabledSections) section.id: section};
    return List.unmodifiable(orderedSectionIds.map((id) => byId[id]!));
  }
}

final class ProfessionalReportBrandingPolicy {
  const ProfessionalReportBrandingPolicy();

  bool get requiresRuhCodeAdvertising => false;

  bool acceptsLogoForPro({required bool isPro, required ProfessionalIdentity professional}) {
    if (professional.logoAssetRef == null) return true;
    return isPro;
  }
}
