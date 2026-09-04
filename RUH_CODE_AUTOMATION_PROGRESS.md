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
- **RC-0020 = pending physical promotion** — real solar-event production runtime bound to requirement-specific contract/validator/CI. First dedicated run `33903421927` failed only because validator used a broad word-level timezone guard; root cause fixed in `adbb9c0f746b0d3612df54860645693f5bc5250d` with concrete timezone/local-clock API rejection. Fresh CI/promotion must be physically observed before TESTED.
- **RC-0021 = pending physical promotion** — real Moon phase now has packaged NASA/JPL DE440s Sun/Moon compiled runtime evidence plus binding validator/CI. Dedicated run `33903728252` was queued at last exact read. No TESTED claim until SUCCESS + bot matrix commit.
- **RC-0022 = pending physical promotion** — entire `calculation_core` ↔ `interpretation` Dart dependency boundary is now scanned fail-closed; separate `CalculationEngine/CalculationResult` and snapshot-based `InterpretationEngine` contracts are required. CI commit `a226d11c9af595e25fd4541812ef2f57dc3fb4bc`; no TESTED claim until physical matrix promotion.

## Bu turdaki gerçek değişiklikler

### RC-0020 — Güneş doğuş/batış

- `requirements/contracts/rc0020_solar_events_contract.json`
- `tools/requirements/validate_rc0020_solar_events.py`
- `.github/workflows/rc0020-solar-events.yml`
- Existing `lib/src/calculation_core/solar/solar_events.dart` + `test/calculation_core/solar_events_test.dart` requirement gate'e bağlandı.
- Gate explicit `CivilDate + latitude + longitude`, apparent sunrise zenith `90.83333333333333°`, UTC sunrise/noon/sunset, polar day/night, coordinate fail-closed ve device-clock/timezone API isolation şartlarını doğrular.
- First dedicated gate failure runtime hesaplama hatası değildi; validator false-positive kök nedeni aynı turda düzeltildi.

### RC-0021 — gerçek Ay fazı

- `test/calculation_core/rc0021_real_moon_phase_test.dart`
- `requirements/contracts/rc0021_real_moon_phase_contract.json`
- `tools/requirements/validate_rc0021_real_moon_phase.py`
- `.github/workflows/rc0021-real-moon-phase.yml`
- Physical compiled test packaged `De440sEphemerisProvider.loadPackaged()` kullanır; Sun ve Moon aynı explicit TT Julian Day'de sample edilir; phase angle `Moon longitude - Sun longitude`, illumination elongation'dan türetilir; NASA/JPL DE440s provenance doğrulanır; mixed provenance fail-closed kalır.

### RC-0022 — astronomi / yorumlama ayrımı

- `requirements/contracts/rc0022_astronomy_interpretation_boundary_contract.json`
- `tools/requirements/validate_rc0022_astronomy_interpretation_boundary.py`
- `.github/workflows/rc0022-astronomy-interpretation-boundary.yml`
- Validator complete `lib/src/calculation_core/**/*.dart` ve `lib/src/interpretation/**/*.dart` ağaçlarını cross-boundary import için tarar.
- `CalculationEngine/CalculationResult` ve `InterpretationEngine<TSnapshot>` ayrılığı zorunlu; merkezi interpretation contract'ın ephemeris/solar/Julian runtime çağırması reddedilir.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. Her tetiklemede önce `requirements/requirement_state.csv`, bu dosya ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0020/RC-0021/RC-0022 exact CI sonuçları ve bot matrix promotion commit'leri fiziksel doğrulanacak.
3. Kırmızı gate varsa job logs alınarak root cause aynı requirement hattında düzeltilecek ve yeniden doğrulanacak.
4. Yeşil/promotion kanıtı sonrası dependency sırası RC-0023 → RC-0024 → ... şeklinde atlamadan sürdürülecek; blocker dışındaki bağımsız işler paralel ilerletilebilir.
5. Yalnız kanıtlanan state yazılacak; 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-04_2110_rc0019_rc0022_solar_lunar_boundary.md`.

**FINAL: NO.**
