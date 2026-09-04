# Ruh Code automation checkpoint — RC-0019 → RC-0022

## Fiziksel başlangıç doğrulaması

- `requirements/requirement_state.csv` yeniden okundu.
- RC-0019 artık fiziksel olarak `TESTED`; önceki çalıştırmada bekleyen promotion tamamlanmış.
- RC-0020, RC-0021 ve RC-0022 için yalnız mevcut kod varlığına dayanılmadı; requirement-specific binding/evidence/CI zinciri kuruldu.

## RC-0020 — gerçek Güneş doğuş/batış hesabı

- Existing production `SolarEvents` explicit `CivilDate + latitude + longitude` tüketiyor, apparent sunrise zenith `90.83333333333333°`, solar noon/sunrise/sunset UTC timeline ve polar day/night durumlarını hesaplıyor; invalid coordinates fail-closed.
- Added `requirements/contracts/rc0020_solar_events_contract.json`.
- Added `tools/requirements/validate_rc0020_solar_events.py`.
- Added `.github/workflows/rc0020-solar-events.yml`; existing compiled `test/calculation_core/solar_events_test.dart` dedicated gate'e bağlandı.
- First dedicated run `33903421927` failed in validator, before compiled tests. Root cause: validator used a broad text-level `timezone` word check; runtime itself was not localizing timezone/DST.
- Root cause fixed in commit `adbb9c0f746b0d3612df54860645693f5bc5250d`: guard now rejects concrete timezone/local-clock APIs (`TZDateTime`, `getLocation`, `.toLocal()`, timezone package imports, etc.) instead of comments/documentation words.
- Fresh exact-HEAD CI/promotion is pending. Do not claim RC-0020 TESTED until physical bot matrix promotion appears.

## RC-0021 — real astronomical Moon phase

- Existing `MoonPhaseEngine` samples Sun and Moon at the same explicit TT Julian Day, derives phase angle from Moon longitude minus Sun longitude, derives illuminated fraction from elongation, and rejects mixed provenance/sample metadata.
- Added compiled physical test `test/calculation_core/rc0021_real_moon_phase_test.dart` that loads packaged `De440sEphemerisProvider`, verifies NASA/JPL DE440s provenance and exercises real new-Moon/full-Moon epochs.
- Added `requirements/contracts/rc0021_real_moon_phase_contract.json`.
- Added `tools/requirements/validate_rc0021_real_moon_phase.py`.
- Added `.github/workflows/rc0021-real-moon-phase.yml` in commit `f1a179164e0f9efb40495799db8fd80811c23261`.
- Dedicated run `33903728252` was still queued at last physical read. No TESTED claim until SUCCESS + bot matrix promotion.

## RC-0022 — astronomy / interpretation separation

- Binding requirement: common astronomy core and astrological interpretation systems must remain separate.
- Added `requirements/contracts/rc0022_astronomy_interpretation_boundary_contract.json`.
- Added fail-closed `tools/requirements/validate_rc0022_astronomy_interpretation_boundary.py`: scans the entire `lib/src/calculation_core/**/*.dart` and `lib/src/interpretation/**/*.dart` trees for forbidden cross-boundary imports, verifies separate `CalculationEngine/CalculationResult` and snapshot-based `InterpretationEngine` contracts, and rejects direct astronomy runtime invocation from the central interpretation contract.
- Added `.github/workflows/rc0022-astronomy-interpretation-boundary.yml` in commit `a226d11c9af595e25fd4541812ef2f57dc3fb4bc`.
- Fresh CI/promotion pending; do not claim TESTED until physical matrix promotion.

## Açık blockerlar / sonraki devam

1. Read physical matrix first; verify RC-0020/21/22 promotions independently.
2. If any dedicated gate is red, fetch job logs, fix root cause in the same requirement line and rerun.
3. If green, verify bot promotion physically and continue dependency order from RC-0023 (Western astrology separate engine), without skipping RCs.
4. RC-0003/0004 editorial evidence; RC-0005/0006/0007 AKİLES provenance; RC-1436/1437 broader astronomy goldens/tolerances; RC-1439 physical UI references; signed reproducible clean-checkout + real-device/offline/accessibility/PDF/Play release gates remain open.
5. FINAL only after RC-0001→RC-1442 all DONE and exact release artifact gates are green.

**FINAL: NO.**
