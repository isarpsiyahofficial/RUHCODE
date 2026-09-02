# Ruh Code Automation Checkpoint — Flutter last failure + requirement validator repair

## Scope discipline

- Binding scope reread: `RC-0001 → RC-1442` / 1,442 requirements.
- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_AUTOMATION_PROGRESS.md`, and sparse requirement state ledger were reread before implementation.
- `requirements/requirement_state.csv` was not changed; no unproven DONE override was added.

## Exact completed baseline

Exact HEAD `30b29b5b552b497a573acb7b370e3ab4c7bca78f` exposed two red checks.

### Flutter Quality

Run/job: `33581506203 / 100096594953`.

- `flutter analyze --fatal-infos`: SUCCESS — `No issues found!`
- `flutter test --reporter expanded`: FAILURE
- exact summary: `+592 -1`
- sole failing test: `test/ui/backup/backup_runtime_wiring_test.dart: failed replace rollback surfaces critical integrity state`
- diagnostic artifact: `9828662609`
- artifact ZIP SHA-256: `55ca5958d82186cfa994daaca9aeba227de4b05ac9e115e9a1ea7ca0a3dda244`

The test was still asserting the rollback-failed Snackbar after a fixed timing assumption. The production contract already maps `BackupRestoreException(rollbackRestored:false)` to `BackupUiPhase.rollbackFailed` and its Turkish copy contains the critical `Veri bütünlüğü kontrol edilmeli` warning.

Repair commit `0aa21e30f25819223e506da449a055a4086ecdea` replaces the fixed 300 ms timing assumption with a bounded deterministic pump-until-visible helper. The assertion still requires the critical integrity warning and still rejects the false `Veriler korundu` state; no product guard or test expectation was weakened.

### Requirement validation

Run/job: `33581506181 / 100096595116`.

The requirement set itself is valid:

- RC-0001 through RC-1442 present exactly once and in order: SUCCESS
- classification policy: SUCCESS
- evidence integrity: SUCCESS (`67 JSON`, `30 contracts`, `454 RC-links`, `182 sources`, `94 tests`, `20 validators`)
- semantic evidence ownership: SUCCESS
- Daily Message contract/editorial coverage: SUCCESS
- multiple PDF/UI/backup traceability validators: SUCCESS until one stale static token check

The failing validator was `tools/backup/validate_backup_restore_preview_accessibility.py`: it still searched `backup_accessibility_test.dart` for stale short semantics labels `Birleştir` / `Değiştir`, while production and the current widget test correctly use canonical full labels `Mevcut Verilerle Birleştir` / `Mevcut Verileri Değiştir`.

Repair commit `dfe0bcf94a6ea99f5f190192ddf827e315a9b516` aligns only that static token validation with the canonical labels. RC ownership, action IDs, 48dp requirement, focus order, merge/replace modes, runtime binding and `done=false` evidence guard remain unchanged.

## Independent release blocker check

Repository root still has no tracked `android/` production host. The previously green APK packaging proof remains valid but was generated with the workflow materialized host; therefore tracked/signable production Android host, signed reproducible clean-checkout release and real-device airplane-mode proof remain open.

## Current verification state

Exact source HEAD `dfe0bcf94a6ea99f5f190192ddf827e315a9b516` triggered 25 checks. At checkpoint time `analyze-and-test` and other jobs were still queued/indexing, so neither repair is counted CI-green yet.

## Next continuation

1. Read completed exact-SHA `analyze-and-test` and `validate-requirements` results for `dfe0bcf...`.
2. If Flutter remains red, use the exact new diagnostic line only; do not weaken the quality threshold.
3. If requirement validation remains red, repair only the exact stale contract/traceability cause; do not mark RCs DONE to silence the gate.
4. Once both are green, continue dependency order into real offline/airplane-mode proof and tracked/signable Android host / clean-checkout signed release work.
5. Keep physical ephemeris/EOP/font/UI-reference/device and final lifecycle gates open until their real evidence exists.

**FINAL: NO.**