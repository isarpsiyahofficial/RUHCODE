import 'bazi_derived_analysis.dart';
import 'bazi_four_pillars.dart';
import 'sexagenary_cycle.dart';

/// RC-0154 element-balance result. Scores are method-specific and must never be
/// presented as seasonal qi unless the selected method explicitly says so.
final class BaziElementBalanceSnapshot {
  const BaziElementBalanceSnapshot({
    required this.scores,
    required this.shares,
    required this.strongest,
    required this.weakest,
    required this.spread,
    required this.methodId,
    required this.sourceId,
    required this.version,
  });

  final Map<WuXingElement, double> scores;
  final Map<WuXingElement, double> shares;
  final WuXingElement strongest;
  final WuXingElement weakest;
  final double spread;
  final String methodId;
  final String sourceId;
  final String version;
}

abstract interface class BaziElementBalanceMethod {
  String get methodId;
  String get sourceId;
  String get version;

  /// Returns one non-negative finite score for every Five Element.
  Map<WuXingElement, double> score({
    required BaziFourPillarsSnapshot chart,
    required BaziDerivedAnalysisSnapshot derived,
  });
}

/// Explicit structural fallback based only on RC-0150 visible+hidden occurrence
/// counts. It is useful for structural balance views but is NOT seasonal qi.
final class StructuralOccurrenceBalanceMethod implements BaziElementBalanceMethod {
  const StructuralOccurrenceBalanceMethod();

  @override
  String get methodId => 'visible-plus-hidden-occurrence-balance-v1';
  @override
  String get sourceId => 'ruhcode-structural-bazi-occurrences';
  @override
  String get version => '1';

  @override
  Map<WuXingElement, double> score({
    required BaziFourPillarsSnapshot chart,
    required BaziDerivedAnalysisSnapshot derived,
  }) => <WuXingElement, double>{
        for (final element in WuXingElement.values)
          element: derived.elementDistribution.counts[element]!.toDouble(),
      };
}

abstract final class BaziElementBalanceEngine {
  static BaziElementBalanceSnapshot analyze({
    required BaziFourPillarsSnapshot chart,
    required BaziElementBalanceMethod method,
  }) {
    _requireMetadata(method.methodId, 'methodId');
    _requireMetadata(method.sourceId, 'sourceId');
    _requireMetadata(method.version, 'version');
    final derived = BaziDerivedAnalysis.calculate(chart);
    final raw = method.score(chart: chart, derived: derived);
    if (raw.length != WuXingElement.values.length ||
        !WuXingElement.values.every(raw.containsKey)) {
      throw StateError('Element-balance method must score all Five Elements exactly once.');
    }
    for (final entry in raw.entries) {
      if (!entry.value.isFinite || entry.value < 0) {
        throw StateError('Invalid element-balance score for ${entry.key.name}.');
      }
    }
    final total = raw.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) throw StateError('Element-balance score total must be positive.');
    final scores = Map<WuXingElement, double>.unmodifiable(raw);
    final shares = Map<WuXingElement, double>.unmodifiable(<WuXingElement, double>{
      for (final e in WuXingElement.values) e: scores[e]! / total,
    });
    final ranked = [...WuXingElement.values]..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    final strongest = ranked.first;
    final weakest = ranked.last;
    return BaziElementBalanceSnapshot(
      scores: scores,
      shares: shares,
      strongest: strongest,
      weakest: weakest,
      spread: shares[strongest]! - shares[weakest]!,
      methodId: method.methodId,
      sourceId: method.sourceId,
      version: method.version,
    );
  }

  static void _requireMetadata(String value, String name) {
    if (value.trim().isEmpty) throw ArgumentError.value(value, name, 'must not be empty');
  }
}

enum DaYunDirection { forward, backward }

final class DaYunConventionResolution {
  DaYunConventionResolution({
    required this.direction,
    required this.startAgeYears,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  }) {
    if (!startAgeYears.isFinite || startAgeYears < 0) {
      throw ArgumentError.value(startAgeYears, 'startAgeYears', 'must be finite and non-negative');
    }
    for (final entry in <String, String>{
      'sourceId': sourceId,
      'version': version,
      'conventionId': conventionId,
    }.entries) {
      if (entry.value.trim().isEmpty) throw ArgumentError.value(entry.value, entry.key, 'must not be empty');
    }
  }

  final DaYunDirection direction;
  final double startAgeYears;
  final String sourceId;
  final String version;
  final String conventionId;
}

abstract interface class DaYunConventionProvider {
  DaYunConventionResolution resolve({required BaziFourPillarsSnapshot natal});
}

final class DaYunPeriod {
  const DaYunPeriod({
    required this.ordinal,
    required this.pillar,
    required this.startAgeYears,
    required this.endAgeYears,
  });

  final int ordinal;
  final SexagenaryPillar pillar;
  final double startAgeYears;
  final double endAgeYears;
}

final class DaYunSnapshot {
  const DaYunSnapshot({
    required this.direction,
    required this.periods,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  });

  final DaYunDirection direction;
  final List<DaYunPeriod> periods;
  final String sourceId;
  final String version;
  final String conventionId;
}

/// RC-0155. Sequence arithmetic is deterministic; direction and start age are
/// delegated to an explicit versioned convention provider because schools vary.
abstract final class DaYunEngine {
  static DaYunSnapshot calculate({
    required BaziFourPillarsSnapshot natal,
    required DaYunConventionProvider conventionProvider,
    int periodCount = 8,
  }) {
    if (periodCount <= 0) throw ArgumentError.value(periodCount, 'periodCount', 'must be positive');
    final convention = conventionProvider.resolve(natal: natal);
    final delta = convention.direction == DaYunDirection.forward ? 1 : -1;
    final month = SexagenaryCycle.at(natal.month.sexagenaryCycleIndex);
    final periods = <DaYunPeriod>[];
    for (var i = 0; i < periodCount; i++) {
      final startAge = convention.startAgeYears + i * 10.0;
      periods.add(DaYunPeriod(
        ordinal: i + 1,
        pillar: SexagenaryCycle.advance(month, delta * (i + 1)),
        startAgeYears: startAge,
        endAgeYears: startAge + 10.0,
      ));
    }
    return DaYunSnapshot(
      direction: convention.direction,
      periods: List.unmodifiable(periods),
      sourceId: convention.sourceId,
      version: convention.version,
      conventionId: convention.conventionId,
    );
  }
}

final class BaziPeriodPillarResolution {
  BaziPeriodPillarResolution({
    required this.cycleIndex,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  }) {
    if (cycleIndex < 0 || cycleIndex >= SexagenaryCycle.length) {
      throw ArgumentError.value(cycleIndex, 'cycleIndex', 'must be 0..59');
    }
    for (final entry in <String, String>{
      'sourceId': sourceId,
      'version': version,
      'conventionId': conventionId,
    }.entries) {
      if (entry.value.trim().isEmpty) throw ArgumentError.value(entry.value, entry.key, 'must not be empty');
    }
  }

  final int cycleIndex;
  final String sourceId;
  final String version;
  final String conventionId;
}

abstract interface class BaziPeriodPillarProvider {
  BaziPeriodPillarResolution resolveYear({required DateTime instantUtc});
  BaziPeriodPillarResolution resolveMonth({required DateTime instantUtc});
}

enum BaziPeriodKind { annual, monthly }

final class BaziPeriodInfluenceSnapshot {
  const BaziPeriodInfluenceSnapshot({
    required this.kind,
    required this.instantUtc,
    required this.pillar,
    required this.stemTenGod,
    required this.sourceId,
    required this.version,
    required this.conventionId,
  });

  final BaziPeriodKind kind;
  final DateTime instantUtc;
  final SexagenaryPillar pillar;
  final BaziTenGod stemTenGod;
  final String sourceId;
  final String version;
  final String conventionId;
}

/// RC-0156/0157. Produces calendar-period Gan-Zhi and its stem relationship to
/// the natal Day Master. The calendar boundary convention remains explicit.
abstract final class BaziPeriodInfluenceEngine {
  static BaziPeriodInfluenceSnapshot annual({
    required BaziFourPillarsSnapshot natal,
    required DateTime instantUtc,
    required BaziPeriodPillarProvider provider,
  }) => _calculate(
        kind: BaziPeriodKind.annual,
        natal: natal,
        instantUtc: instantUtc,
        resolved: provider.resolveYear(instantUtc: _requireUtc(instantUtc)),
      );

  static BaziPeriodInfluenceSnapshot monthly({
    required BaziFourPillarsSnapshot natal,
    required DateTime instantUtc,
    required BaziPeriodPillarProvider provider,
  }) => _calculate(
        kind: BaziPeriodKind.monthly,
        natal: natal,
        instantUtc: instantUtc,
        resolved: provider.resolveMonth(instantUtc: _requireUtc(instantUtc)),
      );

  static BaziPeriodInfluenceSnapshot _calculate({
    required BaziPeriodKind kind,
    required BaziFourPillarsSnapshot natal,
    required DateTime instantUtc,
    required BaziPeriodPillarResolution resolved,
  }) {
    final pillar = SexagenaryCycle.at(resolved.cycleIndex);
    return BaziPeriodInfluenceSnapshot(
      kind: kind,
      instantUtc: instantUtc,
      pillar: pillar,
      stemTenGod: BaziDerivedAnalysis.tenGodFor(dayMaster: natal.day.stem, other: pillar.stem),
      sourceId: resolved.sourceId,
      version: resolved.version,
      conventionId: resolved.conventionId,
    );
  }

  static DateTime _requireUtc(DateTime value) {
    if (!value.isUtc) throw ArgumentError.value(value, 'instantUtc', 'must be UTC');
    return value;
  }
}
