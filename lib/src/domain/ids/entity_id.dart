import 'dart:math';

/// Locale-independent persistent identifier.
///
/// This implementation intentionally has no Flutter/platform dependency so the
/// domain layer can move to other clients later. Production persistence must
/// never derive IDs from user-visible names.
final class EntityId {
  EntityId._(this.value);

  final String value;

  factory EntityId.parse(String value) {
    final normalized = value.trim().toLowerCase();
    final valid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
    if (!valid.hasMatch(normalized)) {
      throw FormatException('Invalid UUID v4 identifier.');
    }
    return EntityId._(normalized);
  }

  factory EntityId.newV4([Random? random]) {
    final source = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => source.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final raw = bytes.map(hex).join();
    return EntityId._('${raw.substring(0, 8)}-${raw.substring(8, 12)}-${raw.substring(12, 16)}-${raw.substring(16, 20)}-${raw.substring(20)}');
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is EntityId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
