import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/quick_calculation_workspace.dart';

QuickCalculationSettings settings(String id) => QuickCalculationSettings(id:id, version:'1', systemId:'western', parameters:const {'house':'placidus'});

void main() {
  test('Professional can calculate a temporary chart and save it only after verified result', () {
    final workspace = QuickCalculationWorkspace(recentState:ProfessionalRecentState());
    final session = workspace.startTemporary(QuickCalculationSession(
      id:'tmp-1', settings:settings('s1'), birthInput:QuickBirthInput(localDateTime:DateTime(1994,5,12,16,20), cityId:'antalya', timeZoneId:'Europe/Istanbul')));
    expect(() => workspace.saveAsClientProfile('tmp-1','client-1'), throwsStateError);
    session.attachVerifiedResult(QuickCalculationResult(id:'r1', kind:QuickCalculationKind.astrology, resultRef:'calc:r1', sourceId:'calculation-core', version:'1'));
    expect(workspace.saveAsClientProfile('tmp-1','client-1'), 'client-1');
  });

  test('Quick numerology uses a distinct input/result kind', () {
    final workspace = QuickCalculationWorkspace(recentState:ProfessionalRecentState());
    final session = workspace.startTemporary(QuickCalculationSession(id:'n1', settings:settings('nset'), freeFormNumerologyInput:'Ada Lovelace'));
    expect(() => session.attachVerifiedResult(QuickCalculationResult(id:'bad', kind:QuickCalculationKind.astrology, resultRef:'x', sourceId:'core', version:'1')), throwsStateError);
    session.attachVerifiedResult(QuickCalculationResult(id:'ok', kind:QuickCalculationKind.numerology, resultRef:'num:ok', sourceId:'num-core', version:'1'));
    expect(session.result!.kind, QuickCalculationKind.numerology);
  });

  test('Recent cities and settings are bounded and de-duplicated', () {
    final state = ProfessionalRecentState(maxCities:2, maxSettings:2);
    state..rememberCity('antalya')..rememberCity('istanbul')..rememberCity('antalya')..rememberCity('izmir');
    expect(state.cities, ['izmir','antalya']);
    state..rememberSettings(settings('a'))..rememberSettings(settings('b'))..rememberSettings(settings('a'));
    expect(state.settings.map((e) => e.id), ['a','b']);
  });

  test('Default professional presets can be stored without changing calculation provenance', () {
    final workspace = QuickCalculationWorkspace(recentState:ProfessionalRecentState());
    workspace.addPreset(ProfessionalPreset(id:'default', name:'My default', settings:settings('s1')));
    expect(() => workspace.addPreset(ProfessionalPreset(id:'default', name:'Duplicate', settings:settings('s2'))), throwsStateError);
  });

  test('Product utility contract covers every intended user role and core promise', () {
    const contract = ProductUtilityContract();
    for (final role in ProfessionalNeed.values) {
      expect(contract.need(role).trim(), isNotEmpty);
    }
    expect(contract.promise, contains('Hesapla'));
    expect(contract.promise, contains('tek yerde'));
  });

  test('Ambiguous quick input fails closed', () {
    expect(() => QuickCalculationSession(id:'bad', settings:settings('s'), birthInput:QuickBirthInput(localDateTime:DateTime(1994), cityId:'a', timeZoneId:'UTC'), freeFormNumerologyInput:'name'), throwsArgumentError);
    expect(() => QuickCalculationSession(id:'none', settings:settings('s')), throwsArgumentError);
  });
}
