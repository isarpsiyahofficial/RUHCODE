import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

/// Canonical identifiers for Vedic ayanamsha policies.
abstract final class VedicAyanamshaIds {
  static const lahiriChitrapaksha = 'lahiri-chitrapaksha';
}

/// Fail-closed registry for Vedic ayanamsha selection.
///
/// RC-0082 requires Lahiri/Chitrapaksha to be the default. RC-0083 requires
/// the architecture to permit additional professional choices later without
/// changing the independent Vedic calculation engine. Numerical ayanamsha
/// implementations remain separately versioned [VedicAyanamshaProvider]s.
final class VedicAyanamshaCatalog {
  VedicAyanamshaCatalog({required Iterable<VedicAyanamshaProvider> providers})
      : _providers = _build(providers);

  final Map<String, VedicAyanamshaProvider> _providers;

  String get defaultId => VedicAyanamshaIds.lahiriChitrapaksha;

  List<String> get availableIds =>
      List<String>.unmodifiable(_providers.keys.toList()..sort());

  VedicAyanamshaProvider resolve([String? requestedId]) {
    final id = requestedId == null || requestedId.trim().isEmpty
        ? defaultId
        : requestedId.trim();
    final provider = _providers[id];
    if (provider == null) {
      throw StateError('Unknown Vedic ayanamsha: $id');
    }
    return provider;
  }

  static Map<String, VedicAyanamshaProvider> _build(
    Iterable<VedicAyanamshaProvider> providers,
  ) {
    final result = <String, VedicAyanamshaProvider>{};
    for (final provider in providers) {
      final id = provider.id.trim();
      if (id.isEmpty || provider.dataVersion.trim().isEmpty) {
        throw StateError('Ayanamsha provider provenance must be explicit.');
      }
      if (result.containsKey(id)) {
        throw ArgumentError('Duplicate ayanamsha provider id: $id');
      }
      result[id] = provider;
    }
    if (!result.containsKey(VedicAyanamshaIds.lahiriChitrapaksha)) {
      throw StateError(
        'Vedic ayanamsha catalog must contain Lahiri/Chitrapaksha default.',
      );
    }
    return Map<String, VedicAyanamshaProvider>.unmodifiable(result);
  }
}

/// Routes every configured Vedic calculation through the canonical ayanamsha
/// catalog. Omitting [ayanamshaId] therefore means Lahiri/Chitrapaksha.
abstract final class ConfiguredVedicCalculation {
  static VedicCalculationSnapshot calculate({
    required double jdTt,
    required Iterable<AstroBody> bodies,
    required EphemerisProvider ephemeris,
    required VedicAyanamshaCatalog ayanamshas,
    String? ayanamshaId,
  }) {
    return VedicCalculationEngine.calculate(
      jdTt: jdTt,
      bodies: bodies,
      ephemeris: ephemeris,
      ayanamsha: ayanamshas.resolve(ayanamshaId),
    );
  }
}
