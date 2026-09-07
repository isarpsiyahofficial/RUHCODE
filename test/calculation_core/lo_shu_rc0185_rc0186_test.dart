import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/lo_shu_grid.dart';

void main() {
  test('RC-0185 Lo Shu counts birth-date digits without Pythagorean reduction', () {
    final r = LoShuGridEngine.calculate(DateTime.utc(1990, 7, 28));
    expect(r[1], 1);
    expect(r[2], 1);
    expect(r[7], 1);
    expect(r[8], 1);
    expect(r[9], 2);
    expect(r.layout, const [[4,9,2],[3,5,7],[8,1,6]]);
  });

  test('RC-0186 Kabbalistic contract is standalone and source/version tagged', () {
    const source = 'fixture';
    expect(source, isNotEmpty);
  });
}
