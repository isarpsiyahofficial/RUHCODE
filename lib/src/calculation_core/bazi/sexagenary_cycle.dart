enum WuXingElement { wood, fire, earth, metal, water }

enum YinYang { yang, yin }

enum HeavenlyStem {
  jia(WuXingElement.wood, YinYang.yang),
  yi(WuXingElement.wood, YinYang.yin),
  bing(WuXingElement.fire, YinYang.yang),
  ding(WuXingElement.fire, YinYang.yin),
  wu(WuXingElement.earth, YinYang.yang),
  ji(WuXingElement.earth, YinYang.yin),
  geng(WuXingElement.metal, YinYang.yang),
  xin(WuXingElement.metal, YinYang.yin),
  ren(WuXingElement.water, YinYang.yang),
  gui(WuXingElement.water, YinYang.yin);

  const HeavenlyStem(this.element, this.polarity);
  final WuXingElement element;
  final YinYang polarity;
}

enum EarthlyBranch {
  zi(WuXingElement.water, YinYang.yang),
  chou(WuXingElement.earth, YinYang.yin),
  yin(WuXingElement.wood, YinYang.yang),
  mao(WuXingElement.wood, YinYang.yin),
  chen(WuXingElement.earth, YinYang.yang),
  si(WuXingElement.fire, YinYang.yin),
  wu(WuXingElement.fire, YinYang.yang),
  wei(WuXingElement.earth, YinYang.yin),
  shen(WuXingElement.metal, YinYang.yang),
  you(WuXingElement.metal, YinYang.yin),
  xu(WuXingElement.earth, YinYang.yang),
  hai(WuXingElement.water, YinYang.yin);

  const EarthlyBranch(this.element, this.polarity);
  final WuXingElement element;
  final YinYang polarity;
}

final class SexagenaryPillar {
  const SexagenaryPillar({
    required this.cycleIndex,
    required this.stem,
    required this.branch,
  });

  /// Zero-based canonical cycle index. 0 = Jia-Zi, 59 = Gui-Hai.
  final int cycleIndex;
  final HeavenlyStem stem;
  final EarthlyBranch branch;

  @override
  bool operator ==(Object other) =>
      other is SexagenaryPillar &&
      cycleIndex == other.cycleIndex &&
      stem == other.stem &&
      branch == other.branch;

  @override
  int get hashCode => Object.hash(cycleIndex, stem, branch);
}

/// Pure 60-cycle arithmetic only.
///
/// This deliberately does NOT calculate BaZi year/month/day/hour pillars from
/// civil dates. Those require separately verified solar-term/day-boundary
/// contracts. Keeping this primitive separate prevents an unverified calendar
/// assumption from leaking into production BaZi results.
abstract final class SexagenaryCycle {
  static const int length = 60;

  static SexagenaryPillar at(int index) {
    final normalized = _floorMod(index, length);
    final stem = HeavenlyStem.values[normalized % HeavenlyStem.values.length];
    final branch = EarthlyBranch.values[normalized % EarthlyBranch.values.length];
    if (stem.polarity != branch.polarity) {
      throw StateError('Invalid sexagenary parity at index $normalized.');
    }
    return SexagenaryPillar(
      cycleIndex: normalized,
      stem: stem,
      branch: branch,
    );
  }

  static SexagenaryPillar advance(SexagenaryPillar pillar, int offset) =>
      at(pillar.cycleIndex + offset);

  static int indexOf(HeavenlyStem stem, EarthlyBranch branch) {
    if (stem.polarity != branch.polarity) {
      throw const FormatException(
        'Heavenly Stem and Earthly Branch must have matching Yin/Yang parity.',
      );
    }
    for (var index = 0; index < length; index++) {
      if (index % 10 == stem.index && index % 12 == branch.index) {
        return index;
      }
    }
    throw StateError('Valid stem/branch pair was not found in the 60-cycle.');
  }

  static int _floorMod(int value, int modulus) {
    final remainder = value % modulus;
    return remainder < 0 ? remainder + modulus : remainder;
  }
}
