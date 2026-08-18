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
- Faz 7 timezone/city source-level: bundled IANA runtime, DST ambiguity/nonexistent policy, half/quarter-hour, UTC+14/date-line ve deterministic CityCatalog mevcut. GeoNames CC BY 4.0 source/license provenance ve attribution/release evidence sözleşmesi güçlendirildi; fiziksel GeoNames source artifact SHA'ları ve generated compact catalog hâlâ açık.

## DailySnapshot — source-level

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour factor.
- [x] Moon Phase factor.
- [x] Tropical Moon Sign factor.
- [x] Pythagorean Personal Day factor.
- [x] Transit factor + natal-target major aspect matching.
- [x] Vedik günlük factor binding: sidereal Sun/Moon + Nakshatra + Pada + Tithi + Paksha tek `vedicIndicator` faktörüne deterministik bağlanıyor.
- [ ] Fiziksel ephemeris/EOP ve independent accuracy kanıtları olmadan astronomik/Vedik faktörler DONE değil.

## Vedik günlük çekirdek — source-level

- [x] Tropical longitude − explicit ayanamsha → normalized sidereal longitude.
- [x] 27 Nakshatra ve 4 Pada deterministic boundary hesabı.
- [x] 30 Tithi; 12° elongation segmenti.
- [x] Shukla 1..15 / Krishna 16..30 paksha sözleşmesi.
- [x] Ephemeris provenance ile ayanamsha provenance birbirinden ayrı tutuluyor.
- [x] Empty provenance ve non-finite input reddediliyor.
- [x] 0° / Nakshatra boundary / 359.999999° / Paksha boundary test vakaları source-level mevcut.
- [x] `DailyFactorKind.vedicIndicator` adapter mevcut.
- [x] Vedic Daily manifest + structural validator + ayrı CI workflow mevcut.
- [ ] Production Lahiri/Chitrapaksha ayanamsha motoru ve independent reference kanıtı.
- [ ] Fiziksel Sun/Moon ephemeris state'leriyle end-to-end Vedic daily golden doğrulaması.
- [ ] Exact Flutter/CI SUCCESS kanıtı.

## Günün Mesajı

- [x] Exact `CivilDate + locale`, deterministic key, random fallback yok.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon sözleşmesi.
- [x] Runtime AI ve TR↔EN machine translation yasak.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Near-duplicate/manual QA, artificial-pattern density, unsafe-certainty review ve release-horizon kanıtı.

## Faz 8 — astronomik çekirdek

### Uygulanmış / source-level
- [x] Julian Day / MJD / J2000.
- [x] UTC/TAI/TT ayrımı ve leap-second coverage.
- [x] JD_UT1/JD_TT explicit sidereal-time input.
- [x] Versioned `EarthOrientationProvider`; UTC sessizce UT1 yerine kullanılmıyor.
- [x] Bundled EOP interpolation loader sözleşmesi; coverage/checksum ve extrapolation yasağı source-level mevcut.
- [x] Strict `EphemerisProvider`: Sun/Moon/planets/nodes, TT coverage + provenance + checksum; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable.
- [x] 12 gündüz + 12 gece planetary-hours motoru.
- [x] Moon phase engine.
- [x] Tropical Moon sign engine.
- [x] Transit-to-natal major aspect motoru.
- [x] Transit aspect `applying / exact / separating / indeterminate` phase sınıflandırması ephemeris longitude speed üzerinden eklendi; direct, retrograde, stationary ve exact test vakaları source-level mevcut.
- [x] Astronomi için hard acceptance-budget manifesti: Sun 0.01°, Moon/planet/node 0.02°, ASC/MC/house cusp 0.05°, sunrise/sunset ve planetary-hour boundary 60 s hedefleri. Bu değerler yalnız acceptance target; `proven=false` ve bağımsız fiziksel kanıt gelmeden DONE yasak.
- [x] Accuracy-budget validator + bağımsız CI workflow.
- [x] Independent astronomy golden dataset schema + runner + self-test + CI contract.
- [x] Offline ephemeris strategy: JPL DE440/NAIF yaklaşımı dokümante ve runtime provenance manifest/validator/CI contract ile kilitli; fiziksel kernel henüz bundle edilmedi.

### Açık ana işler / DONE değil
- [ ] Latest exact commit üzerinde Flutter Quality ve bütün astronomy/numerology/Vedic contract SUCCESS kanıtları.
- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget manifestindeki bütün limitleri bağımsız golden data ile kanıtlama.
- [ ] ASC/MC/house sistemleri ve boundary testleri.
- [ ] Production Lahiri/Chitrapaksha ayanamsha.
- [ ] Vedik varga/dasha motorları.

## Gezegen Saatleri

- [x] Chaldean order + gerçek weekday ruler.
- [x] Sunrise→sunset 12; sunset→next sunrise 12 eşit parça.
- [x] Polar fake sonuç yerine unavailable.
- [x] DailySnapshot entegrasyonu.
- [ ] AKİLES 6.400+ physical golden dataset, global cross-check, local UI/notification ve exact workflow SUCCESS açık.

## City / GeoNames provenance

- [x] GeoNames source provider ve dump endpoint seçildi.
- [x] Resmi dump readme üzerinde CC BY 4.0 lisans ve UTF-8/tab-delimited format doğrulandı.
- [x] `cities500.zip + admin1CodesASCII.txt + countryInfo.txt + readme.txt` minimal source seti manifestte kilitli.
- [x] `alternateNamesV2.zip` optional enrichment; runtime bağımlılığı değil.
- [x] Attribution metni ve commercial-use flag manifestte.
- [x] Release evidence gates: source SHA-256, generated catalog SHA-256, record count, unique IDs, valid IANA IDs, bundled attribution, source snapshot date.
- [x] Web listing gözleminin fiziksel artifact evidence sayılamayacağı açıkça kilitli.
- [ ] Fiziksel source ZIP/TXT dosyalarının exact SHA-256 kaydı.
- [ ] Generated compact catalog fiziksel artifact + SHA-256 + bulk IANA integrity.
- [ ] Büyük katalog performans kanıtı.

## UI reference durumu

- Önceki 9 UI PNG’si yasaklanan `Hesapla` alt menüsünü içerdiği için APPROVED değildir.
- Yeni `Bugün · Araçlar · Kayıtlar · Profil` referansları SCREEN-ID/hash manifestine bağlanmadan UI DONE yapılmayacak.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti automation workspace/repo içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri.
- [ ] 25.000+ Vedik ve 6.400+ planetary-hour fiziksel golden dataset.

## Bu turdaki commitler

- Vedic daily core: `b6bf7ce6a8fd1b39154969129a84f40a24d8c0e9`.
- DailySnapshot Vedic adapter: `5bc5944faeeef37cd066f4e0400e347a39fc5154`.
- Vedic boundary tests: `778e7e5413bae885a6734b5012338a40c9c4123d`.
- Vedic factor test: `839046cb9c714459e36aac189722ebb6a31f84a4`.
- Vedic runtime manifest: `62c22fd73cc5a4f346dbe231b224ea20ff5d3f9b`.
- Vedic structural validator: `3e53a3e87be3d11849f5faebeb489f98ad9f066e`.
- Vedic CI contract: `263a3f77ff3a0599d4ea85c4db4d0ddf3879da64`.
- GeoNames provenance manifest hardening: `83e5d0fbdbac4396371a5e8f9e3a4a810c662bf8`.
- City provenance validator hardening: `a845460f1ccd8ad3836ad400d397a4445cd1dfc4`.
- GitHub combined-status endpoint latest commit için individual status göstermedi; SUCCESS kanıtı uydurulmadı.
- Requirement state CI/evidence gelmediği için yapay biçimde yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde Vedic Daily + City Catalog + DailySnapshot + Flutter Quality ve astronomy contract sonuçlarını doğrula; görünür kırmızıları aynı turda düzelt.
2. Production Lahiri/Chitrapaksha ayanamsha sağlayıcısını versioned/provenance-first şekilde ekle ve independent reference contract hazırla.
3. Fiziksel/versioned IERS EOP artifact + checksum/provenance zincirini bağla; sahte/uydurma gelecek EOP verisi üretme.
4. Ticari yeniden dağıtıma uygun offline ephemeris kernel/runtime ingest yolunu fiziksel artifact ile tamamla.
5. Gerçek GeoNames compact catalog + source/output SHA + timezone-ID toplu integrity testini tamamla.
6. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
7. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
8. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
9. Requirement state'e yalnız workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Vedik günlük hesap katmanı ve GeoNames provenance/evidence sözleşmesi ilerledi; fiziksel ephemeris/EOP/GeoNames verileri, bağımsız accuracy kanıtları, exact CI sonuçları, gerçek daily-message içeriği, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement'lar DONE sayılmayacak.
