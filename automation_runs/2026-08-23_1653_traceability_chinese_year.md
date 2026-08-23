# Ruh Code Automation Checkpoint — 2026-08-23

## 1.442 requirement traceability zinciri sertleştirildi

Bu turda `requirements/requirement_state.csv` dosyasının yalnız başlık taşıdığı ve generated `requirements/requirement_matrix.csv` dosyasının repository'de tutulmadığı görüldü. Sparse state override yaklaşımı korunurken matrix'in gerçek source-level ilerlemeyi kaybetmemesi için üretim zinciri değiştirildi.

`tools/requirements/build_requirement_matrix.py` artık `evidence/**/*.json` sözleşmelerini tarıyor:

- `SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED / TESTED / VERIFIED` evidence bir RC'yi sahipleniyorsa ve explicit state override yoksa matrix o RC'yi yalnız `IMPLEMENTED` olarak gösterir.
- Auto-evidence hiçbir zaman `TESTED`, `VERIFIED` veya `DONE` üretmez.
- Non-default durumda evidence link zorunludur.
- Explicit `requirement_state.csv` override her zaman önceliklidir.
- `DONE` yalnız explicit state override + evidence link ile mümkündür.

Yeni `tools/requirements/validate_matrix_provenance.py`:

- 1.442 exact ordered RC satırını doğrular,
- auto-IMPLEMENTED satırın gerçek `evidence/*.json` dosyasına bağlı olmasını zorunlu kılar,
- linked evidence'ın gerçekten aynı RC'yi sahiplenmesini kontrol eder,
- auto-derived DONE'u yasaklar.

`Requirements Contract` generated matrix'i artık `ruh-code-requirement-matrix` Actions artifact'i olarak saklayacak.

`requirements/README.md` ile sparse state / generated matrix / explicit-only DONE semantiği repository içinde belgelendi.

## Repository-wide evidence path bütünlüğü genişletildi

`validate_evidence_integrity.py` yalnız `sources/tests/validators` alanlarını kontrol ediyordu. Evidence ailesinde kullanılan diğer gerçek biçimler de artık kontrol ediliyor:

- `source_files`, `sourceFiles`, `source_file`, `sourceFile`
- `test_files`, `testFiles`, `test_file`, `testFile`
- `validator_files`, `validatorFiles`, `validator_file`, `validatorFile`
- repository yolu olduğu açık olan singular `source`

Path traversal, missing file ve directory-as-file kullanımı fail-closed.

## PDF structural gate ilerledi

Önceki checkpoint'teki Root→Catalog→Pages kontrolüne ek olarak her gerçek `/Type /Page` nesnesi:

- indirect `/Parent n n R` taşımak,
- Parent exact object/generation ile gerçek `/Type /Pages` nesnesine çözülmek

zorunda. Missing Parent ve non-Pages Parent regression testleri eklendi. Ayrı `PDF Structural Contract` workflow'u Python structural validator + doğrudan Flutter inspector testini çalıştıracak.

Merkezi PDF semantic evidence gate'teki stale RC sahiplikleri de güncel evidence dosyalarıyla birebir eşitlendi. `RC-0952` independent full-parser/open proof olmadan açık kalır.

## Çin Astrolojisi temel çekirdeği eklendi

MASTER `RC-0137 → RC-0142` için ayrı `calculation_core/chinese` motoru eklendi:

- 12 hayvan sırası,
- Çin yılına bağlı 5 element,
- Yin/Yang polarity,
- 1984 Jia-Zi anchor üzerinden 60 yıllık yıl döngüsü,
- exact Çin Yeni Yılı boundary'sine göre effective Chinese year,
- boundary öncesinde önceki Çin yılının korunması,
- boundary gününde yeni yılın başlaması,
- verified boundary yoksa Gregorian-year veya nearest-date fallback yapmadan fail-closed,
- BaZi runtime'ından ayrı modül ve BaZi import yasağı.

Reviewed regression boundary fixtures:

- 2024-02-10
- 2025-01-29
- 2026-02-17

## Çin Yeni Yılı physical dataset sözleşmesi

`ChineseNewYearDatasetLoader` eklendi:

- external immutable SHA-256 manifest,
- source ID + data version,
- schemaVersion,
- exact minimum/maximum Gregorian coverage,
- strict UTF-8 JSON,
- duplicate/missing/out-of-range/wrong-year boundary rejection,
- declared aralıkta her yıl için kesintisiz coverage zorunluluğu.

Production 1890–2110 boundary artifact'i henüz eklenmedi. Bu yüzden Chinese evidence `done=false` kalır.

## CI görünürlüğü

GitHub combined-status yeni commitlerde yine `statuses=[]` döndürdü. Görünür exact SUCCESS olmadan hiçbir RC DONE yapılmadı.

## Yeni ana commitler

- `183df2a7ad6dd69124380db98c2ab630ca87ecdf` PDF Page parent source
- `ff196f7ad66d9b0623a57c9e99f8065b2ddb814a` PDF parent regressions
- `d15c51c9a90bf9d96498db609de8fefb937cfbb4` stale PDF semantic ownership fix
- `adc70054b9d1957829596600da44a85e5a4c88be` evidence-derived IMPLEMENTED matrix
- `ef4054b5df4f596d272ebbf6ffe290c4beb40437` matrix provenance validator
- `46da4b6701bbbe3283ddd0fd47ea56d77aaec134` requirement matrix CI provenance/artifact gate
- `48cce74e8b9a9852dd4651dd99127764c1bcaa92` evidence path convention hardening
- `8d863d88900fdbe610a8a42ee1bd07cb5c6e313d` Chinese zodiac engine
- `069923d456a6a96e137148e4280965d64ea70d51` Chinese New Year dataset loader
- `149c6f2f330fbb5524c18991517f3ed0cd8f672e` Chinese semantic/data validator
- `bd577f9aeae764642d016df7c4dabb957b5c14b9` Chinese full contract test workflow
- `9fcab075bb8b8bed1f2994d5fe2285a12670bd04` Chinese semantic gate in Requirements Contract
- `af2e0d728b353b7de2f3d8f613c2735eb06b9b12` requirement traceability documentation

## Sıradaki güvenli işler

1. Çin Yeni Yılı production boundary artifact'inin 1890–2110 provenance/licensing stratejisini çöz; sahte veya eksik tarih tablosu ekleme.
2. Kalan requirement-bearing evidence ailelerinde semantic RC ownership drift taramasını sürdür.
3. Font gerektirmeyen PDF persisted snapshot/data parity regressionlarını genişlet.
4. UI/action/accessibility blocker-dışı requirement'ları ilerlet.
5. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI refs, production PDF fonts, Play/rewarded device proof ve clean-release blocker'larını açık tut.

**FINAL: NO.**
