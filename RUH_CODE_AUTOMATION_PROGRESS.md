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
- **RC-0068 = IMPLEMENTED + blocked=YES**; production timeline modeline ek olarak compiled test, binding contract, fail-closed validator ve dedicated CI/matrix promotion gate eklendi; physical promotion bekleniyor ve rendered timeline UI/widget-device evidence açık.
- **RC-0069→RC-0070 = IMPLEMENTED + blocked=YES**; deterministic synastry/two-chart production core, compiled regressions, binding contract, fail-closed validator ve dedicated CI/matrix promotion gate eklendi; physical promotion bekleniyor.

## Bu turdaki gerçek geliştirme

### RC-0063→RC-0067 — physical promotion doğrulandı

- `fcf83a4361757fb110dbc688be02cd7342273b66` — `requirements(rc0063-rc0067): record transit core TESTED`
- Transit haritası, Natal×Transit, geçmiş/gelecek explicit TT transitleri ve transit→natal aspect machine gate'i physical matrix tarafından TESTED kabul edildi.
- End-to-end date selection, rendered transit/timeline UI, independent astronomy goldens ve release/device kapıları VERIFIED/DONE öncesinde açık.

### RC-0068 — önemli transit timeline requirement gate

- production model: `lib/src/calculation_core/western/transit_timeline.dart`
- compiled regression: `36539a66b40c7482400d1bde5c779897c5fb5a47`
- binding contract: `967c354cbf9945bfec5384255c53633f27fbb5f7`
- fail-closed validator: `9f43f52c7d6b46110e8e7039e93bf78f30005283`
- CI/matrix gate: `99e894d85c8e2b22c504da533d02821fa445fcee`

Timeline explicit natal×transit snapshot'larından deterministic important-event records üretir; explicit policy kullanır, kronolojik sıralama ve deterministic tie-break uygular, mixed provenance durumunu fail-closed reddeder. Physical SUCCESS + matrix promotion görülmeden TESTED sayılmayacak. Gerçek product timeline rendering ayrıca açık blocker'dır.

### RC-0069→RC-0070 — Synastry / iki kişinin harita karşılaştırması

- production core: `62fffc27d0bed683de853512054925ff47dbac5a` (`lib/src/calculation_core/western/synastry.dart`)
- compiled regressions: `89981e503929581df233d94f9857c5ea6526f353`
- binding contract: `622c846069d0a9877f5696297e8cffa33ab639ee`
- fail-closed validator: `00ece3d97bda3da048625b4e259befba909b1856`
- CI/matrix gate: `fc53658e2495b3bc50fa9f015b25324141ee0880`

İki natal snapshot birbirine karıştırılmadan ayrı korunur; iki TT instant sonuçta saklanır. Person-A placements × Person-B placements cross-chart aspectleri shared explicit aspect/orb policy ile hesaplanır. Signed physical speeds aspect phase hesabına taşınır. Ephemeris source/version uyuşmazlığı fail-closed; device current time veya network fallback yoktur. Physical bot promotion olmadan TESTED denmeyecek.

## Açık product-facing Western maddeleri

- RC-0042 professional minor-aspect settings.
- RC-0044 professional user-editable orb settings + persistence/entitlement/UI.
- RC-0046 Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- RC-0048 retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- RC-0049 planetary rulerships'in ürün yüzeyinde gösterilebilmesi.
- RC-0061 active house-system adının gerçek kullanıcı ekranında görünürlüğü.
- RC-0068 important-transit timeline gerçek UI/widget-device evidence.
- RC-0069/0070 rendered synastry/two-chart product UI evidence.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0068 ve RC-0069→0070 dedicated CI/promotion sonuçları doğrulanacak; kırmızıysa exact Actions job/log kök nedeni aynı turda düzeltilecek.
3. RC-0062 natal-chart physical promotion problemi yeniden doğrulanacak/retrigger gereksinimi incelenecek.
4. RC-0061 ve RC-0068 product-screen/widget evidence ilerletilecek.
5. Ardından dependency sırasıyla **RC-0071 Composite chart** ve RC-0072+ ilerletilecek.
6. Açık RC-0042/0044/0046/0048/0049 product-facing eksikleri blocker olmayan noktalarda paralel kapatılacak.
7. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
