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
- **RC-0063→RC-0067 = NOT_STARTED**; production transit core, compiled regression, binding contract, validator ve dedicated CI/promotion gate eklendi; physical SUCCESS + matrix promotion bekleniyor.
- **RC-0068 = IMPLEMENTED + blocked=YES**; important-transit timeline calculation/model katmanı eklendi, fakat requirement-specific compiled gate ve gerçek timeline UI/widget-device evidence henüz yok.

## Bu turdaki gerçek geliştirme

### RC-0057→RC-0061 — physical promotion sonucu

- `b2c6a512dfc0cb5c95c8fa1ff09203c02b8e1aca` — `requirements(rc0057-rc0061): record house-system evaluation state`
- RC-0057/58/59/60 → TESTED + blocked=YES
- RC-0061 → IMPLEMENTED + blocked=YES; product screen integration ve widget/device evidence açık.

### RC-0062 — Natal chart

Dedicated zincir mevcut:

- `requirements/contracts/rc0062_natal_chart_contract.json`
- `tools/requirements/validate_rc0062_natal_chart.py`
- `.github/workflows/rc0062-natal-chart.yml`
- `test/calculation_core/western/natal_chart_test.dart`

Physical bot promotion commit'i henüz görülmediği için status yükseltilmedi.

### RC-0063→RC-0067 — Transit calculation core

- `lib/src/calculation_core/western/transit_chart.dart` — `10fad8356316d0a21ffd61c92e77bd76204612eb`
- `test/calculation_core/western/transit_chart_test.dart` — `4efa74da3304ef70bf499d1977dc2ba24f8da91a`
- `requirements/contracts/rc0063_rc0067_transit_contract.json` — `89f23951d5667853b15ac005698ab41b6c3ed0f0`
- `tools/requirements/validate_rc0063_rc0067_transit.py` — `ed3a79f312667de71ccf2ca060645e50e47be76d`
- `.github/workflows/rc0063-rc0067-transit.yml` — `c1edff0c5d9574dfac82fe7069d4cf4f48046a31`

Transit chart yalnız explicit TT instant'taki versioned ephemeris state'lerini tüketiyor; mixed instant, duplicate body ve mixed provenance fail-closed. Geçmiş/gelecek tarih aynı deterministic explicit-instant path'i kullanıyor. Natal ve transit snapshot'ları ayrı tutuluyor; comparison iki JD'yi de koruyor. Transit→natal aspect'ler shared major-aspect/orb policy üzerinden hesaplanıyor.

Physical bot promotion görülmeden RC-0063→0067 TESTED sayılmayacak.

### RC-0068 — önemli transit timeline

- `lib/src/calculation_core/western/transit_timeline.dart` — `da53297d4a5f45e7100bb61f0b5516b26cab02fe`

Yeni timeline builder natal×transit comparison snapshot'larını kronolojik `ImportantTransitEvent` kayıtlarına dönüştürüyor. Varsayılan önemli aspect policy conjunction/square/trine/opposition ve explicit 2° orb; policy değiştirilebilir. Mixed provenance fail-closed ve sonuç sırası deterministic. Bu yalnız calculation/model implementation'dır; compiled requirement gate ve gerçek kullanıcı timeline görünürlüğü olmadan TESTED sayılmayacak.

## Açık product-facing Western maddeleri

- RC-0042 professional minor-aspect settings.
- RC-0044 professional user-editable orb settings + persistence/entitlement/UI.
- RC-0046 Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- RC-0048 retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- RC-0049 planetary rulerships'in ürün yüzeyinde gösterilebilmesi.
- RC-0061 active house-system adının gerçek kullanıcı ekranında görünürlüğü.
- RC-0068 important-transit timeline gerçek UI/widget-device evidence.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0062 dedicated gate ve RC-0063→0067 transit gate exact CI/promotion sonuçları doğrulanacak; kırmızıysa job/log kök nedeni aynı turda düzeltilecek.
3. RC-0068 için compiled requirement gate kurulacak ve sonrasında gerçek timeline UI evidence üretilecek.
4. RC-0061 gerçek product-screen/widget evidence ile TESTED seviyesine taşınmaya çalışılacak.
5. Ardından dependency sırasıyla **RC-0069 synastry** ve devamı ilerletilecek.
6. Açık RC-0042/0044/0046/0048/0049 product-facing eksikleri blocker olmayan noktalarda paralel kapatılacak.
7. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
