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
- **RC-0031→RC-0035 = TESTED + blocked=YES**; physical bot promotion: `a164a622a8d5db68dada9799b6270aba2cbce300`.
- **RC-0052→RC-0053 = TESTED + blocked=YES**; physical bot promotion: `c49e07ca6970e626e03abd15861ad6b569f936ab`.
- **RC-0054→RC-0056 = TESTED + blocked=YES**; physical bot promotion: `a5deba73bff246c64d93e7d089194c2dc0bdd2ba`.

## Bu turdaki gerçek geliştirme

### RC-0057→RC-0061 — cancelled gate retrigger

House-system catalog implementation/contract/test zinciri mevcut. İlk dedicated run `33959238167` code/test sonucu üretmeden `cancelled` kaldı. Aynı fail-closed gate yeniden tetiklendi:

- `.github/workflows/rc0057-rc0061-house-system-catalog.yml`
- retrigger commit: `d48a0249d4831e4f8f744a6d29496d87f3d845f4`

Physical SUCCESS + matrix promotion görülmeden RC-0057→0060 TESTED, RC-0061 IMPLEMENTED sayılmayacak.

### RC-0062 — Natal chart requirement gate

Binding şart: `Natal harita oluşturulacak.`

Production `WesternNatalChartAssembler` zaten aynı provenance altında house cusps, natal placements, aspects, aspect grid ve essential dignities üreten aggregate oluşturuyor. Existing compiled `test/calculation_core/western/natal_chart_test.dart` assembler'ı çalıştırıyor. Bu turda exact requirement evidence zinciri eklendi:

- `requirements/contracts/rc0062_natal_chart_contract.json` — `48fbbfd507263d15a196a56998f9b384ef907208`
- `tools/requirements/validate_rc0062_natal_chart.py` — `f09310937efafbcb35265a761b2a4db49abef043`
- `.github/workflows/rc0062-natal-chart.yml` — `a289d770389f4673ea75d43c70623433dcc20dc1`

Gate binding SHA'yı, runtime/compiled evidence dosyalarını, chart componentlerini ve placements/aspects provenance tutarlılığını fail-closed doğrular; compiled Flutter natal-chart regression'ını çalıştırır. Physical bot promotion görülmeden RC-0062 TESTED sayılmayacak.

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
2. RC-0057→0061 retrigger ve RC-0062 dedicated gate exact CI/promotion sonuçları doğrulanacak; kırmızıysa job/log kök nedeni düzeltilecek.
3. RC-0061 gerçek ürün ekranına bağlanıp widget/device evidence üretilecek.
4. Ardından dependency sırasıyla RC-0063 transit chart, RC-0064 natal×transit, RC-0065 geçmiş transit, RC-0066 gelecek transit ve RC-0067 transit→natal aspect zinciri ilerletilecek.
5. Açık RC-0042/0044/0046/0048/0049 product-facing eksikleri bağımsız blocker olmayan noktalarda paralel kapatılacak.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
