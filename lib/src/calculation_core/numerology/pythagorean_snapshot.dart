import '../time/civil_calendar.dart';
import 'karmic_debt.dart';
import 'personal_cycles.dart';
import 'personal_day.dart';
import 'pinnacles_challenges.dart';
import 'pythagorean_extended_name.dart';
import 'pythagorean_profile.dart';

/// One canonical Pythagorean calculation snapshot for a person and, when
/// requested, one exact target date.
///
/// UI, PDF and interpretation layers should consume this object rather than
/// independently recalculating individual numerology values. That prevents
/// policy/date drift and preserves exact reduction provenance for Karmic Debt.
final class PythagoreanNumerologySnapshot {
  const PythagoreanNumerologySnapshot({
    required this.profile,
    required this.extendedName,
    required this.pinnaclesChallenges,
    required this.profileKarmicDebt,
    this.personalCycles,
    this.cycleKarmicDebt = const <KarmicDebtFinding>[],
  });

  final PythagoreanProfileResult profile;
  final PythagoreanExtendedNameResult extendedName;
  final PythagoreanPinnacleChallengeResult pinnaclesChallenges;
  final List<KarmicDebtFinding> profileKarmicDebt;
  final PythagoreanPersonalCycleResult? personalCycles;
  final List<KarmicDebtFinding> cycleKarmicDebt;

  CivilDate get birthDate => profile.birthDate;
  PersonalCycleReductionPolicy get profilePolicy => profile.policy;

  /// The target date is intentionally absent when no date-dependent cycle was
  /// requested. Callers must not substitute the device's current date.
  CivilDate? get targetDate => personalCycles?.targetDate;
}

abstract final class PythagoreanNumerologySnapshotEngine {
  static const String engineId = 'numerology.pythagorean.snapshot';
  static const String engineVersion = '1';

  static PythagoreanNumerologySnapshot calculate({
    required CivilDate birthDate,
    required String fullName,
    CivilDate? targetDate,
    PersonalCycleReductionPolicy profilePolicy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
    PersonalCycleReductionPolicy cyclePolicy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    final profile = PythagoreanProfileEngine.calculate(
      birthDate: birthDate,
      fullName: fullName,
      policy: profilePolicy,
    );
    final extendedName = PythagoreanExtendedNameEngine.calculate(
      fullName: fullName,
      policy: profilePolicy,
    );
    final pinnaclesChallenges = PythagoreanPinnacleChallengeEngine.calculate(
      birthDate: birthDate,
      policy: profilePolicy,
    );

    _validateStaticConsistency(
      profile: profile,
      extendedName: extendedName,
      pinnaclesChallenges: pinnaclesChallenges,
    );

    final profileDebt = PythagoreanKarmicDebtEngine.detect(
      PythagoreanKarmicDebtEngine.observationsFromProfile(profile),
    );

    PythagoreanPersonalCycleResult? cycles;
    List<KarmicDebtFinding> cycleDebt = const <KarmicDebtFinding>[];
    if (targetDate != null) {
      cycles = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
        policy: cyclePolicy,
      );
      if (cycles.birthDate != birthDate || cycles.targetDate != targetDate) {
        throw StateError('Personal cycle engine returned mismatched dates.');
      }
      cycleDebt = PythagoreanKarmicDebtEngine.detect(
        PythagoreanKarmicDebtEngine.observationsFromPersonalCycles(cycles),
      );
    }

    return PythagoreanNumerologySnapshot(
      profile: profile,
      extendedName: extendedName,
      pinnaclesChallenges: pinnaclesChallenges,
      profileKarmicDebt: List<KarmicDebtFinding>.unmodifiable(profileDebt),
      personalCycles: cycles,
      cycleKarmicDebt: List<KarmicDebtFinding>.unmodifiable(cycleDebt),
    );
  }

  static void _validateStaticConsistency({
    required PythagoreanProfileResult profile,
    required PythagoreanExtendedNameResult extendedName,
    required PythagoreanPinnacleChallengeResult pinnaclesChallenges,
  }) {
    if (profile.normalizedName != extendedName.normalizedName) {
      throw StateError('Pythagorean name normalization drift detected.');
    }
    if (profile.birthDate != pinnaclesChallenges.birthDate) {
      throw StateError('Pinnacle/Challenge birth date drift detected.');
    }
    if (profile.policy != pinnaclesChallenges.policy) {
      throw StateError('Pythagorean profile reduction policy drift detected.');
    }
    if (profile.lifePath != pinnaclesChallenges.lifePath) {
      throw StateError('Life Path drift detected between Pythagorean engines.');
    }
  }
}
