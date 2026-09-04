import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/lunar/moon_phase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RC-0021 physical Moon phase', () {
    test('packaged DE440s Sun/Moon states drive the phase result', () async {
      final provider = await De440sEphemerisProvider.loadPackaged();
      const jdTt = 2460409.25; // 2024-04-08 near the astronomical new Moon.
      final sun = provider.stateAt(body: AstroBody.sun, jdTt: jdTt);
      final moon = provider.stateAt(body: AstroBody.moon, jdTt: jdTt);
      final result = MoonPhaseEngine(provider).calculate(jdTt);

      final expectedAngle = _normalize(moon.longitudeDegrees - sun.longitudeDegrees);
      expect(result.sourceId, 'NASA/JPL DE440s');
      expect(result.dataVersion, 'DE440s');
      expect(result.phaseAngleDegrees, closeTo(expectedAngle, 1e-12));
      expect(result.phase, MoonPhaseName.newMoon);
      expect(result.illuminatedFraction, inInclusiveRange(0.0, 0.01));
    });

    test('packaged DE440s resolves a real full-Moon epoch independently', () async {
      final provider = await De440sEphemerisProvider.loadPackaged();
      const jdTt = 2460394.7917; // 2024-03-25 near the astronomical full Moon.
      final result = MoonPhaseEngine(provider).calculate(jdTt);

      expect(result.sourceId, 'NASA/JPL DE440s');
      expect(result.phase, MoonPhaseName.fullMoon);
      expect(result.phaseAngleDegrees, inInclusiveRange(175.0, 185.0));
      expect(result.illuminatedFraction, greaterThan(0.99));
    });
  });
}

double _normalize(double value) {
  final normalized = value % 360.0;
  return normalized < 0 ? normalized + 360.0 : normalized;
}
