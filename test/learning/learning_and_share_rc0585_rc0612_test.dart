import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/learning/learning_and_share.dart';

void main() {
  test('Learning mode exposes planet sign house aspect and combination content', () {
    final context = ChartLearningContext(resultRef: 'chart:1', items: [
      LearningItem(id:'p', topic:LearningTopic.planet, title:'Venus', explanation:'planet', sourceId:'content', version:'1'),
      LearningItem(id:'s', topic:LearningTopic.sign, title:'Libra', explanation:'sign', sourceId:'content', version:'1'),
      LearningItem(id:'h', topic:LearningTopic.house, title:'7', explanation:'house', sourceId:'content', version:'1'),
      LearningItem(id:'a', topic:LearningTopic.aspect, title:'trine', explanation:'aspect', sourceId:'content', version:'1'),
      LearningItem(id:'c', topic:LearningTopic.combination, title:'combo', explanation:'combination', sourceId:'content', version:'1'),
    ]);
    expect(context.items.map((e) => e.topic).toSet().length, 5);
  });

  test('Teaching view can isolate houses planets and aspects', () {
    final view = TeachingView(resultRef:'chart:1', visibleLayers:{TeachingLayer.houses});
    expect(view.shows(TeachingLayer.houses), isTrue);
    expect(view.shows(TeachingLayer.planets), isFalse);
    expect(view.shows(TeachingLayer.aspects), isFalse);
  });

  test('Share cards require calculation-backed data and preserve professional text separately', () {
    final point = ShareDataPoint(key:'moonLongitude', value:'123.45', calculationResultRef:'calc:today', sourceId:'ephemeris', version:'1');
    final card = ShareCardDraft(kind:ShareCardKind.sky, data:[point]).withProfessionalText('My interpretation');
    expect(card.data.single.calculationResultRef, 'calc:today');
    expect(card.professionalText, 'My interpretation');
    expect(() => ShareCardDraft(kind:ShareCardKind.sky, data:const []), throwsArgumentError);
  });

  test('Numerology and spiritual card kinds are independent', () {
    final point = ShareDataPoint(key:'day', value:'7', calculationResultRef:'num:1', sourceId:'numerology', version:'1');
    expect(ShareCardDraft(kind:ShareCardKind.personalDay, data:[point]).kind, ShareCardKind.personalDay);
    expect(ShareCardDraft(kind:ShareCardKind.universalDay, data:[point]).kind, ShareCardKind.universalDay);
    expect(ShareCardDraft(kind:ShareCardKind.spiritual, data:[point]).kind, ShareCardKind.spiritual);
  });

  test('Daily content assistant does not invent data when calculation output is absent', () {
    expect(() => const DailyContentAssistant().suggestions(const []), throwsStateError);
  });
}
