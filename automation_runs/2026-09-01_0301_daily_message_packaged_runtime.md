# RUH CODE automation checkpoint — packaged daily-message runtime

## Scope and status discipline

Binding scope remains `RC-0001 -> RC-1442`. No requirement was marked DONE in this checkpoint. `requirements/requirement_state.csv` remains unchanged because runtime/device/release evidence is still incomplete.

## Concrete blocker found

The complete 8,036-record Daily Message source catalog was not declared in `pubspec.yaml`, and the production `DailyMessageCatalog` only accepted entries already supplied in memory. Therefore source completeness did not yet prove that an APK contained or loaded the catalog.

## Implemented

- `pubspec.yaml` now packages both `assets/content/daily_messages/tr/` and `assets/content/daily_messages/en/`.
- Added `lib/src/content/daily_messages/daily_message_asset_loader.dart`:
  - discovers packaged daily-message CSV shards from Flutter `AssetManifest`;
  - loads only direct TR/EN catalog shards;
  - parses canonical RFC4180-style CSV including quoted commas/newlines and doubled quotes;
  - converts every row to `CivilDate.parseIso` + exact locale `DailyMessageEntry`;
  - rejects path/row locale mismatch;
  - rejects absent packaged shards;
  - delegates exact duplicate key rejection to `DailyMessageCatalog`;
  - contains no network, random fallback, or AI generation path.
- Added `test/content/daily_message_asset_loader_test.dart` for exact-date lookup, quoted CSV parsing, locale mismatch rejection and duplicate rejection.
- `RuhCodeRuntime.create()` now loads the packaged offline catalog before completing production runtime bootstrap and exposes it as `runtime.dailyMessages`.
- `tools/content/validate_daily_message_contract.py` now fails if the packaged asset directories, runtime loader, loader tests or critical fail-closed tokens disappear.
- `evidence/content/daily_messages_editorial_progress.json` now records packaging/runtime sources and retains `done:false`.

## Rolling horizon work in the same run

Earlier in this run a dynamic RC-1433 gate was also added:

- `tools/content/validate_daily_message_release_horizon.py`
- `tools/content/test_validate_daily_message_release_horizon.py`
- manifest `rolling_ten_year_release_horizon` gate
- CI enforcement against the compiled catalog using the UTC release date
- machine-readable horizon report uploaded with strict editorial audit

## Current CI state

Exact evidence HEAD before this checkpoint: `ee30dd8718d429f679ac550d35bf5acceddde4b7`.

23 exact-head workflow runs had been created and were still queued at the last query. New runtime loader/Flutter analyze/test results are therefore not yet claimed green.

## Remaining daily-message release evidence

- exact visible CI SUCCESS for the rolling horizon gate and Dart packaged-loader tests;
- final approved Today/Daily Message UI consumption of `runtime.dailyMessages` using exact local date + locale, with no random fallback;
- built APK asset inspection and offline/device open proof;
- continued future stock extension so every actual release retains at least ten full years ahead.

## Broader blockers still open

Physical IERS/EOP, redistributable offline ephemeris and independent accuracy, Lahiri/GeoNames production artifacts, APPROVED UI references and real-device regression, Unicode PDF font/render/delivery proof, Play/rewarded device proof, dependency lock/reproducible clean checkout, airplane-mode and final 1,442-RC lifecycle audit remain open.

**FINAL: NO**
