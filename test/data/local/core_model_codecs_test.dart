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
  EntityId id(String prefix) => EntityId.parse('$prefix-1234-4abc-8def-1234567890ab');

  test('profile round trip preserves birth data and unicode', () {
    final original = Profile(
      id: id('12345678'),
      displayName: 'İbrahim Yeşilyurt',
      birthData: birthData,
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restored = CoreModelCodecs.profileFromMap(CoreModelCodecs.profileToMap(original));
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
      id: id('22345678'),
      displayName: 'Saat Bilinmiyor',
      tags: const ['Batı', 'PRO'],
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restored = CoreModelCodecs.clientFromMap(CoreModelCodecs.clientToMap(original));
    expect(restored.birthData, isNull);
    expect(restored.tags, ['Batı', 'PRO']);
    expect(restored.displayName, original.displayName);
  });

  test('calculation manifest round trip preserves reproducibility fields', () {
    final original = CalculationManifest(
      id: id('32345678'),
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
    final clientId = id('42345678');
    final consultation = Consultation(
      id: id('52345678'),
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
      id: id('62345678'),
      ownerEntityId: consultation.id,
      text: 'Çok satırlı\nTürkçe danışmanlık notu ✨',
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredNote = CoreModelCodecs.noteFromMap(CoreModelCodecs.noteToMap(note));
    expect(restoredNote.ownerEntityId, consultation.id);
    expect(restoredNote.text, note.text);
  });

  test('journal, goal and habit round trips preserve profile relationships', () {
    final profileId = id('72345678');
    final journal = JournalEntry(
      id: id('82345678'),
      profileId: profileId,
      localDateIso: '2026-08-18',
      text: 'Bugün sakinim.',
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredJournal = CoreModelCodecs.journalEntryFromMap(
      CoreModelCodecs.journalEntryToMap(journal),
    );
    expect(restoredJournal.profileId, profileId);
    expect(restoredJournal.localDateIso, '2026-08-18');

    final goal = Goal(
      id: id('92345678'),
      profileId: profileId,
      title: 'Raporu tamamla',
      completed: true,
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredGoal = CoreModelCodecs.goalFromMap(CoreModelCodecs.goalToMap(goal));
    expect(restoredGoal.completed, isTrue);
    expect(restoredGoal.profileId, profileId);

    final habit = Habit(
      id: id('a2345678'),
      profileId: profileId,
      title: 'Günlük yaz',
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredHabit = CoreModelCodecs.habitFromMap(CoreModelCodecs.habitToMap(habit));
    expect(restoredHabit.title, 'Günlük yaz');
    expect(restoredHabit.profileId, profileId);
  });

  test('tarot and professional preset round trips preserve ordered values', () {
    final tarot = TarotSession(
      id: id('b2345678'),
      clientId: id('c2345678'),
      spreadId: 'three-card',
      cardIds: const ['star', 'moon', 'sun'],
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredTarot = CoreModelCodecs.tarotSessionFromMap(
      CoreModelCodecs.tarotSessionToMap(tarot),
    );
    expect(restoredTarot.cardIds, ['star', 'moon', 'sun']);
    expect(restoredTarot.spreadId, 'three-card');

    final preset = ProfessionalPreset(
      id: id('d2345678'),
      name: 'Danışmanlık',
      systemId: 'western',
      settings: const {'houseSystem': 'placidus', 'orbPreset': 'strict'},
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredPreset = CoreModelCodecs.professionalPresetFromMap(
      CoreModelCodecs.professionalPresetToMap(preset),
    );
    expect(restoredPreset.settings['houseSystem'], 'placidus');
  });

  test('interpretation entitlement and backup manifest round trips are locale safe', () {
    final template = InterpretationTemplate(
      id: id('e2345678'),
      systemId: 'western',
      ruleId: 'sun.taurus',
      localeTag: 'tr',
      text: 'İstikrar ve somutluk.',
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
    final restoredTemplate = CoreModelCodecs.interpretationTemplateFromMap(
      CoreModelCodecs.interpretationTemplateToMap(template),
    );
    expect(restoredTemplate.localeTag, 'tr');
    expect(restoredTemplate.text, template.text);

    final entitlement = FeatureEntitlement(
      featureId: 'pdf_professional',
      tier: EntitlementTier.temporary,
      validUntilUtc: updated,
    );
    final restoredEntitlement = CoreModelCodecs.featureEntitlementFromMap(
      CoreModelCodecs.featureEntitlementToMap(entitlement),
    );
    expect(restoredEntitlement.tier, EntitlementTier.temporary);
    expect(restoredEntitlement.validUntilUtc, updated);

    final backup = BackupManifest(
      schemaVersion: 1,
      appVersion: '0.1.0+1',
      engineVersion: 'core-1',
      exportedAtUtc: updated,
      localeTag: 'tr',
      recordCounts: const {'profiles': 1, 'notes': 2},
      checksums: const {'profiles.csv': 'abc', 'notes.csv': 'def'},
    );
    final restoredBackup = CoreModelCodecs.backupManifestFromMap(
      CoreModelCodecs.backupManifestToMap(backup),
    );
    expect(restoredBackup.schemaVersion, 1);
    expect(restoredBackup.recordCounts['notes'], 2);
    expect(restoredBackup.checksums['profiles.csv'], 'abc');
  });
}
