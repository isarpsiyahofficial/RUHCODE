import '../data/local/local_database.dart';
import 'entitlement_service.dart';

abstract interface class EntitlementWallClock {
  DateTime nowUtc();
}

final class SystemEntitlementWallClock implements EntitlementWallClock {
  const SystemEntitlementWallClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// Serverless rollback resistance for temporary entitlement expiry.
///
/// The effective time never moves behind the latest UTC instant previously
/// observed by this installation. This raises the cost of simple device-clock
/// rollback without claiming to be tamper-proof: clearing app data/reinstalling
/// can remove the local anchor, so purchase ownership must still be restored
/// from the platform store when available.
final class LocalRollbackResistantEntitlementClock implements EntitlementClock {
  const LocalRollbackResistantEntitlementClock({
    required this.database,
    this.wallClock = const SystemEntitlementWallClock(),
  });

  static const tableName = 'system_entitlement_time_anchor';
  static const recordId = 'latest_seen_utc';
  static const valueKey = 'latestSeenUtc';

  final LocalDatabase database;
  final EntitlementWallClock wallClock;

  @override
  Future<DateTime> nowUtc() async {
    final wallNow = wallClock.nowUtc();
    if (!wallNow.isUtc) {
      throw StateError('Entitlement wall clock must return UTC.');
    }

    return database.transaction((tx) async {
      final stored = await tx.get(table: tableName, id: recordId);
      DateTime? anchor;
      if (stored != null) {
        final raw = stored[valueKey];
        if (raw is! String) {
          throw const FormatException('Stored entitlement time anchor must be an ISO-8601 string.');
        }
        anchor = DateTime.tryParse(raw);
        if (anchor == null || !anchor.isUtc) {
          throw const FormatException('Stored entitlement time anchor must be UTC ISO-8601.');
        }
      }

      final DateTime effective;
      if (anchor == null) {
        effective = wallNow;
      } else {
        effective = wallNow.isAfter(anchor) ? wallNow : anchor;
      }
      if (anchor == null || effective.isAfter(anchor)) {
        await tx.put(
          table: tableName,
          id: recordId,
          value: <String, Object?>{valueKey: effective.toIso8601String()},
        );
      }
      return effective;
    });
  }
}
