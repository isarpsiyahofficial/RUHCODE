import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

enum EclipseKind { solar, lunar }
enum EclipseContactKind { conjunction, opposition }

final class VerifiedEclipseEvent {
  const VerifiedEclipseEvent({
    required this.kind,
    required this.jdTt,
    required this.longitudeDegrees,
    required this.sourceId,
    required this.dataVersion,
  });

  final EclipseKind kind;
  final double jdTt;
  final double longitudeDegrees;
  final String sourceId;
  final String dataVersion;

  void validate() {
    if (!jdTt.isFinite) throw StateError('Eclipse TT instant must be finite.');
    if (!longitudeDegrees.isFinite || longitudeDegrees < 0 || longitudeDegrees >= 360) {
      throw RangeError('Eclipse longitude must be normalized to [0, 360).');
    }
    if (sourceId.trim().isEmpty || dataVersion.trim().isEmpty) {
      throw StateError('Eclipse provenance is required.');
    }
  }
}

final class EclipseNatalContact {
  const EclipseNatalContact({
    required this.eclipse,
    required this.natalBody,
    required this.contactKind,
    required this.separationDegrees,
    required this.orbDegrees,
  });

  final VerifiedEclipseEvent eclipse;
  final AstroBody natalBody;
  final EclipseContactKind contactKind;
  final double separationDegrees;
  final double orbDegrees;
}

final class EclipseOverlayResult {
  EclipseOverlayResult({
    required this.natalJdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<EclipseNatalContact> contacts,
  }) : contacts = List<EclipseNatalContact>.unmodifiable(contacts);

  final double natalJdTt;
  final String sourceId;
  final String dataVersion;
  final List<EclipseNatalContact> contacts;
}

/// Neutral calculation-layer eclipse overlay for later professional modules.
///
/// This class does not invent interpretive claims or eclipse dates. Callers must
/// supply verified, provenance-tagged eclipse events. It only computes explicit
/// conjunction/opposition contacts to natal planetary longitudes within a
/// caller-controlled orb.
abstract final class WesternEclipseOverlay {
  static EclipseOverlayResult calculate({
    required NatalPlacementSet natal,
    required Iterable<VerifiedEclipseEvent> eclipses,
    double maximumOrbDegrees = 3.0,
  }) {
    if (!maximumOrbDegrees.isFinite || maximumOrbDegrees <= 0 || maximumOrbDegrees > 30) {
      throw RangeError('Eclipse overlay orb must be finite and within (0, 30].');
    }
    if (natal.sourceId.trim().isEmpty || natal.dataVersion.trim().isEmpty) {
      throw StateError('Natal provenance is required for eclipse overlays.');
    }

    final events = eclipses.toList(growable: false);
    final contacts = <EclipseNatalContact>[];
    for (final eclipse in events) {
      eclipse.validate();
      if (eclipse.sourceId != natal.sourceId || eclipse.dataVersion != natal.dataVersion) {
        throw StateError('Eclipse and natal provenance must match.');
      }
      for (final placement in natal.placements) {
        final separation = _smallestSeparation(
          eclipse.longitudeDegrees,
          placement.longitudeDegrees,
        );
        final conjunctionOrb = separation;
        final oppositionOrb = (180.0 - separation).abs();
        if (conjunctionOrb <= maximumOrbDegrees) {
          contacts.add(
            EclipseNatalContact(
              eclipse: eclipse,
              natalBody: placement.body,
              contactKind: EclipseContactKind.conjunction,
              separationDegrees: separation,
              orbDegrees: conjunctionOrb,
            ),
          );
        } else if (oppositionOrb <= maximumOrbDegrees) {
          contacts.add(
            EclipseNatalContact(
              eclipse: eclipse,
              natalBody: placement.body,
              contactKind: EclipseContactKind.opposition,
              separationDegrees: separation,
              orbDegrees: oppositionOrb,
            ),
          );
        }
      }
    }

    contacts.sort((a, b) {
      final time = a.eclipse.jdTt.compareTo(b.eclipse.jdTt);
      if (time != 0) return time;
      final body = a.natalBody.index.compareTo(b.natalBody.index);
      if (body != 0) return body;
      return a.contactKind.index.compareTo(b.contactKind.index);
    });

    return EclipseOverlayResult(
      natalJdTt: natal.jdTt,
      sourceId: natal.sourceId,
      dataVersion: natal.dataVersion,
      contacts: contacts,
    );
  }

  static double _smallestSeparation(double a, double b) {
    var difference = (a - b).abs() % 360.0;
    if (difference > 180) difference = 360.0 - difference;
    return difference;
  }
}
