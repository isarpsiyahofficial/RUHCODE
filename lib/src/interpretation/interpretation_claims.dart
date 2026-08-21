enum InterpretationClaimPolarity {
  supportive,
  challenging,
  neutral,
}

enum InterpretationTopicState {
  aligned,
  mixed,
  neutralOnly,
}

final class InterpretationClaim {
  InterpretationClaim({
    required this.claimId,
    required this.topicId,
    required this.polarity,
    required this.text,
    required this.sourceFactorIds,
  }) {
    if (claimId.trim().isEmpty) {
      throw const FormatException('Interpretation claimId cannot be blank.');
    }
    if (topicId.trim().isEmpty) {
      throw const FormatException('Interpretation topicId cannot be blank.');
    }
    if (text.trim().isEmpty) {
      throw const FormatException('Interpretation claim text cannot be blank.');
    }
    if (sourceFactorIds.isEmpty ||
        sourceFactorIds.any((id) => id.trim().isEmpty)) {
      throw const FormatException(
        'Interpretation claims require non-empty source factor IDs.',
      );
    }
    if (sourceFactorIds.toSet().length != sourceFactorIds.length) {
      throw const FormatException(
        'Interpretation claim source factor IDs must be unique.',
      );
    }
  }

  final String claimId;
  final String topicId;
  final InterpretationClaimPolarity polarity;
  final String text;
  final List<String> sourceFactorIds;
}

final class InterpretationTopicGroup {
  const InterpretationTopicGroup({
    required this.topicId,
    required this.state,
    required this.claims,
  });

  final String topicId;
  final InterpretationTopicState state;
  final List<InterpretationClaim> claims;

  bool get hasConflictingFactors => state == InterpretationTopicState.mixed;
}

/// Groups interpretation claims without flattening conflicting factors into a
/// single fabricated conclusion.
///
/// A topic becomes `mixed` when at least one supportive and one challenging
/// claim are both present. All claims and their source factor IDs are retained
/// so the UI/PDF can present the factors separately, as required by RC-1077/78.
abstract final class InterpretationClaimAggregator {
  static List<InterpretationTopicGroup> group(
    Iterable<InterpretationClaim> claims,
  ) {
    final byTopic = <String, List<InterpretationClaim>>{};
    final seenClaimIds = <String>{};

    for (final claim in claims) {
      if (!seenClaimIds.add(claim.claimId)) {
        throw StateError('Duplicate interpretation claimId: ${claim.claimId}');
      }
      byTopic.putIfAbsent(claim.topicId, () => <InterpretationClaim>[]).add(claim);
    }

    final topicIds = byTopic.keys.toList()..sort();
    final groups = <InterpretationTopicGroup>[];
    for (final topicId in topicIds) {
      final topicClaims = List<InterpretationClaim>.of(byTopic[topicId]!)
        ..sort((a, b) => a.claimId.compareTo(b.claimId));
      final polarities = topicClaims.map((claim) => claim.polarity).toSet();
      final hasSupportive =
          polarities.contains(InterpretationClaimPolarity.supportive);
      final hasChallenging =
          polarities.contains(InterpretationClaimPolarity.challenging);

      final state = hasSupportive && hasChallenging
          ? InterpretationTopicState.mixed
          : (hasSupportive || hasChallenging)
              ? InterpretationTopicState.aligned
              : InterpretationTopicState.neutralOnly;

      groups.add(
        InterpretationTopicGroup(
          topicId: topicId,
          state: state,
          claims: List<InterpretationClaim>.unmodifiable(topicClaims),
        ),
      );
    }

    return List<InterpretationTopicGroup>.unmodifiable(groups);
  }
}
