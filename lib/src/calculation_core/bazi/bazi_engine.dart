import '../../domain/models/core_models.dart';
import '../calculation_engine.dart';

final class BaZiPillarInput {
  const BaZiPillarInput({required this.stemIndex, required this.branchIndex});

  final int stemIndex;
  final int branchIndex;
}

final class BaZiInput {
  const BaZiInput({
    required this.manifest,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });

  final CalculationManifest manifest;
  final BaZiPillarInput year;
  final BaZiPillarInput month;
  final BaZiPillarInput day;
  final BaZiPillarInput hour;
}

final class BaZiPillar {
  const BaZiPillar({required this.stemIndex, required this.branchIndex});

  final int stemIndex;
  final int branchIndex;
}

final class BaZiChart {
  const BaZiChart({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });

  final BaZiPillar year;
  final BaZiPillar month;
  final BaZiPillar day;
  final BaZiPillar hour;
}

final class BaZiEngine implements CalculationEngine<BaZiInput, BaZiChart> {
  const BaZiEngine();

  @override
  String get engineId => 'bazi';

  @override
  String get engineVersion => '1.0.0';

  @override
  Future<CalculationResult<BaZiChart>> calculate(BaZiInput input) async {
    if (input.manifest.engineId != engineId) {
      throw StateError('BaZi manifest engineId mismatch.');
    }
    if (input.manifest.validity != CalculationValidity.valid) {
      throw StateError('BaZi requires a valid calculation manifest.');
    }

    final chart = BaZiChart(
      year: _validated(input.year, 'year'),
      month: _validated(input.month, 'month'),
      day: _validated(input.day, 'day'),
      hour: _validated(input.hour, 'hour'),
    );
    return CalculationResult<BaZiChart>(manifest: input.manifest, value: chart);
  }

  static BaZiPillar _validated(BaZiPillarInput input, String name) {
    if (input.stemIndex < 0 || input.stemIndex > 9) {
      throw RangeError.range(input.stemIndex, 0, 9, '$name.stemIndex');
    }
    if (input.branchIndex < 0 || input.branchIndex > 11) {
      throw RangeError.range(input.branchIndex, 0, 11, '$name.branchIndex');
    }
    return BaZiPillar(stemIndex: input.stemIndex, branchIndex: input.branchIndex);
  }
}
