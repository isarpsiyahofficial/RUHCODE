import '../planetary_hours/planetary_hours.dart';
import 'daily_snapshot.dart';

final class PlanetaryHourDailyFactor {
  PlanetaryHourDailyFactor._();

  static const String engineId = 'planetary-hours';
  static const String engineVersion = '1.0.0';

  /// Resolves the planetary hour active at [utcInstant] for a DailySnapshot.
  ///
  /// The previous civil date is checked first because the classical planetary
  /// day starts at sunrise, not civil midnight. This prevents 00:00→sunrise
  /// from being mislabeled as the new weekday ruler.
  static DailyFactorReference? resolve({
    required DailySnapshotIdentity identity,
    required DateTime utcInstant,
  }) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected UTC.');
    }

    for (final date in <dynamic>[
      identity.civilDate.addDays(-1),
      identity.civilDate,
    ]) {
      final result = PlanetaryHours.forDate(
        date: date,
        latitudeDegrees: identity.latitude,
        longitudeDegrees: identity.longitude,
      );
      if (!result.isAvailable) continue;
      for (final slot in result.slots) {
        if (!_contains(slot, utcInstant)) continue;
        final ruler = slot.ruler.name;
        return DailyFactorReference(
          kind: DailyFactorKind.planetaryHour,
          sourceEngineId: engineId,
          sourceEngineVersion: engineVersion,
          resultId: [
            'ph',
            result.date.isoKey,
            slot.index.toString().padLeft(2, '0'),
            ruler,
            slot.startUtc.toIso8601String(),
            slot.endUtc.toIso8601String(),
          ].join('|'),
        );
      }
    }
    return null;
  }

  static bool _contains(PlanetaryHourSlot slot, DateTime utcInstant) =>
      !utcInstant.isBefore(slot.startUtc) && utcInstant.isBefore(slot.endUtc);
}
