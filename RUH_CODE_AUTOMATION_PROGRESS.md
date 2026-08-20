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
- [ ] Production Unicode TR/EN font binary asset + lisans dosyası + immutable SHA manifesti.
- [ ] Gerçek approved font ile byte-render testi.
- [ ] Western geometry için production vector painter + approved zodiac/planet glyph asset bağlantısı + label collision.
- [ ] Vedik vector chart embedding.
- [ ] BaZi/Numerology table renderers.
- [ ] Table split prevention için gerçek uzun-table render/regression kanıtı.
- [ ] 5 / 25 / 50+ gerçek page-count testleri ve low-memory test.
- [ ] PDF open/parse validation, crop/glyph checks, visual regression.
- [ ] Free sample PDF'nin APPROVED referans tasarımı ve gerçek demo-only wiring'i.
- [ ] Exact workflow SUCCESS görünür kanıtı.

## Son tur — 2026-08-20 14:56

Checkpoint: `automation_runs/2026-08-20_1456_backup_registry_pdf_renderer.md`

Öne çıkan commitler:
- `7d8f23e0491f3a0821eafc47a7ea2ef89f9ca3e0` local PDF dependency
- `fe74cf58b8dccca48b23023ca240bc115468e15e` local PDF byte renderer
- `93f7a19079b9ad97daf6dd04e6d007dc754ca11d` portable backup action labels
- `88666955fdb9adb3e485067b05b848185e23a390` renderer contract tests
- `3068f19619cdb89dea0cab35aca30ce501cab69f` renderer evidence
- `84d0c173a04bf85bde83d127249e6fa6030fabad` backup action wording validator
- `ccae7354789833171f88fe03d9c64eb7e7a4d052` UI CI wiring
- `60d5c317410a091893763e3f5330e1c7ee351b30` PDF local report service
- `953553628f38a92985749ec124ca6303651f10e9` verified asset font provider
- `d22ea908ecf195f954745a568913896d30a7e48d` renderer test syntax fix
- `11c70e0191740fc0166dfabc31365a148d215c4f` font provider tests
- `2a27c425ae7ed04e497a5acbd11a59f22de4c49e` PDF service/font structural gate
- `2ab7e9cfa60986dd9ba4cb46a430c0a6b46657fb` long-report pagination safeguards
- `aa0a37c5aa2d760fa7e17af3be6e9a5478112712` pagination evidence update
- `06de5176e2bf4f114d22864e9ed2e7a0f2657b87` pagination structural gate
- `a2431e5bd472ca735254040a2cd872b8f1e88728` Western PDF geometry adapter
- `89f1e5799bef03a5f1557b3682aab62efc461d84` Western geometry orientation fix
- `ec072984cafa4930839c2b71010934e692664a42` Western geometry tests
- `4b9cff70b1f5ff57e11350e45b0c32303f1320c4` dynamic geometry manifest progress
- `2e14f2adfe60302cfc868480fd6b89405b9678bf` Western geometry evidence
- `f116a399631708655ee84180de8de07631b1f4c5` Western geometry structural validator
- `fb4155a3ebff1cdf688261b13ec4fd0866270129` Western PDF geometry CI gate
- `0fada9ba15dadf3d4d57345c47a2c518e698511a` extended run checkpoint

GitHub combined-status exact UI workflow hedef commit'i için `statuses=[]` döndürdü; SUCCESS uydurulmadı ve requirement state yapay biçimde yükseltilmedi.

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
2. Approved Unicode TR/EN font asset + license + SHA-256 manifestini gerçek artifact ile bağla; binary artifact yoksa blocker'ı açık tut.
3. Gerçek fontla 5/25/50+ PDF byte generation ve parse/open testlerini kur.
4. Uzun table pagination, missing glyph, crop ve visual regression kapılarını ekle.
5. Western geometry modelini approved glyph assetlerini kullanan production PDF vector painter'a bağla; golden onay olmadan görseli final sayma.
6. Vedik dynamic vector geometry'yi aynı calculation snapshot üzerinden PDF adapterına bağla.
7. BaZi/Numerology tablolarını gerçek PDF layout'a bağla.
8. `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit et.
9. Paralelde physical astronomy/GeoNames/daily-message/UI-reference blocker dışı işleri ilerlet.
10. Requirement state'e yalnız gerçek workflow/test/evidence kanıtı alınan RC'leri yükselt.

## Final durumu

**FINAL DEĞİL.** Master requirement, içerik, UI, backup/PDF, security, offline, physical astronomy evidence ve release fazları tamamlanmadan proje FINAL olmayacak.