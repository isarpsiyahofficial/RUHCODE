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
- [x] Placidus implementation contract: semidiurnal/seminocturnal definition, max 100 iterations, convergence mandatory, polar/invented-cusp prohibition, explicit Porphyry fallback only.
- [x] Placidus source-level solver: independent pole-height iteration, 11/12/2/3 cusp solve, angular/opposite cusp assembly, non-monotonic geometry rejection.
- [x] Placidus source-level tests: normal latitude, exact cusp assignment, polar unavailable, explicit Porphyry fallback metadata, invalid latitude.
- [x] Placidus evidence/validator/Flutter CI workflow source-level zinciri.
- [ ] Placidus independent golden proof henüz yok; 0.05° house-cusp budget kanıtlanmadı.
- [ ] Exact latest Flutter/GitHub Actions SUCCESS görünür değil; ilgili RC’ler DONE değil.

## Son tur — 2026-08-19 16:52

Checkpoint: `automation_runs/2026-08-19_1652_western_placidus_solver.md`

Bu turda Placidus ilk genel fixed-point taslağından çıkarılıp resmî Placidus tanımıyla uyumlu pole-height iterasyonuna göre bağımsız olarak yeniden yazıldı. Swiss Ephemeris reference olarak kullanılıyor; runtime dependency veya doğrudan kaynak kopyası yok. 100 iteration ceiling, domain/polar failure, explicit fallback metadata ve house-cycle invariants source seviyesinde zorunlu.

Commit zinciri:
- İlk strict solver `ed8f7cd6353f2c7ccacbdecf6b5cc0d385a6678a`
- Solver tests `7d1cb7273fb91b6abc605a06176f3b0f56c759f8`
- Evidence source-level `73716d339fbb05371257683f059eab7d2fee43b4`
- Structural validator `dde64670c9ec241a97030e2c7e69ff3e3160775f`
- Flutter CI gate `15c02933719085e7b575f2e785759026856f3a52`
- Dart hardening `5648eb059508e2dcb0ab2bce4298dc421cc3d7ea`
- Pole-height correction `131ac77a2689ec81e934871c838258ba1a41ccdc`
- Validator correction `e890edb92e9056ab452d85da17ce57c62197acb4`
- Run checkpoint `a5b4ee4a50731f887657fe833e09b917d90c2c86`

GitHub combined-status exact commit için individual checks göstermedi (`statuses=[]`). Bu nedenle workflow SUCCESS uydurulmadı; `RC-0054`, `RC-0265`, `RC-1436` ve ilişkili requirement’lar DONE yapılmadı.

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
2. ASC/MC + Placidus/Porphyry için gerçek independent golden house-cusp datasetlerini `house_cusp_deg` metric ile bağla ve 0.05° budget koş.
3. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance zincirini ilerlet.
4. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
5. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
6. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
7. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Placidus artık source-level gerçek solver seviyesinde; fakat independent accuracy/golden proof, exact CI görünürlüğü ve fiziksel EOP/ephemeris zinciri olmadan DONE kabul edilmiyor. Master requirement, içerik, UI, backup/PDF, security, offline ve release fazları tamamlanmadan proje FINAL olmayacak.
