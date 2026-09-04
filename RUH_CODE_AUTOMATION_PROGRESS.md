# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları da gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical requirement durumu

- **RC-0002 = DONE** — production runtime dil kapsamı exact TR/EN ve dedicated static+compiled gate ile doğrulandı.
- **RC-0003 = NOT_STARTED** — editorial-independence otomasyonu mevcut; fiziksel promotion/provenance eksik.
- **RC-0004 = TESTED + blocked=YES** — terminology/copy-quality machine gate geçti; independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES** — exact latest AKİLES source/artifact + immutable version/hash/capture/reference-scope provenance eksik.
- **RC-0006 = TESTED + blocked=YES** — modular calculation core doğrulandı; AKİLES method-level comparison/provenance açık.
- **RC-0007 = NOT_STARTED** — RC-0005/0006 provenance blocker'ına bağlı.
- **RC-0008 = TESTED + blocked=YES**, **RC-0009 = TESTED**, **RC-0010 = TESTED** — deterministic explicit time/IANA/DST-history gates.
- **RC-0011 = TESTED + blocked=YES**, **RC-0012 = TESTED + blocked=YES** — stable city identity + coordinates + IANA timezone; end-to-end birth-place propagation açık.
- **RC-0013 = TESTED + blocked=YES** — shared packaged DE440s astronomy core.
- **RC-0014 = TESTED + blocked=YES** — physical Sun/Moon/planet positions via packaged DE440s provider.
- **RC-0015 = TESTED + blocked=YES** — deterministic TT-based mean/true lunar-node engine; independent official goldens/integration açık.
- **RC-0016 = TESTED + blocked=YES** — signed longitude-velocity direct/stationary/retrograde classification; independent apparent-motion goldens açık.
- **RC-0017 = TESTED + blocked=YES** — central Julian Day/MJD/J2000 core; broader timescale/release evidence açık.
- **RC-0018 = TESTED + blocked=YES** — explicit UT1/TT + location ASC/MC geometry; independent multi-location goldens/end-to-end time propagation açık.
- **RC-0019 = TESTED + blocked=YES** — real 12-house cusp production motor and dedicated gate; independent multi-location/multi-epoch golden coverage açık.
- **RC-0020 = NOT_STARTED / corrected gate pending physical promotion** — real solar-event implementation/contract/CI mevcut; known validator false-positive `adbb9c0f746b0d3612df54860645693f5bc5250d` ile düzeltildi fakat `requirements(rc0020): ... TESTED` bot commit'i henüz fiziksel görülmedi.
- **RC-0021 = TESTED + blocked=YES** — packaged NASA/JPL DE440s Sun/Moon states üzerinden gerçek astronomik Ay fazı gate'i physical matrixte TESTED.
- **RC-0022 = TESTED + blocked=YES** — calculation-core ↔ interpretation dependency boundary ve snapshot-temelli interpretation ayrımı physical matrixte TESTED.
- **RC-0023 = TESTED + blocked=YES** — ayrı `western-astrology` CalculationEngine ve requirement-specific gate physical matrixte TESTED.
- **RC-0024 = TESTED + blocked=YES** — ayrı `vedic-astrology` CalculationEngine; explicit sidereal/ayanamsha ve ephemeris provenance kontrolleri. Physical bot promotion `de09bc914ff6818c7687571a7ed96cf448e6ca1a`.
- **RC-0025 = NOT_STARTED / corrected gate pending physical rerun** — ayrı `ChineseAstrologyEngine` mevcut. İlk CI `33924063984`, source'ta calendar-boundary ownership açıklaması exact validator marker'ını karşılamadığı için kırıldı; `f5ee2924eb5c1112f38237a2a6e8b3f87df21d55` ile Chinese New Year + solar-term ownership versioned calendar layer'a açıkça bağlandı. Corrected run `33931165269` ortak matrix-writer concurrency kuyruğunda job başlamadan cancelled oldu; bot promotion olmadan statü yükseltilmedi.
- **RC-0026 = TESTED + blocked=YES** — ayrı `BaZiEngine`; ilk CI testte var olmayan `CalculationValidity.invalid` enumu nedeniyle compile kırıldı, `0fd2332c753ae830793ed28bce1471aa76cb3e4c` ile canonical `.error` durumuna düzeltildi. Physical promotion `5b4083585337774d709f783bfb309bd6d5ed11a2`. Versioned civil-time/location→solar-term/calendar→four-pillar derivation ve authoritative goldens açık.
- **RC-0027 = NOT_STARTED / implementation+gate pending physical promotion** — mevcut numerology production ağacı için astroloji sistemlerinden bağımsızlık contract/validator/CI eklendi; Pythagorean, Chaldean ve Lo Shu compiled golden vectors gate'e bağlı. Bot promotion henüz fiziksel görülmedi.
- **RC-0028 = NOT_STARTED / implementation+gate pending physical promotion** — Western/Vedic/Chinese/BaZi/Numerology named calculation root'ları arasında cross-system calculation importlarını fail-closed yasaklayan architecture contract/validator/CI eklendi; neutral shared core izinli. Bot promotion henüz fiziksel görülmedi.

## Bu turdaki gerçek değişiklikler

### RC-0025 — Chinese engine CI root-cause düzeltmesi

- İlk run `33924063984`: validator failure `RC-0025 source must explicitly document calendar-boundary ownership`.
- `f5ee2924eb5c1112f38237a2a6e8b3f87df21d55`: Chinese New Year ve solar-term boundary ownership production source içinde explicit hale getirildi.
- Corrected run `33931165269` job başlamadan concurrency nedeniyle cancelled; physical promotion tekrar tetiklenecek.

### RC-0026 — BaZi compiled test düzeltmesi ve TESTED promotion

- İlk run `33924214176`: validator PASS, Flutter compile failure `CalculationValidity.invalid` member yok.
- Canonical enum `valid / partial / unavailable / error`; test `CalculationValidity.error` kullanacak şekilde `0fd2332c753ae830793ed28bce1471aa76cb3e4c` ile düzeltildi.
- Bot promotion `5b4083585337774d709f783bfb309bd6d5ed11a2`; canonical matrix artık TESTED + blocked=YES.

### RC-0027 — numeroloji bağımsızlığı

- `requirements/contracts/rc0027_numerology_independence_contract.json`
- `tools/requirements/validate_rc0027_numerology_independence.py`
- `.github/workflows/rc0027-numerology-independence.yml`
- Production numerology Dart ağacı Western/Vedic/Chinese/BaZi/ephemeris coupling ve `DateTime.now()` için fail-closed taranıyor.
- Existing compiled golden test Pythagorean, Chaldean ve Lo Shu ailelerini çalıştırıyor.

### RC-0028 — sistem hesaplama yöntemi izolasyonu

- `requirements/contracts/rc0028_system_method_isolation_contract.json`
- `tools/requirements/validate_rc0028_system_method_isolation.py`
- `.github/workflows/rc0028-system-method-isolation.yml`
- Named system roots başka named system calculation root'unu import edemez; neutral shared ephemeris/time/calculation-engine/domain altyapısı ortak kullanılabilir.
- Workflow representative Western/Vedic/Chinese/BaZi ve numerology regressions'ı ayrı ayrı çalıştırır.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. Her tetiklemede önce `requirements/requirement_state.csv`, bu dosya ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0025 corrected gate physical olarak yeniden çalıştırılacak; SUCCESS + bot matrix promotion olmadan TESTED denmeyecek.
3. RC-0027/RC-0028 exact CI sonuçları ve bot matrix promotion commit'leri fiziksel doğrulanacak; kırmızıysa root cause aynı requirement'ta düzeltilip yeniden çalıştırılacak.
4. RC-0020 corrected solar-events gate physical promotion eksikliği ayrıca takip edilecek.
5. Ardından dependency sırası RC-0029 (Western default Tropical) ve devamı şeklinde ilerletilecek.
6. Yalnız kanıtlanan state yazılacak; 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-05_0252_rc0025_rc0028_progress.md`.

**FINAL: NO.**
