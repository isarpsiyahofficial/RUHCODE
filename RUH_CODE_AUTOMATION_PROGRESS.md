# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `source-level` kayıtları DONE anlamına gelmez; yalnız gerekli test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel 25.000+/6.400+ golden datasetler açık.
- Faz 2 bilgi mimarisi mevcut: `Bugün · Araçlar · Kayıtlar · Profil`, SCREEN-ID ve ACTION-ID sözleşmeleri.
- Faz 3 structural UI reference/action/static-asset/dynamic-geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4 design-token/component sözleşmeleri mevcut.
- Faz 5 persistence source-level: Flutter entrypoint, domain/UUID, SQLite schema-v1, migration/transaction/integrity/repository katmanı ve backup için transactional table snapshot/clear operasyonları mevcut. Exact Flutter/device kanıtları açık.
- Faz 6 Gregorian calendar source-level: `CivilDate`, 1890–2110, leap-year/century, ISO weekday/date-key ve rollover testleri mevcut.
- Faz 7 timezone/city source-level: bundled IANA runtime, DST ambiguity/nonexistent policy, half/quarter-hour, UTC+14/date-line ve deterministic CityCatalog mevcut. GeoNames fiziksel source/output SHA ve bulk IANA integrity açık.

## DailySnapshot — source-level

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour factor.
- [x] Moon Phase factor.
- [x] Tropical Moon Sign factor.
- [x] Pythagorean Personal Day factor.
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

- [x] Julian Day / MJD / J2000.
- [x] UTC/TAI/TT ayrımı ve leap-second coverage.
- [x] JD_UT1/JD_TT explicit sidereal-time input.
- [x] Versioned EarthOrientationProvider + bundled interpolation loader; extrapolation yasağı.
- [x] Strict EphemerisProvider: TT coverage + provenance + checksum; network/nearest-date/zero fallback yok.
- [x] Deterministic solar events + polar unavailable.
- [x] 12 gündüz + 12 gece planetary-hours motoru.
- [x] Hard astronomy acceptance budgets + independent golden schema/runner/self-test contract.
- [x] Offline ephemeris strategy JPL DE440/NAIF contract seviyesinde.
- [x] Whole Sign + Equal House + Porphyry source-level.
- [x] ASC/MC strict geometry core.
- [x] Western natal placements + aspects + orb + element/modality + aspect grid + classical dignities/rulership.
- [x] WesternNatalChartAssembler ve derived-data integrity.
- [x] Strict Placidus solver + polar unavailable/explicit Porphyry fallback contract.
- [ ] Placidus/ASC/MC independent golden proof ve 0.05° cusp budget kanıtı.
- [ ] Fiziksel EOP/ephemeris/Lahiri artifacts ve exact checksum/provenance.
- [ ] Exact latest Flutter/GitHub Actions SUCCESS görünür kanıtı.

## Backup / CSV — source-level

- [x] Strict CSV value/document codec; Unicode, CRLF, comma/quote/newline, null/empty/zero, locale-independent numbers.
- [x] Versioned 14-table CSV schema registry; PK/FK/nullable/enum/date/datetime/decimal/JSON metadata.
- [x] SHA-256 package manifest; byte length + record count + deterministic ordering + tamper verification.
- [x] Strict manifest parser.
- [x] `BackupPackageWriter` ve `BackupPackageReader.preview`: manifest/schema → member set → SHA/length → UTF-8 → row count → schema → FK doğrulama.
- [x] Preview storage mutation yapmıyor.
- [x] `BackupImportCoordinator`: valid preview olmadan mutation yasak; merge PK-upsert; replace safety snapshot + rollback sözleşmesi.
- [x] `LocalDatabaseTransaction.readTable/clearTable`: bulk operasyonlar yalnız transaction içinde.
- [x] `SqfliteLocalDatabase`: deterministic table snapshot ve transactional clear implementasyonu.
- [x] Production `LocalDatabaseBackupImportStore` adapterı.
- [x] Durable pre-replace snapshot: diske flush edilen versioned JSON safety snapshot.
- [x] Snapshot restore: snapshot/db schema doğrulaması + bütün registered tabloları tek transaction içinde geri yükleme.
- [x] CSV→runtime storage payload mapping; Profile mapping gerçek `CoreRepositories` ile okunabilir integration testine bağlı.
- [x] SQLite FFI production adapter integration testleri.
- [x] `evidence/backup/production_store_contract.json` + structural validator + genişletilmiş Backup CSV workflow.
- [x] Portable `BackupPackageBytes` ↔ tek ZIP byte stream adapterı.
- [x] ZIP safety: CRC verify, zip-slip/absolute/nested path, directory/symlink, duplicate member ve zip-bomb size/count guard.
- [x] Native local file store: `.ruhcode.zip`, atomic `.tmp` + flush + rename, read/write size guards; network yok.
- [x] Runtime LocalDatabase → canonical 14-table CSV export mapperı.
- [x] Export deterministic record order + canonical JSON key order + storage key/payload id consistency.
- [x] `exportPackage` strict package preview acceptance testine bağlı.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android document picker/share-sheet platform entegrasyonu.
- [ ] Production SQLite 14-table export → ZIP → import → domain/storage equality lifecycle proof.
- [ ] TR→EN / EN→TR clean-install round-trip proof.
- [ ] Legacy schema migration/adoption proof.
- [ ] Large-data/stress restore.
- [ ] Export→erase→restore→domain equality lifecycle proof.
- [ ] `pubspec.lock` henüz repository'de yok; clean-checkout reproducibility için gerçek dependency resolution sonrası commit edilmeli.

## Son tur — 2026-08-20 02:55

Checkpoint: `automation_runs/2026-08-20_0255_backup_portable_zip_export.md`

Bu turda backup paketi logical member map seviyesinden gerçek portable tek dosya ZIP seviyesine taşındı. ZIP decode CRC verify kullanıyor; traversal, absolute/nested path, backslash, directory/symlink, duplicate member ve expanded-size saldırıları reddediliyor. Ardından local-only atomik `.ruhcode.zip` file store eklendi. Aynı turda import yönünün tersi olan `LocalDatabaseBackupExporter` kuruldu: 14 tablo tek DB transaction snapshot içinde canonical CSV'ye dönüyor, Profile nested payload mapping ve deterministic/canonical JSON export mevcut.

Son commit zinciri:
- `d204fed87a59d3a968e7df6cd3411fe8808578d4` archive dependency
- `c3ead898f182b1d6bca6d6be9c7c7ae4ae8d74bb` portable ZIP codec
- `a5ed192068e9f43239f3aee11a05338cedc37ad1` ZIP tests
- `45145051dbe34b996b0191c338c9a632fbf9af86` ZIP evidence
- `98b3d2ea4c0b77e2e1a5791888610e53d63be7f1` ZIP validator
- `900925636653f3bac799097333bf8dabea771de6` ZIP CI wiring
- `b46cb70f4c174de12374cbe98153d730c26304ea` file-store source fix
- `5e8732d193344e9475ed20f407390682ad15c2e1` file-store tests corrected
- `f3cd25ea64aadbd2fdddeac2178884edc12de26e` file-store evidence
- `569b32e01c9222c6c37e8531354a0a996ff51e1a` file-store validator
- `8bb7753a4bc200a17b891a797ed02e8f03d2f97f` file-store CI wiring
- `9cfb66e25c36344fb96056313657597d6dcd19c8` LocalDatabase exporter
- `ef8f973dd4650691fe0a3731673e6ddb924213dc` exporter tests
- `01bd3b8209ebb91dfd328bc7fd1729ae019c7e5e` exporter evidence
- `da5c90a277163f26b71689ec9616e59eb795c99e` exporter validator
- `c33ce557af0fa80ae48dc10deb0f1a5af5bfe6c9` exporter CI wiring
- `7750ea603715d99d67a3473a26774e1bccf2a459` run checkpoint

GitHub combined-status `c33ce557...` için yine `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. SQLite FFI üzerinde LocalDatabase export → package → portable ZIP → decode → preview → production import symmetry testi.
3. Import sonrası domain/storage equality ve aynı backup ikinci import idempotency.
4. TR→EN / EN→TR locale-independent restore.
5. Legacy schema migration/adoption fixture.
6. Large-data stress export/restore.
7. Android document picker/share-sheet adapterı; core file store platform UI'dan ayrı kalacak.
8. `pubspec.lock` clean-checkout reproducibility kapısı.
9. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
10. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
11. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
12. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
13. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
14. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
