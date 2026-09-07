/// Professional-mode application primitives for RUH CODE.
///
/// Normal-user simplicity and professional functionality share one app, but
/// professional data/settings remain explicit and never silently affect simple mode.
enum ExperienceMode { simple, professional }
enum ProfessionalRole { astrologer, numerologist }
enum HouseSystem { wholeSign, placidus, equal, koch, regiomontanus }
enum NodeMethod { trueNode, meanNode }

final class ProfessionalAccessPolicy {
  const ProfessionalAccessPolicy({required this.mode, required this.isPro});
  final ExperienceMode mode;
  final bool isPro;

  bool get professionalToolsVisible => mode == ExperienceMode.professional && isPro;
  bool get simpleExperience => mode == ExperienceMode.simple;
}

final class BirthProfile {
  BirthProfile({required this.id, required this.displayName, required this.birthInstantUtc, required this.latitude, required this.longitude, required this.timeZoneId}) {
    _text(id, 'id'); _text(displayName, 'displayName'); _text(timeZoneId, 'timeZoneId');
    if (!birthInstantUtc.isUtc) throw ArgumentError('birthInstantUtc must be UTC');
    if (latitude < -90 || latitude > 90) throw ArgumentError('latitude must be -90..90');
    if (longitude < -180 || longitude > 180) throw ArgumentError('longitude must be -180..180');
  }
  final String id; final String displayName; final DateTime birthInstantUtc; final double latitude; final double longitude; final String timeZoneId;
}

final class ClientNote {
  ClientNote({required this.id, required this.body, required this.createdAtUtc}) { _text(id,'id'); _text(body,'body'); if (!createdAtUtc.isUtc) throw ArgumentError('createdAtUtc must be UTC'); }
  final String id; final String body; final DateTime createdAtUtc;
}

final class AnalysisRecord {
  AnalysisRecord({required this.id, required this.kind, required this.resultRef, required this.createdAtUtc}) { _text(id,'id'); _text(kind,'kind'); _text(resultRef,'resultRef'); if (!createdAtUtc.isUtc) throw ArgumentError('createdAtUtc must be UTC'); }
  final String id; final String kind; final String resultRef; final DateTime createdAtUtc;
}

final class TransitRecord {
  TransitRecord({required this.id, required this.targetInstantUtc, required this.resultRef}) { _text(id,'id'); _text(resultRef,'resultRef'); if (!targetInstantUtc.isUtc) throw ArgumentError('targetInstantUtc must be UTC'); }
  final String id; final DateTime targetInstantUtc; final String resultRef;
}

final class ProfessionalClient {
  ProfessionalClient({
    required this.id,
    required this.displayName,
    required Iterable<BirthProfile> profiles,
    required Iterable<ClientNote> notes,
    required Iterable<String> tags,
    required Iterable<AnalysisRecord> analyses,
    required Iterable<TransitRecord> transitHistory,
  }) : profiles=List.unmodifiable(profiles), notes=List.unmodifiable(notes), tags=List.unmodifiable(tags), analyses=List.unmodifiable(analyses), transitHistory=List.unmodifiable(transitHistory) {
    _text(id,'id'); _text(displayName,'displayName');
    _unique(this.profiles.map((e)=>e.id), 'profile'); _unique(this.notes.map((e)=>e.id), 'note'); _unique(this.analyses.map((e)=>e.id), 'analysis'); _unique(this.transitHistory.map((e)=>e.id), 'transit');
    final normalized=<String>{}; for (final tag in this.tags) { _text(tag,'tag'); if (!normalized.add(tag.trim().toLowerCase())) throw ArgumentError('duplicate client tag: $tag'); }
  }
  final String id; final String displayName; final List<BirthProfile> profiles; final List<ClientNote> notes; final List<String> tags; final List<AnalysisRecord> analyses; final List<TransitRecord> transitHistory;

  bool matches(String query) {
    final q=query.trim().toLowerCase(); if (q.isEmpty) return false;
    return displayName.toLowerCase().contains(q) || tags.any((e)=>e.toLowerCase().contains(q)) || profiles.any((e)=>e.displayName.toLowerCase().contains(q));
  }
}

final class ProfessionalCalculationSettings {
  ProfessionalCalculationSettings({required this.houseSystem, required this.aspectOrbDegrees, required this.ayanamshaId, required this.nodeMethod}) {
    if (aspectOrbDegrees <= 0 || aspectOrbDegrees > 15) throw ArgumentError('aspectOrbDegrees must be >0 and <=15');
    _text(ayanamshaId,'ayanamshaId');
  }
  final HouseSystem houseSystem; final double aspectOrbDegrees; final String ayanamshaId; final NodeMethod nodeMethod;
}

final class ProfessionalWorkspace {
  ProfessionalWorkspace({required this.role, required Iterable<ProfessionalClient> clients, required this.settings, required this.access}) : clients=List.unmodifiable(clients) {
    _unique(this.clients.map((e)=>e.id), 'client');
    if (!access.professionalToolsVisible) throw StateError('professional workspace requires PRO professional mode');
  }
  final ProfessionalRole role; final List<ProfessionalClient> clients; final ProfessionalCalculationSettings settings; final ProfessionalAccessPolicy access;

  List<ProfessionalClient> searchClients(String query) => List.unmodifiable(clients.where((e)=>e.matches(query)));
  BirthProfile profileById(String id) => clients.expand((e)=>e.profiles).firstWhere((e)=>e.id==id, orElse:()=>throw StateError('profile not found: $id'));
  ({BirthProfile left, BirthProfile right}) synastryPair(String leftId,String rightId) {
    if (leftId==rightId) throw ArgumentError('synastry requires two distinct profiles');
    return (left: profileById(leftId), right: profileById(rightId));
  }
}

/// Product surfaces can render these tables without recomputing astrology.
final class ProfessionalResultTables {
  ProfessionalResultTables({required Iterable<String> rawDegreeRows, required Iterable<String> aspectRows, required Iterable<String> transitTimelineRows}) : rawDegreeRows=List.unmodifiable(rawDegreeRows), aspectRows=List.unmodifiable(aspectRows), transitTimelineRows=List.unmodifiable(transitTimelineRows) {
    for (final row in [...this.rawDegreeRows,...this.aspectRows,...this.transitTimelineRows]) { _text(row,'table row'); }
  }
  final List<String> rawDegreeRows; final List<String> aspectRows; final List<String> transitTimelineRows;
}

void _text(String value,String field){ if(value.trim().isEmpty) throw ArgumentError('$field cannot be blank'); }
void _unique(Iterable<String> values,String kind){ final seen=<String>{}; for(final v in values){ _text(v,'$kind id'); if(!seen.add(v)) throw ArgumentError('duplicate $kind id: $v'); } }
