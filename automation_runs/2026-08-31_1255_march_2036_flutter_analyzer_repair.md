# RUH CODE — Checkpoint: March 2036 + Flutter analyzer repair

## Binding scope

- Exact contract remains `RC-0001 → RC-1442`.
- No requirement is promoted to DONE without mandatory evidence and release gates.
- FINAL remains forbidden while Flutter Quality or any required release gate is red/unverified.

## Baseline CI re-read

Baseline exact HEAD inspected: `eb497fb92063adbb3283ee2ef526ceffa32027c4`.

The decoded Flutter Quality job log shows `flutter analyze --fatal-infos` failing with **50 issues**. The workflow test step did not run because Analyze failed. The gate was not weakened or bypassed.

Verified analyzer root-cause repairs committed in this run:

- `lib/src/pdf/pdf_numerology_section.dart`: removed 2 invalid `const StateError` invocations.
- `lib/src/ui/pdf/combined_pdf_selection_state.dart`: removed 7 invalid `const StateError` invocations.
- `test/calculation_core/numerology/pinnacles_challenges_test.dart`: migrated two stale named/const `CivilDate` calls to the current positional non-const constructor.
- `lib/src/pdf/pdf_asset_font_provider.dart`: removed redundant `dart:typed_data` import reported as fatal info.

These changes target 20 diagnostic emissions present in the decoded baseline log. They are not counted as CI success until a newer exact SHA produces completed visible green evidence.

Remaining decoded analyzer debt includes other PDF invalid const calls, BackupImportMode test import drift, PDF contract symbol/import drift, deprecated form-field use, and warning/info cleanup.

## Daily-message progress

Added and committed:

- `assets/content/daily_messages/tr/2036-03.csv` — 31 canonical TR rows.
- `assets/content/daily_messages/en/2036-03.csv` — 31 independent canonical EN rows.

Both files were reloaded from `main` after commit and verified for canonical header, locale, and exact contiguous dates `2036-03-01 → 2036-03-31`.

Editorial ledger advanced only after the re-read:

- TR: 3743
- EN: 3743
- total: 7486 / 8036
- remaining: 550
- next exact start: `2036-04-01`

`RC-1424/1425/1426/1427/1433/1434` remain not-DONE pending complete 8,036-record strict release audit and exact CI/release evidence.

## Commits in this checkpoint chain

- `9c00625953417ad6616a6ec2d3499d62e1a905e2` — March 2036 TR shard
- `5269651f78e7a94c9554665388730ca51b5c995a` — March 2036 EN shard
- `12ebc6e40e73a81bf1c6a4051f4c43d54cfe4660` — numerology PDF StateError repair
- `abc9ba0371d382ff8145dad8d635cf530b687b4f` — combined PDF selection StateError repair
- `6d593450cf244c95b8f3f02698811fea31943175` — CivilDate test constructor repair
- `d28df72ac4fdb842320cd937e3953c4f6e95cff8` — PDF font import cleanup
- `4a2b920ba6dfb87da91c0ccef67be356c5cce1f6` — editorial ledger advance
- `db038a12d7a270132ce47171075866720e852af1` — progress checkpoint update

## Next safe work

1. Read completed Flutter Quality results for the newest exact HEAD and continue from decoded failures.
2. Close remaining analyzer/test debt without weakening `--fatal-infos`.
3. Continue independent TR/EN editorial coverage from `2036-04-01`.
4. Never claim FINAL before all 1,442 RCs and release gates are verified.

**FINAL: NO.**
