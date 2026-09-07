import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/profile/profile_storage_contract.dart';
import 'package:ruh_code/src/domain/profile/birth_profile.dart';

void main() {
  StoredProfile record(String owner, String id, ProfileRelationship relationship) =>
      StoredProfile(
        ownerId: owner,
        profile: BirthProfile(
          id: id,
          displayName: id,
          birthDate: DateTime(1990, 1, 1),
          birthTime: BirthTimeValue.known(hour: 12, minute: 10),
        ),
        relationship: relationship,
        storageTier: ProfileStorageTier.localEncrypted,
        clientNotes: relationship == ProfileRelationship.client ? const ['private note'] : const [],
      );

  test('relationship model supports self partner family and client records', () {
    expect(ProfileRelationship.values.toSet(), {
      ProfileRelationship.self,
      ProfileRelationship.partner,
      ProfileRelationship.family,
      ProfileRelationship.client,
    });
  });

  test('multiple profiles remain scoped to an explicit owner', () {
    final records = [
      record('owner-a', 'self', ProfileRelationship.self),
      record('owner-a', 'partner', ProfileRelationship.partner),
      record('owner-a', 'client', ProfileRelationship.client),
    ];
    expect(records.map((r) => r.profile.id).toSet().length, 3);
    expect(
      () => ProfileIsolationPolicy.assertNoCrossOwnerNotes('owner-a', records),
      returnsNormally,
    );
  });

  test('cross-owner profile or client-note access fails closed', () {
    final client = record('owner-b', 'client-b', ProfileRelationship.client);
    expect(
      () => ProfileIsolationPolicy.assertOwnedBy('owner-a', client),
      throwsStateError,
    );
    expect(
      () => ProfileIsolationPolicy.assertNoCrossOwnerNotes('owner-a', [client]),
      throwsStateError,
    );
  });

  test('birth-bearing records are explicitly detectable as sensitive', () {
    expect(record('owner-a', 'self', ProfileRelationship.self).containsSensitiveBirthData, isTrue);
  });
}
