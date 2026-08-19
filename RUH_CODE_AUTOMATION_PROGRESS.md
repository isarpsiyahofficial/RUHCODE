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

## Vedik günlük çekirdek — source-level

- [x] Tropical longitude − ayanamsha → normalized sidereal longitude.
- [x] 27 Nakshatra, 4 Pada, 30 Tithi ve Shukla/Krishna Paksha hesabı.
- [x] Ephemeris provenance ile ayanamsha provenance ayrılmış durumda.
- [x] `AyanamshaProvider` + `TabulatedAyanamshaProvider` eklendi.
- [x] Provider TT Julian Day kullanıyor; source/version/SHA-256 zorunlu.
- [x] Tablo örnekleri strictly increasing olmak zorunda.
- [x] Coverage dışına ayanamsha extrapolation yasak.
- [x] Vedic daily engine için `calculateWithProvider` production-yolu eklendi.
- [x] Provider interpolation/provenance/coverage ve Vedic binding testleri source-level mevcut.
- [x] `ayanamsha_runtime.json` evidence contract + structural validator + ayrı CI workflow mevcut.
- [ ] Fiziksel/versioned Lahiri/Chitrapaksha üretim datası ve exact SHA-256.
- [ ] Independent Lahiri reference golden suite.
- [ ] Fiziksel Sun/Moon ephemeris state'leriyle end-to-end Vedik daily golden doğrulaması.
- [ ] Exact Flutter/CI SUCCESS kanıtı.

## Günün Mesajı

- [x] Exact `CivilDate + locale`, deterministic key, random fallback yok.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon sözleşmesi.
- [x] Runtime AI ve TR↔EN machine translation yasak.
- [x] Exact duplicate quality gate.
- [x] Near-duplicate candidate engine: locale-isolated, informative-token candidate generation + SequenceMatcher threshold.
- [x] Repetitive opening yoğunluğu locale bazında denetleniyor.
- [x] TR/EN unsafe-certainty pattern review kapısı eklendi.
- [x] Near-duplicate, cross-locale isolation ve unsafe-certainty unit testleri mevcut.
- [x] Manifestte explicit editorial QA thresholds ve fail policies tanımlı.
- [x] Daily Message structural contract yeni QA kapılarını zorunlu kılıyor.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Gerçek 8.036 kayıt üzerinde near-duplicate/manual QA, artificial-pattern density ve unsafe-certainty final raporu.
- [ ] Release-date rolling 10-year horizon kanıtı.

## Faz 8 — astronomik çekirdek

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
- [x] Natal aspect 0/360 seam, inclusive orb boundary, invalid policy and deterministic pair tests.
- [x] `WesternNatalChartAssembler`: placements + houses + aspects tek provenance snapshotında birleştiriliyor.
- [x] Western natal aspect evidence manifest + structural validator + ayrı CI workflow.

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

## Son Western foundation commitleri

- Whole Sign / Equal House: `18072e32188369f349e262ce50ff254fd8ee8b51`.
- Western ASC/MC geometry: `2c09aad03f3b8774de9e6d59204c3bb2dbc815be`.
- Western natal placements: `6f1bc62bf03740791446de2faa1bba354be660c5`.
- Western natal aspect engine: `38ecbcca73c579a7d6c5c2386cd7c79caf4ae356`.
- Natal aspect tests: `74bda0ca42db1f5ff5c48e9f00fe9dd06c1ac4e6`.
- Natal chart assembler: `5daa6f6feaad830dfab5d54c06581ee1f633eb50`.
- Natal chart tests: `937b8f873ed2b3b513da8437c8cdcd2491f5788b`.
- Natal aspect evidence: `ea232595f75cb7a800960f9af09a2cb163dc3381`.
- Natal aspect structural validator: `f50cfd8be2f532f01ae950cf20ff6cec9bc62a97`.
- Natal aspect CI contract: `3b9239a05c89f5e5191fb5bba9e6ae4b05ca8db2`.

GitHub connector latest push için individual Actions sonuçlarını görünür şekilde döndürmedi; CI SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde Western Natal Aspects, Western Natal Placements, Western ASC/MC, DailySnapshot ve Flutter Quality sonuçlarını doğrula; görünür kırmızıları aynı turda düzelt.
2. Western natal chart için element/modality distribution + aspect grid gibi ephemeris bağımsız türetilmiş verileri source/test/contract ile ilerlet.
3. Fiziksel/versioned IERS EOP artifact + checksum/provenance zincirini bağla; sahte gelecek EOP üretme.
4. Ticari yeniden dağıtıma uygun offline ephemeris kernel/runtime ingest yolunu fiziksel artifact ile tamamla.
5. Gerçek GeoNames compact catalog + source/output SHA + timezone-ID toplu integrity testini tamamla.
6. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
7. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
8. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
9. Requirement state'e yalnız workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Western natal aspect/orb ve tek natal snapshot assembly source/test/contract seviyesinde eklendi. Fiziksel ephemeris/EOP/Lahiri/GeoNames verileri, bağımsız accuracy kanıtları, exact CI sonuçları, gerçek 8.036 editoryal mesaj, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement'lar DONE sayılmayacak.
