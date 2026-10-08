import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_compatibility.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';
import 'package:ruh_code/src/calculation_core/numerology/numerology_system.dart';
import 'package:ruh_code/src/calculation_core/ziwei/zi_wei_engine.dart';

final class _FourPillarsProvider implements BaziFourPillarsProvider {
  const _FourPillarsProvider(this.offset);
  final int offset;

  @override
  BaziFourPillarsResolution resolve({required DateTime birthInstantUtc}) =>
      BaziFourPillarsResolution(
        yearCycleIndex: offset % 60,
        monthCycleIndex: (offset + 1) % 60,
        dayCycleIndex: (offset + 2) % 60,
        hourCycleIndex: (offset + 3) % 60,
        sourceId: 'fixture-four-pillars',
        version: '1',
        conventionId: 'fixture',
      );
}

final class _ZiWeiFixture implements ZiWeiDouShuEngine<int, int> {
  @override
  String get engineId => 'ziwei-fixture';
  @override
  String get sourceId => 'fixture';
  @override
  String get version => '1';
  @override
  int calculate(int input) => input + 1;
}

final class _PythagoreanFixture implements PythagoreanNumerologySystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.pythagorean;
  @override
  String get sourceId => 'fixture-pythagorean';
  @override
  String get version => '1';
  @override
  int calculate(int input) => input;
}

final class _ChaldeanFixture implements ChaldeanNumerologySystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.chaldean;
  @override
  String get sourceId => 'fixture-chaldean';
  @override
  String get version => '1';
  @override
  int calculate(int input) => input;
}

final class _LoShuFixture implements LoShuGridSystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.loShuGrid;
  @override
  String get sourceId => 'fixture-loshu';
  @override
  String get version => '1';
  @override
  int calculate(int input) => input;
}

void main() {
  test('RC-0158 BaZi compatibility is explicit rule/version/source driven', () {
    final a = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(1990),
      provider: const _FourPillarsProvider(0),
    );
    final b = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(1991),
      provider: const _FourPillarsProvider(10),
    );
    final result = BaziCompatibilityEngine.evaluate(
      a: a,
      b: b,
      rules: [
        BaziCompatibilityRule(
          id: 'fixture-rule',
          version: '1',
          sourceId: 'fixture',
          maxScore: 10,
          evaluate: (left, right) => left.day.stem == right.day.stem ? 10 : 4,
        ),
      ],
    );
    expect(result.maxScore, 10);
    expect(result.results.single.sourceId, 'fixture');
  });

  test('RC-0159 and RC-0160 Zi Wei has an independent engine contract', () {
    final engine = _ZiWeiFixture();
    expect(engine.engineId, 'ziwei-fixture');
    expect(engine.calculate(1), 2);
  });

  test('RC-0161 RC-0162 RC-0163 RC-0164 numerology exposes three distinct systems', () {
    final systems = <NumerologySystem<dynamic, dynamic>>[
      _PythagoreanFixture(),
      _ChaldeanFixture(),
      _LoShuFixture(),
    ];
    expect(systems.map((e) => e.systemId).toSet(), NumerologySystemId.values.toSet());
    expect(systems.map((e) => e.sourceId).toSet().length, 3);
  });

  test('RC-0165 result envelope exposes exact numerology system identity', () {
    final result = NumerologyResultEnvelope<int>(
      systemId: NumerologySystemId.chaldean,
      version: '1',
      sourceId: 'fixture',
      value: 42,
    );
    expect(result.systemDisplayName, 'Chaldean');
    expect(result.systemId, NumerologySystemId.chaldean);
  });

  test('compatibility and registry fail closed on invalid or duplicate rules', () {
    final chart = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(1990),
      provider: const _FourPillarsProvider(0),
    );
    expect(
      () => BaziCompatibilityEngine.evaluate(a: chart, b: chart, rules: const []),
      throwsArgumentError,
    );
    expect(
      () => NumerologySystemRegistry([
        _PythagoreanFixture(),
        _PythagoreanFixture(),
      ]),
      throwsStateError,
    );
  });
}
