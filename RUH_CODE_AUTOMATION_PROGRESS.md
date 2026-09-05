# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical requirement durumu

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0019** — ilgili requirement matrix satırlarında TESTED; independent astronomy/location/release kanıtları açık olanlar blocked=YES.
- **RC-0020 = TESTED + blocked=YES** — corrected real solar-events gate explicit retrigger sonrası physical bot promotion `5dbb577f8754cb30b888dae415417cd8d6cc139d` ile doğrulandı. Broader authoritative multi-location/date goldens ve timezone-localization e2e kanıtı açık.
- **RC-0021→RC-0027 = TESTED + blocked=YES**.
- **RC-0028 = TESTED + blocked=YES** — corrected run `33943328752` SUCCESS; physical bot promotion `2940c3534d318ef7b13575deceb716993f21d561`.
- **RC-0029 = TESTED + blocked=YES** — physical bot promotion `38a298e8c2990a2ec0a8d2a37e1bcb82e15eb7af`; Western default Tropical mapping machine gate'ten geçti.
- **RC-0030 = NOT_STARTED / gate pending** — Sun/Moon/Ascendant production projection + compiled regressions + contract + validator + dedicated gate mevcut; physical promotion görülmeden TESTED denmeyecek.
- **RC-0031→RC-0035 = NOT_STARTED / gate pending** — her RC için ayrı binding contract; all placements/signs/degrees/houses/12 cusps requirement-bazlı validator + compiled gate mevcut. Physical matrix promotion bekleniyor.
- **RC-0036 = NOT_STARTED / gate pending** — 12 house cusp/start degree contract + validator + dedicated gate mevcut; physical promotion bekleniyor.

## Bu turdaki gerçek değişiklikler

### RC-0028 / RC-0029 / RC-0020 physical kapanışları

- RC-0028 corrected workflow run `33943328752` SUCCESS ve `2940c3534d318ef7b13575deceb716993f21d561` TESTED promotion.
- RC-0029 `38a298e8c2990a2ec0a8d2a37e1bcb82e15eb7af` TESTED promotion.
- RC-0020 corrected solar-event gate `db79aba7ee66411dbb96cb4bb717a39701688f82` ile açıkça retrigger edildi; physical TESTED promotion `5dbb577f8754cb30b888dae415417cd8d6cc139d` oluştu.

### RC-0030 — Western Sun / Moon / Ascendant

- `lib/src/calculation_core/western/luminaries_ascendant.dart`: aynı coherent Western snapshot'tan physical Sun/Moon placement ve calculated HouseCusps ASC tüketimi.
- `test/calculation_core/western/luminaries_ascendant_test.dart`: Sun/Moon/ASC tropical sign+degree regression ve missing luminary fail-closed.
- `requirements/contracts/rc0030_western_sun_moon_ascendant_contract.json`.
- `tools/requirements/validate_rc0030_western_sun_moon_ascendant.py`.
- `.github/workflows/rc0030-western-sun-moon-ascendant.yml`.
- End-to-end birth input → time/location → ephemeris → houses/ASC → Western UI goldens tamamlanmadan VERIFIED/DONE yok.

### RC-0031 → RC-0035 — placements / signs / degrees / houses

Her requirement ayrı binding/hash/evidence/blocker ile tutuluyor:

- RC-0031 tüm supplied unique physical body states → placements; duplicate/provenance fail-closed.
- RC-0032 physical longitude → Tropical sign; exact boundary regressions.
- RC-0033 normalized longitude + degree-in-sign.
- RC-0034 physical longitude + HouseCusps → houseNumber.
- RC-0035 exactly 12 validated/individually addressable cusps.

Ortak requirement-specific validator: `tools/requirements/validate_rc0031_rc0035_western_placements_houses.py`.
Dedicated compiled gate: `.github/workflows/rc0031-rc0035-western-placements-houses.yml`.

### RC-0036 — her evin başlangıç derecesi

- `requirements/contracts/rc0036_house_cusp_degrees_contract.json`.
- `tools/requirements/validate_rc0036_house_cusp_degrees.py`.
- `.github/workflows/rc0036-house-cusp-degrees.yml`.
- Gate 12 cusp değerinin ayrı ayrı adreslenmesini, `[0,360)` normalizasyonunu, ASC/MC'nin cusp 1/10'a bağlılığını ve invalid house-number fail-closed davranışını zorunlu tutuyor.
- TR/EN UI rendering + exact release artifact kanıtı VERIFIED/DONE blocker'ı olarak açık.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu dosya ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0030 dedicated gate + physical `record ... TESTED` promotion doğrulanacak; failure varsa exact root cause aynı requirement standardı korunarak düzeltilecek.
3. RC-0031→RC-0035 ortak gate'in her ayrı matrix row promotion'ı doğrulanacak; failure varsa failing contract/test tek tek düzeltilecek.
4. RC-0036 dedicated gate ve physical promotion doğrulanacak.
5. Ardından dependency sırası RC-0037 (ev tema açıklaması), RC-0038 (ev yöneticileri) ve sonraki Western rulership/aspect requirement'ları şeklinde ilerletilecek.
6. Yalnız kanıtlanan state yazılacak; 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-05_0854_rc0020_rc0036_western_core.md`.

**FINAL: NO.**
