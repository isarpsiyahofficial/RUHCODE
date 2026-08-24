# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya güncel source-level checkpoint'i özetler. Ayrıntılı çalışma geçmişi `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md` ve `RUH_CODE_MASTER_TODO.md` dosyalarıdır.

**Kural:** `SOURCE_LEVEL_IMPLEMENTED` veya matrix'teki `IMPLEMENTED`, requirement'ın DONE olduğu anlamına gelmez. `DONE` yalnız explicit state + gerekli test/golden/device/release kanıtı ile verilebilir.

## Requirement traceability — güncel

- Kapsam exact `RC-0001 → RC-1442`.
- `requirement_state.csv` sparse explicit override ledger'ıdır.
- Evidence yalnız ilgili RC'yi en fazla `IMPLEMENTED` seviyesine çıkarabilir; source-level kanıt otomatik TESTED/VERIFIED/DONE üretmez.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktiftir.
- PDF/backup/UI/Western/combined semantic validator'ları merkezi Requirements Contract'a bağlıdır.

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
- Combined PDF: persisted Western + Pythagorean projection, localized system separation, guarded multi-record preview/build application service, runtime/UI action bridge, preview invalidation state ve native delivery composition.

## Combined PDF — güncel

`RC-0903` ve `RC-0904` source-level evidence altında, DONE değil:

- en az iki distinct calculation system zorunlu,
- child calculations PDF sırasında yeniden hesaplanmıyor,
- exact persisted Western + Pythagorean snapshot/provenance doğrulanıyor,
- yeni Western kayıtları explicit `subjectKind=profile|client` saklıyor,
- legacy Western subjectKind'sız kayıt yalnız profile kabul ediliyor,
- Western projector hard-coded profile kullanmıyor,
- tüm member snapshot'lar aynı stable `subjectKind + subjectId` değerine ait olmalı,
- aynı kişiye ait candidate catalog subject kind + stable ID ile filtreleniyor,
- child digest/collision/shared-section kontrolleri fail-closed,
- exact child identities deterministic combined SHA-256 üretiyor,
- TR/EN child başlıkları açık `Batı Astrolojisi / Western Astrology` ve `Numeroloji / Numerology` prefix'i taşıyor,
- combined application service canonical `pdf.professional_export` PRO guard kullanıyor,
- preview exact record IDs + locale + subject + composite digest + systems + section order mühürlüyor,
- build persisted records'ı yeniden yükleyip digest/system/section drift varsa reddediyor,
- production runtime persisted combined projection + application service'i gerçek SQLite snapshot source ile kuruyor,
- UI-safe action bridge subject discovery/candidate/preview/build sınırlarını expose ediyor,
- subject/record/locale/section değişikliği sealed preview'ı anında geçersiz kılıyor,
- native Save As/share exact preview token üzerinden yeniden build doğrulamasına giriyor,
- approved font/render zinciri hazır değilken combined byte üretimi açıkça fail-closed.

`RC-0905` bilinçli olarak açık: gerçek persisted Vedik PDF sistemi olmadan “Batı sonucu Vedik gibi gösterilmez” requirement'ı sahiplenilmiyor.

## PDF structural — güncel

- `/Pages /Count` actual Page sayısıyla eşleşmek zorunda.
- final `%%EOF`, `startxref`, xref/XRef target zorunlu.
- xref `/Root` exact Catalog nesnesine çözülmek zorunda.
- Catalog `/Pages` exact Pages-tree nesnesine çözülmek zorunda.
- Page Parent zinciri doğrulanıyor.
- `/MediaBox` gerçek planlanan sayfa geometrisiyle eşleşmek zorunda.
- `RC-0952` bağımsız full-parser/open kanıtı olmadan açık.

## UI / Accessibility — açık kalanlar

- Canonical ana navigasyon: `Bugün · Araçlar · Kayıtlar · Profil`.
- Design token contrast, 48dp, Semantics ve kritik 2.0x text-scale kaynak sözleşmeleri mevcut.
- Combined PDF için final görünür multi-select Flutter page/route henüz bağlanmadı.
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
- Vedic vector chart / BaZi production tables gereken kapsamda tamamlanmalı.
- 5/25/50+ gerçek rendered PDF, low-memory, glyph/crop/visual regression.
- gerçek cihaz Save As/share smoke evidence.
- combined final visible multi-select builder UI/route ve approved-font renderer.

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

`automation_runs/2026-08-24_0452_combined_pdf_runtime_selection_delivery.md`

Combined UI Runtime Contract için exact görünür GitHub Actions SUCCESS kanıtı henüz olmadığı için `RC-0903/0904` DONE yapılmadı.

## Sıradaki çalışma

1. Gerçek Flutter combined multi-select page/route oluştur ve runtime binding'e bağla.
2. 48dp + Semantics + 2.0x text-scale widget contract ekle.
3. Combined Save As/share UI actions'ı exact preview token üzerinden bağla.
4. RC-0905'i persisted Vedik PDF sistemi olmadan sahiplenme.
5. Fiziksel artifact/font/UI blocker'larında kanıtsız DONE verme; bağımsız işlere devam et.

**FINAL: NO.**
