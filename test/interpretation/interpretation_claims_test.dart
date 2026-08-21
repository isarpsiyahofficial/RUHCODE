import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/interpretation/interpretation_claims.dart';

void main() {
  test('mixed topic preserves supportive and challenging factors separately', () {
    final groups = InterpretationClaimAggregator.group(<InterpretationClaim>[
      InterpretationClaim(
        claimId: 'transit.jupiter.trine.sun',
        topicId: 'career.expansion',
        polarity: InterpretationClaimPolarity.supportive,
        text: 'Büyüme fırsatları desteklenebilir.',
        sourceFactorIds: const <String>['transit.jupiter.trine.sun'],
      ),
      InterpretationClaim(
        claimId: 'transit.saturn.square.mc',
        topicId: 'career.expansion',
        polarity: InterpretationClaimPolarity.challenging,
        text: 'Sorumluluk ve gecikme baskısı aynı anda artabilir.',
        sourceFactorIds: const <String>['transit.saturn.square.mc'],
      ),
    ]);

    expect(groups, hasLength(1));
    expect(groups.single.state, InterpretationTopicState.mixed);
    expect(groups.single.hasConflictingFactors, isTrue);
    expect(groups.single.claims, hasLength(2));
    expect(
      groups.single.claims.expand((claim) => claim.sourceFactorIds).toSet(),
      <String>{'transit.jupiter.trine.sun', 'transit.saturn.square.mc'},
    );
  });

  test('aligned and neutral-only topics remain distinct', () {
    final groups = InterpretationClaimAggregator.group(<InterpretationClaim>[
      InterpretationClaim(
        claimId: 'claim.a',
        topicId: 'a-topic',
        polarity: InterpretationClaimPolarity.supportive,
        text: 'Destekleyici faktör.',
        sourceFactorIds: const <String>['factor.a'],
      ),
      InterpretationClaim(
        claimId: 'claim.b',
        topicId: 'b-topic',
        polarity: InterpretationClaimPolarity.neutral,
        text: 'Nötr gözlem.',
        sourceFactorIds: const <String>['factor.b'],
      ),
    ]);

    expect(groups.map((group) => group.topicId).toList(), <String>['a-topic', 'b-topic']);
    expect(groups.first.state, InterpretationTopicState.aligned);
    expect(groups.last.state, InterpretationTopicState.neutralOnly);
  });

  test('aggregation is deterministic by topic and claim ID', () {
    final groups = InterpretationClaimAggregator.group(<InterpretationClaim>[
      InterpretationClaim(
        claimId: 'z-claim',
        topicId: 'topic-z',
        polarity: InterpretationClaimPolarity.neutral,
        text: 'Z.',
        sourceFactorIds: const <String>['factor.z'],
      ),
      InterpretationClaim(
        claimId: 'b-claim',
        topicId: 'topic-a',
        polarity: InterpretationClaimPolarity.supportive,
        text: 'B.',
        sourceFactorIds: const <String>['factor.b'],
      ),
      InterpretationClaim(
        claimId: 'a-claim',
        topicId: 'topic-a',
        polarity: InterpretationClaimPolarity.supportive,
        text: 'A.',
        sourceFactorIds: const <String>['factor.a'],
      ),
    ]);

    expect(groups.map((group) => group.topicId).toList(), <String>['topic-a', 'topic-z']);
    expect(
      groups.first.claims.map((claim) => claim.claimId).toList(),
      <String>['a-claim', 'b-claim'],
    );
  });

  test('invalid or duplicate claim provenance fails closed', () {
    expect(
      () => InterpretationClaim(
        claimId: 'claim.blank-source',
        topicId: 'topic',
        polarity: InterpretationClaimPolarity.neutral,
        text: 'Metin.',
        sourceFactorIds: const <String>[],
      ),
      throwsFormatException,
    );

    final duplicateA = InterpretationClaim(
      claimId: 'claim.duplicate',
      topicId: 'topic',
      polarity: InterpretationClaimPolarity.supportive,
      text: 'Birinci.',
      sourceFactorIds: const <String>['factor.1'],
    );
    final duplicateB = InterpretationClaim(
      claimId: 'claim.duplicate',
      topicId: 'topic',
      polarity: InterpretationClaimPolarity.challenging,
      text: 'İkinci.',
      sourceFactorIds: const <String>['factor.2'],
    );

    expect(
      () => InterpretationClaimAggregator.group(<InterpretationClaim>[
        duplicateA,
        duplicateB,
      ]),
      throwsStateError,
    );
  });
}
