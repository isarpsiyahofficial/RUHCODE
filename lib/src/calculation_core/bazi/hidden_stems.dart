import 'sexagenary_cycle.dart';

/// Ordered Hidden Stems (藏干 / Cang Gan) for each Earthly Branch.
///
/// The list is ordered main qi first, then secondary/residual qi where present.
/// No percentage weights are encoded because weight systems differ by school;
/// inventing one here would mix interpretation policy into the calculation core.
abstract final class BaZiHiddenStems {
  static const Map<EarthlyBranch, List<HeavenlyStem>> _byBranch =
      <EarthlyBranch, List<HeavenlyStem>>{
        EarthlyBranch.zi: <HeavenlyStem>[HeavenlyStem.gui],
        EarthlyBranch.chou: <HeavenlyStem>[
          HeavenlyStem.ji,
          HeavenlyStem.gui,
          HeavenlyStem.xin,
        ],
        EarthlyBranch.yin: <HeavenlyStem>[
          HeavenlyStem.jia,
          HeavenlyStem.bing,
          HeavenlyStem.wu,
        ],
        EarthlyBranch.mao: <HeavenlyStem>[HeavenlyStem.yi],
        EarthlyBranch.chen: <HeavenlyStem>[
          HeavenlyStem.wu,
          HeavenlyStem.yi,
          HeavenlyStem.gui,
        ],
        EarthlyBranch.si: <HeavenlyStem>[
          HeavenlyStem.bing,
          HeavenlyStem.wu,
          HeavenlyStem.geng,
        ],
        EarthlyBranch.wu: <HeavenlyStem>[
          HeavenlyStem.ding,
          HeavenlyStem.ji,
        ],
        EarthlyBranch.wei: <HeavenlyStem>[
          HeavenlyStem.ji,
          HeavenlyStem.ding,
          HeavenlyStem.yi,
        ],
        EarthlyBranch.shen: <HeavenlyStem>[
          HeavenlyStem.geng,
          HeavenlyStem.ren,
          HeavenlyStem.wu,
        ],
        EarthlyBranch.you: <HeavenlyStem>[HeavenlyStem.xin],
        EarthlyBranch.xu: <HeavenlyStem>[
          HeavenlyStem.wu,
          HeavenlyStem.xin,
          HeavenlyStem.ding,
        ],
        EarthlyBranch.hai: <HeavenlyStem>[
          HeavenlyStem.ren,
          HeavenlyStem.jia,
        ],
      };

  static List<HeavenlyStem> of(EarthlyBranch branch) {
    final stems = _byBranch[branch];
    if (stems == null || stems.isEmpty) {
      throw StateError('Hidden-stem mapping is missing for ${branch.name}.');
    }
    return List<HeavenlyStem>.unmodifiable(stems);
  }

  static HeavenlyStem mainQi(EarthlyBranch branch) => of(branch).first;

  static void assertComplete() {
    if (_byBranch.length != EarthlyBranch.values.length) {
      throw StateError('Every Earthly Branch must have a hidden-stem mapping.');
    }
    for (final branch in EarthlyBranch.values) {
      final stems = _byBranch[branch];
      if (stems == null || stems.isEmpty || stems.toSet().length != stems.length) {
        throw StateError('Invalid hidden-stem mapping for ${branch.name}.');
      }
    }
  }
}
