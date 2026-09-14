import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/numerology_system.dart';

final class _PythagoreanFixture
    implements PythagoreanNumerologySystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.pythagorean;

  @override
  String get version => '1.0.0-test';

  @override
  String get sourceId => 'fixture:pythagorean';

  @override
  int calculate(int input) => input + 1;
}

final class _ChaldeanFixture implements ChaldeanNumerologySystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.chaldean;

  @override
  String get version => '1.0.0-test';

  @override
  String get sourceId => 'fixture:chaldean';

  @override
  int calculate(int input) => input + 2;
}

final class _LoShuFixture implements LoShuGridSystem<int, int> {
  @override
  NumerologySystemId get systemId => NumerologySystemId.loShuGrid;

  @override
  String get version => '1.0.0-test';

  @override
  String get sourceId => 'fixture:lo-shu';

  @override
  int calculate(int input) => input + 3;
}

void main() {
  group('RC-0161..RC-0165 numerology system boundaries', () {
    test('Pythagorean, Chaldean and Lo Shu remain distinct registered systems', () {
      final registry = NumerologySystemRegistry(<NumerologySystem<dynamic, dynamic>>[
        _PythagoreanFixture(),
        _ChaldeanFixture(),
        _LoShuFixture(),
      ]);

      expect(registry.systems.keys.toSet(), <NumerologySystemId>{
        NumerologySystemId.pythagorean,
        NumerologySystemId.chaldean,
        NumerologySystemId.loShuGrid,
      });
      expect(registry.systems[NumerologySystemId.pythagorean]!.calculate(10), 11);
      expect(registry.systems[NumerologySystemId.chaldean]!.calculate(10), 12);
      expect(registry.systems[NumerologySystemId.loShuGrid]!.calculate(10), 13);
    });

    test('active system identity remains visible in result envelopes', () {
      final result = NumerologyResultEnvelope<int>(
        systemId: NumerologySystemId.chaldean,
        version: '1.0.0-test',
        sourceId: 'fixture:chaldean',
        value: 7,
      );

      expect(result.systemId, NumerologySystemId.chaldean);
      expect(result.systemDisplayName, 'Chaldean');
      expect(result.version, '1.0.0-test');
      expect(result.sourceId, 'fixture:chaldean');
    });

    test('duplicate systems and missing provenance fail closed', () {
      expect(
        () => NumerologySystemRegistry(<NumerologySystem<dynamic, dynamic>>[
          _PythagoreanFixture(),
          _PythagoreanFixture(),
        ]),
        throwsStateError,
      );

      expect(
        () => NumerologyResultEnvelope<int>(
          systemId: NumerologySystemId.pythagorean,
          version: '',
          sourceId: 'fixture',
          value: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
