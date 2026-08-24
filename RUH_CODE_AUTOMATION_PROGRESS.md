# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya güncel source-level checkpoint'i özetler. Ayrıntılı çalışma geçmişi `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md` ve `RUH_CODE_MASTER_TODO.md` dosyalarıdır.

**Kural:** `SOURCE_LEVEL_IMPLEMENTED` veya matrix'teki `IMPLEMENTED`, requirement'ın DONE olduğu anlamına gelmez. `DONE` yalnız explicit state + gerekli test/golden/device/release kanıtı ile verilebilir.

## Requirement traceability — güncel

- Kapsam exact `RC-0001 → RC-1442`.
- Evidence yalnız ilgili RC'yi en fazla `IMPLEMENTED` seviyesine çıkarabilir; source-level kanıt otomatik TESTED/VERIFIED/DONE üretmez.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktiftir.
- PDF/backup/UI/Western/combined semantic validator'ları merkezi Requirements Contract'a bağlıdır.
- Visible combined PDF runtime/action/accessibility validator'ı da merkezi Requirements Contract'a bağlıdır.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar / leap-year / exact-date identity.
- UTC/TT/UT1/sidereal-time provider sınırları.
- Ephemeris/EOP strict provider sözleşmeleri.
- Solar events ve Gezegen Saatleri.
- DailySnapshot: planetary hour, Moon phase/sign, Personal Day, transit ve Vedik daily primitives.
- Western: ASC/MC, Whole Sign/Equal/Porphyry/strict Placidus, placements, aspects/orbs, distribution, aspect grid, dignity/rulership, sealed persisted natal snapshot ve atomic manifest persistence.
- Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, name metrics, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity.
- BaZi primitives: stems/branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- Çin Astrolojisi basic year core.
- Entitlement: canonical Feature IDs, UI/route/service guards, offline entitlement snapshot/time anchor, Play lifetime restore composition, rewarded cancel/failure safety.
- Backup: strict CSV, 15-table schema, manifest/checksum/FK preview, transactional merge/replace/rollback, SQLite export/import, `.ruhcode.zip`, native save/pick/share, legacy migration, tek-tabla CSV export.
- Professional PDF: local planning/renderer contracts, preview→build parity, persisted Numerology/Western handlers, structural inspection, native delivery, subject/snapshot parity ve page geometry validation.
- Combined PDF: persisted Western + Pythagorean projection, localized system separation, guarded multi-record preview/build, görünür Flutter route, exact-preview native delivery ve action/accessibility sözleşmesi.

## Combined PDF — güncel

`RC-0903` ve `RC-0904` source-level evidence altında, DONE değil:

- en az iki **farklı calculation system** zorunlu,
- iki aynı-system kayıt subject discovery, selection-state ve visible Preview disabled-state seviyesinde yeterli sayılmıyor,
- child calculations PDF sırasında yeniden hesaplanmıyor,
- exact persisted Western + Pythagorean snapshot/provenance doğrulanıyor,
- tüm member snapshot'lar aynı stable `subjectKind + subjectId` değerine ait olmalı,
- child digest/collision/shared-section kontrolleri fail-closed,
- exact child identities deterministic combined SHA-256 üretiyor,
- TR/EN child ve visible section başlıkları ayrı,
- combined application service canonical `pdf.professional_export` PRO guard kullanıyor,
- preview exact record IDs + locale + subject + composite digest + systems + section order mühürlüyor,
- subject/record/locale/section değişikliği sealed preview'ı geçersiz kılıyor,
- build persisted records'ı yeniden yükleyip digest/system/section drift varsa reddediyor,
- production runtime combined application + native delivery bridge'ini gerçek SQLite snapshot source ile kuruyor,
- görünür `CombinedProfessionalPdfBuilderPage` `/pdf/combined` route'una bağlı,
- `Profil → Ayarlar → Kombine PDF Raporu` canonical PRO-guarded route action'ı mevcut,
- Free route reddi ve PRO route erişimi widget regression'a bağlı,
- Save As/share `sealedPreviewForDelivery()` ile current selection'ı tekrar doğruluyor,
- route/preview/create/save/share canonical ACTION-ID'leri action registry + runtime binding manifestine bağlı,
- kritik combined kontroller Semantics + minimum 48dp kullanıyor,
- 2.0x text-scale ve EN section-label leakage regression'ları eklendi,
- approved font/render zinciri hazır değilken combined byte üretimi fail-closed.

`RC-0905` bilinçli olarak açık: gerçek persisted Vedik PDF sistemi olmadan “Batı sonucu Vedik sonuç gibi gösterilmeyecek” requirement'ı sahiplenilmiyor.

## PDF structural — güncel

- `/Pages /Count` actual Page sayısıyla eşleşmek zorunda.
- final `%%EOF`, `startxref`, xref/XRef target zorunlu.
- xref `/Root` exact Catalog nesnesine, Catalog `/Pages` exact Pages-tree nesnesine çözülmek zorunda.
- Page Parent zinciri doğrulanıyor.
- `/MediaBox` gerçek planlanan sayfa geometrisiyle eşleşmek zorunda.
- `RC-0952` bağımsız full-parser/open kanıtı olmadan açık.

## UI / Accessibility — açık kalanlar

- Canonical ana navigasyon: `Bugün · Araçlar · Kayıtlar · Profil`.
- Design token contrast, 48dp, Semantics ve kritik 2.0x text-scale kaynak sözleşmeleri mevcut.
- Combined PDF görünür multi-select route artık source-level bağlı ve test sözleşmesine sahip.
- APPROVED final UI PNG/reference/hash seti tamamlanmadı.
- Real-device screen-reader/focus traversal ve tam visual regression açık.

## Backup — açık kalanlar

- Android gerçek cihaz save/pick/share smoke proof.
- Release-candidate clean-install export→erase→restore proof.
- Exact visible Backup/UI/Flutter CI success.

## PDF — açık kalanlar

- Production Unicode TR/EN font binary + license + immutable SHA.
- Independent full PDF parser/open proof.
- Western production vector painter + approved glyph assets.
- Vedic vector chart / persisted Vedic PDF schema.
- BaZi production tables gereken kapsamda tamamlanmalı.
- 5/25/50+ gerçek rendered PDF, low-memory, glyph/crop/visual regression.
- gerçek cihaz Save As/share smoke evidence.

## Fiziksel veri / içerik blocker'ları

- versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- ticari yeniden dağıtıma uygun offline ephemeris artifact.
- production Lahiri/Chitrapaksha artifact.
- GeoNames source/output SHA + bulk IANA integrity.
- independent astronomical golden accuracy suite.
- 4.018 TR + bağımsız 4.018 EN gerçek editoryal Günün Mesajı.
- 1890–2110 verified Chinese New Year boundary artifact.

## Release blocker'ları

- APPROVED UI reference/hash seti.
- Production PDF font artifact.
- Exact görünür GitHub Actions SUCCESS kanıtları.
- `pubspec.lock` yalnız gerçek dependency resolution sonrası.
- Play/rewarded real-device proof.
- clean-checkout/reproducible release APK.
- airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint

`automation_runs/2026-08-24_0655_combined_pdf_visible_ui_route.md`

Latest dedicated workflow-target `62ff34493459bd0dc80191b5c76f26993f73f92a` için GitHub combined status `statuses=[]` döndürdü. Exact görünür SUCCESS olmadığı için `RC-0903/0904` veya global accessibility/action requirement'ları DONE yapılmadı.

## Sıradaki çalışma

1. Combined evidence semantic ownership auditini sürdür; `RC-0905`'i persisted Vedik PDF olmadan sahiplenme.
2. Doğrulanmış persisted Vedik schema yoksa format uydurma; başka blocker-dışı requirement'a geç.
3. PDF/UI/accessibility/evidence işlerini sürdür.
4. Daily-message editorial catalog işini release completeness gate'i kırmadan staging/editoryal akışta ilerlet.
5. Fiziksel artifact/font/UI blocker'larında kanıtsız DONE verme.

**FINAL: NO.**
