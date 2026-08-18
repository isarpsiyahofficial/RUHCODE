abstract interface class InterpretationEngine<TSnapshot> {
  String get interpretationVersion;

  Future<InterpretationBundle> interpret({
    required TSnapshot snapshot,
    required String localeTag,
  });
}

final class InterpretationBundle {
  const InterpretationBundle({
    required this.items,
    required this.sourceRuleIds,
  });

  final List<String> items;
  final List<String> sourceRuleIds;
}
