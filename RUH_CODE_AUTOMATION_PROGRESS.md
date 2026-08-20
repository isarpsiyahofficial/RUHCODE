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
- [x] SQLite FFI source → 14-table export → package → ZIP encode/decode → strict preview → production import → target storage equality lifecycle testi source-level mevcut.
- [x] Aynı portable backup'ın ikinci merge importunda idempotency/storage equality testi source-level mevcut.
- [x] `localeTag=tr` ve `localeTag=en` export/import sonucunun aynı machine storage üretmesi testi source-level mevcut.
- [x] 2.500 deterministic Unicode kayıtla portable ZIP + replace restore stress testi source-level mevcut.
- [x] `evidence/backup/full_lifecycle_contract.json` + structural validator + Backup CSV workflow bağlantısı mevcut.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android document picker/share-sheet platform entegrasyonu.
- [ ] 14 tablonun tamamı non-empty ve ilişkisel fixture ile full symmetry kanıtı.
- [ ] Legacy schema migration/adoption proof.
- [ ] Export→erase→restore→domain-object equality lifecycle proof.
- [ ] `pubspec.lock` henüz repository'de yok; clean-checkout reproducibility için gerçek dependency resolution sonrası commit edilmeli.

## Son tur — 2026-08-20 04:57

Checkpoint: `automation_runs/2026-08-20_0457_backup_full_lifecycle.md`

Bu turda backup hattı ilk kez tek bir integration test zincirinde gerçek SQLite kaynak ve hedef veritabanlarıyla uçtan uca bağlandı. Source database kayıtları canonical 14-table CSV paketine export ediliyor, portable ZIP'e encode edilip tekrar decode ediliyor, strict package preview'dan geçiyor ve production `LocalDatabaseBackupImportStore` üzerinden target SQLite'a import ediliyor. Import sonrası bütün registered logical tablolar source snapshot ile karşılaştırılıyor. Aynı backup ikinci kez merge edildiğinde duplicate/mutation olmaması ayrıca sınanıyor.

Aynı lifecycle testine TR/EN locale metadata izolasyonu ve 2.500 deterministic Unicode settings kaydıyla replace-mode stress restore eklendi. İlk test taslağındaki yanlış `BackupImportPreview.errors` kullanımı aynı turda gerçek `issues` API'sine düzeltildi.

Son commit zinciri:
- `80fe838cbdd65a800cb4409cd756587503a21e5d` full SQLite portable lifecycle test ilk sürüm
- `b0107420fee113d40f74f147d97716b51c8ab30b` lifecycle evidence contract
- `bae7e9313726cf62eb6ac644b9ecb6fba8b380fd` lifecycle structural validator
- `dc80ddc293ee27048d563febc655eb1cf542d904` Backup CI wiring
- `500f0e7500b760dcaa4c2f09a10034a61f1dac98` preview API fix + 2.500-record stress test
- `68697550e675e6cbf3ef4fff7995d8054fa1daf2` stress evidence update
- `1120c367f0f9f36f50d0546160cbef33ef9b3206` stress validator update
- `82aa97c935c809b65542c70da9bfbf6e4a142d06` run checkpoint

GitHub combined-status `dc80ddc293ee27048d563febc655eb1cf542d904` için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. 14 logical tablonun tamamı için non-empty ilişkisel representative fixture oluştur ve full export/import symmetry'yi kanıtla.
3. Export→erase→restore→domain-object equality lifecycle testi.
4. Legacy schema migration/adoption fixture ve explicit migrator.
5. Android document picker/share-sheet adapterı; core file store platform UI'dan ayrı kalacak.
6. `pubspec.lock` clean-checkout reproducibility kapısı.
7. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
8. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
9. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
10. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
11. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
12. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
