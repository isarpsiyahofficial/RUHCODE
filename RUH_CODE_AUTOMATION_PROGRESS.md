# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0030** için physical TESTED promotion görmüş satırlar matrix gerçeğine göre korunur; global astronomy/location/UI/release blocker'ları açık kalır.
- Semantic reconciliation tamamlandı: exact binding anlamıyla **RC-0036→0041, RC-0043, RC-0045, RC-0047 ve RC-0050 = TESTED + blocked=YES**; shifted/non-matching kanıt taşıyan **RC-0042/0044/0046/0048/0049 = NOT_STARTED** olarak konservatif biçimde bırakıldı.

## Bu turdaki gerçek geliştirme

### RC-0031→RC-0035 — Western placements / signs / degrees / houses

Mevcut `WesternNatalPlacements` runtime'ı fiziksel ephemeris state'lerinden her body için longitude, tropical sign, degree-in-sign ve calculated house number üretiyor; `HouseCusps` 12 ayrı cusp'ı fail-closed doğruluyor. Önceki kanıt hattına ek olarak exact binding'i yeniden tetikleyen yeni contract/validator/workflow zinciri eklendi:

- `requirements/contracts/rc0031_rc0035_western_placements_contract.json`
- `tools/requirements/validate_rc0031_rc0035_western_placements.py`
- `.github/workflows/rc0031-rc0035-western-placements.yml`

Commitler: `9ed43fc04ccef6d256bbd36bbe95c10c34efc38c`, `f3a615923aa412e5896b262a086da2d66fbb86a9`, `7e730ff11faba775701b958153c7c26757173526`.

Physical bot promotion görülmeden RC-0031→0035 TESTED sayılmayacak.

### RC-0052 / RC-0053 — Gezegen ve ev derece tabloları

Yeni production model `lib/src/calculation_core/western/degree_tables.dart` eklendi. `WesternDegreeTables.planets()` hesaplanmış natal placement snapshot'ından body/longitude/sign/degree-in-sign/house number satırları; `WesternDegreeTables.houses()` ise `HouseCusps` üzerinden tam 12 numaralı cusp/sign/degree-in-sign satırı üretir. Compiled regresyon: `test/calculation_core/western/degree_tables_test.dart`.

Binding/evidence zinciri:

- `requirements/contracts/rc0052_rc0053_degree_tables_contract.json`
- `tools/requirements/validate_rc0052_rc0053_degree_tables.py`
- `.github/workflows/rc0052-rc0053-degree-tables.yml`

Commitler: `5c90d70719b35dce05225a85ec1d754e85c3d605`, `c0221bfa4f2b1154aa4cf39dc7f8c62b979802a6`, `726a92c6d1a18859212e290780aa1901146b5dcc`, `0e05429dc9aab8acea380d2433ad3c084d0d0672`, `15a0916b710532c73e83962e96082bb42683a9ac`.

Physical CI + matrix promotion görülmeden RC-0052/0053 TESTED sayılmayacak.

### RC-0054→RC-0056 — Placidus / Whole Sign / Equal House

Mevcut production `placidus_houses.dart` ile `equal_house_systems.dart` ayrı executable house-system yolları olarak exact requirement kanıtına bağlandı. Binding contract/validator/compiled gate:

- `requirements/contracts/rc0054_rc0056_house_systems_contract.json`
- `tools/requirements/validate_rc0054_rc0056_house_systems.py`
- `.github/workflows/rc0054-rc0056-house-systems.yml`

Commitler: `8cf013266dcc5f829ab3f0a12fb224303d48adcb`, `33b19665457d092bec5e332695bac4fa7b14e9e5`, `025c2ee440a058710cd68b3fee0a449b77b82895`.

Physical CI + matrix promotion görülmeden RC-0054/0055/0056 TESTED sayılmayacak.

## Açık product-facing Western maddeleri

- RC-0042 professional minor-aspect settings.
- RC-0044 professional user-editable orb settings + persistence/entitlement/UI.
- RC-0046 Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- RC-0048 retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- RC-0049 planetary rulerships'in ürün yüzeyinde gösterilebilmesi.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0031→0035, RC-0052/0053 ve RC-0054→0056 dedicated CI sonuçları + physical bot matrix promotion commitleri doğrulanacak; kırmızıysa job/log kök nedeni aynı turda düzeltilecek.
3. Açık product-facing RC-0042/0044/0046/0048/0049 gerçekten uygulanacak.
4. Ardından dependency sırası RC-0057+ ile devam edecek.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
