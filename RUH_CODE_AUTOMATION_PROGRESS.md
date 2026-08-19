# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. Buradaki `source-level` kayıtları DONE anlamına gelmez; yalnız test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Son doğrulanmış kapsam

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel 25.000+/6.400+ golden datasetleri açık.
- Faz 2: `Bugün · Araçlar · Kayıtlar · Profil`, SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3: structural UI reference/state tracking, action registry, static asset manifest ve dynamic geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4: warm ivory/purple/gold design token ve component sözleşmeleri mevcut.
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
- [x] Vedik günlük factor binding: sidereal Sun/Moon + Nakshatra + Pada + Tithi + Paksha.
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

## Faz 8 — astronomik çekirdek / Western ilerlemesi

### Uygulanmış / source-level
- [x] Julian Day / MJD / J2000.
- [x] UTC/TAI/TT ayrımı ve leap-second coverage.
- [x] JD_UT1/JD_TT explicit sidereal-time input.
- [x] Versioned `EarthOrientationProvider`; UTC sessizce UT1 yerine kullanılmıyor.
- [x] Bundled EOP interpolation loader; coverage/checksum ve extrapolation yasağı.
- [x] Strict `EphemerisProvider`: TT coverage + provenance + checksum; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable.
- [x] 12 gündüz + 12 gece planetary-hours motoru.
- [x] Moon phase, Tropical Moon sign, transit-to-natal major aspects.
- [x] Transit `applying / exact / separating / indeterminate` phase sınıflandırması.
- [x] Hard astronomy acceptance budgets + validator + CI contract.
- [x] Independent astronomy golden dataset schema/runner/self-test/CI contract.
- [x] Offline ephemeris stratejisi JPL DE440/NAIF yaklaşımıyla contract seviyesinde kilitli; fiziksel kernel henüz bundle edilmedi.
- [x] Western Whole Sign + Equal House deterministic cusp/house assignment.
- [x] Western ASC/MC strict geometry core + boundary tests + evidence/CI contract.
- [x] Western natal placements: Tropical sign, degree, house, motion + shared TT/provenance guards.
- [x] Western natal major aspects: conjunction/sextile/square/trine/opposition + configurable per-aspect orb.
- [x] Western natal element/modality distribution + explicit weight policy.
- [x] Western natal aspect grid: deterministic square matrix, empty diagonal, symmetric pair lookup, provenance/duplicate guards.
- [x] Classical Western essential dignities: domicile/exaltation/detriment/fall; overlapping statuses preserved; outer planets/nodes receive no invented classical status.
- [x] `WesternNatalChartAssembler`: placements + houses + aspects + aspectGrid + dignities tek natal snapshotta birleştiriliyor.
- [x] Aspect-grid ve dignity source/test/evidence/validator/CI contractları eklendi.

### Son Western commitleri

- Aspect grid: `3d6a0e9efa0d96540cdd183d1fc771d6c5601825`.
- Classical dignities: `ea8ee3a2a9879e07180f66c80f7dd19bc447dc3e`.
- Aspect-grid tests: `276dfbdc25923e4cf82713bd7733118aa8a79cf8`.
- Dignity test cleanup/overlap coverage: `46fffff63a2db607c165c9f76c81e47748ed1092`.
- Natal chart integration: `dede3f07e34fb07bf9bada29732482926d099211`.
- Aspect-grid evidence/validator/workflow: `b75cce5a...`, `ff53a1b3...`, `8b19d94b...`.
- Dignity evidence/validator/workflow: `10f22059...`, `e1b4a6f7...`, `c683256d...`.
- Ayrıntılı checkpoint: `automation_runs/2026-08-19_1054_western_aspect_grid_dignities.md`.

### Açık ana işler / DONE değil

- [ ] Latest exact commit üzerinde Flutter Quality ve bütün contract SUCCESS kanıtları.
- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] ASC/MC independent golden-reference kanıtı.
- [ ] Placidus ve kabul edilen diğer house sistemleri.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] Vedik varga/dasha motorları.

## City / GeoNames provenance

- [x] GeoNames source provider/dump endpoint ve CC BY 4.0 provenance sözleşmesi.
- [x] Minimal source set: `cities500.zip + admin1CodesASCII.txt + countryInfo.txt + readme.txt`.
- [x] Attribution ve release evidence gates tanımlı.
- [ ] Fiziksel source ZIP/TXT exact SHA-256.
- [ ] Generated compact catalog fiziksel artifact + SHA-256 + bulk IANA integrity.
- [ ] Büyük katalog performans kanıtı.

## UI reference durumu

- Önceki 9 UI PNG’si yasaklanan `Hesapla` alt menüsünü içerdiği için APPROVED değildir.
- Yeni `Bugün · Araçlar · Kayıtlar · Profil` referansları SCREEN-ID/hash manifestine bağlanmadan UI DONE yapılmayacak.

## CI görünürlüğü

Latest Western dignity workflow commit `c683256d6394769ce11951e132c962167744c6d0` için GitHub combined-status connector sonucu `statuses=[]` döndürdü. Bu nedenle CI SUCCESS uydurulmadı ve ilgili RC'ler DONE'a yükseltilmedi.

## Sıradaki çalışma

1. Western aspect-grid/dignity workflow sonuçlarında görünür kırmızı oluşursa aynı turda düzelt.
2. Natal chart derived-data snapshot bütünlüğünü testte genişlet; aspectGrid/dignity body setinin placement setiyle birebir eşleşmesini kanıtla.
3. Classical rulership query API'sini canonical dignity tablosundan türet; tabloyu ikinci kez duplicate etme.
4. Placidus algoritma/reference/tolerance sözleşmesini kesinleştir ve source/test contractını ilerlet; independent golden olmadan DONE deme.
5. Fiziksel/versioned IERS EOP + checksum/provenance zincirini bağla.
6. Ticari yeniden dağıtıma uygun offline ephemeris kernel/runtime ingest yolunu fiziksel artifact ile tamamla.
7. Gerçek GeoNames compact catalog + source/output SHA + timezone-ID toplu integrity testini tamamla.
8. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
9. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
10. Requirement state'e yalnız workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Western aspect-grid ve classical dignity katmanı source/test/evidence/CI contract seviyesinde ilerledi. Fiziksel ephemeris/EOP/Lahiri/GeoNames verileri, bağımsız accuracy kanıtları, exact CI sonuçları, gerçek 8.036 editoryal mesaj, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement'lar DONE sayılmayacak.
