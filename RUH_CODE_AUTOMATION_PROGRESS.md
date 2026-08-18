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
- Faz 7 timezone/city source-level: bundled IANA runtime, DST ambiguity/nonexistent policy, half/quarter-hour, UTC+14/date-line ve deterministic CityCatalog mevcut. Gerçek GeoNames artifact/SHA ve büyük katalog kanıtı açık.

## DailySnapshot — source-level

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour factor.
- [x] Moon Phase factor.
- [x] Tropical Moon Sign factor.
- [x] Pythagorean Personal Day factor.
- [x] Transit factor + natal-target major aspect matching.
- [ ] Vedik günlük faktörler.
- [ ] Fiziksel ephemeris/EOP ve independent accuracy kanıtları olmadan bu faktörler DONE değil.

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
- [x] Astronomi için hard acceptance-budget manifesti eklendi: Sun 0.01°, Moon/planet/node 0.02°, ASC/MC/house cusp 0.05°, sunrise/sunset ve planetary-hour boundary 60 s hedefleri. Bu değerler yalnız acceptance target; `proven=false` ve bağımsız fiziksel kanıt gelmeden DONE yasak.
- [x] Accuracy-budget validator + bağımsız CI workflow eklendi.

### Açık ana işler / DONE değil
- [ ] Latest exact commit üzerinde Flutter Quality ve bütün astronomy/numerology contract SUCCESS kanıtları.
- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget manifestindeki bütün limitleri bağımsız golden data ile kanıtlama.
- [ ] ASC/MC/house sistemleri ve boundary testleri.
- [ ] Vedik sidereal/ayanamsha/nakshatra/pada/varga/dasha motorları.

## Gezegen Saatleri

- [x] Chaldean order + gerçek weekday ruler.
- [x] Sunrise→sunset 12; sunset→next sunrise 12 eşit parça.
- [x] Polar fake sonuç yerine unavailable.
- [x] DailySnapshot entegrasyonu.
- [ ] AKİLES 6.400+ physical golden dataset, global cross-check, local UI/notification ve exact workflow SUCCESS açık.

## UI reference durumu

- Önceki 9 UI PNG’si yasaklanan `Hesapla` alt menüsünü içerdiği için APPROVED değildir.
- Yeni `Bugün · Araçlar · Kayıtlar · Profil` referansları SCREEN-ID/hash manifestine bağlanmadan UI DONE yapılmayacak.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti automation workspace/repo içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri.
- [ ] 25.000+ Vedik ve 6.400+ planetary-hour fiziksel golden dataset.

## Son çalışma commitleri

- Transit phase engine: `c7593a8a1b7d1684d4d26e3a8a5aaaa4773ceaab`.
- Transit phase tests: `db76c63444af464089d87207facd43f248e53054`.
- Transit manifest: `83b54462443adf0fcd6b321d5e2b80cf641f5431`.
- Transit validator: `967d5f63dca48710dd477b6313910529a58e9571`.
- Astronomy accuracy-budget manifest: `bbc720296bf0603eef319320cb28d2a01a230caa`.
- Accuracy-budget validator: `666f484b3d085d878600a4c48d4f2a6a9c0d3c28`.
- Accuracy-budget CI gate: `92a4b932324e1ae7911a4c7669419beede2a8df9`.
- GitHub combined-status endpoint exact commit için individual status göstermedi; SUCCESS kanıtı uydurulmadı.
- Automation runtime içinde Flutter/Dart executable yok; Flutter testleri yerelde çalıştırılamadı.
- Requirement state, CI/evidence gelmediği için yapay biçimde yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde Transit + Accuracy Budget + DailySnapshot + Flutter Quality ve astronomy contract sonuçlarını doğrula; görünür kırmızıları aynı turda düzelt.
2. Fiziksel/versioned IERS EOP artifact + checksum/provenance zincirini bağla; sahte/uydurma gelecek EOP verisi üretme.
3. Ticari yeniden dağıtıma uygun offline ephemeris dataset/lisans stratejisini kesinleştir ve runtime loader’a fiziksel veri bağla.
4. Accuracy-budget golden dataset formatını ve independent-reference runner’ı oluştur.
5. Gerçek GeoNames compact catalog + timezone-ID toplu integrity testini tamamla.
6. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
7. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
8. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
9. Requirement state’e yalnız workflow/test/evidence kanıtı alınan RC’leri yükselt.

## Final durumu

**FINAL DEĞİL.** Transit phase ve accuracy-budget sözleşmeleri ilerledi; fiziksel ephemeris/EOP verileri, bağımsız accuracy kanıtları, exact CI sonuçları, gerçek city/message datasetleri, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
