# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. Buradaki `source-level` kayıtları DONE anlamına gelmez; yalnız test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Son doğrulanmış kapsam

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel 25.000+/6.400+ golden datasetleri açık.
- Faz 2: `Bugün · Araçlar · Kayıtlar · Profil`, 106 SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3: structural UI reference/state tracking, action registry, static asset manifest ve dynamic geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4: warm ivory/purple/gold design token ve component sözleşmeleri mevcut.

## Faz 5 — persistence

### Uygulanmış / source-level
- [x] Flutter package/entrypoint ve dört ana navigation destination.
- [x] Platform bağımsız domain + UUID sözleşmesi.
- [x] calculation_core / interpretation / data / ui / pdf / backup / entitlements sınırları.
- [x] Transaction/migration/integrity-check DB portu, SQLite adapter, schema-v1 ve rollback/integrity testleri.
- [x] Core domain codec/round-trip testleri.
- [x] Generic transactional repository + typed registry.

### Açık / DONE değil
- [ ] Exact-commit Flutter Quality + Architecture/UI/Requirements SUCCESS kanıtları.
- [ ] Standard Flutter Android/iOS generated project klasörleri.
- [ ] Android release/signing.
- [ ] Gerçek cihaz/emülatör SQLite smoke ve performance testleri.

## Faz 6 — Gregorian calendar + daily date

- [x] Strict `CivilDate`, destek aralığı `1890–2110`.
- [x] Gregorian `%400/%100/%4`, century boundaries ve leap-day testleri.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` key + ISO weekday.
- [x] 16.08.2026 / 16.08.2027 bağımsız test.
- [x] `DailyDateContext`, midnight rollover, year partition ve leap-day testleri.

## Faz 7 — IANA timezone + şehir/konum

- [x] Bundled IANA timezone runtime + explicit ambiguous/nonexistent-time policies.
- [x] Half/quarter-hour, UTC+14, date-line, DST ve skipped-day testleri.
- [x] Offline deterministic `CityCatalog`, Türkçe diacritics/alias/same-name-city testleri.
- [x] GeoNames manifest + deterministic compact catalog builder/fixture tests.
- [ ] Exact workflow SUCCESS, gerçek GeoNames artifact/SHA, attribution UI ve büyük-katalog integrity açık.

## DailySnapshot

### Uygulanmış / source-level
- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity ve cache partition.
- [x] Provenance-only factor modeli.
- [x] Planetary-hour factor gerçek motor üstünden bağlı.
- [x] Moon phase factor strict ephemeris üstünden bağlı.
- [x] Tropical Moon sign factor strict ephemeris üstünden bağlı.
- [x] Pythagorean Personal Day factor strict `CivilDate` üstünden bağlı.
- [x] Merkezi `DailySnapshotAssembler` eklendi; faktör sırası deterministik, duplicate factor kind yasak, boş provenance yasak ve generation timestamp UTC olmak zorunda.

### Personal Day — son tur
- [x] `PythagoreanPersonalDayEngine` eklendi.
- [x] Explicit `singleDigit` ve `preserveMasterNumbers` reduction policy eklendi.
- [x] Master-number seti `11/22/33` sözleşmeye bağlandı.
- [x] Universal Year → Personal Year → Personal Month → Personal Day zinciri deterministik ve locale/network bağımsız.
- [x] 16.08.2026 örneği single-digit policy ile `Personal Day 4`.
- [x] 16.08.2027 aynı doğum verisiyle bağımsız yeniden hesaplanıp `Personal Day 5`.
- [x] 16.08.2026 master-number policy ile final `22` korunuyor.
- [x] 29.02.2028 leap-day test vakası mevcut.
- [x] `PersonalDayDailyFactor`, `DailyFactorKind.personalDay` provenance reference üretiyor.
- [x] Policy result identity içine yazılıyor; farklı policy sonuçları cache/identity seviyesinde karışmıyor.
- [x] `personal_day_runtime.json` manifesti, structural validator ve ayrı `Personal Day Contract` workflow’u eklendi.
- [ ] Exact commit Flutter/Actions SUCCESS kanıtı gelmeden DONE değil.

### Snapshot assembly — son tur
- [x] Faktörler canonical sırada toplanıyor: Moon Sign → Moon Phase → Transit → Planetary Hour → Personal Day → Vedik indicator.
- [x] Aynı factor kind iki kere eklenemiyor.
- [x] `sourceEngineId`, `sourceEngineVersion` ve `resultId` boş olamıyor.
- [x] `generatedAtUtc` local DateTime olamıyor.
- [x] Sonuç faktör listesi unmodifiable olarak snapshot’a giriyor.
- [x] Daily Snapshot Contract validator/test sözleşmesi bu kurallarla güçlendirildi.
- [ ] Exact workflow SUCCESS olmadan DONE değil.

### Açık / DONE değil
- [ ] Moon phase/sign physical ephemeris + independent accuracy kanıtı.
- [ ] Transit gerçek motor bağlantısı.
- [ ] Vedik günlük faktörler gerçek motor bağlantısı.
- [ ] Exact Flutter Quality SUCCESS kanıtı.

## Günün Mesajı

- [x] Exact `CivilDate + locale`, deterministic key, no random fallback.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon.
- [x] Runtime AI ve TR↔EN machine translation yasak.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Near-duplicate/manual QA, artificial-pattern density, unsafe-certainty review ve release-horizon gate.

## Faz 8 — astronomik çekirdek

### Uygulanmış / source-level
- [x] Julian Day / MJD / J2000.
- [x] UTC/TAI/TT ayrımı ve leap-second coverage.
- [x] JD_UT1/JD_TT explicit sidereal-time input.
- [x] Versioned `EarthOrientationProvider`; UTC sessizce UT1 yerine kullanılmıyor.
- [x] Strict `EphemerisProvider`: Sun/Moon/planets/nodes; TT coverage + provenance + checksum sözleşmesi; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable.
- [x] 12 gündüz + 12 gece planetary-hours motoru.
- [x] Moon phase engine + DailySnapshot factor.
- [x] Tropical Moon sign engine + DailySnapshot factor.

### Açık kalan ana işler
- [ ] Latest exact commit üzerinde Flutter Quality ve bütün astronomy/numerology contract SUCCESS kanıtları.
- [ ] Packaged/versioned offline EOP/UT1−UTC dataset + coverage + checksum.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state doğrulaması.
- [ ] Hard accuracy budgets + bağımsız golden cross-check.

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

## Son çalışma doğrulama notu

- Moon phase source/test/manifest/validator/workflow commit’i: `aa5981065513982b74775e5b5e739505e03807ba`.
- Tropical Moon sign source/test/manifest/validator/workflow commit’i: `5cf93b4dcc6719c1117414182fc57eb5f3b8f226`.
- Personal Day source/test/manifest/validator/workflow commit’i: `8886ab7b709c3343238a601982189bd539f845b7`.
- DailySnapshot assembler/source/test/validator son commit zinciri: `ccb7eefec98cfe1e65e991c8bd3f609c0554b6fb` → `963078b464e889d4e1d86a1043c03df024de55ed` → `a0645e5068393085861748d8f60801c3e0316087`.
- Personal Day 1990-05-19 doğum / 2026-08-16 hedef hesabı bağımsız arithmetic kontrolünde single-digit `4`, master-preserving `22`; 2027-08-16 single-digit `5` verdi.
- Combined-status endpoint exact commit için check listesi göstermedi; SUCCESS kanıtı uydurulmadı.
- Automation runtime içinde Flutter/Dart executable yok; Flutter testleri yerelde çalıştırılamadı.
- Requirement state, CI/evidence gelmediği için yapay biçimde yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde Personal Day + Daily Snapshot + Moon Phase + Moon Sign + Flutter Quality + astronomy contract sonuçlarını doğrula; kırmızıları aynı turda düzelt.
2. Packaged/versioned IERS EOP/UT1−UTC dataset loader + checksum zincirini fiziksel veriye bağla.
3. Ticari yeniden dağıtıma uygun offline ephemeris dataset stratejisini kesinleştir.
4. Transit motoru için natal-target aspect contract ve DailySnapshot provenance bağlantısını kur.
5. Gerçek GeoNames compact catalog + timezone-ID toplu integrity testini tamamla.
6. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
7. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
8. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
9. Requirement state’e yalnız workflow/test/evidence kanıtı alınan RC’leri yükselt.

## Final durumu

**FINAL DEĞİL.** DailySnapshot artık planetary hour + Moon phase + tropical Moon sign + Pythagorean Personal Day source-level faktörlerine ve deterministic assembly contract’ına sahip; fiziksel ephemeris/EOP verileri, exact CI kanıtları, gerçek city/message datasetleri, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
