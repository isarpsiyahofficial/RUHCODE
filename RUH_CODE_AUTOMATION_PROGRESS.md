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
- **RC-0057→RC-0060 = TESTED + blocked=YES**; physical bot promotion: `b2c6a512dfc0cb5c95c8fa1ff09203c02b8e1aca`.
- **RC-0061 = IMPLEMENTED + blocked=YES**; aktif ev sistemi adı için reusable TR/EN contract mevcut, fakat gerçek kullanıcı ekranı/widget-device evidence henüz yok.
- **RC-0062 = NOT_STARTED**; dedicated natal-chart contract/test/CI zinciri mevcut fakat physical `record natal chart TESTED` promotion henüz görülmedi.
- **RC-0063→RC-0067 = TESTED + blocked=YES**; physical bot promotion: `fcf83a4361757fb110dbc688be02cd7342273b66`.
- **RC-0068 = TESTED + blocked=YES**; physical bot promotion: `b1a6a9aeaf0eba788a9b4dc8061d3796bcb2e97d`. Rendered timeline UI/widget-device evidence açık.
- **RC-0069→RC-0070 = TESTED + blocked=YES**; physical bot promotion: `c02f9c5ee4860a222aa01f98e0cc7080b83e92c2`. Rendered synastry/two-chart product UI evidence açık.
- **RC-0071 = IMPLEMENTED + blocked=YES**; deterministic Composite chart planetary core, compiled regressions, exact binding contract, fail-closed validator ve dedicated CI/matrix promotion gate eklendi. Physical `record composite chart core TESTED` promotion henüz görülmedi.

## Bu turdaki gerçek geliştirme

### RC-0068 ve RC-0069→RC-0070 — physical promotion doğrulandı

- `b1a6a9aeaf0eba788a9b4dc8061d3796bcb2e97d` — `requirements(rc0068): record transit timeline core TESTED`
- `c02f9c5ee4860a222aa01f98e0cc7080b83e92c2` — `requirements(rc0069-rc0070): record synastry core TESTED`
- Her iki hat TESTED seviyesine fiziksel requirement-matrix promotion ile yükseldi; UI/device/release blocker'ları nedeniyle VERIFIED/DONE değildir.

### RC-0071 — Composite chart

- production core: `1b31fda1af52a7b65eb1b29bd3255b441c70f8b2` (`lib/src/calculation_core/western/composite_chart.dart`)
- compiled regressions: `2456ef597af6ee4cf4a8c5afec2c2de58295a616`
- binding contract: `d91c6f5f8664f5197e0b0df93094ff079bf22235`
- fail-closed validator: `0440c7eda31f00cf8d3a66309e843585e083950f`
- CI/matrix gate: `fd4993a2d9f2ad635190ee428144ad667527f070`

Composite planetary placements iki bağımsız natal placement setinden shortest-circular midpoint ile üretilir; 350°/10° sınırı 0° olarak çözülür. Person A ve B TT instant'ları ayrı korunur. Ephemeris source/version uyuşmazlığı, duplicate body ve unequal body set fail-closed reddedilir. Explicit ayrıca doğrulanmış time/location policy olmadan composite houses/angles uydurulmaz. Physical bot promotion oluşmadan TESTED denmeyecek.

## Açık product-facing Western maddeleri

- RC-0042 professional minor-aspect settings.
- RC-0044 professional user-editable orb settings + persistence/entitlement/UI.
- RC-0046 Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- RC-0048 retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- RC-0049 planetary rulerships'in ürün yüzeyinde gösterilebilmesi.
- RC-0061 active house-system adının gerçek kullanıcı ekranında görünürlüğü.
- RC-0068 important-transit timeline gerçek UI/widget-device evidence.
- RC-0069/0070 rendered synastry/two-chart product UI evidence.
- RC-0071 rendered composite-chart UI ve ayrıca tanımlanmış/doğrulanmış composite house/angle policy.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0071 dedicated CI/promotion sonucu doğrulanacak; kırmızıysa exact Actions job/log kök nedeni aynı turda düzeltilecek.
3. RC-0062 natal-chart physical promotion problemi yeniden doğrulanacak/retrigger gereksinimi incelenecek.
4. RC-0061 ve RC-0068/0069/0070/0071 product-screen/widget evidence ilerletilecek.
5. Ardından bağlayıcı dependency sırasıyla **RC-0072 Davison chart → RC-0073 Solar Return → RC-0074 Lunar Return → RC-0075 Planetary Return** ilerletilecek. Astronomik algoritma/golden kanıt olmadan approximation uydurulmayacak.
6. Açık RC-0042/0044/0046/0048/0049 product-facing eksikleri blocker olmayan noktalarda paralel kapatılacak.
7. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-05_2057_rc0068_rc0071_progress.md`.

**FINAL: NO.**
