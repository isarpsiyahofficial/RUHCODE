enum BaziPresentationLevel { simple, professional }

final class PillarRef {
  PillarRef({required this.name, required this.stem, required this.branch}) {
    if ([name, stem, branch].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('pillar name/stem/branch required');
    }
  }
  final String name;
  final String stem;
  final String branch;
}

final class BaziRelation {
  BaziRelation({
    required this.id,
    required this.leftRef,
    required this.rightRef,
    required this.kind,
    required this.sourceId,
    required this.version,
  }) {
    if ([id, leftRef, rightRef, kind, sourceId, version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('relation provenance required');
    }
  }
  final String id;
  final String leftRef;
  final String rightRef;
  final String kind;
  final String sourceId;
  final String version;
}

final class LuckPillarPeriod {
  LuckPillarPeriod({
    required this.id,
    required this.pillar,
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.sourceId,
    required this.version,
  }) {
    if (!startsAtUtc.isUtc || !endsAtUtc.isUtc || !endsAtUtc.isAfter(startsAtUtc)) {
      throw ArgumentError('valid UTC luck-pillar range required');
    }
    if ([id, sourceId, version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('luck-pillar provenance required');
    }
  }
  final String id;
  final PillarRef pillar;
  final DateTime startsAtUtc;
  final DateTime endsAtUtc;
  final String sourceId;
  final String version;
}

final class AnnualPillarRef {
  AnnualPillarRef({
    required this.year,
    required this.pillar,
    required this.sourceId,
    required this.version,
  }) {
    if (year < 1 || sourceId.trim().isEmpty || version.trim().isEmpty) {
      throw ArgumentError('valid annual pillar provenance required');
    }
  }
  final int year;
  final PillarRef pillar;
  final String sourceId;
  final String version;
}

final class BaziPresentation {
  const BaziPresentation({required this.level, required this.summary, required this.technicalRows});
  final BaziPresentationLevel level;
  final String summary;
  final List<String> technicalRows;
}

final class BaziProfessionalWorkspace {
  BaziProfessionalWorkspace({
    required Iterable<PillarRef> natalPillars,
    required Iterable<LuckPillarPeriod> luckPillars,
    required Iterable<AnnualPillarRef> annualPillars,
    required Iterable<BaziRelation> relations,
    required this.simpleSummary,
  })  : natalPillars = List.unmodifiable(natalPillars),
        luckPillars = List.unmodifiable(luckPillars),
        annualPillars = List.unmodifiable(annualPillars),
        relations = List.unmodifiable(relations) {
    if (this.natalPillars.length != 4) throw ArgumentError('Four Pillars requires exactly four natal pillars');
    if (simpleSummary.trim().isEmpty) throw ArgumentError('simple summary required');
  }

  final List<PillarRef> natalPillars;
  final List<LuckPillarPeriod> luckPillars;
  final List<AnnualPillarRef> annualPillars;
  final List<BaziRelation> relations;
  final String simpleSummary;

  List<LuckPillarPeriod> luckTimeline() {
    final items = [...luckPillars]..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));
    return List.unmodifiable(items);
  }

  List<BaziRelation> relationsForAnnualYear(int year) {
    final annual = annualPillars.where((p) => p.year == year).toList();
    if (annual.length != 1) throw StateError('exact annual pillar required for requested year');
    final annualName = annual.single.pillar.name;
    return List.unmodifiable(relations.where((r) => r.leftRef == annualName || r.rightRef == annualName));
  }

  BaziPresentation present(BaziPresentationLevel level) {
    if (level == BaziPresentationLevel.simple) {
      return BaziPresentation(level: level, summary: simpleSummary, technicalRows: const []);
    }
    final rows = <String>[
      ...natalPillars.map((p) => '${p.name}: ${p.stem}/${p.branch}'),
      ...relations.map((r) => '${r.leftRef} ↔ ${r.rightRef}: ${r.kind}'),
    ];
    return BaziPresentation(level: level, summary: simpleSummary, technicalRows: List.unmodifiable(rows));
  }
}

final class WesternDualPresentation {
  const WesternDualPresentation({
    required this.simpleMeaning,
    required this.degree,
    required this.aspects,
    required this.orbs,
    required this.dispositor,
  });
  final String simpleMeaning;
  final double degree;
  final List<String> aspects;
  final List<double> orbs;
  final String dispositor;
}
