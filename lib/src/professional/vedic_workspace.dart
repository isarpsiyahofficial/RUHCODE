enum VargaChart { d1, d9, d10 }

final class VedicPeriod {
  VedicPeriod({
    required this.id,
    required this.level,
    required this.lord,
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.sourceId,
    required this.version,
  }) {
    if ([id, lord, sourceId, version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('period id/lord/source/version required');
    }
    if (!startsAtUtc.isUtc || !endsAtUtc.isUtc || !endsAtUtc.isAfter(startsAtUtc)) {
      throw ArgumentError('valid UTC period range required');
    }
  }

  final String id;
  final String level; // dasha / antardasha
  final String lord;
  final DateTime startsAtUtc;
  final DateTime endsAtUtc;
  final String sourceId;
  final String version;
}

final class VedicGocharaHit {
  VedicGocharaHit({
    required this.id,
    required this.exactAtUtc,
    required this.resultRef,
    required this.sourceId,
    required this.version,
  }) {
    if ([id, resultRef, sourceId, version].any((v) => v.trim().isEmpty)) {
      throw ArgumentError('gochara id/result/source/version required');
    }
    if (!exactAtUtc.isUtc) throw ArgumentError('exactAtUtc must be UTC');
  }

  final String id;
  final DateTime exactAtUtc;
  final String resultRef;
  final String sourceId;
  final String version;
}

final class VedicProfessionalWorkspace {
  VedicProfessionalWorkspace({
    required Iterable<VedicPeriod> periods,
    required Iterable<VedicGocharaHit> gochara,
    required Map<VargaChart, String> chartResultRefs,
  })  : periods = List.unmodifiable(periods),
        gochara = List.unmodifiable(gochara),
        chartResultRefs = Map.unmodifiable(chartResultRefs) {
    if (!this.chartResultRefs.containsKey(VargaChart.d1)) {
      throw ArgumentError('D1 result required');
    }
    final ids = this.periods.map((e) => e.id).toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('duplicate Vedic period id');
  }

  final List<VedicPeriod> periods;
  final List<VedicGocharaHit> gochara;
  final Map<VargaChart, String> chartResultRefs;

  List<VedicPeriod> activeAt(DateTime utc) {
    if (!utc.isUtc) throw ArgumentError('UTC required');
    return List.unmodifiable(periods.where((p) => !utc.isBefore(p.startsAtUtc) && utc.isBefore(p.endsAtUtc)));
  }

  List<VedicPeriod> antardashaChanges() {
    final result = periods.where((p) => p.level == 'antardasha').toList()
      ..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));
    return List.unmodifiable(result);
  }

  List<Object> combinedTiming(DateTime fromUtc, DateTime toUtc) {
    if (!fromUtc.isUtc || !toUtc.isUtc || !toUtc.isAfter(fromUtc)) {
      throw ArgumentError('valid UTC range required');
    }
    final items = <Object>[
      ...periods.where((p) => p.endsAtUtc.isAfter(fromUtc) && p.startsAtUtc.isBefore(toUtc)),
      ...gochara.where((g) => !g.exactAtUtc.isBefore(fromUtc) && g.exactAtUtc.isBefore(toUtc)),
    ];
    return List.unmodifiable(items);
  }

  List<String> sideBySide(List<VargaChart> charts) {
    if (charts.length < 2 || charts.length > 3) {
      throw ArgumentError('two or three Varga charts required');
    }
    if (charts.toSet().length != charts.length) throw ArgumentError('duplicate Varga chart');
    final refs = charts.map((chart) => chartResultRefs[chart]).toList();
    if (refs.any((ref) => ref == null || ref!.trim().isEmpty)) {
      throw StateError('requested Varga result is unavailable');
    }
    return List.unmodifiable(refs.cast<String>());
  }
}
