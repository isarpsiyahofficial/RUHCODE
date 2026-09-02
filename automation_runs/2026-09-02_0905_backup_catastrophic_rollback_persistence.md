# Ruh Code Automation — Backup Catastrophic Rollback Persistence

## Binding scope

- `RC-0001 → RC-1442` / 1,442 requirements remains binding.
- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_AUTOMATION_PROGRESS.md`, and sparse `requirements/requirement_state.csv` were reread before changes.
- No unproven RC status/DONE override was added.

## Verified CI baseline

Exact pre-repair HEAD `4d3462a8dc35731473b89370840b78e840962d92`:

- `validate-requirements`: **SUCCESS** (`100120467983`).
- `verify-apk-assets`: **SUCCESS** (`100120467578`).
- Flutter `analyze-and-test`: **FAILURE** (`100120467749`).
- Analyzer: **SUCCESS — No issues found**.
- Flutter tests: **`+592 -1`**.
- Sole failure: `test/ui/backup/backup_runtime_wiring_test.dart: failed replace rollback surfaces critical integrity state`.

Decoded job log proved the prior bounded wait repair did not solve the root cause: the critical integrity text was never rendered.

## Root cause and production repair

The exception mapping was already correct: `BackupRestoreException(rollbackRestored:false)` maps to `BackupUiPhase.rollbackFailed`, and the TR/EN copy contains the mandatory data-integrity warning. The real weakness was presentation/lifecycle: catastrophic rollback failure was exposed only through transient Snackbar feedback.

Production repair lineage:

- `5d2003a48c8bb25272def1ba7ce951538e078672` — add persistent critical rollback state, live-region warning card, and block further backup/restore actions after catastrophic rollback failure.
- `299fbcec0c2bdba34d56e4b042a9220fab1a5f61` — remove duplicate critical Snackbar announcement; catastrophic rollback now has one canonical persistent accessible warning while non-critical restore failures retain Snackbar feedback.

The critical copy was not weakened. The incorrect generic `Veriler korundu` state remains rejected by the existing test.

## Release-host verification

`.github/workflows/daily-message-apk-packaging.yml` was reread. It still materializes Android with `flutter create` when `android/` is absent. Repository `android/` remains absent on the source repair SHA. Therefore packaged APK asset success does **not** satisfy tracked/signable/reproducible production release requirements.

## Current verification state

- Source repair SHA `299fbcec0c2bdba34d56e4b042a9220fab1a5f61` triggered fresh CI.
- At checkpoint time the exact Flutter run was not yet completed, so the repair is not recorded as CI-green/DONE.
- Requirement state ledger remains unchanged.

## Continue from here

1. Read exact completed Flutter Quality for `299fbcec...`; if red, use decoded exact log and repair the actual root cause without relaxing the critical warning.
2. If green, preserve this as the first fully green Flutter suite lineage and proceed to Daily Message real offline/airplane-mode lookup evidence.
3. In parallel close the tracked/signable Android host blocker; generated-host APK provenance remains insufficient for FINAL.
4. Continue physical EOP/ephemeris/font/UI/device and signed clean-checkout release gates.

**FINAL: NO.**