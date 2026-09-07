/// Explicit disclosure metadata for symbolic/traditional content.
///
/// Product UI decides when to render this notice, but content carrying this
/// metadata cannot masquerade as scientific or calculation-engine truth.
enum SymbolicContentNature { symbolic, traditional, reflective }

final class SymbolicContentDisclosure {
  SymbolicContentDisclosure({
    required this.contentId,
    required this.nature,
    required this.locale,
    required this.notice,
    required this.policyId,
    required this.version,
  }) {
    for (final value in [contentId, locale, notice, policyId, version]) {
      if (value.trim().isEmpty) throw ArgumentError('disclosure fields cannot be blank');
    }
  }

  final String contentId;
  final SymbolicContentNature nature;
  final String locale;
  final String notice;
  final String policyId;
  final String version;
}
