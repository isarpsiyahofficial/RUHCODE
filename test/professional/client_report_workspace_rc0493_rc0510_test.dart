import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/client_report_workspace.dart';

void main() {
  test('tablet landscape exposes chart technical details and notes together', () {
    const policy = ConsultationLayoutPolicy();
    expect(
      policy.usesHorizontalChartTechnicalSplit(
        deviceClass: ConsultationDeviceClass.tablet,
        orientation: ConsultationOrientation.landscape,
      ),
      isTrue,
    );
    expect(
      policy.visiblePanes(
        deviceClass: ConsultationDeviceClass.tablet,
        orientation: ConsultationOrientation.landscape,
      ),
      {ConsultationPane.chart, ConsultationPane.technicalDetails, ConsultationPane.notes},
    );
  });

  test('client report is composed from professional-selected sections', () {
    final draft = ClientReportDraft(
      reportId: 'report-1',
      clientId: 'client-1',
      professional: ProfessionalIdentity(displayName: 'Astrolog A'),
      sections: [
        ClientReportSection(id: 'chart', type: ClientReportSectionType.chart, title: 'Chart', contentRef: 'result:chart'),
        ClientReportSection(
          id: 'technical',
          type: ClientReportSectionType.technicalDegreeTables,
          title: 'Technical',
          contentRef: 'result:degrees',
          enabled: false,
        ),
        ClientReportSection(
          id: 'notes',
          type: ClientReportSectionType.professionalNotes,
          title: 'Notes',
          contentRef: 'notes:session-1',
        ),
      ],
      createdAtUtc: DateTime.utc(2026, 9, 8),
    );
    expect(draft.enabledSections.map((e) => e.id), ['chart', 'notes']);
    expect(draft.canRenderChartAndNotesOnly, isTrue);
  });

  test('preview requires each selected section exactly once and allows reordering', () {
    final draft = ClientReportDraft(
      reportId: 'report-1',
      clientId: 'client-1',
      professional: ProfessionalIdentity(displayName: 'Numerolog N'),
      sections: [
        ClientReportSection(id: 'a', type: ClientReportSectionType.chart, title: 'A', contentRef: 'a'),
        ClientReportSection(id: 'b', type: ClientReportSectionType.clientFriendlyInterpretation, title: 'B', contentRef: 'b'),
      ],
      createdAtUtc: DateTime.utc(2026, 9, 8),
    );
    final preview = ClientReportPreview(draft: draft, orderedSectionIds: const ['b', 'a']);
    expect(preview.orderedSections.map((e) => e.id), ['b', 'a']);
    expect(() => ClientReportPreview(draft: draft, orderedSectionIds: const ['a']), throwsArgumentError);
  });

  test('PRO logo is optional while professional name is always explicit', () {
    const policy = ProfessionalReportBrandingPolicy();
    final identity = ProfessionalIdentity(displayName: 'Professional', logoAssetRef: 'asset:logo');
    expect(policy.acceptsLogoForPro(isPro: true, professional: identity), isTrue);
    expect(policy.acceptsLogoForPro(isPro: false, professional: identity), isFalse);
    expect(policy.requiresRuhCodeAdvertising, isFalse);
  });

  test('detailed report target remains within twenty to thirty pages', () {
    expect(
      () => ClientReportDraft(
        reportId: 'r',
        clientId: 'c',
        professional: ProfessionalIdentity(displayName: 'P'),
        sections: [ClientReportSection(id: 'a', type: ClientReportSectionType.chart, title: 'A', contentRef: 'a')],
        createdAtUtc: DateTime.utc(2026, 9, 8),
        maxDetailedPageTarget: 31,
      ),
      throwsArgumentError,
    );
  });
}
