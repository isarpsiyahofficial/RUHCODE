import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/consultation_workspace.dart';

void main() {
  final client = SharedClientProfile(
    clientId: 'client-1',
    displayName: 'Example Client',
    birthProfileId: 'birth-1',
  );

  test('consultation preparation keeps technical transit evidence', () {
    final prep = ConsultationPreparationAssembler.build(
      client: client,
      natalResultId: 'natal-result-1',
      importantTransits: [
        TechnicalTransit(
          id: 't1',
          label: 'Transit Saturn square Natal Sun',
          orbArcMinutes: 42,
          applying: true,
          importanceReason: 'Tight applying major aspect',
          calculationResultId: 'transit-result-1',
        ),
      ],
      previousSessionNotes: const ['career timing'],
      upcomingImportantDates: [DateTime.utc(2026, 10, 1)],
    );
    expect(prep.importantTransits.single.orbArcMinutes, 42);
    expect(prep.importantTransits.single.applying, isTrue);
    expect(prep.previousSessionNotes, contains('career timing'));
  });

  test('system interpretation and professional personal note remain separate', () {
    const record = ProfessionalInterpretationRecord(
      conditionId: 'saturn.house7',
      systemText: 'Prepared system text',
      personalNote: 'My own client-specific note',
    );
    expect(record.systemText, isNot(record.personalNote));
  });

  test('knowledge library can retrieve reusable professional templates', () {
    final library = KnowledgeLibrary(templates: [
      InterpretationTemplate(
        id: 'tpl-1',
        conditionId: 'saturn square venus',
        text: 'Relationship responsibility pattern',
      ),
    ]);
    expect(library.search('saturn square venus'), hasLength(1));
  });

  test('client workspace only shows explicitly enabled methods', () {
    final workspace = ClientWorkspace(
      client: client,
      enabledMethods: {ProfessionalMethod.western, ProfessionalMethod.numerology},
    );
    expect(workspace.shows(ProfessionalMethod.western), isTrue);
    expect(workspace.shows(ProfessionalMethod.vedic), isFalse);
  });

  test('consultation history supports UTC follow-up reminders', () {
    final session = ConsultationSession(
      id: 'session-1',
      clientId: client.clientId,
      occurredAtUtc: DateTime.utc(2026, 9, 7, 12),
      topics: const ['transits'],
      followUps: const ['review again in three months'],
      remindAtUtc: DateTime.utc(2026, 12, 7, 12),
    );
    expect(session.followUps, isNotEmpty);
    expect(session.remindAtUtc?.isUtc, isTrue);
  });

  test('numerology preparation exposes consultation metrics together', () {
    const prep = NumerologyPreparation(
      lifePath: 7,
      personalYear: 5,
      personalMonth: 3,
      personalDay: 9,
      pinnacleLabels: ['P1', 'P2'],
      activePeriods: ['2026 personal year 5'],
    );
    expect(prep.lifePath, 7);
    expect(prep.activePeriods, isNotEmpty);
  });
}
