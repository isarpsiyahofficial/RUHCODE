import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/core_model_codecs.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

void main() {
  final location = LocationRecord(
    label: 'Antalya, Türkiye',
    countryCode: 'TR',
    latitude: 36.8969,
    longitude: 30.7133,
    ianaTimeZoneId: 'Europe/Istanbul',
  );
  final birthData = BirthData(
    localDateIso: '2002-06-23',
    timeKnowledge: BirthTimeKnowledge.exact,
    localTime: '08:45:00',
    location: location,
  );
  final created = DateTime.utc(2026, 8, 18, 3, 0);
  final updated = DateTime.utc(2026, 8, 18, 4, 0);

  test('profile round trip preserves birth data and unicode', () {
    final original = Profile(
      id: EntityId.parse('12345678-1234-4abc-8def-1234567890ab'),
      displayName: 'İbrahim Yeşilyurt',
      birthData: birthData,
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restored = CoreModelCodecs.profileFromMap(
      CoreModelCodecs.profileToMap(original),
    );

    expect(restored.id, original.id);
    expect(restored.displayName, original.displayName);
    expect(restored.birthData.localDateIso, '2002-06-23');
    expect(restored.birthData.localTime, '08:45:00');
    expect(restored.birthData.timeKnowledge, BirthTimeKnowledge.exact);
    expect(restored.birthData.location.ianaTimeZoneId, 'Europe/Istanbul');
    expect(restored.createdAtUtc, created);
    expect(restored.updatedAtUtc, updated);
  });

  test('client round trip preserves null birth data and tags', () {
    final original = Client(
      id: EntityId.parse('22345678-1234-4abc-8def-1234567890ab'),
      displayName: 'Saat Bilinmiyor',
      tags: const ['Batı', 'PRO'],
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restored = CoreModelCodecs.clientFromMap(
      CoreModelCodecs.clientToMap(original),
    );

    expect(restored.birthData, isNull);
    expect(restored.tags, ['Batı', 'PRO']);
    expect(restored.displayName, original.displayName);
  });

  test('calculation manifest round trip preserves reproducibility fields', () {
    final original = CalculationManifest(
      id: EntityId.parse('32345678-1234-4abc-8def-1234567890ab'),
      engineId: 'western',
      engineVersion: '1.0.0',
      algorithmVersion: 'western-1',
      dataVersion: 'ephem-2026-01',
      timezoneDatabaseVersion: '2026c',
      localDateTime: DateTime(2002, 6, 23, 8, 45),
      utcDateTime: DateTime.utc(2002, 6, 23, 5, 45),
      location: location,
      validity: CalculationValidity.valid,
      houseSystemId: 'placidus',
      zodiacSystemId: 'tropical',
      nodeModeId: 'true-node',
    );
    final restored = CoreModelCodecs.calculationManifestFromMap(
      CoreModelCodecs.calculationManifestToMap(original),
    );

    expect(restored.id, original.id);
    expect(restored.engineId, 'western');
    expect(restored.timezoneDatabaseVersion, '2026c');
    expect(restored.houseSystemId, 'placidus');
    expect(restored.zodiacSystemId, 'tropical');
    expect(restored.validity, CalculationValidity.valid);
    expect(restored.utcDateTime, original.utcDateTime);
  });

  test('consultation and note round trips preserve relationships', () {
    final clientId = EntityId.parse('42345678-1234-4abc-8def-1234567890ab');
    final consultation = Consultation(
      id: EntityId.parse('52345678-1234-4abc-8def-1234567890ab'),
      clientId: clientId,
      startedAtUtc: created,
      endedAtUtc: updated,
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredConsultation = CoreModelCodecs.consultationFromMap(
      CoreModelCodecs.consultationToMap(consultation),
    );
    expect(restoredConsultation.clientId, clientId);
    expect(restoredConsultation.endedAtUtc, updated);

    final note = Note(
      id: EntityId.parse('62345678-1234-4abc-8def-1234567890ab'),
      ownerEntityId: consultation.id,
      text: 'Çok satırlı\nTürkçe danışmanlık notu ✨',
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredNote = CoreModelCodecs.noteFromMap(
      CoreModelCodecs.noteToMap(note),
    );
    expect(restoredNote.ownerEntityId, consultation.id);
    expect(restoredNote.text, note.text);
  });
}
