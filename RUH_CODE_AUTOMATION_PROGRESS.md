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
- [x] Backup application service: export→package→ZIP→Save As/share; picker→ZIP decode→strict preview; preview-before-mutation; merge/replace transactional coordinator; user cancellation normal result.
- [x] TR/EN backup UI copy/state contract: full backup/save/share/select/merge/replace/cancel; invalid-preview/share-unavailable/rollback-restored durumları ayrıldı.
- [x] Replace restore hatası artık typed `BackupRestoreException` ile gerçek rollback sonucunu taşıyor; rollback başarısızken UI'nın “geri yüklendi” demesi engellendi.
- [x] Backup UI test/evidence/structural validator ve Backup CI wiring eklendi.
- [ ] Primary `ui/action_registry.csv` içinde eski `CSV Dışa Aktar / CSV İçe Aktar` wording hâlâ bulunuyor; registry migrasyonu açık.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Approved backup UI reference PNG/state seti.
- [ ] Released historical backup fixture mevcut olduğunda gerçek fixture doğrulaması.
- [ ] `pubspec.lock` gerçek dependency resolution sonrası commit edilmeli; elle uydurulmayacak.

## Profesyonel PDF — Faz 23 source-level başlangıç

- [x] A4 `210×297 mm` page contract + deterministik margin/content geometry.
- [x] Typography hierarchy token sözleşmesi.
- [x] Canonical section ID'leri.
- [x] User-selected section ordering.
- [x] Empty-section suppression.
- [x] Professional / client-friendly cover style ayrımı.
- [x] Optional professional/brand/logo metadata contract.
- [x] PDF v1 locale contract yalnız `tr` ve `en`.
- [x] Sample PDF yalnız demo origin; gerçek rapor yalnız user origin.
- [x] PDF section'larının tek exact calculation snapshot SHA-256 identity'sine bağlı olması zorunlu.
- [x] Cross-snapshot/client section mixing render öncesi reddediliyor.
- [x] UI ve PDF calculation snapshot parity guard mevcut.
- [x] PDF planning/data tests + evidence + structural validator + ayrı CI workflow eklendi.
- [ ] Production local PDF byte renderer.
- [ ] Unicode TR/EN font asset + lisans/hash manifesti.
- [ ] Western/Vedic vector chart embedding.
- [ ] BaZi/Numerology table renderers.
- [ ] Cover/section/page-number renderer.
- [ ] Controlled pagination, orphan prevention, table split prevention.
- [ ] 5 / 25 / 50+ page tests ve low-memory test.
- [ ] PDF open/parse validation, crop/glyph checks, visual regression.
- [ ] Free sample PDF'nin APPROVED referans tasarımı ve gerçek demo-only wiring'i.
- [ ] Exact workflow SUCCESS görünür kanıtı.

## Son tur — 2026-08-20 12:56

Checkpoint: `automation_runs/2026-08-20_1256_backup_ui_pdf_foundations.md`

Öne çıkan commitler:
- `9786ca1621ea237e79b16c37ab42663211392908` backup UI contract API düzeltmesi
- `c16858da1750f320a73a2f047730b7c2cfe7d0cc` backup UI tests
- `ecedb9e9655c5edf806b58d8011a05c14b250d0e` backup UI structural validator
- `29495f1b1b29907aea26bdc8eb732c9e3d58c16a` Backup CI UI wiring
- `3f2f64e2834f2dd668ac5b7b738dc72db307e255` typed rollback exception
- `f818ed2c7acdb134242cdc5a0d128cabe3d8aaf2` rollback outcome tests
- `afd69af6ca2716ef728a735434373a97587059da` rollback→UI state mapping
- `5f0e2640f91eead02e68e7abab13eb1945364205` backup UI rollback mapping tests
- `5e5c4e8fde457215e1d0f607f629951ccec1c099` PDF report planning contract
- `dc8e798c28f1b46b3ff6ad109fcddbf78bcf0542` PDF planning tests
- `47aa2b564e43cd1f85df6b9e6df3970f99475088` PDF CI workflow
- `e4f281212a6567811df5ca595c2e921698475de7` PDF snapshot data contract
- `70c6eab92d0e49871edd8f1397a52060cfae22aa` PDF snapshot isolation tests
- `6c1f83cc4bbedce678abfbd2401babc41190dcfa` PDF structural validator expansion
- `413df63c61c9cbc89cbaf723ec808c39a22701c5` run checkpoint

GitHub combined-status latest test commit için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. Primary `ui/action_registry.csv` portable-backup wording/action IDs ile migrate et; eski CSV etiketi kullanıcıya görünür contract'ta kalmasın.
3. Gerçek dependency resolution mümkün olduğunda `pubspec.lock` üret ve clean-checkout gate'e ekle.
4. Faz 23: local PDF byte renderer + bundled Unicode font lisans/hash contract kur.
5. Cover/section/page-number/pagination renderer'ını kur; ardından Western/Vedic vector chart adapterlarına geç.
6. PDF 5/25/50+ page, parse/render, missing-glyph, crop ve visual-regression testlerini ekle.
7. Paralelde physical astronomy/GeoNames/daily-message/UI-reference blocker'larını ilerlet.
8. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.