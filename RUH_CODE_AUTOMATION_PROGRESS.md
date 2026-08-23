# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya güncel source-level checkpoint'i özetler. Ayrıntılı çalışma geçmişi `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md` ve `RUH_CODE_MASTER_TODO.md` dosyalarıdır.

**Kural:** `SOURCE_LEVEL_IMPLEMENTED` veya matrix'teki `IMPLEMENTED`, requirement'ın DONE olduğu anlamına gelmez. `DONE` yalnız explicit state + gerekli test/golden/device/release kanıtı ile verilebilir.

## Requirement traceability — güncel

- Kapsam exact `RC-0001 → RC-1442`.
- `requirement_state.csv` bilinçli olarak sparse explicit override ledger'ıdır.
- `build_requirement_matrix.py` bütün evidence JSON'larını tarayıp source-level kanıtı olan RC'leri en fazla `IMPLEMENTED` olarak türetir.
- Auto-evidence hiçbir zaman `TESTED`, `VERIFIED` veya `DONE` üretmez.
- `validate_matrix_provenance.py`, auto-IMPLEMENTED satırın gerçekten aynı RC'yi sahiplenen evidence JSON'una bağlı olduğunu doğrular.
- Requirements Contract 1.442 satırlık generated matrix'i Actions artifact'i olarak saklayacak.
- Evidence integrity validator `sources/tests/validators` yanında `source_files/sourceFiles/test_files/testFiles` ve tekil repo-path biçimlerini de doğrular.
- PDF semantic gate'teki stale RC ownership listeleri güncel evidence dosyalarıyla eşitlendi.
- `page_geometry_contract.json` artık ayrı MASTER-aware semantic gate ile exact `RC-0878/0879` sahipliğine kilitli.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar / leap-year / exact-date identity.
- UTC/TT/UT1/sidereal-time provider sınırları.
- Ephemeris/EOP strict provider sözleşmeleri.
- Solar events ve Gezegen Saatleri.
- DailySnapshot: planetary hour, Moon phase/sign, Personal Day, transit ve Vedik daily primitives.
- Western: ASC/MC, Whole Sign/Equal/Porphyry/strict Placidus, placements, aspects/orbs, distribution, aspect grid, dignity/rulership, sealed persisted natal snapshot ve atomic manifest persistence.
- Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, name metrics, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity.
- BaZi primitives: stems/branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- Çin Astrolojisi basic year core: 12 hayvan, element, Yin/Yang, exact Chinese New Year boundary, checksum/coverage-validated boundary dataset loader.
- Entitlement: canonical Feature IDs, UI/route/service guards, offline entitlement snapshot/time anchor, Play lifetime restore composition, rewarded cancel/failure safety.
- Backup: strict CSV, 15-table schema, manifest/checksum/FK preview, transactional merge/replace/rollback, SQLite export/import, `.ruhcode.zip`, native save/pick/share, legacy migration, tek-tabla CSV export.
- Professional PDF: local report planning/renderer contracts, preview→build parity, persisted Numerology/Western handlers, structural PDF inspection, native delivery, strong subject/snapshot parity, serialized page geometry validation.

## PDF structural — güncel

- `/Pages /Count` actual Page sayısıyla eşleşmek zorunda.
- final `%%EOF`, `startxref`, xref/XRef target zorunlu.
- xref `/Root` exact Catalog object/generation'a çözülmek zorunda.
- Catalog `/Pages` exact Pages-tree object/generation'a çözülmek zorunda.
- her gerçek `/Type /Page`, indirect `/Parent` taşımak zorunda.
- her Page Parent exact `/Type /Pages` object/generation'a çözülmek zorunda.
- missing Parent veya Catalog/non-Pages Parent fail-closed.
- serialized `/MediaBox` gerçek planlanan sayfa geometrisiyle eşleşmek zorunda; A4 planından Letter çıktısı gibi format drift fail-closed.
- `RC-0878/0879` page-geometry evidence exact semantic ownership ile merkezi Requirements Contract'a bağlı.
- dedicated `PDF Structural Contract` workflow source validator + Flutter inspector regressionlarını çalıştıracak.
- `RC-0952` bağımsız full-parser/open kanıtı olmadan açık.

## Çin Astrolojisi — güncel

`RC-0137 → RC-0142` source-level evidence altında:

- 12 hayvan döngüsü.
- Çin burcu, element ve Yin/Yang year-stem mantığı.
- 1984 Jia-Zi anchor ile sexagenary year index.
- civil date, exact Chinese New Year boundary'den önceyse önceki Chinese year kullanılır.
- boundary gününde yeni Chinese year başlar.
- boundary yoksa January 1 / Gregorian year / nearest-year fallback yasak.
- basic Chinese zodiac modülü BaZi Four Pillars runtime'ından ayrı.
- reviewed fixture boundaries: `2024-02-10`, `2025-01-29`, `2026-02-17`.
- bundled dataset loader SHA-256, schemaVersion, source/data version, min/max coverage, duplicate/missing/wrong-year kontrolü yapıyor.

**Açık:** 1890–2110 tam fiziksel Chinese New Year boundary artifact'i ve bağımsız multi-century golden doğrulama yok; bu nedenle DONE değildir.

## UI / Accessibility — açık kalanlar

- Canonical ana navigasyon: `Bugün · Araçlar · Kayıtlar · Profil`.
- Design token contrast ve 48dp/semantics kaynak sözleşmeleri mevcut.
- 2.0x text-scale kritik yüzeylerin bir kısmında regression mevcut.
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

`automation_runs/2026-08-23_1853_pdf_page_geometry_traceability.md`

Bu turda PDF page geometry evidence exact `RC-0878/0879` semantic ownership'a kilitlendi ve merkezi Requirements Contract'a bağlandı. Evidence approved-font rendered fixture, visual regression, device-open ve exact CI kanıtı olmadan DONE olamaz.

Workflow-target commit `6baed733344eb932f34c59cd709b79b975ec1439` için GitHub combined-status yine `statuses=[]` döndürdüğü için hiçbir ilgili requirement DONE yapılmadı.

## Sıradaki çalışma

1. Font gerektirmeyen persisted PDF snapshot/data parity regressionlarını genişlet.
2. Kalan evidence semantic ownership drift auditini sürdür.
3. UI/action/accessibility blocker-dışı requirement'ları ilerlet.
4. Fiziksel artifact/font/UI blocker'larında kanıtsız DONE verme.

**FINAL: NO.**
