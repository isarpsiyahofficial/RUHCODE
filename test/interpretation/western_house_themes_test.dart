import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/interpretation/western_house_themes.dart';

void main() {
  test('contains exactly twelve separately addressable bilingual house themes', () {
    expect(WesternHouseThemes.all, hasLength(12));
    for (var house = 1; house <= 12; house++) {
      final theme = WesternHouseThemes.forHouse(house);
      expect(theme.houseNumber, house);
      expect(theme.titleTr.trim(), isNotEmpty);
      expect(theme.titleEn.trim(), isNotEmpty);
      expect(theme.descriptionTr.trim(), isNotEmpty);
      expect(theme.descriptionEn.trim(), isNotEmpty);
    }
    expect(WesternHouseThemes.forHouse(1).titleEn, 'Self and approach');
    expect(WesternHouseThemes.forHouse(12).titleTr, 'İç dünya ve geri çekilme');
  });

  test('rejects house numbers outside one through twelve', () {
    expect(() => WesternHouseThemes.forHouse(0), throwsRangeError);
    expect(() => WesternHouseThemes.forHouse(13), throwsRangeError);
  });
}
