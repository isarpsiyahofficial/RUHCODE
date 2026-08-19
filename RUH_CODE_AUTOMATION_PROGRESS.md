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
- [x] UTF-8-compatible Unicode string round-trip contract.
- [x] Null / empty string / zero ayrımı; `\\N` null sentinel + literal-backslash escaping.
- [x] Locale-independent machine-number contract.
- [x] Türkçe, Japonca, Arapça, emoji, embedded newline/quote/comma unit tests.
- [x] Versioned per-table CSV schema registry: 14 taşınabilir tablo, sabit kolon sırası ve primary-key metadata.
- [x] Nullable/enum/date/datetime/decimal/JSON column contracts.
- [x] Foreign-key metadata ve cross-table FK validator.
- [x] Header, duplicate PK, unknown enum, locale-formatted decimal, non-UTC datetime ve unresolved-FK rejection tests.
- [x] SHA-256 package-file manifest builder: byte length + record count + deterministic file ordering + tamper verification.
- [x] `crypto ^3.0.7` (`dart.dev`, BSD-3-Clause) dependency ile gerçek SHA-256 byte hashing.
- [x] Backup structural/evidence validator ve genişletilmiş `Backup CSV Contract` workflow.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Gerçek multi-file package writer/reader (`manifest.json` + UTF-8 CSV bytes).
- [ ] Import öncesi checksum + record-count + schema + FK preview zinciri.
- [ ] Transactional merge/replace + replace öncesi safety snapshot + failure rollback.
- [ ] Duplicate-ID/idempotent re-import policy.
- [ ] TR↔EN, legacy schema ve stress round-trip proof.

## Son tur — 2026-08-19 20:57

Checkpoint: `automation_runs/2026-08-19_2057_backup_schema_manifest.md`

Backup hattı tablo sözleşmesi ve gerçek SHA-256 manifest seviyesine taşındı. `profiles/clients/consultations/notes/calculations/calculation_manifests/journal/goals/habits/tarot/favorites/settings/professional_presets/interpretation_templates` için machine-readable schema registry oluştu. Import öncesi tip/enum/PK/FK doğrulama primitives'i eklendi. Manifest builder UTF-8 byte stream SHA-256, byte length ve record count üretip tamper doğruluyor.

Commit zincirinin son bölümü:
- `9c767ff2ab0fc51f332e8fc19adf12149b0510a4` schema registry
- `af1010b6e368f431e98b88ea7f344cbd886d0c9d` schema validator
- `edaf9e52247295d42c304b57cdb7f270ec810a91` schema tests
- `0f998c38895a2027f95fae95f77f4f8c0d9e5cfd` schema evidence
- `e6abbd54bb5a8d7abe76e94ae0d59404a109cd64` structural validator
- `f40dbf4e5f09a3f503c96b374c4a64078134a3e2` backup CI expansion
- `5413cd2ec7e1fba4b690ad46b74ce8b6ba3186fd` crypto dependency
- `30db4145d3f7d8039e2fd630a1be76e80eef024c` package manifest builder
- `87b84e57ff07c9b9266e5297f4882296d199d653` manifest tests
- `c5da46e9135313471ab1aa513448d80c7cdaf0ce` manifest evidence
- `a56f5d8b2a7cc423f53931c15cc3ed2bd43be639` run checkpoint

GitHub combined-status `c5da46e...` için `statuses=[]` döndürdü; SUCCESS uydurulmadı.

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
2. Backup package writer/reader: `manifest.json` + CSV byte files.
3. Import pipeline: checksum/count → schema → FK → preview; hiçbir validation geçmeden storage mutation yok.
4. Transactional merge/replace; replace öncesi safety snapshot; exception durumunda rollback.
5. Duplicate-ID policy + aynı backup'ın ikinci importunda idempotency.
6. TR→EN / EN→TR + legacy schema + large-data round-trip testleri.
7. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
8. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
9. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
10. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
11. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
12. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
