# RUH CODE automation checkpoint — Flutter 11-failure root-cause repair

Binding scope remains `RC-0001 → RC-1442`. This checkpoint does not mark any RC requirement DONE merely because source/test code changed.

## Re-read baseline

Exact completed Flutter Quality baseline:

- HEAD: `b726b3196d9dfa0a15c740bc79a8c41f32379aff`
- run/job: `33564911120 / 100045753949`
- Analyze: **SUCCESS**
- Test: **FAILURE**
- exact summary: **`+582 -11`**

This improves the earlier recorded progression from `+559 -28` and `+573 -17`, but the critical gate was still red.

## Exact 11-failure triage

The completed diagnostic log reduced the failures to two root-cause families:

1. Five production-generated PDF tests rejected otherwise valid `pdf 3.13.0` PDF 1.5 xref-stream output because `PdfOutputInspector` required `/Type /XRef` to be serialized before `/Root` inside a PDF dictionary.
2. Six UI/accessibility tests exercised lazy/off-screen controls through stale finder assumptions or exposed one real numerology metric semantics grouping weakness.

## Production PDF repair

Commit `715d348bb48b1368d93bdc16daa0385ab828ccba` updates `PdfOutputInspector` without relaxing fail-closed structural validation.

For a PDF 1.5 xref stream, the inspector now:

- bounds the candidate xref object before trailing `startxref`,
- independently proves it is an indirect object,
- independently requires `/Type /XRef`,
- independently extracts a strict indirect `/Root n g R` reference from the same bounded object,
- preserves subsequent `/Root → Catalog → Pages` resolution,
- still rejects missing/invalid Root and malformed xref targets.

This removes only the invalid dictionary-key-order assumption. Classic xref validation remains unchanged.

## UI/test repairs

The same run applied:

- `8ee645fa5d33b20b83290d2f60bdd961b1b28f61` — Professional PDF share tests now scroll/ensure the lazy share action into the viewport before asserting/tapping it.
- `cb5243fec9bfad26c122f41b8d235d625678b365` — Backup merge/replace accessibility assertions are performed while each control is actually visible, preserving 48dp and deterministic focus-order checks.
- `7cbab2c0e2c8f602467bef032ad1f6f1c0470ce7` — Backup runtime navigation uses canonical action IDs and failed-replace rollback taps a guaranteed-visible Replace action.
- `07eca6e98b01ad975c8f78f83ca329270c17c290` — 2.0x text-scale route test uses canonical navigation/action IDs rather than ambiguous text nodes in the `IndexedStack`, and scrolls the actual Records list to the professional-client action.
- `78dbb9056d3881d0ebc9fe1d8c9482dd27e8a7bd` — production numerology metric rows now expose one explicit semantics container such as `Yaşam Yolu: 7`, while preserving visible label/value text.

Compared with the red baseline, `78dbb905...` is **6 commits ahead / 0 behind** and changes exactly the PDF inspector, numerology semantics surface, and four affected test files.

## Current verification state

The new exact source SHA `78dbb9056d3881d0ebc9fe1d8c9482dd27e8a7bd` has begun spawning GitHub Actions runs. At the time of this checkpoint they were queued/indexing; they are **not** counted as SUCCESS.

Therefore:

- no new RC requirement is marked DONE,
- `requirements/requirement_state.csv` remains unchanged,
- Flutter Quality remains an open release gate until the new exact SHA completes,
- Daily Message APK packaging/offline-device evidence remains a separate open dependency after Flutter Quality.

## Next continuation

1. Read the completed Flutter Quality run for the newest exact SHA; do not infer green from source patches.
2. If red, download/read the new `flutter-test.log` artifact and repair only the exact remaining failures.
3. If green, record exact run/job/artifact evidence and proceed to the canonical+legacy Daily Message APK Packaging gate.
4. If APK packaging is green, record APK SHA-256/JSON evidence and move to real offline/airplane-mode device lookup proof.
5. Continue physical EOP/ephemeris/font/UI/device/signing/clean-checkout/release blockers in dependency order.
6. Do not mark FINAL until all `RC-0001 → RC-1442` are evidence-backed DONE and all mandatory release gates are green.

**FINAL: NO.**
