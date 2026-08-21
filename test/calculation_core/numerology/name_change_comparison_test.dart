import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/name_change_comparison.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  final birthDate = CivilDate(1990, 5, 19);

  test('compares only name-dependent metrics and preserves birth identity', () {
    final before = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'İbrahim Yeşilyurt',
    );
    final after = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'İbrahim Kaya',
    );

    final result = PythagoreanNameChangeComparisonEngine.compare(
      before: before,
      after: after,
    );

    expect(result.oldNormalizedName, 'IBRAHIMYESILYURT');
    expect(result.newNormalizedName, 'IBRAHIMKAYA');
    expect(result.unchangedBirthDateIdentity, '1990-05-19');
    expect(
      result.changes.map((item) => item.metric).toList(),
      <NumerologyNameMetric>[
        NumerologyNameMetric.expression,
        NumerologyNameMetric.soulUrge,
        NumerologyNameMetric.personality,
        NumerologyNameMetric.maturity,
      ],
    );
    expect(before.lifePath, after.lifePath);
    expect(before.birthday, after.birthday);
  });

  test('changed flag is transparent and no synthetic score is produced', () {
    final before = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Yılmaz',
    );
    final after = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Kaya',
    );

    final result = PythagoreanNameChangeComparisonEngine.compare(
      before: before,
      after: after,
    );

    expect(result.changedMetricCount, greaterThan(0));
    for (final change in result.changes) {
      expect(change.changed, change.before != change.after);
    }
  });

  test('rejects different birth dates', () {
    final before = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Yılmaz',
    );
    final after = PythagoreanProfileEngine.calculate(
      birthDate: CivilDate(1991, 5, 19),
      fullName: 'Ayşe Kaya',
    );

    expect(
      () => PythagoreanNameChangeComparisonEngine.compare(
        before: before,
        after: after,
      ),
      throwsArgumentError,
    );
  });

  test('rejects mixed reduction policies and identical normalized names', () {
    final before = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Yılmaz',
    );
    final mixedPolicy = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Kaya',
      policy: PersonalCycleReductionPolicy.singleDigit,
    );
    final sameName = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: 'Ayşe Yılmaz',
    );

    expect(
      () => PythagoreanNameChangeComparisonEngine.compare(
        before: before,
        after: mixedPolicy,
      ),
      throwsArgumentError,
    );
    expect(
      () => PythagoreanNameChangeComparisonEngine.compare(
        before: before,
        after: sameName,
      ),
      throwsArgumentError,
    );
  });
}
