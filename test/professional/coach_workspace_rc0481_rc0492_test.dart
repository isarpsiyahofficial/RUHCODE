import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/coach_workspace.dart';

void main() {
  test('coach workspace keeps goals notes actions weekly reviews without mandatory astrology', () {
    final workspace = CoachClientWorkspace(
      clientId: 'client-1',
      goals: [CoachGoal(id: 'g1', title: 'Routine', progressPercent: 40)],
      meetingNotes: const ['First meeting'],
      actions: [BetweenSessionAction(id: 'a1', description: 'Daily journal', dueLocalDate: '2026-09-15')],
      weeklyReviews: [WeeklyGrowthReview(weekId: '2026-W37', summary: 'Steady progress', createdAtUtc: DateTime.utc(2026, 9, 8))],
    );
    expect(workspace.reference, isNull);
    expect(workspace.goals.single.progressPercent, 40);
    expect(workspace.meetingNotes, ['First meeting']);
    expect(workspace.actions, hasLength(1));
    expect(workspace.weeklyReviews, hasLength(1));
  });

  test('growth reference is optional but requires provenance when supplied', () {
    final workspace = CoachClientWorkspace(
      clientId: 'client-1',
      goals: const [], meetingNotes: const [], actions: const [], weeklyReviews: const [],
      reference: const OptionalGrowthReference(
        system: GrowthReferenceSystem.numerology, resultId: 'result-1', sourceId: 'numerology-core', version: '1',
      ),
    );
    expect(workspace.reference?.system, GrowthReferenceSystem.numerology);
    expect(
      () => CoachClientWorkspace(
        clientId: 'client-1', goals: const [], meetingNotes: const [], actions: const [], weeklyReviews: const [],
        reference: const OptionalGrowthReference(system: GrowthReferenceSystem.westernAstrology, resultId: '', sourceId: 'src', version: '1'),
      ),
      throwsArgumentError,
    );
  });

  test('goal progress is bounded', () {
    expect(() => CoachGoal(id: 'g', title: 'x', progressPercent: 101), throwsArgumentError);
    expect(CoachGoal(id: 'g', title: 'x', progressPercent: 100).progressPercent, 100);
  });

  test('single-screen consultation exposes only required consultation sections', () {
    final model = SingleScreenConsultationModel(
      clientName: 'Client',
      method: ConsultationWorkMethod.coaching,
      primaryDataRef: 'workspace:client-1',
      importantPoints: const ['Goal A'],
      notes: 'Session note',
    );
    expect(model.usesReducedNavigation, isTrue);
    expect(SingleScreenConsultationModel.visibleSections, {
      SingleScreenSection.clientName,
      SingleScreenSection.workMethod,
      SingleScreenSection.primaryData,
      SingleScreenSection.importantPoints,
      SingleScreenSection.notes,
    });
  });
}
