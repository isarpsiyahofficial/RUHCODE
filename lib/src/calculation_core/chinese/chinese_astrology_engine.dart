import '../../domain/models/core_models.dart';
import '../calculation_engine.dart';

final class ChineseAstrologyInput {
  const ChineseAstrologyInput({
    required this.manifest,
    required this.cycleYear,
  });

  final CalculationManifest manifest;

  /// The already-resolved traditional Chinese cycle year.
  ///
  /// Civil-date to Chinese-year boundary resolution, including Chinese New Year
  /// and solar-term ownership, is deliberately outside this engine until a
  /// versioned calendar/solar-term source is bound. Callers must therefore pass
  /// a cycleYear resolved by that authoritative boundary layer rather than
  /// deriving a Chinese year from the Gregorian year inside this engine.
  final int cycleYear;
}

final class ChineseYearCycle {
  const ChineseYearCycle({
    required this.cycleYear,
    required this.sexagenaryIndex,
    required this.heavenlyStemIndex,
    required this.earthlyBranchIndex,
  });

  final int cycleYear;
  final int sexagenaryIndex;
  final int heavenlyStemIndex;
  final int earthlyBranchIndex;
}

final class ChineseAstrologyEngine
    implements CalculationEngine<ChineseAstrologyInput, ChineseYearCycle> {
  const ChineseAstrologyEngine();

  static const int _jiaZiReferenceYear = 1984;

  @override
  String get engineId => 'chinese-astrology';

  @override
  String get engineVersion => '1.0.0';

  @override
  Future<CalculationResult<ChineseYearCycle>> calculate(
    ChineseAstrologyInput input,
  ) async {
    final manifest = input.manifest;
    if (manifest.engineId != engineId) {
      throw StateError('Chinese astrology manifest engineId mismatch.');
    }
    if (manifest.validity != CalculationValidity.valid) {
      throw StateError('Chinese astrology requires a valid calculation manifest.');
    }

    // Limit the accepted range to years that can be represented safely by the
    // application's supported historical/future calendar layer. A wider range
    // must be introduced together with a versioned calendar evidence source.
    if (input.cycleYear < -9999 || input.cycleYear > 9999) {
      throw RangeError.range(input.cycleYear, -9999, 9999, 'cycleYear');
    }

    final sexagenaryIndex = _floorMod(input.cycleYear - _jiaZiReferenceYear, 60);
    final value = ChineseYearCycle(
      cycleYear: input.cycleYear,
      sexagenaryIndex: sexagenaryIndex,
      heavenlyStemIndex: sexagenaryIndex % 10,
      earthlyBranchIndex: sexagenaryIndex % 12,
    );

    return CalculationResult<ChineseYearCycle>(manifest: manifest, value: value);
  }

  static int _floorMod(int value, int modulus) {
    final remainder = value % modulus;
    return remainder < 0 ? remainder + modulus : remainder;
  }
}
