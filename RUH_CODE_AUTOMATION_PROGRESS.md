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
- [x] **14 logical tablonun tamamı non-empty representative relational fixture ile full export/import symmetry testine bağlı.**
- [x] **Export → bütün registered tabloları erase → replace restore → raw storage equality testi mevcut.**
- [x] **Aynı erase/restore akışında `CoreRepositories` + `CoreModelCodecs` üzerinden domain-object equality testi mevcut.**
- [x] **Explicit legacy v0 migrator mevcut:** manifestsiz `profiles.csv` + opsiyonel `settings.csv`; birth-time knowledge migration; bilinmeyen saati midnight uydurmama; yeni tabloları boş üretme; unknown member/header rejection.
- [x] Legacy v0 → current strict preview → production SQLite import → domain read source-level testi mevcut.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android document picker/share-sheet platform entegrasyonu.
- [ ] Released historical backup fixture mevcut olduğunda gerçek tarihsel fixture doğrulaması.
- [ ] `pubspec.lock` henüz repository'de yok; clean-checkout reproducibility için gerçek dependency resolution sonrası commit edilmeli.

## Son tur — 2026-08-20 06:56

Checkpoint: `automation_runs/2026-08-20_0656_backup_symmetry_legacy.md`

Bu turda backup hattındaki iki büyük açık source-level kapatıldı: bütün 14 tablo non-empty ve gerçek FK ilişkileri taşıyan representative fixture ile portable restore symmetry testine alındı; ayrıca export sonrası bütün tabloların silinip restore edilmesi ve domain repository seviyesinde aynı nesnelere dönülmesi kanıt zincirine eklendi.

Legacy migration için de ilk açık ve deterministik sürüm geçişi eklendi. V0 backup'ın manifest taşımadığı, yalnız profile/settings bildiği ve `birth_time_knowledge` taşımadığı sözleşme olarak tanımlandı. Saat varsa `exact`, yoksa `unknown`; `00:00` uydurma kesinlikle yok. V0'da bulunmayan tablolar boş current-schema dosyalarına dönüşüyor ve bilinmeyen legacy yapılar reddediliyor.

Son commit zinciri:
- `7c98cb0e66daab80ab6f984cac7ee7df1ceacbfc` all-table symmetry + erase/restore
- `daafa91264e4701736d45f99fa0441f8061451a2` lifecycle evidence
- `f6656686241c7c93aeaac56fcf0a0fa0eb2a584a` lifecycle validator
- `95d442c6887a97ed2b196a052c85821e9b785775` legacy v0 migrator
- `997c190054dfe3e05721d3610fee069478e726b2` legacy tests
- `3c6cc898eb3a5180d07743e63a2d6a848f83d71b` legacy evidence
- `a00424f9e7329791ec4169160c51dd30e183d7af` legacy validator
- `f962595646febeb8a978b558ab682c2900817753` Backup CI wiring
- `60fb7b02d8b7d0c40c8d6aeee012e7a0703a2687` run checkpoint

GitHub combined-status latest workflow commit için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. Android document picker/share-sheet adapterını core backup file store'dan ayrı platform katmanı olarak ekle.
3. `pubspec.lock` clean-checkout reproducibility kapısı.
4. Backup hattı sonrası PDF motoru ve export/preview contract'a ilerle.
5. Paralelde ASC/MC + Placidus/Porphyry independent golden proof.
6. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
7. GeoNames gerçek compact catalog + source/output SHA + timezone bulk integrity.
8. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
9. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
10. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
