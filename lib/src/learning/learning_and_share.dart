enum LearningTopic { planet, sign, house, aspect, combination }
enum TeachingLayer { houses, planets, aspects }
enum ShareCardKind { sky, personalDay, universalDay, spiritual }

final class LearningItem {
  LearningItem({required this.id, required this.topic, required this.title, required this.explanation, required this.sourceId, required this.version}) {
    if ([id, title, explanation, sourceId, version].any((v) => v.trim().isEmpty)) throw ArgumentError('learning fields required');
  }
  final String id;
  final LearningTopic topic;
  final String title;
  final String explanation;
  final String sourceId;
  final String version;
}

final class ChartLearningContext {
  ChartLearningContext({required this.resultRef, required Iterable<LearningItem> items}) : items = List.unmodifiable(items) {
    if (resultRef.trim().isEmpty) throw ArgumentError('resultRef required');
  }
  final String resultRef;
  final List<LearningItem> items;

  List<LearningItem> byTopic(LearningTopic topic) => List.unmodifiable(items.where((e) => e.topic == topic));
}

final class TeachingView {
  TeachingView({required this.resultRef, required Set<TeachingLayer> visibleLayers}) : visibleLayers = Set.unmodifiable(visibleLayers) {
    if (resultRef.trim().isEmpty) throw ArgumentError('resultRef required');
  }
  final String resultRef;
  final Set<TeachingLayer> visibleLayers;
  bool shows(TeachingLayer layer) => visibleLayers.contains(layer);
}

final class ShareDataPoint {
  ShareDataPoint({required this.key, required this.value, required this.calculationResultRef, required this.sourceId, required this.version}) {
    if ([key, value, calculationResultRef, sourceId, version].any((v) => v.trim().isEmpty)) throw ArgumentError('calculated share data required');
  }
  final String key;
  final String value;
  final String calculationResultRef;
  final String sourceId;
  final String version;
}

final class ShareCardDraft {
  ShareCardDraft({required this.kind, required Iterable<ShareDataPoint> data, this.professionalText}) : data = List.unmodifiable(data) {
    if (this.data.isEmpty) throw ArgumentError('share card requires calculated data');
    if (professionalText != null && professionalText!.trim().isEmpty) throw ArgumentError('professionalText cannot be blank');
  }
  final ShareCardKind kind;
  final List<ShareDataPoint> data;
  final String? professionalText;

  ShareCardDraft withProfessionalText(String text) => ShareCardDraft(kind: kind, data: data, professionalText: text);
}

final class DailyContentAssistant {
  const DailyContentAssistant();
  List<ShareDataPoint> suggestions(Iterable<ShareDataPoint> calculated) {
    final values = calculated.toList();
    if (values.isEmpty) throw StateError('verified calculated data required');
    return List.unmodifiable(values);
  }
}
