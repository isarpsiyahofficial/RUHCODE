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

## Free / PRO / temporary entitlement — Faz 21 source-level

- [x] Merkezi canonical `RuhFeatureIds` kataloğu.
- [x] Her canonical ID için tek Free/PRO base policy.
- [x] Unknown feature ID fail-closed.
- [x] PRO snapshot bütün canonical özellikleri açıyor.
- [x] Temporary unlock yalnız açıkça izin verilen PRO feature'larda çalışıyor.
- [x] Temporary grant exact UTC expiry ile bitiyor; non-UTC expiry/clock reddediliyor.
- [x] Professional client/preset alanları temporary/ad grant ile açılamıyor.
- [x] Offline `LocalEntitlementSnapshotStore` dedicated `system_entitlement_state` logical table üzerinde mevcut.
- [x] Entitlement save/load/clear işlemlerinin profile/client/note gibi user-domain tablolarını değiştirmemesi source-level test sözleşmesine bağlı.
- [x] Entitlement unit tests + evidence + structural validator + ayrı CI workflow mevcut.
- [ ] Google Play purchase ownership restore / reinstall / device-change doğrulaması.
- [ ] Serverless sınırlar içinde rollback-resistant local time anchor.
- [ ] UI, route ve service guard'larının aynı `EntitlementService` kaynağına bağlanması.
- [ ] Production SQLite üzerinde Free↔PRO geçişlerinde bütün kullanıcı verisinin değişmediğini integration test et.
- [ ] Rewarded-ad failure/cancel durumunun entitlement state'i bozmamasını kanıtla.
- [ ] Exact workflow + release-mode Free/PRO/temporary matrix SUCCESS görünür kanıtı.

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
- [x] Replace restore hatası typed `BackupRestoreException` ile gerçek rollback sonucunu taşıyor; rollback başarısızken UI'nın “geri yüklendi” demesi engellendi.
- [x] Backup UI test/evidence/structural validator ve Backup CI wiring eklendi.
- [x] Primary `ui/action_registry.csv` portable full-backup davranışıyla hizalandı: `Tam Yedek Oluştur` / `Yedekten Geri Yükle`.
- [x] Legacy `CSV Dışa Aktar / CSV İçe Aktar` wording'in primary action registry'ye geri girmesini engelleyen validator + UI CI gate eklendi.
- [ ] Exact workflow SUCCESS görünür değil; ilgili Backup RC'leri DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Approved backup UI reference PNG/state seti.
- [ ] Released historical backup fixture mevcut olduğunda gerçek fixture doğrulaması.
- [ ] `pubspec.lock` gerçek dependency resolution sonrası commit edilmeli; elle uydurulmayacak.

## Profesyonel PDF — Faz 23 source-level

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
- [x] PDF planning/data tests + evidence + structural validator + ayrı CI workflow mevcut.
- [x] Production local PDF byte renderer source-level eklendi; yerel `pdf` package üzerinden gerçek byte üretim yolu mevcut.
- [x] `PdfLocalReportService` planning/data contract → font provider → byte renderer zincirini mevcut `PdfService` arayüzüne bağladı.
- [x] Font byte'larında SHA-256 doğrulaması ve family/license ID zorunluluğu var.
- [x] `PdfAssetFontBundleProvider` TR + EN için explicit asset spec zorunlu kılıyor ve asset byte'larını yükleme sonrası SHA-256 ile tekrar doğruluyor.
- [x] Page-number footer ve A4 local renderer yolu mevcut.
- [x] 50+ rapor gereksinimi için explicit `maxReportPages = 200` safety ceiling tanımlandı.
- [x] Section heading orphan prevention için minimum remaining-space page break + inseparable heading/first-paragraph sözleşmesi eklendi.
- [x] Western PDF normalized vector geometry adapter gerçek `WesternNatalChart` house/placement/aspect snapshot'ından türetiliyor; decorative/random geometri yok.
- [x] ASC 9 yönü + counter-clockwise zodiac coordinate contract test/evidence ile kilitlendi.
- [x] `GEOM-PDF-WESTERN-WHEEL` source geometry status `IMPLEMENTED`; painter/golden kanıtı beklediğinden DONE değil.
- [x] Local renderer/font provider/Western geometry source tests + evidence + structural gates PDF CI'a bağlandı.
- [x] `PdfOutputInspector`: generated PDF byte'larında `%PDF-`, `%%EOF`, Catalog, Pages tree ve en az bir gerçek Page object zorunlu; truncated output reddediliyor.
- [x] `PdfTableLayout`: uzun logical tablolar bounded chunk'lara ayrılıyor, header tekrarlanıyor ve kolon genişliği tutarsızlığı render öncesi reddediliyor.
- [x] Output inspector + table layout renderer/evidence/structural validator zincirine bağlandı.
- [ ] Production Unicode TR/EN font binary asset + lisans dosyası + immutable SHA manifesti.
- [ ] Gerçek approved font ile byte-render testi.
- [ ] Western geometry için production vector painter + approved zodiac/planet glyph asset bağlantısı + label collision.
- [ ] Vedik vector chart embedding.
- [ ] BaZi/Numerology table renderers.
- [ ] 5 / 25 / 50+ gerçek page-count testleri ve low-memory test.
- [ ] Full PDF parser/open validation, crop/glyph checks, visual regression.
- [ ] Free sample PDF'nin APPROVED referans tasarımı ve gerçek demo-only wiring'i.
- [ ] Exact workflow SUCCESS görünür kanıtı.

## Son tur — 2026-08-20 16:57

Checkpoint: `automation_runs/2026-08-20_1657_pdf_entitlements.md`

Öne çıkan commitler:
- `86fcc401b59ff6740f99de84e5a4fe24d92cf1e1` PDF output structural inspector
- `c49924802ab78b219fec52741faf7a4b777922a8` inspector tests
- `ceaab74451e059ff28f7c3bce4ce2a5281665b73` deterministic long-table layout
- `8457ce3dead0cdb17a19e54a9d080539d4e5c970` renderer output/table integration
- `d541058f50ce327616adedf19475fe6ee727f74d` PDF evidence extension
- `a481337fca101aa34a88c95a6c7d4954c6733d4b` PDF structural validator extension
- `ca67a8716e5ff917b3f086046850d2629dd90a30` canonical Feature ID/Free-PRO matrix
- `26ad0ed6ef03533b6fd1a92986febb23d5651e94` central entitlement resolver
- `3b8819a926b5cc326e96bef8f8ecc08f7197e5c1` async entitlement test correction
- `3b65a3058d952765c70be560e78f9c0b1a367648` entitlement evidence
- `7bbfb87ec563296b34aba2c1afc7c7060926b38b` entitlement structural validator
- `d4af235f14b53813d2e11eab22d642c0b06ce669` entitlement CI gate
- `8f72fa20dbeaf65412fcf559f7b25745426680de` offline entitlement snapshot store
- `79a0add5ed40eb2f9007420d1e458da5d896dbfc` local entitlement store tests
- `853f99944302bb156ea297b5a227c6693e1b8250` entitlement validator store extension
- `3d9a42fe29a6b0de2dd378de68dbbe1f8446af1a` entitlement offline-store evidence update

GitHub combined-status exact entitlement workflow hedef commit'i için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

## Açık fiziksel/evidence blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- [ ] Pre-1972 Delta-T/time-scale yaklaşımı.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris runtime dataset/lisans/version/checksum.
- [ ] Accuracy-budget limitlerini bağımsız golden data ile kanıtlama.
- [ ] Production Lahiri/Chitrapaksha physical artifact.
- [ ] GeoNames source/output SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal Günün Mesajı kaydı.
- [ ] Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI referans seti.
- [ ] Production Unicode PDF font binary + lisans/hash artifact.

## Sıradaki çalışma

1. Exact workflow sonucu görünür kırmızı olursa aynı turda düzelt; görünmüyorsa SUCCESS uydurma.
2. Entitlement için production SQLite Free↔PRO data-preservation integration testi ve local rollback-resistant time anchor sözleşmesini ekle.
3. UI/route/service feature guard'larını aynı `EntitlementService` kaynağına bağla.
4. Google Play ownership restore/reinstall/device-change akışını resmi purchase API sözleşmesine bağla; cached offline ownership ile network bağımlılığını ayır.
5. Approved Unicode TR/EN font artifact yoksa blocker'ı açık tut; 5/25/50+ PDF fixture/page-count ve parser/crop/glyph kapı altyapısını ilerlet.
6. Western production PDF vector painter + approved glyph bağlantısı; ardından Vedik vector adapter ve BaZi/Numeroloji tabloları.
7. `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit et.
8. Paralelde physical astronomy/GeoNames/daily-message/UI-reference blocker dışı işleri ilerlet.
9. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, entitlement, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.