import 'hidden_stems.dart';
import 'sexagenary_cycle.dart';

/// Canonical Ten Gods (十神 / Shi Shen) relationship categories.
///
/// These are calculation identities only. No interpretation text, strength,
/// auspiciousness, percentage weighting, or civil-date pillar derivation lives
/// in this primitive.
enum TenGod {
  friend,
  robWealth,
  eatingGod,
  hurtingOfficer,
  indirectWealth,
  directWealth,
  sevenKillings,
  directOfficer,
  indirectResource,
  directResource,
}

final class TenGodAssessment {
  const TenGodAssessment({
    required this.dayMaster,
    required this.target,
    required this.tenGod,
  });

  final HeavenlyStem dayMaster;
  final HeavenlyStem target;
  final TenGod tenGod;

  bool get samePolarity => dayMaster.polarity == target.polarity;
}

/// Pure Day-Master-vs-Heavenly-Stem Ten Gods classifier.
///
/// Relationship rules:
/// - same element: same polarity Friend, opposite polarity Rob Wealth
/// - Day Master generates target: same Eating God, opposite Hurting Officer
/// - Day Master controls target: same Indirect Wealth, opposite Direct Wealth
/// - target controls Day Master: same Seven Killings, opposite Direct Officer
/// - target generates Day Master: same Indirect Resource, opposite Direct Resource
///
/// This deliberately accepts an already-known Day Master. It does NOT derive a
/// Day Pillar from a civil date because that requires the separately verified
/// BaZi day-boundary and solar-term contracts.
abstract final class BaZiTenGods {
  static TenGodAssessment assess({
    required HeavenlyStem dayMaster,
    required HeavenlyStem target,
  }) {
    final samePolarity = dayMaster.polarity == target.polarity;
    final tenGod = _classify(
      dayMaster.element,
      target.element,
      samePolarity: samePolarity,
    );
    return TenGodAssessment(
      dayMaster: dayMaster,
      target: target,
      tenGod: tenGod,
    );
  }

  static List<TenGodAssessment> assessHiddenStems({
    required HeavenlyStem dayMaster,
    required EarthlyBranch branch,
  }) {
    return List<TenGodAssessment>.unmodifiable(
      BaZiHiddenStems.of(branch).map(
        (stem) => assess(dayMaster: dayMaster, target: stem),
      ),
    );
  }

  static TenGod _classify(
    WuXingElement dayMaster,
    WuXingElement target, {
    required bool samePolarity,
  }) {
    if (dayMaster == target) {
      return samePolarity ? TenGod.friend : TenGod.robWealth;
    }
    if (_generates(dayMaster) == target) {
      return samePolarity ? TenGod.eatingGod : TenGod.hurtingOfficer;
    }
    if (_controls(dayMaster) == target) {
      return samePolarity ? TenGod.indirectWealth : TenGod.directWealth;
    }
    if (_controls(target) == dayMaster) {
      return samePolarity ? TenGod.sevenKillings : TenGod.directOfficer;
    }
    if (_generates(target) == dayMaster) {
      return samePolarity ? TenGod.indirectResource : TenGod.directResource;
    }
    throw StateError('Unreachable Wu Xing relationship.');
  }

  static WuXingElement _generates(WuXingElement element) => switch (element) {
        WuXingElement.wood => WuXingElement.fire,
        WuXingElement.fire => WuXingElement.earth,
        WuXingElement.earth => WuXingElement.metal,
        WuXingElement.metal => WuXingElement.water,
        WuXingElement.water => WuXingElement.wood,
      };

  static WuXingElement _controls(WuXingElement element) => switch (element) {
        WuXingElement.wood => WuXingElement.earth,
        WuXingElement.fire => WuXingElement.metal,
        WuXingElement.earth => WuXingElement.water,
        WuXingElement.metal => WuXingElement.wood,
        WuXingElement.water => WuXingElement.fire,
      };
}
