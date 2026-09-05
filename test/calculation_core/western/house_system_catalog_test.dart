import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/western/house_system_catalog.dart';

void main() {
  test('catalog covers every declared Western house system exactly once', () {
    expect(WesternHouseSystemCatalog.descriptors.length, WesternHouseSystem.values.length);
    for (final system in WesternHouseSystem.values) {
      expect(WesternHouseSystemCatalog.descriptors.containsKey(system), isTrue);
      expect(WesternHouseSystemCatalog.descriptor(system).system, system);
    }
  });

  test('Koch Campanus and Regiomontanus are explicitly evaluated but fail closed', () {
    for (final system in <WesternHouseSystem>[
      WesternHouseSystem.koch,
      WesternHouseSystem.campanus,
      WesternHouseSystem.regiomontanus,
    ]) {
      final descriptor = WesternHouseSystemCatalog.descriptor(system);
      expect(descriptor.support, HouseSystemSupport.evaluatedNotImplemented);
      expect(descriptor.assessment, isNotEmpty);
      expect(() => WesternHouseSystemCatalog.requireExecutable(system), throwsUnsupportedError);
    }
  });

  test('Porphyry is an executable evaluated house system', () {
    final descriptor = WesternHouseSystemCatalog.descriptor(WesternHouseSystem.porphyry);
    expect(descriptor.support, HouseSystemSupport.supported);
    expect(() => WesternHouseSystemCatalog.requireExecutable(WesternHouseSystem.porphyry), returnsNormally);
  });

  test('active system title is explicit in both supported product languages', () {
    expect(
      WesternHouseSystemCatalog.visibleTitle(WesternHouseSystem.wholeSign, languageCode: 'tr'),
      'Whole Sign',
    );
    expect(
      WesternHouseSystemCatalog.visibleTitle(WesternHouseSystem.wholeSign, languageCode: 'en'),
      'Whole Sign',
    );
    expect(
      () => WesternHouseSystemCatalog.visibleTitle(WesternHouseSystem.placidus, languageCode: 'de'),
      throwsArgumentError,
    );
  });
}
