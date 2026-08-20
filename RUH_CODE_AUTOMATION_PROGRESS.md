# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `source-level` kayıtları DONE anlamına gelmez; yalnız gerekli test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES exact binary ZIP/hash ve fiziksel golden datasetler açık.
- Faz 2 bilgi mimarisi mevcut: `Bugün · Araçlar · Kayıtlar · Profil`, SCREEN-ID ve ACTION-ID sözleşmeleri.
- Faz 3 structural UI reference/action/static-asset/dynamic-geometry contract mevcut; güncel APPROVED PNG seti yok.
- Faz 4 design-token/component sözleşmeleri mevcut.
- Faz 5 persistence source-level: Flutter entrypoint, domain/UUID, SQLite schema-v1, migration/transaction/integrity/repository katmanı mevcut.
- Faz 6 Gregorian calendar source-level tamamlanmış temel sözleşmelere sahip.
- Faz 7 timezone/city source-level mevcut; fiziksel GeoNames provenance/bulk integrity açık.

## DailySnapshot / içerik

- [x] Profile + exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Deterministic assembler; duplicate factor kind ve boş provenance yasak.
- [x] Planetary Hour, Moon Phase, Tropical Moon Sign, Pythagorean Personal Day.
- [x] Transit factor + natal-target major aspect + applying/exact/separating.
- [x] Vedik günlük factor: sidereal Sun/Moon + Nakshatra + Pada + Tithi + Paksha.
- [ ] Fiziksel ephemeris/EOP/Lahiri ve independent accuracy kanıtları.
- [x] Günün Mesajı exact-date/locale/rolling-horizon/duplicate/near-duplicate kalite sözleşmesi.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik ve final QA.

## Astronomik / Western source-level

- [x] Julian/time-scale/sidereal-time provider sınırları.
- [x] Strict EphemerisProvider ve EarthOrientationProvider contract'ları.
- [x] Solar events + planetary hours.
- [x] Whole Sign + Equal House + Porphyry + strict Placidus source-level.
- [x] ASC/MC geometry core.
- [x] Western placements/aspects/orbs/element/modality/aspect-grid/dignity/rulership/chart assembly.
- [ ] Fiziksel EOP/ephemeris artifacts + checksums.
- [ ] ASC/MC + Placidus independent golden proof ve 0.05° cusp budget.
- [ ] Exact latest Flutter/GitHub Actions SUCCESS görünür kanıtı.

## Backup / CSV — source-level

- [x] Strict Unicode CSV codec ve 14-table versioned schema registry.
- [x] SHA-256 package manifest + checksum/count/schema/FK preview.
- [x] Transactional merge/replace + durable safety snapshot + rollback.
- [x] Production SQLite import store ve LocalDatabase exporter.
- [x] Portable `.ruhcode.zip` codec + zip-slip/CRC/duplicate/zip-bomb guards.
- [x] Atomic local file store.
- [x] Full SQLite export→ZIP→preview→import lifecycle; idempotency; TR/EN machine-data isolation; 2.500 Unicode stress; all-14-table relational fixture; erase→restore raw/domain equality.
- [x] Legacy v0 migrator; unknown birth time midnight'e çevrilmiyor.
- [x] Native platform gateway: OS Save As, picker, native share; `.ruhcode.zip` policy; user cancel nullable.
- [x] **Backup application service:** export→package→ZIP→Save As/share; picker→ZIP decode→strict preview; preview-before-mutation; merge/replace transactional coordinator; user cancellation normal result.
- [x] Application-service unit contract + evidence + structural validator + Backup CI wiring.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Backup TR/EN UI action/state entegrasyonu ve portable-backup etiketlerinin final uyumu.
- [ ] Released historical backup fixture mevcut olduğunda gerçek fixture doğrulaması.
- [ ] `pubspec.lock` gerçek dependency resolution sonrası commit edilmeli; elle uydurulmayacak.

## Son tur — 2026-08-20 10:52

Checkpoint: `automation_runs/2026-08-20_1052_backup_application_service.md`

Yeni application-service kaynak commit zinciri:
- `ee0c660c8f9172eb8f46c627ff000e86d98c6a12` application service
- `c2efd26359160088aedba1a9ff6e24a3fcb12900` application service tests
- `ffad956e8ee1cc370c21dfa50ad9c3558a03ec78` test cleanup
- `bd97df39932be7c716cec2bfa4d3f905049c683f` evidence
- `7911d07692b3a05d61e1895ba86be1c9f9575ef0` structural validator
- `e6b84549f16ff3bd9e64f97b676c175b9951d723` Backup CI wiring
- `0b0493f0982afa57e3189c9486148d94ee42e610` run checkpoint

GitHub combined-status `e6b84549...` için yine `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

## Açık fiziksel/evidence blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] GeoNames source/output SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal Günün Mesajı kaydı.
- [ ] Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI referans seti.

## Sıradaki çalışma

1. Exact workflow sonucu görünür kırmızı olursa aynı turda düzelt.
2. Backup action/state sözleşmesini application service ile eşleştir; `CSV Dışa Aktar/İçe Aktar` gibi artık yanıltıcı olabilecek UI etiketlerini gerçek portable backup davranışına göre düzelt.
3. TR/EN backup state metinlerini ve cancellation/success/invalid-preview/rollback/share-unavailable durumlarını bağla.
4. Gerçek dependency resolution mümkün olduğunda `pubspec.lock` üret ve clean-checkout gate'e ekle.
5. Backup hattı sonrası Faz 23 profesyonel PDF motoruna ilerle.
6. Paralelde physical astronomy/GeoNames/daily-message/UI-reference blocker'larını ilerlet.
7. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.
