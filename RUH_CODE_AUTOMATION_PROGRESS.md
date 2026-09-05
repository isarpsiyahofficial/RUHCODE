# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0030** için physical TESTED promotion görmüş satırlar matrix gerçeğine göre korunur; global astronomy/location/UI/release blocker'ları açık kalır.
- Semantic reconciliation exact binding anlamıyla korunur: **RC-0036→0041, RC-0043, RC-0045, RC-0047 ve RC-0050 = TESTED + blocked=YES**; **RC-0042/0044/0046/0048/0049 = NOT_STARTED**.
- **RC-0031→RC-0035 = TESTED + blocked=YES**; physical bot promotion commit: `a164a622a8d5db68dada9799b6270aba2cbce300`.
- **RC-0054→RC-0056 = TESTED + blocked=YES**; physical bot promotion commit: `a5deba73bff246c64d93e7d089194c2dc0bdd2ba`.

## Bu turdaki gerçek geliştirme

### RC-0052 / RC-0053 — Degree table gate retrigger

Production `WesternDegreeTables` ve compiled regressions mevcut. İlk dedicated run `33954572079` code/test failure değil, concurrency sırasında `cancelled` kaldı. Exact workflow yeniden tetiklendi:

- `.github/workflows/rc0052-rc0053-degree-tables.yml`
- retrigger commit: `d4c7666dad525a433a266f8fcdc3e5454ed0c8a7`

Physical SUCCESS + matrix promotion görülmeden RC-0052/0053 TESTED sayılmayacak.

### RC-0057→RC-0061 — House-system evaluation / active-system visibility

Yeni production registry:

- `lib/src/calculation_core/western/house_system_catalog.dart`
- commit: `5f8c969b2fbe1e5fe5e373fc409883e764cf87ab`

Registry bütün Western house-system kimliklerini tek yerde tutuyor. Placidus, Whole Sign, Equal ve mevcut executable Porphyry `supported`; Koch, Campanus ve Regiomontanus ise profesyonel olarak değerlendirilmiş fakat authoritative algorithm/golden evidence gelmeden `evaluatedNotImplemented` ve fail-closed. Böylece uygulama doğrulanmamış bir sistemi varmış gibi sunmuyor.

Compiled regression:

- `test/calculation_core/western/house_system_catalog_test.dart`
- commit: `295a59c10de35c6fb39733a6f4af91b0e483024d`

Binding/evidence:

- `requirements/contracts/rc0057_rc0061_house_system_catalog_contract.json`
- `tools/requirements/validate_rc0057_rc0061_house_system_catalog.py`
- `.github/workflows/rc0057-rc0061-house-system-catalog.yml`
- commits: `0d10b9feab7ff9b721c1707640b25b30f6323aee`, `8b055e01d3bbc9532d61d1e28d44d4fdb870ec19`, `1126f139540d79301c6e9ee578ee09037e5556b1`

Gate RC-0057→0060 için successful compiled validation sonrası en fazla TESTED promotion yapar. RC-0061 için yalnız TR/EN active-system naming contract bulunması user-visible screen proof sayılmadığından gate onu en fazla IMPLEMENTED durumuna taşır; actual product-screen integration + widget/device evidence gelmeden TESTED verilmez.

## Açık product-facing Western maddeleri

- RC-0042 professional minor-aspect settings.
- RC-0044 professional user-editable orb settings + persistence/entitlement/UI.
- RC-0046 Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- RC-0048 retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- RC-0049 planetary rulerships'in ürün yüzeyinde gösterilebilmesi.
- RC-0061 active house-system adının gerçek kullanıcı ekranında görünürlüğü.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0052/0053 retrigger ve RC-0057→0061 dedicated gate exact CI/promotion sonuçları doğrulanacak; kırmızıysa job/log kök nedeni düzeltilecek.
3. RC-0061 gerçek ürün ekranına bağlanacak; ardından RC-0062 natal chart ve RC-0063+ transit zinciri dependency sırasıyla ilerletilecek.
4. Açık RC-0042/0044/0046/0048/0049 product-facing eksikleri bağımsız blocker olmayan noktalarda paralel kapatılacak.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
