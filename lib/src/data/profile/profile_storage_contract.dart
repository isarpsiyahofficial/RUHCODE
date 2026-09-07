import '../../domain/profile/birth_profile.dart';

enum ProfileRelationship { self, partner, family, client }

enum ProfileStorageTier { localEncrypted, cloudEncrypted }

/// User/tenant-scoped profile record. Birth data and professional notes are
/// explicitly marked sensitive and may never be addressed without ownerId.
final class StoredProfile {
  StoredProfile({
    required this.ownerId,
    required this.profile,
    required this.relationship,
    required this.storageTier,
    List<String> clientNotes = const [],
  }) : clientNotes = List.unmodifiable(clientNotes) {
    if (ownerId.trim().isEmpty) throw ArgumentError('ownerId');
    if (clientNotes.any((note) => note.trim().isEmpty)) {
      throw ArgumentError('client notes cannot be blank');
    }
  }

  final String ownerId;
  final BirthProfile profile;
  final ProfileRelationship relationship;
  final ProfileStorageTier storageTier;
  final List<String> clientNotes;

  bool get containsSensitiveBirthData =>
      profile.birthDate != null || profile.birthPlace != null || profile.birthTime.isKnown;
}

abstract interface class ProfileRepository {
  /// Implementations must encrypt sensitive payloads at rest and scope every
  /// query by ownerId. A global unscoped list API is intentionally absent.
  Future<void> save(StoredProfile profile);
  Future<List<StoredProfile>> listForOwner(String ownerId);
  Future<StoredProfile?> getForOwner(String ownerId, String profileId);
  Future<void> deleteForOwner(String ownerId, String profileId);
}

final class ProfileIsolationPolicy {
  const ProfileIsolationPolicy._();

  static void assertOwnedBy(String ownerId, StoredProfile profile) {
    if (ownerId.trim().isEmpty || profile.ownerId != ownerId) {
      throw StateError('cross-owner profile access blocked');
    }
  }

  static void assertNoCrossOwnerNotes(
    String ownerId,
    Iterable<StoredProfile> records,
  ) {
    for (final record in records) {
      assertOwnedBy(ownerId, record);
    }
  }
}
