import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/csv_codec.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/backup/local_database_backup_import_store.dart';
import 'package:ruh_code/src/backup/single_table_csv_exporter.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_engine.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/numerology/numerology_core.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_astrology_engine.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/western_astrology_engine.dart';
import 'package:ruh_code/src/data/local/core_repositories.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

CalculationManifest _manifest({
  required String engineId,
  required String dataVersion,
  String? houseSystemId,
  String? zodiacSystemId,
  String? ayanamshaId,
}) {
  return CalculationManifest(
    id: EntityId.parse('123e4567-e89b-42d3-a456-426614174099'),
    engineId: engineId,
    engineVersion: '1.0.0',
    algorithmVersion: 'airplane-device-harness-v1',
    dataVersion: dataVersion,
    localDateTime: DateTime.utc(2026, 9, 11, 12),
    utcDateTime: DateTime.utc(2026, 9, 11, 12),
    location: const LocationRecord(
      label: 'Istanbul',
      countryCode: 'TR',
      latitude: 41.0082,
      longitude: 28.9784,
      ianaTimeZoneId: 'Europe/Istanbul',
    ),
    validity: CalculationValidity.valid,
    houseSystemId: houseSystemId,
    zodiacSystemId: zodiacSystemId,
    ayanamshaId: ayanamshaId,
  );
}

EclipticState _state({
  required AstroBody body,
  required double longitude,
  required String dataVersion,
}) {
  return EclipticState(
    body: body,
    jdTt: 2461295.0,
    longitudeDegrees: longitude,
    latitudeDegrees: 0,
    distanceAu: 1,
    longitudeSpeedDegreesPerDay: 1,
    sourceId: 'bundled-device-harness',
    dataVersion: dataVersion,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RC-1363..RC-1372 airplane-mode production device harness', () {
    testWidgets('RC-1363 Western chart production engine executes', (tester) async {
      const engine = WesternAstrologyEngine();
      final result = await engine.calculate(
        WesternAstrologyInput(
          manifest: _manifest(
            engineId: 'western-astrology',
            dataVersion: 'airplane-device-v1',
            houseSystemId: 'whole-sign',
            zodiacSystemId: 'tropical',
          ),
          states: <EclipticState>[
            _state(
              body: AstroBody.sun,
              longitude: 168.5,
              dataVersion: 'airplane-device-v1',
            ),
            _state(
              body: AstroBody.moon,
              longitude: 42.25,
              dataVersion: 'airplane-device-v1',
            ),
            _state(
              body: AstroBody.mercury,
              longitude: 181.75,
              dataVersion: 'airplane-device-v1',
            ),
          ],
          houses: EqualHouseSystems.wholeSign(ascendantLongitude: 95),
        ),
      );

      expect(result.manifest.engineId, 'western-astrology');
      expect(result.value.placements.placements, hasLength(3));
      expect(result.value.houses.cusps, hasLength(12));
    });

    testWidgets('RC-1364 Vedic production engine executes', (tester) async {
      const engine = VedicAstrologyEngine();
      final result = await engine.calculate(
        VedicAstrologyInput(
          manifest: _manifest(
            engineId: 'vedic-astrology',
            dataVersion: 'airplane-device-v1',
            zodiacSystemId: 'sidereal',
            ayanamshaId: 'lahiri-device-harness',
          ),
          states: <EclipticState>[
            _state(
              body: AstroBody.sun,
              longitude: 168.5,
              dataVersion: 'airplane-device-v1',
            ),
            _state(
              body: AstroBody.moon,
              longitude: 42.25,
              dataVersion: 'airplane-device-v1',
            ),
          ],
          ayanamshaDegrees: 24.2,
        ),
      );

      expect(result.manifest.engineId, 'vedic-astrology');
      expect(result.value.placements, hasLength(2));
      expect(result.value.ayanamshaDegrees, 24.2);
    });

    testWidgets('RC-1365 Numerology production core executes', (tester) async {
      const profile = NumerologyMethodProfile(
        id: 'pythagorean-core-v1',
        version: '1',
        sourceId: 'airplane-device-harness',
      );
      final birth = DateTime.utc(1990, 7, 28);
      final alphabet = NumerologyAlphabet.pythagorean(
        sourceId: 'airplane-device-harness',
      );
      final names = PythagoreanNumerologyCore.nameNumbers(
        fullName: 'Ada Lovelace',
        alphabet: alphabet,
        profile: profile,
      );

      expect(PythagoreanNumerologyCore.lifePath(birth, profile), 9);
      expect(names.expression, isPositive);
      expect(names.soulUrge, isPositive);
      expect(names.personality, isPositive);
    });

    testWidgets('RC-1366 BaZi production engine executes', (tester) async {
      const engine = BaZiEngine();
      final result = await engine.calculate(
        BaZiInput(
          manifest: _manifest(
            engineId: 'bazi',
            dataVersion: 'calendar-unbound',
          ),
          year: const BaZiPillarInput(stemIndex: 0, branchIndex: 4),
          month: const BaZiPillarInput(stemIndex: 2, branchIndex: 2),
          day: const BaZiPillarInput(stemIndex: 5, branchIndex: 7),
          hour: const BaZiPillarInput(stemIndex: 8, branchIndex: 10),
        ),
      );

      expect(result.manifest.engineId, 'bazi');
      expect(result.value.year.branchIndex, 4);
      expect(result.value.month.stemIndex, 2);
      expect(result.value.day.branchIndex, 7);
      expect(result.value.hour.stemIndex, 8);
    });

    testWidgets('RC-1367 Planetary Hours production core executes', (tester) async {
      final result = PlanetaryHours.forDate(
        date: CivilDate(2026, 9, 11),
        latitudeDegrees: 41.0082,
        longitudeDegrees: 28.9784,
      );

      expect(result.isAvailable, isTrue);
      expect(result.slots, hasLength(24));
      for (var i = 0; i < result.slots.length - 1; i++) {
        expect(result.slots[i].endUtc, result.slots[i + 1].startUtc);
      }
    });

    testWidgets(
      'RC-1368 RC-1370 RC-1371 RC-1372 local records CSV round-trip and professional client management execute',
      (tester) async {
        final temp = await Directory.systemTemp.createTemp('ruhcode-airplane-');
        final database = SqfliteLocalDatabase(
          databasePath: '${temp.path}/airplane-capabilities.db',
        );
        await database.open();
        try {
          final repositories = CoreRepositories(database);
          final now = DateTime.utc(2026, 9, 11, 12, 30);
          final client = Client(
            id: EntityId.parse('123e4567-e89b-42d3-a456-426614174121'),
            displayName: 'Airplane Client',
            createdAtUtc: now,
            updatedAtUtc: now,
            tags: const <String>['offline', 'professional'],
          );

          // RC-1368 + RC-1372: exercise the production sqflite-backed record
          // repository used by professional client management.
          await repositories.clients.save(client);
          final persisted = await repositories.clients.findById(client.id.value);
          expect(persisted, isNotNull);
          expect(persisted!.displayName, client.displayName);
          expect(persisted.tags, client.tags);
          expect((await database.integrityCheck()).ok, isTrue);

          // RC-1370: export the persisted production record through the
          // canonical single-table CSV exporter and schema.
          final databaseExporter = LocalDatabaseBackupExporter(database: database);
          final csvExporter = SingleTableCsvExporter(
            databaseExporter: databaseExporter,
          );
          final export = await csvExporter.export('clients.csv');
          expect(export.recordCount, 1);
          expect(export.bytes, isNotEmpty);

          const csvCodec = RuhCsvDocumentCodec();
          final document = csvCodec.decode(utf8.decode(export.bytes));
          final schema = BackupSchemaRegistry.table('clients.csv');
          expect(
            document.first,
            schema.columns.map((column) => column.name).toList(growable: false),
          );
          expect(document, hasLength(2));

          // RC-1371: prove the exported CSV row can be restored into the
          // production LocalDatabase through the production backup import
          // store while the device remains offline.
          await repositories.clients.deleteById(client.id.value);
          expect(await repositories.clients.findById(client.id.value), isNull);

          final importStore = LocalDatabaseBackupImportStore(
            database: database,
            snapshotDirectory: Directory('${temp.path}/snapshots'),
          );
          await importStore.transaction<void>((transaction) async {
            await transaction.replaceTable(
              'clients.csv',
              document.skip(1).toList(growable: false),
            );
          });

          final restored = await repositories.clients.findById(client.id.value);
          expect(restored, isNotNull);
          expect(restored!.displayName, client.displayName);
          expect(restored.tags, client.tags);
          expect((await database.integrityCheck()).ok, isTrue);
        } finally {
          await database.close();
          await temp.delete(recursive: true);
        }
      },
    );
  });
}
