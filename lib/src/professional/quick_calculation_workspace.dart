enum QuickCalculationKind { astrology, numerology }
enum ProfessionalNeed { normalUser, astrologer, vedicAstrologer, numerologist, spiritualConsultant, coach, student, contentCreator }

final class QuickBirthInput {
  QuickBirthInput({required this.localDateTime, required this.cityId, required this.timeZoneId}) {
    if ([cityId, timeZoneId].any((v) => v.trim().isEmpty)) throw ArgumentError('city/timezone required');
  }
  final DateTime localDateTime;
  final String cityId;
  final String timeZoneId;
}

final class QuickCalculationSettings {
  QuickCalculationSettings({required this.id, required this.version, required this.systemId, required this.parameters}) {
    if ([id, version, systemId].any((v) => v.trim().isEmpty)) throw ArgumentError('settings identity required');
  }
  final String id;
  final String version;
  final String systemId;
  final Map<String, String> parameters;
}

final class QuickCalculationResult {
  QuickCalculationResult({required this.id, required this.kind, required this.resultRef, required this.sourceId, required this.version}) {
    if ([id, resultRef, sourceId, version].any((v) => v.trim().isEmpty)) throw ArgumentError('calculation result provenance required');
  }
  final String id;
  final QuickCalculationKind kind;
  final String resultRef;
  final String sourceId;
  final String version;
}

final class QuickCalculationSession {
  QuickCalculationSession({required this.id, required this.settings, this.birthInput, this.freeFormNumerologyInput}) {
    if (id.trim().isEmpty) throw ArgumentError('session id required');
    final astrologyInput = birthInput != null;
    final numerologyInput = freeFormNumerologyInput != null && freeFormNumerologyInput!.trim().isNotEmpty;
    if (astrologyInput == numerologyInput) throw ArgumentError('exactly one quick input type required');
  }
  final String id;
  final QuickCalculationSettings settings;
  final QuickBirthInput? birthInput;
  final String? freeFormNumerologyInput;
  QuickCalculationResult? result;

  void attachVerifiedResult(QuickCalculationResult value) {
    final expected = birthInput != null ? QuickCalculationKind.astrology : QuickCalculationKind.numerology;
    if (value.kind != expected) throw StateError('result kind does not match quick input');
    result = value;
  }
}

final class ProfessionalRecentState {
  ProfessionalRecentState({this.maxCities = 5, this.maxSettings = 5}) {
    if (maxCities < 1 || maxSettings < 1) throw ArgumentError('recent-state limits must be positive');
  }
  final int maxCities;
  final int maxSettings;
  final List<String> _cities = [];
  final List<QuickCalculationSettings> _settings = [];
  List<String> get cities => List.unmodifiable(_cities);
  List<QuickCalculationSettings> get settings => List.unmodifiable(_settings);

  void rememberCity(String cityId) {
    if (cityId.trim().isEmpty) throw ArgumentError('city required');
    _cities.remove(cityId);
    _cities.insert(0, cityId);
    if (_cities.length > maxCities) _cities.removeRange(maxCities, _cities.length);
  }

  void rememberSettings(QuickCalculationSettings value) {
    _settings.removeWhere((e) => e.id == value.id);
    _settings.insert(0, value);
    if (_settings.length > maxSettings) _settings.removeRange(maxSettings, _settings.length);
  }
}

final class ProfessionalPreset {
  ProfessionalPreset({required this.id, required this.name, required this.settings}) {
    if (id.trim().isEmpty || name.trim().isEmpty) throw ArgumentError('preset identity required');
  }
  final String id;
  final String name;
  final QuickCalculationSettings settings;
}

final class QuickCalculationWorkspace {
  QuickCalculationWorkspace({required this.recentState});
  final ProfessionalRecentState recentState;
  final Map<String, ProfessionalPreset> _presets = {};
  final Map<String, QuickCalculationSession> _temporary = {};

  List<QuickCalculationSession> get temporarySessions => List.unmodifiable(_temporary.values);

  void addPreset(ProfessionalPreset preset) {
    if (_presets.containsKey(preset.id)) throw StateError('duplicate preset id');
    _presets[preset.id] = preset;
  }

  QuickCalculationSession startTemporary(QuickCalculationSession session) {
    if (_temporary.containsKey(session.id)) throw StateError('duplicate session id');
    _temporary[session.id] = session;
    if (session.birthInput != null) recentState.rememberCity(session.birthInput!.cityId);
    recentState.rememberSettings(session.settings);
    return session;
  }

  String saveAsClientProfile(String sessionId, String profileId) {
    final session = _temporary[sessionId];
    if (session == null || session.result == null) throw StateError('verified temporary result required');
    if (profileId.trim().isEmpty) throw ArgumentError('profile id required');
    return profileId;
  }
}

final class ProductUtilityContract {
  const ProductUtilityContract();
  String need(ProfessionalNeed role) => switch (role) {
    ProfessionalNeed.normalUser => 'Bugün benim için ne değişiyor?',
    ProfessionalNeed.astrologer => 'Müşterimi mümkün olan en hızlı ve doğru şekilde analiz et.',
    ProfessionalNeed.vedicAstrologer => 'Dasha, Gochara ve Vargaları aynı yerde getir.',
    ProfessionalNeed.numerologist => 'Müşterimin sayı ve dönem hesaplarını tekrar hesaplatma.',
    ProfessionalNeed.spiritualConsultant => 'Seanslarımı ve danışan geçmişimi kaybetme.',
    ProfessionalNeed.coach => 'Danışanımı, hedeflerini ve görüşme notlarımı bir yerde yönet.',
    ProfessionalNeed.student => 'Sonucu gösterirken nedenini de öğret.',
    ProfessionalNeed.contentCreator => 'Doğru günlük veriyi bul, düzenle ve paylaşılabilir hale getir.',
  };
  String get promise => 'Hesapla, yorumla, takip et, danışanlarını yönet ve günlük çalışmalarını tek yerde yürüt.';
}
