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
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Logical package ↔ gerçek portable ZIP/file bytes adapterı.
- [ ] Device file save/open integration.
- [ ] Runtime storage payload → canonical CSV export row mapping.
- [ ] TR→EN / EN→TR clean-install round-trip proof.
- [ ] Legacy schema migration/adoption proof.
- [ ] Large-data/stress restore.
- [ ] Export→erase→restore→domain equality lifecycle proof.

## Son tur — 2026-08-20 00:57

Checkpoint: `automation_runs/2026-08-20_0057_backup_sqlite_durable_snapshot.md`

Bu turda backup hattı logical transaction mock seviyesinden gerçek offline `LocalDatabase`/SQLite adapter seviyesine taşındı. Destructive replace yalnız transaction içinde clear yapabiliyor; safety snapshot artık memory token değil, diske flush edilen durable snapshot dosyası. Restore snapshot format/schema doğrulaması sonrası kayıtları atomik olarak geri yüklüyor. Profile CSV mapping'in gerçek runtime repository tarafından okunabildiği SQLite FFI testi eklendi.

Son commit zinciri:
- `b9a3993f8fccfe9358fe665ffb96907f963914b7` LocalDatabase bulk transaction contract
- `5d5f0454c3b523e6e16c1e5ba7b30949399d93fc` Sqflite bulk implementation
- `051e5351038918081f1404515032be3763ffdb93` production backup import store
- `e75e35034beef37bb38dd7baddc3505161ca51bd` memory test compatibility
- `c43be712c11841de962cf3a1ab15d2ae9a882aca` production adapter tests
- `24b6f457d7e370006c3aa88103dd6bcab1d1ea7d` test correction
- `99fc529ffeade9c080609e3b257d4488bae19ed9` production-store evidence
- `e985cb8e080cc8867263339921c8c1137a443b70` production-store validator
- `c64d1a5576a872706731acd30771e8a1544b5e37` Backup CSV CI wiring
- `6b34dde89c4b29c73025280cf5e26ce3aeaa5dbd` run checkpoint

GitHub combined-status `c64d1a557...` için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. Portable ZIP/archive adapterı: `BackupPackageBytes` ↔ tek dosya byte stream; zip-slip/duplicate member/size guard.
3. Device file save/open adapter sözleşmesi.
4. Runtime DB → canonical CSV export mapping ve export/import symmetry testleri.
5. TR→EN / EN→TR, legacy schema, large-data ve clean-install export→erase→restore testleri.
6. Paralelde ASC/MC + Placidus/Porphyry independent golden house-cusp proof.
7. Fiziksel IERS EOP + offline ephemeris artifact/checksum/provenance.
8. Gerçek GeoNames compact catalog + source/output SHA + timezone bulk integrity.
9. Günün Mesajı gerçek 8.036 editoryal kayıt hattı.
10. Güncel APPROVED UI reference seti ve SCREEN-ID/hash manifesti.
11. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
