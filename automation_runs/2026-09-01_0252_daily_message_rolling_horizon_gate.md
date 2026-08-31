# RUH CODE automation checkpoint — rolling daily-message release horizon

## Binding scope re-read

- `RUH_CODE_MASTER_TODO.md` and `RUH_CODE_MASTER_INDEX.md` re-read.
- Binding scope remains exactly `RC-0001 -> RC-1442` / 1,442 requirements.
- `requirements/requirement_state.csv` remains the sparse explicit-override ledger with no unproven DONE rows added.
- `RUH_CODE_AUTOMATION_PROGRESS.md` re-read before implementation.

## Baseline verification

Exact starting `main` HEAD: `2ffb060aa80f60bc3f49245dc670f266470ed32e`.

The GitHub Actions collection for that exact SHA contains 23 completed workflow runs. No `conclusion=failure` and no queued run was found in the exact-head result. The previously repaired source-level Requirements/UI/Flutter chain therefore had no visible red gate on this exact starting SHA.

## Work implemented

RC-1433 requires at least ten full years of daily-message stock ahead of every release date. The repository previously declared `rolling_release_horizon_years: 10`, but the release CI did not dynamically prove that the compiled catalog still reaches ten calendar years beyond the actual release date.

Implemented:

1. `tools/content/validate_daily_message_release_horizon.py`
   - takes an explicit ISO release date;
   - reads the canonical compiled catalog and manifest;
   - requires the manifest horizon to be at least ten years;
   - calculates the release-date + horizon calendar target;
   - verifies every date in the release window has both exact `tr` and `en` keys;
   - rejects duplicate exact date/locale keys;
   - emits a machine-readable report with required-through date, locale maxima and missing count.
2. `tools/content/test_validate_daily_message_release_horizon.py`
   - exact ten-year window passes;
   - one missing EN date blocks release;
   - catalog ending one day before the horizon blocks release;
   - leap-day release date has deterministic calendar-year handling.
3. `.github/workflows/daily-message-editorial-contract.yml`
   - runs the new unit tests;
   - after deterministic full-catalog compilation and strict editorial audit, executes the rolling horizon validator with the runner's UTC release date;
   - uploads `daily_messages_release_horizon_report.json` together with the strict audit artifact.
4. `requirements/content_manifests/daily_messages.json`
   - declares the release-horizon validator;
   - adds `rolling_ten_year_release_horizon` as an explicit quality gate.
5. `tools/content/validate_daily_message_contract.py`
   - binds the new validator, tests, manifest wiring and gate into the structural content contract so they cannot silently disappear.
6. `evidence/content/daily_messages_editorial_progress.json`
   - records the new source/test/validator paths and guardrail;
   - retains `done: false`;
   - narrows remaining work to exact-head CI proof, runtime/package consumption proof, and ongoing future-stock maintenance.

## Requirement status discipline

No RC was marked DONE in this run. In particular RC-1433 remains open until the new rolling-horizon gate is visibly green on an exact SHA and release packaging/runtime proof is complete. RC-1424/1425/1426/1427/1434 also remain subject to their remaining release-level evidence.

## Current verification state

Latest implementation/evidence commit before this checkpoint: `7432dbca869a60495ce5a9e3522bb663a7c88379`.

At the last exact-head query made during this run, GitHub had not yet exposed workflow runs for the newly written horizon-gate commits. Therefore the new gate is not claimed SUCCESS yet.

## Next continuation

1. Re-read the newest exact `main` SHA and Actions runs.
2. If the rolling-horizon workflow is red, decode its job log and repair the root cause without weakening the ten-year rule.
3. If green, record its exact run/job/artifact evidence, then evaluate daily-message app/package runtime consumption for RC-1424/1425/1427/1433/1434.
4. Continue into the next independent physical artifact/font/UI/device/release blocker.
5. Do not declare FINAL until all 1,442 requirements and clean-checkout exact release gates are proven.

**FINAL: NO**
