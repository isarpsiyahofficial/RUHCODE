# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. Buradaki `source-level` kayıtları DONE anlamına gelmez; yalnız test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel 25.000+/6.400+ golden datasetler açık.
- Faz 2 bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`, SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3 structural UI reference/action/static-asset/dynamic-geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4 warm ivory/purple/gold design token/component sözleşmeleri mevcut.
- Faz 5 persistence source-level: Flutter package/entrypoint, domain/UUID, layer sınırları, SQLite adapter, schema-v1, migration/transaction/integrity ve repository temeli mevcut. Exact Flutter CI/device kanıtları açık.
- Faz 6 Gregorian calendar source-level: `CivilDate`, 1890–2110, leap-year/century, ISO weekday/date-key, DailyDateContext ve rollover testleri mevcut.
- Faz 7 timezone/city source-level: bundled IANA runtime, DST ambiguity/nonexistent policy, half/quarter-hour, UTC+14/date-line ve deterministic CityCatalog mevcut. GeoNames fiziksel source/output SHA ve bulk IANA integrity hâlâ açık.

## DailySnapshot — source-level

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour factor.
- [x] Moon Phase factor.
- [x] Tropical Moon Sign factor.
- [x] Pythagorean Personal Day factor.
- [x] Transit factor + natal-target major aspect matching.
- [x] Vedik günlük factor: sidereal Sun/Moon + Nakshatra + Pada + Tithi + Paksha.
- [ ] Fiziksel ephemeris/EOP ve independent accuracy kanıtları olmadan astronomik/Vedik faktörler DONE değil.

## Günün Mesajı

- [x] Exact `CivilDate + locale`, deterministic key, random fallback yok.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon sözleşmesi.
- [x] Runtime AI ve TR↔EN machine translation yasak.
- [x] Exact duplicate + near-duplicate + repetitive opening + unsafe-certainty kalite kapıları.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Gerçek 8.036 kayıt üzerinde final editoryal QA.
- [ ] Release-date rolling 10-year horizon kanıtı.

## Astronomik çekirdek / Western — source-level

- [x] Julian Day / MJD / J2000.
- [x] UTC/TAI/TT ayrımı ve leap-second coverage.
- [x] JD_UT1/JD_TT explicit sidereal-time input.
- [x] Versioned `EarthOrientationProvider`; UTC sessizce UT1 yerine kullanılmıyor.
- [x] Bundled EOP interpolation loader; coverage/checksum ve extrapolation yasağı.
- [x] Strict `EphemerisProvider`: TT coverage + provenance + checksum; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable.
- [x] 12 gündüz + 12 gece planetary-hours motoru.
- [x] Moon phase, Tropical Moon sign, transit-to-natal major aspects.
- [x] Transit applying/exact/separating/indeterminate sınıflandırması.
- [x] Hard astronomy acceptance budgets + validator + CI contract.
- [x] Independent astronomy golden dataset schema/runner/self-test/CI contract.
- [x] Offline ephemeris strategy JPL DE440/NAIF contract seviyesinde; fiziksel kernel henüz bundle edilmedi.
- [x] Whole Sign + Equal House deterministic cusp/house assignment.
- [x] ASC/MC strict geometry core + boundary tests + evidence/CI contract.
- [x] Western natal placements: Tropical sign, degree, house, motion + shared TT/provenance guards.
- [x] Natal major aspects + configurable orb.
- [x] Element/modality distribution + explicit weight policy.
- [x] Aspect grid: deterministic/symmetric/provenance guarded.
- [x] Classical essential dignities + canonical classical rulership API.
- [x] `WesternNatalChartAssembler`: placements + houses + aspects + aspectGrid + dignities.
- [x] Derived-data body-set integrity.
- [x] Porphyry house engine + test/evidence/validator/CI contract.
- [x] Placidus implementation contract + strict source-level solver + tests/evidence/validator/CI.
- [ ] Placidus independent golden proof henüz yok; 0.05° house-cusp budget kanıtlanmadı.
- [ ] Exact latest Flutter/GitHub Actions SUCCESS görünür değil; ilgili RC’ler DONE değil.

## Backup / CSV — source-level

- [x] Strict `RuhCsvValueCodec` + `RuhCsvDocumentCodec`.
- [x] CRLF records, comma/quote/newline escaping.
- [x] Unicode round-trip, null/empty/zero ayrımı ve locale-independent machine-number contract.
- [x] Versioned per-table CSV schema registry: 14 taşınabilir tablo, sabit kolon sırası, PK/FK/nullable/enum/date/datetime/decimal/JSON metadata.
- [x] Header, duplicate PK, enum/decimal/datetime/FK rejection testleri.
- [x] SHA-256 manifest builder: byte length + record count + deterministic ordering + tamper verification.
- [x] Strict manifest JSON parser + schema/app/engine/export-time/locale/file-entry validation.
- [x] `BackupPackageWriter`: `manifest.json` + 14 UTF-8 CSV member; boş tablo dahi header ile pakette.
- [x] `BackupPackageReader.preview`: manifest/schema-version → member set → SHA/byte length → strict UTF-8 → CSV count → schema → FK doğrulama sırası.
- [x] Import preview storage mutation yapmıyor; per-table ve total record count taşıyor.
- [x] `BackupImportCoordinator`: valid preview olmadan mutation yasak.
- [x] Merge transaction + primary-key upsert; aynı backup ikinci importta idempotent olacak şekilde testli.
- [x] Replace öncesi safety snapshot; transactional failure sonrası snapshot restore sözleşmesi/testi.
- [x] Package/import source-level evidence + structural validators + genişletilmiş `Backup CSV Contract` workflow.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Production SQLite `BackupImportStore` adapter.
- [ ] Durable safety snapshot implementation.
- [ ] ZIP/file adapter ile gerçek portable package bytes/device integration.
- [ ] TR↔EN, legacy schema, large-data ve clean-install round-trip proof.

## Son tur — 2026-08-19 22:53

Checkpoint: `automation_runs/2026-08-19_2253_backup_package_transaction.md`

Bu turda backup hattı logical package + validation preview + transactional import seviyesine taşındı. Manifest parser artık dışarıdan gelen JSON’u strict okuyor. Writer bütün registered tabloları UTF-8 CSV olarak paketliyor. Reader hiçbir storage mutation öncesi checksum/byte-length/record-count/schema/FK kontrollerini tamamlıyor. Merge PK-upsert ile idempotent; replace güvenlik snapshot’ı alıp hata halinde restore ediyor.

Son commit zinciri:
- `774131d680b247532c9be5a22042fa766f6b2106` strict manifest parser
- `4890aa8a1b520f5700903cb3be946d4ecc51852d` package writer/reader/preview
- `fc44c9df45c85dd3730083a6f5e9b116627b58cb` package tests correction
- `902b6ef7f09f73fd60549017c02670f4ad0d887c` package evidence
- `02fc8ac66c3c628e9f7acdefa909efbeae4a4bdd` package validator
- `93e88ffd0bf5ab757446add029ff4c1f2bdffe06` package CI wiring
- `e9da32525055a98c2956b988740ff9ee1868ba13` transactional import coordinator
- `7a58481896eb347a4028d167af9f3be0efdd5228` merge/replace/rollback/idempotency tests
- `ab0e47ed9de7e59b6eb1b2ba0f26058ec1f3a71a` import evidence
- `108263aff7b0a25fcd92839daae5d940446a826d` import validator
- `1356e9c8d3fce55ef99aff9054da0de69bbb26c2` transactional import CI wiring
- `cae2a8ff6c2050ca5aa2e2fc354bfb5140d220b9` run checkpoint

GitHub combined-status `1356e9c8...` için yine `statuses=[]` döndürdü; SUCCESS uydurulmadı.

## Açık fiziksel/evidence blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] ASC/MC + Placidus/Porphyry independent golden-reference kanıtı.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] GeoNames source ZIP/TXT exact SHA-256 + generated compact catalog SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal Günün Mesajı kaydı.
- [ ] Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI referans seti.

## Sıradaki çalışma

1. Exact workflow sonucu görünür kırmızı olursa aynı turda düzelt.
2. `BackupImportStore` için production SQLite adapter; transaction dışı mutation yasak.
3. Durable safety snapshot + restore; replace failure proof.
4. ZIP/file adapter ile gerçek portable package bytes.
5. TR→EN / EN→TR + legacy schema + large-data + clean-install export→erase→restore testleri.
6. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
7. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
8. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
9. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
10. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
11. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
