# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `source-level` kayıtları DONE anlamına gelmez; yalnız gerekli test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel 25.000+/6.400+ golden datasetler açık.
- Faz 2 bilgi mimarisi mevcut: `Bugün · Araçlar · Kayıtlar · Profil`, SCREEN-ID ve ACTION-ID sözleşmeleri.
- Faz 3 structural UI reference/action/static-asset/dynamic-geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4 design-token/component sözleşmeleri mevcut.
- Faz 5 persistence source-level: Flutter entrypoint, domain/UUID, SQLite schema-v1, migration/transaction/integrity/repository katmanı mevcut.
- Faz 6 Gregorian calendar source-level: `CivilDate`, 1890–2110, leap-year/century, ISO weekday/date-key ve rollover testleri mevcut.
- Faz 7 timezone/city source-level: bundled IANA runtime, DST ambiguity/nonexistent policy, half/quarter-hour, UTC+14/date-line ve deterministic CityCatalog mevcut. GeoNames fiziksel source/output SHA ve bulk IANA integrity açık.

## DailySnapshot — source-level

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour, Moon Phase, Tropical Moon Sign, Pythagorean Personal Day.
- [x] Transit factor + natal-target major aspect matching + applying/exact/separating.
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

- [x] Julian Day / MJD / J2000; UTC/TAI/TT ayrımı; JD_UT1/JD_TT sidereal-time input.
- [x] Versioned EarthOrientationProvider + bundled interpolation loader; extrapolation yasağı.
- [x] Strict EphemerisProvider: TT coverage + provenance + checksum; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable; 12 gündüz + 12 gece planetary-hours motoru.
- [x] Hard astronomy acceptance budgets + independent golden schema/runner/self-test contract.
- [x] Offline ephemeris strategy JPL DE440/NAIF contract seviyesinde.
- [x] Whole Sign + Equal House + Porphyry + strict Placidus source-level.
- [x] ASC/MC strict geometry core.
- [x] Western natal placements + aspects + orb + element/modality + aspect grid + classical dignities/rulership.
- [x] WesternNatalChartAssembler ve derived-data integrity.
- [ ] Placidus/ASC/MC independent golden proof ve 0.05° cusp budget kanıtı.
- [ ] Fiziksel EOP/ephemeris/Lahiri artifacts ve exact checksum/provenance.
- [ ] Exact latest Flutter/GitHub Actions SUCCESS görünür kanıtı.

## Backup / CSV — source-level

- [x] Strict CSV codec: Unicode/CRLF/comma/quote/newline/null-empty-zero/locale-independent numbers.
- [x] Versioned 14-table schema registry: PK/FK/nullable/enum/date/datetime/decimal/JSON.
- [x] SHA-256 package manifest, strict parser ve tamper verification.
- [x] `BackupPackageWriter` / `BackupPackageReader.preview`; mutation öncesi checksum/schema/FK doğrulama.
- [x] Transactional merge/replace; durable pre-replace safety snapshot + rollback.
- [x] Production `LocalDatabaseBackupImportStore` + SQLite FFI integration.
- [x] Portable single-file ZIP codec; zip-slip/CRC/duplicate/zip-bomb guards.
- [x] Atomic local `.ruhcode.zip` file store; `.tmp` + flush + rename; network yok.
- [x] Runtime LocalDatabase → canonical 14-table CSV export mapperı; deterministic order/canonical JSON.
- [x] SQLite source → export → package → ZIP → preview → production import → target storage equality lifecycle.
- [x] Aynı backup ikinci merge import idempotency.
- [x] TR/EN manifest metadata machine-storage isolation.
- [x] 2.500 Unicode kayıt replace-mode stress restore.
- [x] 14 logical tablonun tamamı non-empty representative relational fixture ile full export/import symmetry testine bağlı.
- [x] Export → bütün registered tabloları erase → replace restore → raw storage equality testi mevcut.
- [x] Aynı erase/restore akışında `CoreRepositories` + `CoreModelCodecs` üzerinden domain-object equality testi mevcut.
- [x] Explicit legacy v0 migrator: manifestsiz `profiles.csv` + opsiyonel `settings.csv`; bilinmeyen saati midnight uydurmama; unknown member/header rejection.
- [x] Legacy v0 → current strict preview → production SQLite import → domain read source-level testi mevcut.
- [x] **Native/platform backup gateway eklendi:** OS Save As, tek backup seçme, share sheet; `.ruhcode.zip` suffix/path/payload policy; core serialization'dan ayrı; network yok.
- [x] `file_picker ^12.0.0` ve `share_plus ^13.3.0` dependency contract'a bağlandı.
- [x] Platform gateway policy testleri + evidence + validator + Backup CI wiring mevcut.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Backup export/import application service + kullanıcı iptal semantics.
- [ ] Released historical backup fixture mevcut olduğunda gerçek tarihsel fixture doğrulaması.
- [ ] `pubspec.lock` gerçek dependency resolution sonrası commit edilmeli; elle uydurulmayacak.

## Son tur — 2026-08-20 08:56

Checkpoint: `automation_runs/2026-08-20_0856_backup_platform_gateway.md`

Bu turda Android/cihaz dosya seçme ve paylaşma açığı source-level ilerletildi. Backup serialization/ZIP/SQLite katmanları değiştirilmeden, platform sınırı `BackupPlatformGateway` ile ayrıldı. `NativeBackupPlatformGateway` OS-native save dialog, tek dosya picker ve share sheet kullanıyor. Kullanıcı iptali nullable sonuç olarak korunuyor; platform kodu ağ çağrısı yapmıyor. `.ruhcode.zip` adı, path injection, boş/oversize payload ve 64 MiB sınırı saf `BackupPlatformPolicy` ile test edilebilir hale getirildi.

Son commit zinciri:
- `809a1000eec938a9d9586a544a2fbe3d70b513a0` platform dependencies
- `decba829d49c7d5e8bf1b5f15436be57912fd008` platform gateway + validation policy
- `b2419bba1dee8e3e596d64641bfbfc2fd514d764` platform policy tests
- `b57b68fa2a4346442d7d8cfa7f297c72bf5c5f75` evidence contract
- `35bcf569ec554c9acac607cea4970a0f36be1ebd` structural validator
- `7f7cc01f96771d5153c0d2ec12396740383e9d66` Backup CI wiring
- `a8dcdb77eb736f846c534bcf470b3ad413f6f33b` run checkpoint

GitHub combined-status workflow commit için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

## Açık fiziksel/evidence blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + gerçek checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node runtime state cross-check.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] ASC/MC + Placidus/Porphyry independent golden-reference kanıtı.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] GeoNames source ZIP/TXT exact SHA-256 + compact catalog SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal Günün Mesajı kaydı.
- [ ] Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI referans seti.

## Sıradaki çalışma

1. Exact workflow sonucu görünür kırmızı olursa aynı turda düzelt.
2. Backup export/import application service'i `BackupPlatformGateway` ile bağla; user cancel hata olmasın.
3. Backup kullanıcı aksiyon/state'lerini TR/EN UI/action registry ile bağla.
4. Gerçek dependency resolution mümkün olduğunda `pubspec.lock` üret ve clean-checkout gate'e ekle.
5. Backup hattı sonrası profesyonel PDF motoru ve export/preview contract'a ilerle.
6. Paralelde ASC/MC + Placidus/Porphyry independent golden proof.
7. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
8. GeoNames gerçek compact catalog + source/output SHA + timezone bulk integrity.
9. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
10. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
11. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.