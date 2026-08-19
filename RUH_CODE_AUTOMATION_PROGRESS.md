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
- [x] `evidence/backup/csv_contract.json` source-level evidence.
- [x] `tools/backup/validate_csv_contract.py` structural validator.
- [x] `Backup CSV Contract` GitHub Actions workflow.
- [ ] Exact workflow SUCCESS görünür değil; CSV RC'leri DONE değil.
- [ ] Per-table schema registry ve kolon sözleşmeleri.
- [ ] Manifest + record count + SHA-256.
- [ ] UTF-8 byte/package boundary.
- [ ] Transactional preview/import/merge/replace/rollback.
- [ ] TR↔EN, legacy schema ve stress round-trip proof.

## Son tur — 2026-08-19 18:56

Checkpoint: `automation_runs/2026-08-19_1856_backup_csv_codec.md`

CSV backup formatının en riskli temel kısmı gerçek source/test/evidence/CI sözleşmesine taşındı. Null ile empty string artık aynı hücreye indirgenmiyor; comma/quote/newline ve çok alfabeli Unicode içerik deterministic round-trip sözleşmesine sahip. Full backup paketi tamamlanmadığı için ilgili maddeler DONE yapılmadı.

Commit zinciri:
- CSV codec `87f88998da8daf0d84d9c7208bb4f3069823dbc4`
- CSV tests `23c281e5cc97d3cfe71564b6b2ef7f7b360f23c3`
- Evidence `a84e01ef39878b18457996c161a7fb99c504a199`
- Validator `c8d38d395d8ec1d05ca783fe3811fa0c3321efac`
- CI gate `84ac231f3492305628b07c50e6692f135040d4db`
- Run checkpoint `1d49cfb7f248da0620bf2ca336634df97723c0d1`

GitHub combined-status `84ac231f...` için yine `statuses=[]` döndürdü; SUCCESS uydurulmadı.

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
2. Backup per-table CSV schema registry + nullable/enum/date/FK contract.
3. Backup manifest + file SHA-256 + record counts + UTF-8 package boundary.
4. Transactional import preview + merge/replace + rollback.
5. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
6. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
7. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
8. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
9. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
10. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
