enum WesternHouseSystem {
  placidus,
  wholeSign,
  equal,
  koch,
  campanus,
  regiomontanus,
  porphyry,
}

enum HouseSystemSupport {
  supported,
  evaluatedNotImplemented,
}

final class HouseSystemDescriptor {
  const HouseSystemDescriptor({
    required this.system,
    required this.support,
    required this.titleTr,
    required this.titleEn,
    required this.assessment,
  });

  final WesternHouseSystem system;
  final HouseSystemSupport support;
  final String titleTr;
  final String titleEn;
  final String assessment;

  bool get isExecutable => support == HouseSystemSupport.supported;
}

/// Canonical product-facing registry for Western house systems.
///
/// RC-0057..0059 require an explicit professional evaluation, not a silent
/// claim of implementation. Koch, Campanus and Regiomontanus therefore remain
/// fail-closed until an independently validated executable implementation and
/// authoritative golden vectors are added. Porphyry is executable in the
/// current calculation core and is marked supported.
abstract final class WesternHouseSystemCatalog {
  static const Map<WesternHouseSystem, HouseSystemDescriptor> descriptors = {
    WesternHouseSystem.placidus: HouseSystemDescriptor(
      system: WesternHouseSystem.placidus,
      support: HouseSystemSupport.supported,
      titleTr: 'Placidus',
      titleEn: 'Placidus',
      assessment: 'Executable production implementation with explicit polar failure policy.',
    ),
    WesternHouseSystem.wholeSign: HouseSystemDescriptor(
      system: WesternHouseSystem.wholeSign,
      support: HouseSystemSupport.supported,
      titleTr: 'Whole Sign',
      titleEn: 'Whole Sign',
      assessment: 'Executable production implementation using the Ascendant sign as house one.',
    ),
    WesternHouseSystem.equal: HouseSystemDescriptor(
      system: WesternHouseSystem.equal,
      support: HouseSystemSupport.supported,
      titleTr: 'Equal House',
      titleEn: 'Equal House',
      assessment: 'Executable production implementation anchored to the Ascendant longitude.',
    ),
    WesternHouseSystem.koch: HouseSystemDescriptor(
      system: WesternHouseSystem.koch,
      support: HouseSystemSupport.evaluatedNotImplemented,
      titleTr: 'Koch',
      titleEn: 'Koch',
      assessment: 'Evaluated; intentionally unavailable until authoritative high-latitude semantics and golden vectors are bound.',
    ),
    WesternHouseSystem.campanus: HouseSystemDescriptor(
      system: WesternHouseSystem.campanus,
      support: HouseSystemSupport.evaluatedNotImplemented,
      titleTr: 'Campanus',
      titleEn: 'Campanus',
      assessment: 'Evaluated; intentionally unavailable until a validated prime-vertical implementation and golden vectors are bound.',
    ),
    WesternHouseSystem.regiomontanus: HouseSystemDescriptor(
      system: WesternHouseSystem.regiomontanus,
      support: HouseSystemSupport.evaluatedNotImplemented,
      titleTr: 'Regiomontanus',
      titleEn: 'Regiomontanus',
      assessment: 'Evaluated; intentionally unavailable until a validated celestial-equator implementation and golden vectors are bound.',
    ),
    WesternHouseSystem.porphyry: HouseSystemDescriptor(
      system: WesternHouseSystem.porphyry,
      support: HouseSystemSupport.supported,
      titleTr: 'Porphyry',
      titleEn: 'Porphyry',
      assessment: 'Executable production implementation dividing each angular quadrant into three equal ecliptic arcs.',
    ),
  };

  static HouseSystemDescriptor descriptor(WesternHouseSystem system) =>
      descriptors[system] ?? (throw StateError('Missing house-system descriptor: $system'));

  static String visibleTitle(WesternHouseSystem system, {required String languageCode}) {
    final value = descriptor(system);
    return switch (languageCode) {
      'tr' => value.titleTr,
      'en' => value.titleEn,
      _ => throw ArgumentError.value(languageCode, 'languageCode', 'Only tr/en are supported.'),
    };
  }

  static void requireExecutable(WesternHouseSystem system) {
    final value = descriptor(system);
    if (!value.isExecutable) {
      throw UnsupportedError('${value.titleEn} was evaluated but is not an executable house system in this release.');
    }
  }
}
