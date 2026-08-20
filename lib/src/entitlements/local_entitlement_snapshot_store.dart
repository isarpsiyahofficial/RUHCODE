import '../data/local/local_database.dart';
import 'entitlement_service.dart';

final class LocalEntitlementSnapshotStore implements EntitlementSnapshotProvider {
  const LocalEntitlementSnapshotStore(this.database);

  static const tableName = 'system_entitlement_state';
  static const recordId = 'current';

  final LocalDatabase database;

  @override
  Future<EntitlementSnapshot> load() async {
    final value = await database.transaction(
      (tx) => tx.get(table: tableName, id: recordId),
    );
    if (value == null) {
      return const EntitlementSnapshot(hasPro: false);
    }

    final hasPro = value['hasPro'];
    if (hasPro is! bool) {
      throw const FormatException('Stored entitlement hasPro must be boolean.');
    }
    final rawGrants = value['temporaryGrants'];
    if (rawGrants is! List) {
      throw const FormatException('Stored temporary grants must be a list.');
    }

    final grants = <TemporaryFeatureGrant>[];
    for (final item in rawGrants) {
      if (item is! Map) {
        throw const FormatException('Stored temporary grant must be an object.');
      }
      final featureId = item['featureId'];
      final validUntil = item['validUntilUtc'];
      if (featureId is! String || featureId.trim().isEmpty || validUntil is! String) {
        throw const FormatException('Stored temporary grant fields are invalid.');
      }
      final parsed = DateTime.tryParse(validUntil);
      if (parsed == null || !parsed.isUtc) {
        throw const FormatException('Stored temporary grant expiry must be UTC ISO-8601.');
      }
      grants.add(
        TemporaryFeatureGrant(featureId: featureId, validUntilUtc: parsed),
      );
    }

    return EntitlementSnapshot(
      hasPro: hasPro,
      temporaryGrants: List<TemporaryFeatureGrant>.unmodifiable(grants),
    );
  }

  Future<void> save(EntitlementSnapshot snapshot) async {
    final grants = <Map<String, Object?>>[];
    for (final grant in snapshot.temporaryGrants) {
      if (!grant.validUntilUtc.isUtc) {
        throw const FormatException('Temporary entitlement expiry must be UTC.');
      }
      grants.add(<String, Object?>{
        'featureId': grant.featureId,
        'validUntilUtc': grant.validUntilUtc.toIso8601String(),
      });
    }

    await database.transaction(
      (tx) => tx.put(
        table: tableName,
        id: recordId,
        value: <String, Object?>{
          'hasPro': snapshot.hasPro,
          'temporaryGrants': grants,
        },
      ),
    );
  }

  Future<void> clear() => database.transaction(
        (tx) => tx.delete(table: tableName, id: recordId),
      );
}
