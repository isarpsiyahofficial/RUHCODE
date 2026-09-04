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
- **RC-0025 = NOT_STARTED / implementation+gate pending physical promotion** — ayrı `ChineseAstrologyEngine` eklendi; pre-resolved traditional cycle year → deterministic 60-year sexagenary/stem/branch state. Versioned Chinese calendar/solar-term boundary çözümü VERIFIED/DONE blocker'ı. Bot promotion henüz fiziksel görülmedi.
- **RC-0026 = NOT_STARTED / implementation+gate pending physical promotion** — ayrı `BaZiEngine` eklendi; year/month/day/hour pillar girdileri bağımsız validate ediliyor. Versioned civil-time/location→solar-term/calendar→four-pillar derivation VERIFIED/DONE blocker'ı. Bot promotion henüz fiziksel görülmedi.

## Bu turdaki gerçek değişiklikler

### RC-0024 — ayrı Vedik hesaplama motoru

- `lib/src/calculation_core/vedic/vedic_astrology_engine.dart`
- `test/calculation_core/vedic/vedic_astrology_engine_test.dart`
- `requirements/contracts/rc0024_vedic_engine_contract.json`
- `tools/requirements/validate_rc0024_vedic_engine.py`
- `.github/workflows/rc0024-vedic-engine.yml`
- Separate engine id, explicit sidereal/ayanamsha identity/value, same-instant/source/data-version ephemeris provenance, duplicate-body guard ve deterministic tropical→sidereal placement dönüşümü fail-closed kapıda doğrulandı.

### RC-0025 — ayrı Çin astrolojisi motoru

- `lib/src/calculation_core/chinese/chinese_astrology_engine.dart`
- `test/calculation_core/chinese/chinese_astrology_engine_test.dart`
- `requirements/contracts/rc0025_chinese_engine_contract.json`
- `tools/requirements/validate_rc0025_chinese_engine.py`
- `.github/workflows/rc0025-chinese-engine.yml`
- Jia-Zi reference year 1984 üzerinden deterministic sexagenary cycle, stem/branch indeksleri ve pre-reference floor-mod regressions eklendi. Chinese New Year/solar-term sınırları versioned kaynak olmadan tahmin edilmiyor.

### RC-0026 — ayrı BaZi motoru

- `lib/src/calculation_core/bazi/bazi_engine.dart`
- `test/calculation_core/bazi/bazi_engine_test.dart`
- `requirements/contracts/rc0026_bazi_engine_contract.json`
- `tools/requirements/validate_rc0026_bazi_engine.py`
- `.github/workflows/rc0026-bazi-engine.yml`
- BaZi engine kendi `bazi` identity'sine sahip; dört pillar birbirinden bağımsız korunuyor; stem 0..9, branch 0..11 fail-closed doğrulanıyor. Calendar/day-boundary türetimi versioned evidence olmadan uydurulmuyor.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. Her tetiklemede önce `requirements/requirement_state.csv`, bu dosya ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0025/RC-0026 exact CI sonuçları ve bot matrix promotion commit'leri fiziksel doğrulanacak; kırmızıysa root cause düzeltilip yeniden çalıştırılacak.
3. RC-0020 corrected solar-events gate için physical promotion hâlâ yok; aynı requirement fail-closed açık tutulacak ve exact Actions/root-cause/retrigger doğrulaması sürdürülecek.
4. Ardından dependency sırası RC-0027 (numeroloji astrolojiden tamamen bağımsız) → RC-0028 (bir sistem başka sistemin hesaplama yöntemini kullanmayacak) şeklinde ilerletilecek.
5. Yalnız kanıtlanan state yazılacak; 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-05_0057_rc0020_rc0026_engine_progress.md`.

**FINAL: NO.**
