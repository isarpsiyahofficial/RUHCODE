# RUH CODE — CI / Contract Repair Checkpoint — 2026-08-30 16:53 TRT

## Scope revalidated

- Binding scope remains `RC-0001 → RC-1442`.
- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md` and `RUH_CODE_AUTOMATION_PROGRESS.md` were re-read before implementation.
- No requirement was marked DONE without evidence.
- Daily-message editorial ledger was intentionally left at `6574 / 8036`; CI debt was critical and took dependency priority over the next 2035 content batch.

## Previous exact HEAD CI audit

The previously recorded exact HEAD `7abc2f996cec40539bfcce2820e629a99f07a7b7` did have 23 GitHub Actions runs. Eight were failed, so the earlier assumption that no workflow runs were visible was incorrect.

Failed gates included:

- Western Aspect Grid Contract
- Requirements Contract
- Western Essential Dignities Contract
- Western Natal Aspects Contract
- Western ASC MC Contract
- Flutter Quality
- Earth Orientation Contract
- Ayanamsha Runtime Contract

## Root causes fixed in this run

### Western aspect-grid evidence gate

`tools/astronomy/validate_western_aspect_grid.py` incorrectly required `RC-0277` and `RC-0278`, which belong to Free/product-access behavior rather than the aspect-grid requirement. The binding aspect-grid owner is `RC-0051`. Validator ownership was corrected without weakening the SOURCE_LEVEL_ONLY release rule.

### Western essential-dignity evidence gate

`tools/astronomy/validate_western_essential_dignities.py` incorrectly required unrelated `RC-0276`. Binding dignity ownership remains `RC-0049` and `RC-0050`. Validator ownership was corrected; no DONE claim was added.

### Requirements evidence integrity

The Requirements Contract failed because `evidence/backup/single_table_csv_export.json` used an object in the reserved top-level `contract` field. The evidence record now carries canonical string contract id `single_table_csv_export`; the prior boolean contract detail was preserved under `assertions`.

### Dart / Flutter compatibility — Western ASC/MC

GitHub Actions logs showed Dart compile failures because newer Dart SDKs reject double lower/upper bounds passed to `RangeError.range`. `lib/src/calculation_core/western/asc_mc.dart` now uses `RangeError.value` for longitude, latitude and obliquity validation, preserving fail-closed RangeError behavior while compiling on current Dart.

### Dart / Flutter compatibility — Ayanamsha

The same `RangeError.range(double bounds)` issue broke the Ayanamsha Runtime Contract. `TabulatedAyanamshaProvider.atJulianDayTt` now uses `RangeError.value` for forbidden extrapolation while retaining explicit tabulated-coverage enforcement.

### Dart / Flutter compatibility — Placidus

`lib/src/calculation_core/western/placidus_houses.dart` had the same incompatible double-bound RangeError call. Latitude validation now uses `RangeError.value`; polar geometry/fallback semantics are unchanged.

### Earth Orientation test precision

The Earth Orientation Contract had 8 passing tests and one failure caused by subtracting two ~2.46-million Julian-day doubles and expecting 1e-12-day precision. The source-level UT1 offset itself was correct. The test tolerance was adjusted to `2e-10` day (~17 microseconds), still far below the EOP accuracy budget, with an explanatory regression comment.

### Dart const exception regressions

Current Dart no longer accepts several `const StateError(...)` invocations. Invalid const usage was removed from the entitlement resolver, feature catalog validation and rollback-resistant entitlement clock without changing error semantics.

## Known remaining CI work

The old Flutter Quality log exposed additional analyzer failures beyond the fixes above, including remaining invalid const exception invocations, moved/undefined backup and PDF symbols, outdated `CivilDate` construction in tests, and minor analyzer warnings/infos. These are not hidden or marked resolved.

New commits trigger 23 workflows each. The latest exact SHA still requires completed GitHub Actions evidence before any CI SUCCESS claim. Queued/in-progress runs are not treated as proof.

## Editorial state

- TR: 3287
- EN: 3287
- total: 6574 / 8036
- remaining: 1462
- next content start: `2035-01-01`

## Next safe continuation

1. Re-read the latest exact SHA workflow results and use decoded job logs for any remaining red gates.
2. Continue shared-root analyzer repairs until Flutter Quality can reach the test step and pass.
3. Re-run/verify Requirements Contract after the evidence-schema normalization; fix the next integrity failure if one appears.
4. Once critical CI debt is no longer blocking, resume canonical TR + independent EN daily-message batches from `2035-01-01`.
5. Do not mark final RCs DONE until their calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle evidence is complete.

**FINAL: NO.**
