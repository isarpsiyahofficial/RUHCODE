# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical requirement durumu

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0019** — ilgili requirement matrix satırlarında TESTED; independent astronomy/location/release kanıtları açık olanlar blocked=YES.
- **RC-0020 = TESTED + blocked=YES** — physical bot promotion `5dbb577f8754cb30b888dae415417cd8d6cc139d`.
- **RC-0021→RC-0027 = TESTED + blocked=YES**.
- **RC-0028 = TESTED + blocked=YES** — corrected run `33943328752` SUCCESS; physical bot promotion `2940c3534d318ef7b13575deceb716993f21d561`.
- **RC-0029 = TESTED + blocked=YES** — physical bot promotion `38a298e8c2990a2ec0a8d2a37e1bcb82e15eb7af`.
- **RC-0030 = TESTED + blocked=YES** — physical bot promotion `9158aa0c8853f87c61d19813814fb1dfaa9a929c`; end-to-end birth/time/location/ephemeris/houses/UI goldens hâlâ açık.
- **RC-0031→RC-0036 = gate pending / physical promotion not yet observed at last check.** Kod, ayrı binding contract'lar, validator ve compiled CI mevcut; physical TESTED commit görülmeden statü yükseltilmeyecek.
- **RC-0037 = gate pending** — 12/12 bilingual house-theme interpretation katalogu + tests/contract/validator/CI mevcut; independent editorial/UI/accessibility/release evidence blocker.
- **RC-0038→RC-0040 = gate pending** — explicit traditional/modern rulership catalogs, reverse lookup, actual cusp-sign house rulers + separate contracts/tests/CI mevcut.
- **RC-0041→RC-0049 = gate pending** — six major aspects including quincunx, complete explicit orb policy, body+aspect overrides and compiled tests/contracts/CI mevcut.
- **RC-0050 = corrected gate pending** — applying/exact/separating current longitude + signed physical speed üzerinden hesaplanıyor. NatalPlacement speed-provenance açığı `07bbab3596179c491299e3001da8c463e3ad430c` ile düzeltildi; validator `dff5abeacd69a6b12aa0966dfc880a1c444ff400` ile güçlendirildi; corrected gate `0a00007cf0a1b23848cab76955ae808b3a0a5d80` ile retrigger edildi. Physical promotion görülmeden TESTED denmeyecek.

## Bu turdaki gerçek geliştirme

### RC-0030 — Sun / Moon / Ascendant

Aynı coherent Western snapshot'tan physical Sun/Moon placement ve calculated HouseCusps ASC tüketen production projection + compiled regressions + binding/validator/CI tamamlandı. Physical TESTED promotion `9158aa0c8853f87c61d19813814fb1dfaa9a929c` ile doğrulandı.

### RC-0031 → RC-0036 — placements / signs / degrees / houses / cusp degrees

- RC-0031: her supplied unique physical body state placement olur; duplicate/provenance fail-closed.
- RC-0032: physical longitude → Tropical sign; boundary regressions.
- RC-0033: normalized longitude + degree-in-sign.
- RC-0034: actual HouseCusps + physical longitude → houseNumber.
- RC-0035: exactly 12 validated/individually addressable cusps.
- RC-0036: her evin cusp/start degree'si ayrı adreslenebilir; ASC=cusp1, MC=cusp10; invalid house fail-closed.

Her RC ayrı binding/hash/evidence satırı olarak korunuyor; ortak gate yalnız kanıt yürütmesini paylaşıyor.

### RC-0037 — bilingual house themes

`lib/src/interpretation/western_house_themes.dart` içine tam 12 ev için ayrı TR/EN title+description eklendi. Interpretation içeriği calculation_core'a karıştırılmadı. Completeness/range compiled tests ve dedicated requirement gate eklendi.

### RC-0038 → RC-0040 — Western rulerships

`lib/src/calculation_core/western/rulerships.dart` eklendi:

- explicit traditional + modern schemes,
- bütün 12 Tropical sign için complete maps,
- planet → ruled signs reverse lookup,
- actual calculated cusp sign → house ruler,
- 1..12 all-house resolution ve range fail-closed.

Traditional/modern farkları sessizce birleştirilmiyor: Scorpio Mars/Pluto, Aquarius Saturn/Uranus, Pisces Jupiter/Neptune ayrımı explicit.

### RC-0041 → RC-0049 — aspects / orbs

Production aspect motoru artık conjunction 0°, sextile 60°, square 90°, trine 120°, quincunx 150°, opposition 180° destekliyor. Explicit default orb policy doğrulanıyor. `bodyAspectOverrides` ile orb değerleri hem planet hem aspect türüne göre ayrıştırılabiliyor. Pairwise detection shortest angular separation kullanıyor. Quincunx eklenince eski custom-orb test map'lerinin eksik kalacağı regresyon riski aynı turda giderildi.

### RC-0050 — applying / exact / separating

`AspectPhase { applying, exact, separating }` production aspect sonucuna eklendi. Phase wall-clock/etiket tahmini değil; current physical longitudes + signed longitude speeds ile ileri-zaman probe sonucu orb daralıyor/genişliyor mantığından hesaplanıyor. Retrograde relative-motion ve non-finite fail-closed compiled tests var.

İncelemede gerçek data-flow açığı yakalandı: `NatalPlacement` ephemeris `longitudeSpeedDegreesPerDay` değerini taşımıyordu. Bu speed provenance production modele eklendi (`07bbab...`), RC-0050 validator bunu artık zorunlu tutuyor (`dff5abe...`) ve workflow dependency path'i eklenerek yeniden tetiklendi (`0a00007...`).

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. Matrix + progress + `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0031→0036, RC-0037, RC-0038→0040, RC-0041→0049 ve corrected RC-0050 physical gate/promotion sonuçları doğrulanacak.
3. Kırmızı gate varsa exact workflow job/log okunup root cause aynı çalıştırmada düzeltilecek ve yeniden koşturulacak; requirement zayıflatılmayacak.
4. Yalnız physical promotion gören satırlar TESTED kabul edilecek.
5. Ardından dependency sırası RC-0051+ ile devam edecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-05_0912_rc0030_rc0050_western_rulership_aspects.md`.

**FINAL: NO.**
