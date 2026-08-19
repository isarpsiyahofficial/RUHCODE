import '../ephemeris/ephemeris.dart';
import 'natal_aspects.dart';
import 'natal_placements.dart';

final class AspectGridCell {
  const AspectGridCell({
    required this.rowBody,
    required this.columnBody,
    required this.hit,
  });

  final AstroBody rowBody;
  final AstroBody columnBody;
  final NatalAspectHit? hit;

  bool get hasAspect => hit != null;
}

final class NatalAspectGrid {
  NatalAspectGrid({
    required List<AstroBody> bodies,
    required List<List<AspectGridCell>> rows,
  })  : bodies = List<AstroBody>.unmodifiable(bodies),
        rows = List<List<AspectGridCell>>.unmodifiable(
          rows.map(List<AspectGridCell>.unmodifiable),
        ) {
    if (this.rows.length != this.bodies.length ||
        this.rows.any((row) => row.length != this.bodies.length)) {
      throw StateError('Aspect grid must be square and match the body list.');
    }
  }

  final List<AstroBody> bodies;
  final List<List<AspectGridCell>> rows;

  AspectGridCell cell(AstroBody rowBody, AstroBody columnBody) {
    final row = bodies.indexOf(rowBody);
    final column = bodies.indexOf(columnBody);
    if (row < 0 || column < 0) {
      throw StateError('Requested body is not present in the aspect grid.');
    }
    return rows[row][column];
  }
}

abstract final class WesternAspectGrid {
  static NatalAspectGrid build({
    required NatalPlacementSet placements,
    required NatalAspectSet aspects,
  }) {
    if ((placements.jdTt - aspects.jdTt).abs() > 1e-12 ||
        placements.sourceId != aspects.sourceId ||
        placements.dataVersion != aspects.dataVersion) {
      throw StateError('Aspect grid inputs must share exact provenance.');
    }

    final bodies = placements.placements.map((item) => item.body).toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    final bodySet = bodies.toSet();
    if (bodySet.length != bodies.length) {
      throw StateError('Aspect grid cannot contain duplicate bodies.');
    }

    final hitsByPair = <String, NatalAspectHit>{};
    for (final hit in aspects.aspects) {
      if (!bodySet.contains(hit.bodyA) || !bodySet.contains(hit.bodyB)) {
        throw StateError('Aspect references a body absent from placements.');
      }
      final key = _pairKey(hit.bodyA, hit.bodyB);
      if (hitsByPair.containsKey(key)) {
        throw StateError('Multiple major aspects found for the same body pair.');
      }
      hitsByPair[key] = hit;
    }

    final rows = <List<AspectGridCell>>[];
    for (final rowBody in bodies) {
      final row = <AspectGridCell>[];
      for (final columnBody in bodies) {
        row.add(
          AspectGridCell(
            rowBody: rowBody,
            columnBody: columnBody,
            hit: rowBody == columnBody
                ? null
                : hitsByPair[_pairKey(rowBody, columnBody)],
          ),
        );
      }
      rows.add(row);
    }

    return NatalAspectGrid(bodies: bodies, rows: rows);
  }

  static String _pairKey(AstroBody a, AstroBody b) {
    final first = a.index <= b.index ? a : b;
    final second = a.index <= b.index ? b : a;
    return '${first.name}:${second.name}';
  }
}
