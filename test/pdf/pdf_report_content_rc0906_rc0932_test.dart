import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/central_record_model.dart';
import 'package:ruh_code/src/pdf/pdf_report_content.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  BirthData birth({BirthTimePrecision precision = BirthTimePrecision.exact}) => BirthData(
        birthDate: DateTime(1991, 7, 14),
        timePrecision: precision,
        localBirthDateTime: precision == BirthTimePrecision.unknown ? null : DateTime(1991, 7, 14, 13, 45),
        birthPlace: BirthPlace(
          countryCode: 'TR',
          cityName: 'Antalya',
          displayText: 'Antalya, Türkiye',
          latitude: 36.8841,
          longitude: 30.7056,
          ianaTimezoneId: 'Europe/Istanbul',
        ),
      );

  CalculationManifestRecord manifest({String zodiac = 'tropical', String? ayanamsha}) => CalculationManifestRecord(
        engineVersion: 'engine-1',
        algorithmVersion: 'algo-1',
        dataVersion: 'data-1',
        timezoneDatabaseVersion: 'tzdb-2026a',
        houseSystem: 'Placidus',
        zodiacSystem: zodiac,
        ayanamsha: ayanamsha,
        nodeMode: 'true',
        latitude: 36.8841,
        longitude: 30.7056,
        utcDateTime: DateTime.utc(1991, 7, 14, 10, 45),
        localDateTimeIso: '1991-07-14T13:45:00+03:00',
        professionalSettings: const <String, String>{'orb': 'standard'},
      );

  test('subject exposes birth date, time, place and timezone without invention', () {
    final known = PdfSubjectReportData(displayName: 'Danışan', birthData: birth());
    expect(known.birthDateLabel('tr-TR'), '14.07.1991');
    expect(known.birthDateLabel('en-US'), '1991-07-14');
    expect(known.birthTimeLabel('tr-TR'), '13:45');
    expect(known.birthPlaceLabel, 'Antalya, Türkiye');
    expect(known.timezoneLabel, 'Europe/Istanbul');
    expect(known.coordinatesLabel(), '36.884100, 30.705600');

    final unknown = PdfSubjectReportData(
      displayName: 'Unknown time',
      birthData: birth(precision: BirthTimePrecision.unknown),
    );
    expect(unknown.birthTimeLabel('tr'), 'Bilinmiyor');
    expect(unknown.birthTimeLabel('en'), 'Unknown');
  });

  test('technical report exposes calculation system, house system and manifest summary', () {
    final subject = PdfSubjectReportData(
      displayName: 'Teknik Danışan',
      birthData: birth(),
      calculationManifest: manifest(),
    );
    const PdfReportContentGuard().validateSubject(
      subject: subject,
      detailLevel: PdfSubjectDetailLevel.technical,
    );
    final fields = subject.technicalSummary()!.asFields();
    expect(fields['zodiacSystem'], 'tropical');
    expect(fields['houseSystem'], 'Placidus');
    expect(fields['engineVersion'], 'engine-1');
    expect(fields['timezoneDatabaseVersion'], 'tzdb-2026a');
  });

  test('technical mode fails closed without calculation manifest', () {
    final subject = PdfSubjectReportData(displayName: 'Danışan', birthData: birth());
    expect(
      () => const PdfReportContentGuard().validateSubject(
        subject: subject,
        detailLevel: PdfSubjectDetailLevel.technical,
      ),
      throwsFormatException,
    );
  });

  test('sidereal technical report preserves ayanamsha', () {
    final subject = PdfSubjectReportData(
      displayName: 'Vedik Danışan',
      birthData: birth(),
      calculationManifest: manifest(zodiac: 'sidereal', ayanamsha: 'Lahiri'),
    );
    const PdfReportContentGuard().validateSubject(
      subject: subject,
      detailLevel: PdfSubjectDetailLevel.technical,
    );
    expect(subject.technicalSummary()!.asFields()['ayanamsha'], 'Lahiri');
  });

  test('professional can toggle and reorder non-empty sections; subject remains first content block', () {
    final composition = const PdfSectionCompositionPlanner().compose(
      preferences: <PdfSectionPreference>[
        PdfSectionPreference(id: PdfSectionIds.cover, enabled: true, order: 0),
        PdfSectionPreference(id: PdfSectionIds.subject, enabled: true, order: 9),
        PdfSectionPreference(id: PdfSectionIds.chart, enabled: true, order: 5),
        PdfSectionPreference(id: PdfSectionIds.placements, enabled: true, order: 4),
        PdfSectionPreference(id: PdfSectionIds.houses, enabled: true, order: 3),
        PdfSectionPreference(id: PdfSectionIds.aspects, enabled: true, order: 2),
        PdfSectionPreference(id: PdfSectionIds.transits, enabled: true, order: 1),
        PdfSectionPreference(id: PdfSectionIds.numerology, enabled: true, order: 6),
        PdfSectionPreference(id: PdfSectionIds.customNotes, enabled: true, order: 7),
        PdfSectionPreference(id: PdfSectionIds.preparedInterpretations, enabled: false, order: 8),
      ],
      contentAvailability: const <String, bool>{
        PdfSectionIds.cover: true,
        PdfSectionIds.subject: true,
        PdfSectionIds.chart: true,
        PdfSectionIds.placements: true,
        PdfSectionIds.houses: true,
        PdfSectionIds.aspects: true,
        PdfSectionIds.transits: false,
        PdfSectionIds.numerology: true,
        PdfSectionIds.customNotes: true,
        PdfSectionIds.preparedInterpretations: true,
      },
      detailLevel: PdfSubjectDetailLevel.clientFriendly,
    );
    expect(composition.sectionIds.first, PdfSectionIds.cover);
    expect(composition.sectionIds[1], PdfSectionIds.subject);
    expect(composition.sectionIds, isNot(contains(PdfSectionIds.transits)));
    expect(composition.sectionIds, isNot(contains(PdfSectionIds.preparedInterpretations)));
    expect(composition.sectionIds.indexOf(PdfSectionIds.aspects), lessThan(composition.sectionIds.indexOf(PdfSectionIds.houses)));
    expect(composition.previewSectionIds, composition.sectionIds);
  });

  test('client-friendly report hides technical manifest even when selected', () {
    final composition = const PdfSectionCompositionPlanner().compose(
      preferences: const <PdfSectionPreference>[
        PdfSectionPreference(id: PdfSectionIds.subject, enabled: true, order: 0),
        PdfSectionPreference(id: PdfSectionIds.chart, enabled: true, order: 1),
        PdfSectionPreference(id: PdfSectionIds.technicalManifest, enabled: true, order: 2),
      ],
      contentAvailability: const <String, bool>{
        PdfSectionIds.subject: true,
        PdfSectionIds.chart: true,
        PdfSectionIds.technicalManifest: true,
      },
      detailLevel: PdfSubjectDetailLevel.clientFriendly,
    );
    expect(composition.sectionIds, isNot(contains(PdfSectionIds.technicalManifest)));
  });

  test('empty report sections are not emitted and subject data cannot be omitted', () {
    expect(
      () => const PdfSectionCompositionPlanner().compose(
        preferences: const <PdfSectionPreference>[
          PdfSectionPreference(id: PdfSectionIds.subject, enabled: true, order: 0),
          PdfSectionPreference(id: PdfSectionIds.transits, enabled: true, order: 1),
        ],
        contentAvailability: const <String, bool>{
          PdfSectionIds.subject: true,
          PdfSectionIds.transits: false,
        },
        detailLevel: PdfSubjectDetailLevel.clientFriendly,
      ),
      throwsFormatException,
    );

    expect(
      () => const PdfSectionCompositionPlanner().compose(
        preferences: const <PdfSectionPreference>[
          PdfSectionPreference(id: PdfSectionIds.chart, enabled: true, order: 0),
        ],
        contentAvailability: const <String, bool>{
          PdfSectionIds.subject: false,
          PdfSectionIds.chart: true,
        },
        detailLevel: PdfSubjectDetailLevel.clientFriendly,
      ),
      throwsFormatException,
    );
  });
}
