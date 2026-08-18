# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış kapsam

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES referans/runtime sınırı belgelendi; binary ZIP gerektiren exact hash, aktif JS/CSS/ephemeris/timezone envanteri ve 25.000+/6.400+ dataset dönüştürmeleri açık.
- Faz 2: `Bugün · Araçlar · Kayıtlar · Profil`, 106 SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3: 106/106 structural UI reference/state tracking, action registry, static asset manifest ve dynamic geometry contract mevcut; güncel APPROVED PNG seti henüz yok.
- Faz 4: warm ivory `#FBF8F3`, primary purple `#4C2A91`, strong purple `#6B42E6`, gold `#C89338`, spacing/radius/typography/navigation/touch-target structural design sözleşmeleri mevcut.

## Faz 5 — persistence

### Uygulanmış / source-level
- [x] Flutter package/entrypoint ve dört ana navigation destination.
- [x] Platform bağımsız domain + UUID sözleşmesi.
- [x] calculation_core / interpretation / data / ui / pdf / backup / entitlements sınırları.
- [x] Transaction/migration/integrity-check DB portu, SQLite adapter, schema-v1 ve FFI rollback/integrity testleri.
- [x] Core domain codec/round-trip testleri.
- [x] Generic transactional `JsonRecordRepository<T>` ve typed `CoreRepositories` registry.
- [x] Architecture validator typed repository ve rollback testlerini zorunlu kılıyor.

### Açık / DONE değil
- [ ] Flutter Quality + Architecture/UI/Requirements exact-commit SUCCESS kanıtları.
- [ ] Standard Flutter Android/iOS generated project klasörleri.
- [ ] Android release/signing.
- [ ] Gerçek cihaz/emülatör SQLite smoke ve büyük-data performance testleri.

## Faz 6 — Gregorian calendar + daily date

### Uygulanmış / source-level
- [x] Strict `CivilDate`, destek aralığı `1890–2110`.
- [x] Gregorian `%400/%100/%4`; 1900/2000/2028/2032/2036/2100 sınır testleri.
- [x] 28→29 Şubat→1 Mart ve normal 28 Şubat→1 Mart.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` key + ISO weekday.
- [x] 16.08.2026 / 16.08.2027 bağımsız test.
- [x] `DailyDateContext`, local-midnight rollover, year partition ve leap-day testleri.

## Faz 7 — IANA timezone + şehir/konum

### Uygulanmış / source-level
- [x] `timezone` + `flutter_timezone`, bundled `latest_all`, version `2025c` manifesti.
- [x] Explicit ambiguous/nonexistent-time policies.
- [x] Kolkata/Kathmandu/Kiritimati/date-line/New York DST/Apia skipped-day testleri.
- [x] Platform IANA identifier doğrulaması ve Timezone Contract.
- [x] `CityRecord` + offline deterministic `CityCatalog`.
- [x] Türkçe diacritics/alias/same-name-city testleri.
- [x] GeoNames kaynak/lisans manifesti ve deterministic compact catalog builder.
- [x] Builder source/generated SHA üretimi, fixture/invalid ZIP testleri ve City Catalog Contract.

### Açık / DONE değil
- [ ] Timezone / City Catalog / Flutter Quality exact-commit SUCCESS kanıtları.
- [ ] Dependency lock/checksum clean-checkout zinciri.
- [ ] Timezone release hash/integrity.
- [ ] Gerçek GeoNames source artifact + generated catalog + gerçek SHA-256.
- [ ] Attribution UI, büyük katalog performance ve toplu timezone-ID integrity.

## DailySnapshot

- [x] `DailySnapshotIdentity` profile + exact date + IANA zone + coordinate + engineVersion + tzDatabaseVersion.
- [x] Cache partition testleri ve provenance-only factor modeli.
- [x] Daily Snapshot Contract.
- [ ] Moon/phase, transit, planetary-hour, Personal Day ve Vedik günlük faktörleri gerçek motorlara bağlanmalı.
- [ ] Flutter Quality SUCCESS kanıtı.

## Günün Mesajı

- [x] Exact `CivilDate + locale` model, deterministic `YYYY-MM-DD|locale`, no random fallback.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon.
- [x] Runtime AI, random fallback ve TR↔EN machine translation yasak.
- [x] Catalog validator + fixture tests + Daily Message Contract.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Near-duplicate/manual QA, artificial-pattern density, unsafe-certainty review ve release-horizon gate.

## Faz 8 — ortak astronomik calculation core / zaman tabanı

### Uygulanmış / source-level
- [x] `JulianDay`: CivilDate/UTC → JD, MJD, J2000 centuries.
- [x] USNO Julian Day referans testleri, manifest, validator ve `Julian Day Contract`.
- [x] `UtcTaiOffsetTable`: 1972 sonrası leap-second segmentleri explicit.
- [x] `TimeScales`: `TT = TAI + 32.184s`, UTC→TT Julian Day.
- [x] Pre-1972 UTC sahte offset yerine reject.
- [x] Gelecekteki leap-second kararları uydurulmuyor; IERS Bulletin C 72 ile built-in safe coverage `UTC < 2027-07-01T00:00:00Z`.
- [x] Historical offset + 2026 + USNO J2000 TT epoch testleri.
- [x] IAU SOFA / USNO / IERS time-scale reference manifesti, validator ve CI contract.
- [x] `SiderealTime.greenwichMeanHours`: JD_UT1 ve JD_TT explicit input; USNO approximate GMST.
- [x] J2000 noon/midnight, normalization, degree tests; USNO manifest/validator/CI contract.
- [x] `EarthOrientationProvider` portu eklendi; calculation core UT1−UTC verisini explicit ve versioned provenance ile ister.
- [x] `AstronomicalTimeContext` UTC, JD_UTC, JD_TT ve JD_UT1 değerlerini ayrı tutar.
- [x] EOP sample timestamp mismatch, missing provenance ve `|UT1−UTC| >= 0.9s` reddedilir; UTC sessizce UT1 yerine kullanılamaz.
- [x] IERS Earth-orientation manifesti `pendingRuntimeData=NOT_DONE` durumunu açık tutar; packaged offline EOP dataset olmadan DONE iddiası yapılamaz.
- [x] Earth Orientation unit tests, structural validator ve `Earth Orientation Contract` workflow’u eklendi.

### Açık / DONE değil
- [ ] `Flutter Quality`, `Time Scales`, `Julian Day`, `Sidereal Time`, `Earth Orientation` contract exact-latest SUCCESS kanıtları.
- [ ] Packaged/versioned offline EOP/UT1−UTC dataset + coverage + checksum manifesti.
- [ ] Pre-1972 zaman ölçeği/Delta-T yaklaşımı; 1890–1971 hassas zaman hesapları henüz DONE değil.
- [ ] Ephemeris runtime/lisans stratejisi ve version/checksum manifesti.
- [ ] Güneş/Ay/gezegen konumları, nodes, retrograde/station, sunrise/sunset, Moon phase.
- [ ] Hard accuracy budgets + independent golden cross-check.

## UI reference durumu

- Önceki 9 adet UI PNG’si yasaklanan `Hesapla` alt menüsünü içerdiği için APPROVED değildir.
- Authoritative Gezegen Saatleri güncel reference setinde yok.
- Yeni `Bugün · Araçlar · Kayıtlar · Profil` referansları SCREEN-ID/hash manifestine bağlanmadan UI DONE yapılmayacak.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repo/automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri.
- [ ] 25.000+ Vedik ve 6.400+ planetary-hour fiziksel golden dataset.
- [x] AKİLES raporu davranış referansı olarak bulundu; binary/golden dataset yerine geçmiyor.

## Son çalışma doğrulama notu

- GitHub’a gerçek source/test/reference-manifest/validator/workflow commitleri yazıldı.
- Runtime container’dan public GitHub DNS erişimi olmadığı için clean `git clone` girişimi ağ seviyesinde başarısız oldu; SUCCESS kanıtı sayılmadı.
- GitHub push workflow SUCCESS sonucu connector üzerinden bu turda henüz elde edilemedi. Bu yüzden yeni işler source-level ilerlemedir; ilgili RC/TODO maddeleri DONE’a yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde Flutter Quality + bütün yeni/eski contract sonuçlarını doğrula; kırmızıysa düzelt.
2. Offline/versioned IERS EOP/UT1−UTC dataset stratejisini ve checksum/coverage manifestini fiziksel veriye bağla.
3. Ephemeris runtime/lisans/version/checksum stratejisini kesinleştir; AKİLES binary bulunursa ayrıca hash/golden dataset taşı.
4. Gerçek GeoNames compact catalog + timezone-ID toplu integrity testini tamamla.
5. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
6. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
7. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
8. Requirement state’e yalnız workflow/test/evidence kanıtı alınan RC’leri yükselt.

## Final durumu

**FINAL DEĞİL.** Astronomik zaman altyapısı Julian Day + UTC/TAI/TT + explicit UT1/EOP + UT1/TT ayrımlı GMST seviyesine ilerledi. Gerçek CI kanıtları, EOP/ephemeris data, gezegen hesapları, gerçek city/message datasetleri, güncel UI reference assetleri ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
