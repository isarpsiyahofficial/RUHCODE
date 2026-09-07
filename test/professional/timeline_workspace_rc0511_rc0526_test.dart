import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/timeline_workspace.dart';

void main() {
  test('timeline supports 30-day, 3-month and 1-year windows with sorting', () {
    final anchor = DateTime.utc(2026, 9, 8);
    final timeline = ProfessionalTimeline(anchorUtc: anchor, events: [
      TimelineEvent(id: 'e2', startsAtUtc: anchor.add(const Duration(days: 20)), importance: TimelineImportance.high, planet: TimelinePlanet.saturn, topics: const {TimelineTopic.career}, resultRef: 'r2', sourceId: 'astro', version: '1'),
      TimelineEvent(id: 'e1', startsAtUtc: anchor.add(const Duration(days: 5)), importance: TimelineImportance.medium, planet: TimelinePlanet.venus, topics: const {TimelineTopic.relationship}, resultRef: 'r1', sourceId: 'astro', version: '1'),
      TimelineEvent(id: 'e3', startsAtUtc: anchor.add(const Duration(days: 40)), importance: TimelineImportance.high, planet: TimelinePlanet.saturn, topics: const {TimelineTopic.general}, resultRef: 'r3', sourceId: 'astro', version: '1'),
    ]);
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next30Days)).map((e) => e.id), ['e1', 'e2']);
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next3Months)).length, 3);
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next1Year)).length, 3);
  });

  test('high importance, Saturn, relationship and career filters are independent', () {
    final anchor = DateTime.utc(2026, 9, 8);
    final timeline = ProfessionalTimeline(anchorUtc: anchor, events: [
      TimelineEvent(id: 's', startsAtUtc: anchor.add(const Duration(days: 2)), importance: TimelineImportance.high, planet: TimelinePlanet.saturn, topics: const {TimelineTopic.career}, resultRef: 's', sourceId: 'astro', version: '1'),
      TimelineEvent(id: 'v', startsAtUtc: anchor.add(const Duration(days: 3)), importance: TimelineImportance.high, planet: TimelinePlanet.venus, topics: const {TimelineTopic.relationship}, resultRef: 'v', sourceId: 'astro', version: '1'),
    ]);
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next30Days, highImportanceOnly: true)).length, 2);
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next30Days, planet: TimelinePlanet.saturn)).single.id, 's');
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next30Days, topic: TimelineTopic.relationship)).single.id, 'v');
    expect(timeline.apply(const TimelineFilter(window: TimelineWindow.next30Days, topic: TimelineTopic.career)).single.id, 's');
  });

  test('TR/EN timeline language explicitly rejects certain-event prediction framing', () {
    const policy = TimelineLanguagePolicy();
    expect(policy.disclaimer(locale: 'tr'), contains('kesin olay tahmini değildir'));
    expect(policy.disclaimer(locale: 'en'), contains('not certain event predictions'));
    expect(() => policy.disclaimer(locale: 'de'), throwsArgumentError);
  });

  test('custom preset library stores reusable relationship and career presets', () {
    final library = TimelinePresetLibrary([
      TimelineFilterPreset(id: 'rel', name: 'İlişki danışmanlığı', filter: const TimelineFilter(window: TimelineWindow.next3Months, topic: TimelineTopic.relationship)),
      TimelineFilterPreset(id: 'career', name: 'Kariyer danışmanlığı', filter: const TimelineFilter(window: TimelineWindow.next1Year, topic: TimelineTopic.career)),
      TimelineFilterPreset(id: 'annual', name: 'Yıllık danışmanlık', filter: const TimelineFilter(window: TimelineWindow.next1Year)),
    ]);
    expect(library.presets.map((e) => e.name), ['İlişki danışmanlığı', 'Kariyer danışmanlığı', 'Yıllık danışmanlık']);
  });
}
