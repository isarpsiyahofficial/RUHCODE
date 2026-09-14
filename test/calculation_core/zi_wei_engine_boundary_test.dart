import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/zi_wei/zi_wei_engine.dart';

final class _FakeZiWeiEngine implements ZiWeiDouShuEngine<int, int> {
  @override
  String get engineId => 'zi-wei-test-engine';

  @override
  String get version => '1.0.0-test';

  @override
  String get sourceId => 'fixture:zi-wei-boundary';

  @override
  int calculate(int input) => input * 2;
}

void main() {
  group('RC-0159/RC-0160 Zi Wei independent engine boundary', () {
    test('Zi Wei exposes its own engine identity and calculation contract', () {
      final engine = _FakeZiWeiEngine();

      expect(engine.engineId, 'zi-wei-test-engine');
      expect(engine.calculate(21), 42);
      expect(engine.version, isNotEmpty);
      expect(engine.sourceId, isNotEmpty);
    });

    test('result provenance is explicit and fail-closed', () {
      final result = ZiWeiDouShuResultEnvelope<int>(
        engineId: 'zi-wei-test-engine',
        version: '1.0.0-test',
        sourceId: 'fixture:zi-wei-boundary',
        value: 42,
      );

      expect(result.engineId, 'zi-wei-test-engine');
      expect(result.value, 42);
      expect(
        () => ZiWeiDouShuResultEnvelope<int>(
          engineId: '',
          version: '1',
          sourceId: 'fixture',
          value: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
