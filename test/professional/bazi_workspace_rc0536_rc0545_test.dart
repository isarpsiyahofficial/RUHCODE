import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/bazi_workspace.dart';

void main() {
  final natal = [
    PillarRef(name: 'Year', stem: 'Jia', branch: 'Zi'),
    PillarRef(name: 'Month', stem: 'Yi', branch: 'Chou'),
    PillarRef(name: 'Day', stem: 'Bing', branch: 'Yin'),
    PillarRef(name: 'Hour', stem: 'Ding', branch: 'Mao'),
  ];
  final luck = LuckPillarPeriod(
    id: 'lp1', pillar: PillarRef(name: 'Luck-1', stem: 'Wu', branch: 'Chen'),
    startsAtUtc: DateTime.utc(2025), endsAtUtc: DateTime.utc(2035),
    sourceId: 'bazi-ref', version: '1',
  );
  final annual = AnnualPillarRef(
    year: 2026, pillar: PillarRef(name: 'Annual-2026', stem: 'Bing', branch: 'Wu'),
    sourceId: 'bazi-ref', version: '1',
  );
  final relation = BaziRelation(
    id: 'r1', leftRef: 'Annual-2026', rightRef: 'Day', kind: 'interaction',
    sourceId: 'bazi-ref', version: '1',
  );

  test('RC-0536→0540 keeps Four Pillars, Luck timeline, annual relations and raw Stem/Branch data', () {
    final workspace = BaziProfessionalWorkspace(
      natalPillars: natal, luckPillars: [luck], annualPillars: [annual],
      relations: [relation], simpleSummary: 'Sade açıklama',
    );
    expect(workspace.natalPillars.length, 4);
    expect(workspace.luckTimeline().single.id, 'lp1');
    expect(workspace.relationsForAnnualYear(2026).single.id, 'r1');
    expect(workspace.present(BaziPresentationLevel.professional).technicalRows, isNotEmpty);
  });

  test('RC-0541→0545 uses the same result with simple and professional presentation levels', () {
    final workspace = BaziProfessionalWorkspace(
      natalPillars: natal, luckPillars: [luck], annualPillars: [annual],
      relations: [relation], simpleSummary: 'Sade açıklama',
    );
    final simple = workspace.present(BaziPresentationLevel.simple);
    final professional = workspace.present(BaziPresentationLevel.professional);
    expect(simple.summary, professional.summary);
    expect(simple.technicalRows, isEmpty);
    expect(professional.technicalRows, isNotEmpty);

    const western = WesternDualPresentation(
      simpleMeaning: 'Venüs 7. evde ilişki temalarını vurgular.', degree: 12.5,
      aspects: ['trine Mars'], orbs: [1.2], dispositor: 'Mercury',
    );
    expect(western.simpleMeaning, isNotEmpty);
    expect(western.degree, 12.5);
    expect(western.aspects.single, 'trine Mars');
    expect(western.dispositor, 'Mercury');
  });

  test('Four Pillars fails closed when natal pillar count is not four', () {
    expect(
      () => BaziProfessionalWorkspace(
        natalPillars: natal.take(3), luckPillars: [luck], annualPillars: [annual],
        relations: [relation], simpleSummary: 'Sade açıklama',
      ),
      throwsArgumentError,
    );
  });
}
