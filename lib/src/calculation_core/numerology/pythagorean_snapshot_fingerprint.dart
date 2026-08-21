import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'karmic_debt.dart';
import 'pythagorean_snapshot.dart';

/// Deterministic canonical identity for one Pythagorean numerology snapshot.
///
/// The digest can be shared by UI/PDF/cache layers to prove they are rendering
/// the same calculation result. It contains calculation data only; translated
/// labels and interpretation prose are deliberately excluded.
abstract final class PythagoreanSnapshotFingerprint {
  static const String schemaVersion = '1';

  static String sha256Hex(PythagoreanNumerologySnapshot snapshot) {
    final canonical = canonicalJson(snapshot);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static String canonicalJson(PythagoreanNumerologySnapshot snapshot) {
    final profile = snapshot.profile;
    final extended = snapshot.extendedName;
    final periods = snapshot.pinnaclesChallenges;
    final cycles = snapshot.personalCycles;

    final payload = <String, Object?>{
      'schemaVersion': schemaVersion,
      'engineId': PythagoreanNumerologySnapshotEngine.engineId,
      'engineVersion': PythagoreanNumerologySnapshotEngine.engineVersion,
      'birthDate': snapshot.birthDate.isoKey,
      'normalizedName': profile.normalizedName,
      'profilePolicy': profile.policy.name,
      'profile': <String, Object?>{
        'lifePath': profile.lifePath,
        'expression': profile.expression,
        'soulUrge': profile.soulUrge,
        'personality': profile.personality,
        'birthday': profile.birthday,
        'maturity': profile.maturity,
        'lifePathTrace': profile.lifePathTrace.steps,
        'expressionTrace': profile.expressionTrace.steps,
        'soulUrgeTrace': profile.soulUrgeTrace.steps,
        'personalityTrace': profile.personalityTrace.steps,
        'birthdayTrace': profile.birthdayTrace.steps,
        'maturityTrace': profile.maturityTrace.steps,
      },
      'extendedName': <String, Object?>{
        'balance': extended.balance,
        'karmicLessons': extended.karmicLessons,
        'hiddenPassions': extended.hiddenPassions,
        'valueFrequencies': <String, Object?>{
          for (var value = 1; value <= 9; value++)
            '$value': extended.valueFrequencies[value],
        },
      },
      'periods': <String, Object?>{
        'lifePath': periods.lifePath,
        'pinnacles': periods.pinnacles,
        'challenges': periods.challenges,
        'firstPeriodEndAgeInclusive': periods.firstPeriodEndAgeInclusive,
        'secondPeriodEndAgeInclusive': periods.secondPeriodEndAgeInclusive,
        'thirdPeriodEndAgeInclusive': periods.thirdPeriodEndAgeInclusive,
      },
      'profileKarmicDebt': _debt(snapshot.profileKarmicDebt),
      'targetDate': snapshot.targetDate?.isoKey,
      'cycles': cycles == null
          ? null
          : <String, Object?>{
              'policy': cycles.policy.name,
              'universalYear': cycles.universalYear,
              'personalYear': cycles.personalYear,
              'personalMonth': cycles.personalMonth,
              'personalDay': cycles.personalDay,
              'universalYearTrace': cycles.universalYearTrace.steps,
              'personalYearTrace': cycles.personalYearTrace.steps,
              'personalMonthTrace': cycles.personalMonthTrace.steps,
              'personalDayTrace': cycles.personalDayTrace.steps,
            },
      'cycleKarmicDebt': _debt(snapshot.cycleKarmicDebt),
    };

    return jsonEncode(payload);
  }

  static List<Map<String, Object?>> _debt(List<KarmicDebtFinding> findings) =>
      <Map<String, Object?>>[
        for (final item in findings)
          <String, Object?>{
            'metric': item.metric.name,
            'compoundValue': item.compoundValue,
            'reducedValue': item.reducedValue,
            'provenance': item.provenance,
          },
      ];
}
