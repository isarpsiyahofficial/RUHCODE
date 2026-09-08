import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/vedic_workspace.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1);
  final dasha = VedicPeriod(
    id: 'd1', level: 'dasha', lord: 'Saturn', startsAtUtc: start,
    endsAtUtc: DateTime.utc(2028, 1, 1), sourceId: 'vedic-ref', version: '1',
  );
  final antara = VedicPeriod(
    id: 'a1', level: 'antardasha', lord: 'Venus', startsAtUtc: start,
    endsAtUtc: DateTime.utc(2026, 8, 1), sourceId: 'vedic-ref', version: '1',
  );
  final hit = VedicGocharaHit(
    id: 'g1', exactAtUtc: DateTime.utc(2026, 3, 1), resultRef: 'gochara:1',
    sourceId: 'vedic-ref', version: '1',
  );

  test('RC-0527→0530 keeps Dasha, Antardasha and Gochara available together', () {
    final workspace = VedicProfessionalWorkspace(
      periods: [dasha, antara], gochara: [hit], chartResultRefs: {VargaChart.d1: 'd1:result'},
    );
    expect(workspace.activeAt(DateTime.utc(2026, 2, 1)).length, 2);
    expect(workspace.antardashaChanges().single.id, 'a1');
    expect(workspace.combinedTiming(start, DateTime.utc(2026, 5, 1)).length, 3);
  });

  test('RC-0531→0534 supports D1+D9, D1+D10 and three-chart comparison', () {
    final workspace = VedicProfessionalWorkspace(
      periods: [dasha], gochara: const [],
      chartResultRefs: {
        VargaChart.d1: 'd1:result', VargaChart.d9: 'd9:result', VargaChart.d10: 'd10:result',
      },
    );
    expect(workspace.sideBySide([VargaChart.d1, VargaChart.d9]), ['d1:result', 'd9:result']);
    expect(workspace.sideBySide([VargaChart.d1, VargaChart.d10]), ['d1:result', 'd10:result']);
    expect(workspace.sideBySide([VargaChart.d1, VargaChart.d9, VargaChart.d10]).length, 3);
  });

  test('requested unavailable Varga fails closed', () {
    final workspace = VedicProfessionalWorkspace(
      periods: [dasha], gochara: const [], chartResultRefs: {VargaChart.d1: 'd1:result'},
    );
    expect(() => workspace.sideBySide([VargaChart.d1, VargaChart.d9]), throwsStateError);
  });
}
