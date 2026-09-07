/// BaZi / Four Pillars calculation domain.
///
/// This module intentionally does not import the simple Chinese-zodiac engine.
/// RC-0142 requires BaZi to remain a separate calculation system.
enum BaziHeavenlyStem {
  jia,
  yi,
  bing,
  ding,
  wu,
  ji,
  geng,
  xin,
  ren,
  gui,
}

enum BaziEarthlyBranch {
  zi,
  chou,
  yin,
  mao,
  chen,
  si,
  wu,
  wei,
  shen,
  you,
  xu,
  hai,
}

enum BaziPillarKind { year, month, day, hour }

final class BaziPillar {
  const BaziPillar({
    required this.kind,
    required this.stem,
    required this.branch,
    required this.sexagenaryCycleIndex,
  });

  final BaziPillarKind kind;
  final BaziHeavenlyStem stem;
  final BaziEarthlyBranch branch;
  final int sexagenaryCycleIndex;
}

/// Authoritative calendar resolution consumed by the BaZi domain.
///
/// The provider must resolve the four Gan-Zhi cycle indices using an explicit,
/// versioned BaZi calendar convention. The core refuses to substitute a lunar
/// Chinese-zodiac year or Gregorian-year shortcut for these values.
final class BaziFourPillarsResolution {
  BaziFourPillarsResolution({
    required this.yearCycleIndex,
    required this.monthCycleIndex,
    required this.dayCycleIndex,
    required this.hourCycleIndex,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  }) {
    for (final entry in <String, int>{
      'yearCycleIndex': yearCycleIndex,
      'monthCycleIndex': monthCycleIndex,
      'dayCycleIndex': dayCycleIndex,
      'hourCycleIndex': hourCycleIndex,
    }.entries) {
      if (entry.value < 0 || entry.value >= 60) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'must be in 0..59 where 0 is Jia-Zi',
        );
      }
    }
    for (final entry in <String, String>{
      'sourceId': sourceId,
      'version': version,
      'conventionId': conventionId,
    }.entries) {
      if (entry.value.trim().isEmpty) {
        throw ArgumentError.value(entry.value, entry.key, 'must not be empty');
      }
    }
  }

  final int yearCycleIndex;
  final int monthCycleIndex;
  final int dayCycleIndex;
  final int hourCycleIndex;
  final String sourceId;
  final String version;
  final String conventionId;
}

abstract interface class BaziFourPillarsProvider {
  BaziFourPillarsResolution resolve({required DateTime birthInstantUtc});
}

final class BaziFourPillarsSnapshot {
  const BaziFourPillarsSnapshot({
    required this.birthInstantUtc,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  });

  final DateTime birthInstantUtc;
  final BaziPillar year;
  final BaziPillar month;
  final BaziPillar day;
  final BaziPillar hour;
  final String sourceId;
  final String version;
  final String conventionId;

  List<BaziPillar> get pillars => <BaziPillar>[year, month, day, hour];
}

/// RC-0142..RC-0148 Four Pillars assembly core.
///
/// The deterministic Gan-Zhi mapping is performed here. Calendar astronomy,
/// solar-term boundaries, day-cycle anchoring and local hour-boundary policy
/// remain the responsibility of a versioned [BaziFourPillarsProvider].
abstract final class BaziFourPillarsEngine {
  static const List<BaziHeavenlyStem> stems = <BaziHeavenlyStem>[
    BaziHeavenlyStem.jia,
    BaziHeavenlyStem.yi,
    BaziHeavenlyStem.bing,
    BaziHeavenlyStem.ding,
    BaziHeavenlyStem.wu,
    BaziHeavenlyStem.ji,
    BaziHeavenlyStem.geng,
    BaziHeavenlyStem.xin,
    BaziHeavenlyStem.ren,
    BaziHeavenlyStem.gui,
  ];

  static const List<BaziEarthlyBranch> branches = <BaziEarthlyBranch>[
    BaziEarthlyBranch.zi,
    BaziEarthlyBranch.chou,
    BaziEarthlyBranch.yin,
    BaziEarthlyBranch.mao,
    BaziEarthlyBranch.chen,
    BaziEarthlyBranch.si,
    BaziEarthlyBranch.wu,
    BaziEarthlyBranch.wei,
    BaziEarthlyBranch.shen,
    BaziEarthlyBranch.you,
    BaziEarthlyBranch.xu,
    BaziEarthlyBranch.hai,
  ];

  static BaziFourPillarsSnapshot calculate({
    required DateTime birthInstantUtc,
    required BaziFourPillarsProvider provider,
  }) {
    if (!birthInstantUtc.isUtc) {
      throw ArgumentError.value(
        birthInstantUtc,
        'birthInstantUtc',
        'must be UTC',
      );
    }

    final resolved = provider.resolve(birthInstantUtc: birthInstantUtc);
    return BaziFourPillarsSnapshot(
      birthInstantUtc: birthInstantUtc,
      year: _pillar(BaziPillarKind.year, resolved.yearCycleIndex),
      month: _pillar(BaziPillarKind.month, resolved.monthCycleIndex),
      day: _pillar(BaziPillarKind.day, resolved.dayCycleIndex),
      hour: _pillar(BaziPillarKind.hour, resolved.hourCycleIndex),
      sourceId: resolved.sourceId,
      version: resolved.version,
      conventionId: resolved.conventionId,
    );
  }

  static BaziPillar _pillar(BaziPillarKind kind, int cycleIndex) => BaziPillar(
        kind: kind,
        stem: stems[cycleIndex % 10],
        branch: branches[cycleIndex % 12],
        sexagenaryCycleIndex: cycleIndex,
      );
}
