# RUH CODE automation checkpoint — Flutter failure triage + APK gate

## Binding scope

- Canonical scope remains `RC-0001 → RC-1442` (1,442 requirements).
- `requirements/requirement_state.csv` remains unchanged; no evidence-free DONE override was added.
- FINAL remains forbidden while critical test/release gates are red or incomplete.

## Exact baseline revalidation

Baseline exact HEAD `27fff69fe715d6b75e45310fb906b661623238c1` had 23 check-runs: 22 SUCCESS and only `analyze-and-test` FAILURE. Actions run/job: `33529478301 / 99928648490`.

The job steps proved `Analyze` SUCCESS and `Test` FAILURE. The diagnostic artifact introduced in the prior run was present and downloadable:

- artifact id: `9809184752`
- name: `flutter-test-diagnostics`
- size: 29,832 bytes

The artifact was opened in this run. The final Flutter summary was `+556 -31`: 31 failing tests, so the blocker is not one isolated assertion.

## Confirmed failure clusters

Examples extracted directly from `flutter-test.log`:

- backup exporter stale schema count: expected 14 tables, canonical schema now emits 15 (including additive `tarot_cards.csv`).
- TR widget localization: `MaterialLocalizations` and `CupertinoLocalizations` delegates were missing for declared `tr` locale.
- persisted PDF router fail-closed test did not protect the synchronous throw before a Future was returned.
- strict PDF inspector now rejects legacy 222-byte synthetic fixtures because they lack `startxref`/xref/root linkage.
- additional independent calculation-core failures remain in BaZi and historical timezone tests.
- additional widget/accessibility failures remain and must be repaired from exact logs, not waived.

## Changes made

### APK-level Daily Message evidence gate

Added `tools/content/validate_daily_message_apk_assets.py` and `.github/workflows/daily-message-apk-packaging.yml`.

The workflow builds a release APK, inspects the APK ZIP itself for packaged TR/EN Daily Message CSV assets, validates exact 2026-01-01..2036-12-31 date+locale coverage (4,018 per locale), rejects missing/duplicate/mismatched records, records the release APK SHA-256, and uploads the machine-readable evidence report. This does not replace the still-required real-device/offline proof.

### Production TR/EN localization wiring

`RuhCodeApp` now wires `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, and `GlobalCupertinoLocalizations` for the explicitly supported `tr` and `en` locales. The Today widget test fixture was aligned with the same production delegate contract.

### Backup schema test drift

`local_database_backup_exporter_test.dart` was restored to its canonical pre-edit structure and its stale `recordCounts.length` expectation was updated from 14 to 15, matching `BackupSchemaRegistry.tables` and the additive schema-v1 `tarot_cards.csv` member.

### PDF router test boundary

The unknown-calculation-type fail-closed assertion now wraps the call in `Future.sync`, so both synchronous rejection and Future rejection are captured without changing the production guard semantics.

## Commits in this run

- `10a2ca430b46b6baaae1250949fd8f9fdc0c6980` — APK-level Daily Message validator
- `43327fbeba32245e2433c4bbe82b9bdd72884444` — Daily Message APK packaging workflow
- `f1aeb30e9de133d6d49bf994dea8b01e4cb9047b` — production Flutter TR/EN localization delegates
- `4c2d93866912f59b2caaa51910f8f639d467e183` — Today widget locale fixture alignment
- `b5d13545976a68990f28e5ee504bd5655684f23e` — canonical backup exporter test restored with 15-table expectation
- `345a7cf56fb6b75920ef8545f04e09692feb3b06` — synchronous PDF router fail-closed test boundary

An intermediate backup-test edit was immediately superseded by the canonical restore commit and must not be treated as final content.

## Remaining critical work

- wait for/read the newest exact-SHA Flutter Quality and new APK Packaging runs; do not count queued/indexing state as SUCCESS.
- continue reducing the remaining 31-test baseline by exact root-cause cluster: strict PDF fixture generation, BaZi primitive expectation/implementation, historical timezone skipped-day semantics, widget/accessibility failures.
- obtain exact release APK asset evidence from the new workflow, then add real offline/airplane-mode device-open proof.
- keep RC-1424/1425/1426/1427/1433/1434 OPEN until their complete runtime/release/device evidence is satisfied.
- continue all other master blockers in dependency order after critical gates recover.

**FINAL: NO.**
