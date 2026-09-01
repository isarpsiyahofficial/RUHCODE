# Ruh Code — Flutter/APK Runtime Failure-Cluster Repair Checkpoint

## Binding scope

- Binding scope remains `RC-0001 → RC-1442` / 1,442 requirements.
- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md`, the base specification and RC-1421→RC-1442 addendum were reread before continuing.
- `requirements/requirement_state.csv` was not modified. Source/test changes below do not by themselves prove any RC DONE.

## Exact baseline revalidation

Baseline source HEAD for this repair pass was `f18493949d0229a41e47d2dc05338e2167f599ac`.

### Flutter Quality

Run/job `33541602606 / 99968946166`:

- Analyze: SUCCESS
- Test: FAILURE
- downloaded diagnostic artifact `9814027794` (`flutter-test-diagnostics`)
- exact artifact summary: `+559 -28` — 28 failing tests, not the older stale 31-failure count

The failures were grouped by shared root cause instead of patched one assertion at a time.

### Daily Message APK Packaging

The first packaging failure was caused by the repository not containing an Android host. The gate was repaired to materialize a deterministic Flutter 3.44.7 Android host from a clean checkout when no tracked host exists, while recording provenance.

On exact SHA `5fb94606b7c4c9445f2675fb3ebf42b36b142ba6`, run/job `33552722873 / 100005891069` proved:

- Android host materialization: SUCCESS
- release APK build: SUCCESS
- produced APK size: 53.2 MB
- APK asset validation: FAILURE

This second failure exposed a real runtime/content compatibility defect rather than a CI-only issue.

## Real Daily Message runtime defect found and repaired

The packaged source changes schema at `2030-07`:

- up through `2030-06`: canonical six-column CSV (`date,locale,title,teaser,full_text,theme_tag`)
- from `2030-07` in the existing historical shards: five-column legacy CSV (`date,title,teaser,message,theme`)

The production `DailyMessageAssetLoader` previously accepted only the six-column schema, so packaged historical shards after 2030-06 would fail closed at runtime even though source coverage was complete.

Repair:

- production loader now accepts exactly two explicitly known schemas: canonical six-column and legacy five-column
- legacy locale is derived strictly from the asset path (`tr/` or `en/`); no language fallback is introduced
- legacy `message` maps to `fullText`; `theme` maps to `themeTag`
- unknown headers remain rejected
- canonical row/path locale mismatch remains rejected
- empty required title/teaser/full text/theme remains rejected through `DailyMessageEntry`
- exact duplicate date+locale remains rejected through `DailyMessageCatalog`
- no network, AI, random-date or random-language fallback was added

The APK ZIP validator was updated to apply the same explicit schema contract and still requires exactly 4,018 TR + 4,018 EN exact date records, no missing keys, no duplicates and no empty normalized fields.

Relevant commits include:

- `d7e5316c429e10d1cb37fdc304fd33d81beacf0d` production legacy normalization
- `13a0ee5a0024fdfa33f2253155b42d41b176066c` loader tests
- `54ff35b77e5b7e64ef260e1013448882ae9d29a3` strict APK canonical+legacy validator
- `ac5cbd787ceeca5d79f16f60a998bc29d8795db6` contract-test identity preservation

## Flutter failure clusters repaired in source/tests

### Calculation fixtures

- BaZi Hidden Stems fixture aligned with canonical branch tables: water=1 and total hidden-stem occurrences=10; production algorithm was not weakened.
- Pacific/Apia skipped-day expectation aligned with the explicit `shiftForward = first valid wall-clock instant` policy: noon on skipped 2011-12-30 advances 12 wall-clock hours to 2011-12-31 00:00, not 24 hours.

### Strict PDF fixtures

Four failures were caused by test delegates returning tiny synthetic byte strings that began with `%PDF` but were not structurally valid PDFs. Strict production PDF inspection was retained. Test renderers now generate genuine PDFs with the `pdf` package.

### Persisted Western snapshot fixtures

- tamper test now changes a structurally valid sealed field so SHA-256 identity is what rejects the payload
- aspect mismatch fixture now contains a genuine type/geometry inconsistency instead of a very large orb that accidentally made the aspect valid

### Localization test harness

A shared widget-test defect was identified: tests requested Turkish locale without installing the same Material/Widgets/Cupertino localization delegates production uses. Affected navigation, backup, professional PDF, combined PDF, text-scale and semantics fixtures were aligned with the production TR/EN localization contract.

### Accessibility production repair

`ProfessionalPdfBuilderPage` wrapped Material buttons in an outer labelled `Semantics` node while leaving child button semantics active, producing duplicate screen-reader labels for preview/create/share. The outer wrappers now use `excludeSemantics: true`, leaving exactly one canonical labelled actionable semantics node while preserving the 48dp controls.

## Requirement discipline

- No requirement was marked DONE because of these source/test repairs.
- Daily Message source coverage remains 4,018 TR + 4,018 EN, but APK validator success on a new exact SHA and real offline/device proof are still required before release-level closure.
- RC-1442 clean-checkout/reproducible release remains open: the temporary generated Android host provides packaging evidence, not the final tracked/signable release-host proof.

## Exact source continuation point

Source/test repair HEAD before this checkpoint: `faf0a061fa939a440108c54a61a1a40ea86a9f28`.

New exact CI must be read before claiming any repaired failure cluster green. Queued/in-progress runs are not SUCCESS.

## Next dependency-ordered work

1. Read Flutter Quality for the newest exact SHA; if red, download the new `flutter-test-diagnostics` artifact and repair the remaining exact failure clusters without weakening gates.
2. Read Daily Message APK Packaging for the newest exact SHA. If the strict validator is green, preserve JSON report + APK digest evidence; if red, repair the exact packaged-data/runtime mismatch.
3. After APK packaging is green, add real offline/airplane-mode device evidence for packaged Daily Message lookup.
4. Continue physical ephemeris/EOP/font/UI-reference/device and clean-checkout release blockers in dependency order.
5. Do not say FINAL until every RC-0001→RC-1442 requirement and all mandatory release gates are proven green.

**FINAL: NO.**
