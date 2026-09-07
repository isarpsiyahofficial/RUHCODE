import 'dart:math' as math;

enum ProductVisualTone { professionalModern, spiritualEditorial }

enum ChartDensity { phone, tablet, desktop }

final class ChartReadabilityPolicy {
  const ChartReadabilityPolicy({
    this.minimumLabelSeparationDegrees = 7.0,
    this.minimumPhoneDegreeFontSize = 12.0,
    this.minimumPlanetGlyphSize = 18.0,
    this.maximumAspectLinesPhone = 28,
    this.maximumAspectLinesTablet = 48,
    this.minimumZoom = 1.0,
    this.maximumZoom = 4.0,
  });

  final double minimumLabelSeparationDegrees;
  final double minimumPhoneDegreeFontSize;
  final double minimumPlanetGlyphSize;
  final int maximumAspectLinesPhone;
  final int maximumAspectLinesTablet;
  final double minimumZoom;
  final double maximumZoom;

  double clampZoom(double value) {
    if (!value.isFinite) throw ArgumentError('zoom must be finite');
    return value.clamp(minimumZoom, maximumZoom).toDouble();
  }

  int maxAspectLines(ChartDensity density) => switch (density) {
        ChartDensity.phone => maximumAspectLinesPhone,
        ChartDensity.tablet => maximumAspectLinesTablet,
        ChartDensity.desktop => 80,
      };
}

final class AngularLabel {
  const AngularLabel({required this.id, required this.longitude});
  final String id;
  final double longitude;
}

final class PositionedAngularLabel {
  const PositionedAngularLabel({
    required this.id,
    required this.originalLongitude,
    required this.displayLongitude,
  });
  final String id;
  final double originalLongitude;
  final double displayLongitude;
}

/// Deterministic circular label deconfliction. It changes only presentation
/// coordinates; the original astronomical longitude is always retained.
final class CircularLabelLayout {
  const CircularLabelLayout(this.policy);
  final ChartReadabilityPolicy policy;

  List<PositionedAngularLabel> position(Iterable<AngularLabel> labels) {
    final sorted = labels.toList()
      ..sort((a, b) => _norm(a.longitude).compareTo(_norm(b.longitude)));
    if (sorted.map((e) => e.id).toSet().length != sorted.length) {
      throw ArgumentError('duplicate chart label id');
    }
    final placed = <PositionedAngularLabel>[];
    double? previous;
    for (final item in sorted) {
      final original = _norm(item.longitude);
      var display = original;
      if (previous != null && display - previous < policy.minimumLabelSeparationDegrees) {
        display = previous + policy.minimumLabelSeparationDegrees;
      }
      placed.add(PositionedAngularLabel(
        id: item.id,
        originalLongitude: original,
        displayLongitude: display,
      ));
      previous = display;
    }
    return List.unmodifiable(placed);
  }

  static double _norm(double value) {
    if (!value.isFinite) throw ArgumentError('longitude must be finite');
    var v = value % 360.0;
    if (v < 0) v += 360.0;
    if ((v - 360).abs() < 1e-9) v = 0;
    return v;
  }
}

final class AspectVisual {
  const AspectVisual({
    required this.id,
    required this.orbDegrees,
    required this.priority,
  });
  final String id;
  final double orbDegrees;
  final int priority;
}

final class AspectLineReducer {
  const AspectLineReducer(this.policy);
  final ChartReadabilityPolicy policy;

  List<AspectVisual> forDensity(Iterable<AspectVisual> aspects, ChartDensity density) {
    final limit = policy.maxAspectLines(density);
    final sorted = aspects.toList()
      ..sort((a, b) {
        final p = b.priority.compareTo(a.priority);
        if (p != 0) return p;
        return a.orbDegrees.abs().compareTo(b.orbDegrees.abs());
      });
    return List.unmodifiable(sorted.take(math.min(limit, sorted.length)));
  }
}

abstract final class UiPlatformPolicy {
  static const primaryPlatform = 'android';
  static const renderingFramework = 'flutter';
  static const platformNeutralDomainLayer = true;
  static const productTone = ProductVisualTone.professionalModern;
  static const computationScreensPrioritizeReadability = true;
}
