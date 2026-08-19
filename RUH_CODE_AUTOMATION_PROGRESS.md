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
- [x] Porphyry house engine: ASC/IC/DSC/MC quadrant trisection, wrap, exact-cusp assignment, degenerate-input rejection.
- [x] Porphyry source/test/evidence/validator/CI contract.
- [x] Placidus implementation contract: semidiurnal/seminocturnal arc definition, max 100 iterations, convergence required, polar/invented-cusp prohibition, non-convergence=UNAVAILABLE, explicit optional Porphyry fallback, silent fallback forbidden.
- [ ] Placidus solver implementation henüz yok.
- [ ] Placidus independent golden proof henüz yok.

## Son tur — 2026-08-19 14:53

Checkpoint: `automation_runs/2026-08-19_1453_western_porphyry_placidus_contract.md`

Commit zinciri:
- Porphyry source `a925bb2b981a785f5444806070c8feabb12f0188`
- Porphyry tests `4151e6057b57235995c7c24fd484689a2a6d3419`
- Porphyry evidence `9e3b0d3d79002d07994e6d47d7c7e846583b3d6b`
- Porphyry validator `44c5589e1007f5aaf93671bdf1e2437fc98b5c88`
- Porphyry workflow `5d2ac858c413ae7bd60808aea67e472991628459`
- Placidus contract `ff758f0a1346d3f219853bfb58620a3942472ed6`
- Placidus validator `5b617f80475e24559264f20f7f64f80d5fa2c813`
- Placidus workflow `92dc24123c792552705485bfb7bf90a444d207a6`
- Run checkpoint `36a3779179013ac95847e61d967c420dddad4d8d`

GitHub combined-status latest checked exact commit için yine `statuses=[]` döndürdü. Bu nedenle workflow SUCCESS uydurulmadı; RC-0060 ve Placidus RC'leri DONE yapılmadı.

## Açık fiziksel/evidence blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] ASC/MC independent golden-reference kanıtı.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] GeoNames source ZIP/TXT exact SHA-256 + generated compact catalog SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal Günün Mesajı kaydı.
- [ ] Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI referans seti.

## Sıradaki çalışma

1. Exact workflow sonucu görünür kırmızı olursa aynı turda düzelt.
2. Placidus solver'ı strict result metadata ile uygula: success/unavailable/explicit Porphyry fallback.
3. Placidus convergence/high-latitude/polar boundary testlerini ekle.
4. ASC/MC + Placidus/Porphyry independent golden datasetlerini 0.05° acceptance budget ile bağla.
5. Fiziksel IERS EOP + offline ephemeris artifact zincirini ilerlet.
6. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
7. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
8. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
9. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Porphyry gerçek source-level motora, Placidus ise güvenli ve ölçülebilir implementation contract'ına ilerledi. Fiziksel ephemeris/EOP/Lahiri/GeoNames verileri, bağımsız accuracy kanıtları, exact CI sonuçları, gerçek Placidus solver, 8.036 editoryal mesaj, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement'lar DONE sayılmayacak.
