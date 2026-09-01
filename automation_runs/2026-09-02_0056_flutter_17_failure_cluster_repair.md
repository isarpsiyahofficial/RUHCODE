# RUH CODE — Flutter 17-Failure Cluster Repair Checkpoint

## Binding scope

- Binding requirements remain `RC-0001 → RC-1442`.
- `requirements/requirement_state.csv` remains unchanged; no source-only work was promoted to DONE.
- FINAL remains prohibited while critical test/release/device gates are open.

## Baseline re-verification

Exact baseline HEAD `bf9b954f454f8c8685469010e4519c22073b7773` was re-read together with the master TODO/index and automation progress.

Flutter Quality run/job:

- run: `33554498838`
- job: `100011879752`
- Analyze: **SUCCESS** (`flutter analyze --fatal-infos`: no issues)
- Test: **FAILURE**
- exact diagnostic summary: **`+573 -17`**
- diagnostic artifact ID: `9819339077`

This proves the previous 28-failure baseline had already dropped to 17 failures before this run.

## Repairs applied in this run

### 1. Production PDF structural inspector

Real PDFs emitted by the production `pdf` package had header/EOF/catalog/pages/startxref/xref target all valid, but were rejected with `xrefRoot=false` because the classic trailer parser stopped at the first nested `>>` before `/Root`.

Repair:

- classic xref trailer parsing is now bounded from `trailer` to final `startxref`
- `/Root n g R` is still mandatory and must still resolve to a Catalog
- Catalog `/Pages` must still resolve to a Pages tree
- malformed/no-root fixtures remain fail-closed
- xref-stream behavior was not weakened

Commit: `022eaef96c436445e46bc359f87db0193c3af8c6`

### 2. Professional PDF builder lazy ListView tests

Four builder tests attempted to tap `ACTION-PDF-BUILDER-CREATE` after preview insertion pushed the control outside the lazy ListView build window. The production control was not removed or moved merely to satisfy tests.

Repair:

- tests now scroll the canonical create control into view before tap
- preview/create/share behavior and production button keys remain unchanged

Commit: `874e58db99351918ff12444b435d0ee17901d486`

### 3. Numerology metric accessibility

The metric value Semantics node inherited child text in addition to its explicit localized label, making the screen-reader contract unstable.

Repair:

- metric Semantics now uses `excludeSemantics: true`
- canonical label remains `localized metric label: value`
- visual label/value layout is unchanged

Commit: `3f37100895e1435191d73cccfb55c7b083469afe`

### 4. Critical PDF semantics test

After preview insertion, create/share controls can be outside the lazy ListView build window.

Repair:

- critical semantics test scrolls create/share controls into view before asserting/tapping
- SemanticsHandle is explicitly disposed before test completion

Commit: `8c3d4faaa0ecefc314f419ac11a9be3d3f4b1208`

### 5. Backup accessibility and restore tests

Repair:

- SemanticsHandle lifetime is explicitly closed inside tests
- lazy restore merge/replace controls are scrolled into view before semantics/size/tap assertions
- replace rollback wiring test scrolls the canonical keyed replace action into view before tap

Commits:

- `88ecaa4991cec9c4017570d5fef35c9917cc8612`
- `89c67e1923686ecd060a8c90d4cebac52cf7baca`

### 6. 2.0x text-scale navigation

`Kişisel Gelişim` can be outside the Tools ListView build window at 360×800 and 2.0x text scale.

Repair:

- the accessibility test scrolls the real target into view before asserting it
- production layout/text scaling was not weakened

Commit: `99d32991626d2b5407f328be0e0dfc3eb8422c6e`

### 7. Navigation route-back and semantics lifetime

`tester.pageBack()` is not reliable for the Turkish Material route because its helper searches framework-specific back surfaces. The application route itself is valid.

Repair:

- test pops the Navigator through the actual Chinese astrology route context
- action-tile SemanticsHandle is explicitly disposed

Commit: `109d45daae0847ee562ad24aee7c3836a3bcda63`

### 8. Combined PDF English labels

The production page already maps `technicalManifest` to independent English `Calculation Details`; the test only scrolled as far as the Numerology section, leaving the later lazy child unbuilt.

Repair:

- test now scrolls the actual `Calculation Details` label into view before asserting it
- production TR/EN copy was not weakened

Commit: `593f74fbda30ba5b56473ca30a08c86f72f372ee`

## Current exact source HEAD at checkpoint start

`593f74fbda30ba5b56473ca30a08c86f72f372ee`

GitHub created 26 workflow runs for that exact SHA. At the checkpoint observation they were queued, so none were counted as SUCCESS.

## Next dependency-safe work

1. Read exact HEAD Flutter Quality completion; if red, consume the diagnostic artifact and patch only the remaining exact failures.
2. Re-read Daily Message APK Packaging on the same exact source lineage; require 4,018 TR + 4,018 EN, missing=0, duplicate=0 and APK digest evidence.
3. Do not mark Daily Message or PDF RCs DONE until their required APK/device/release evidence is complete.
4. Once Flutter Quality and APK packaging are green, continue with real offline/airplane-mode lookup and remaining physical ephemeris/EOP/font/UI-reference/device/clean-checkout release blockers.

**FINAL: NO.**
