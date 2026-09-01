# Ruh Code — PDF inspector regression + CI continuation

## Binding scope

- RC-0001 → RC-1442 remains binding.
- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_AUTOMATION_PROGRESS.md` and `requirements/requirement_state.csv` were re-read before continuing.
- `requirements/requirement_state.csv` remains a sparse explicit-override ledger and was not modified. No RC was promoted to DONE without evidence.

## Baseline re-validation

The latest completed Flutter Quality diagnostic baseline that exposes concrete failures is exact HEAD `bf9b954f454f8c8685469010e4519c22073b7773`, run/job `33554498838 / 100011879752`, artifact `9819339077`.

Exact summary: `+573 -17`.

The 17 failures consisted of:

- 4 Professional PDF builder lazy-action test failures,
- 3 backup accessibility/runtime lazy-control/lifecycle failures,
- 1 2.0x text-scale lazy Tools target failure,
- 2 main-navigation route/semantics failures,
- 2 critical semantics failures,
- 1 combined PDF English lazy-label failure,
- 4 production-PDF structural-inspection failures caused by classic-xref trailer `/Root` discovery.

The source lineage after that artifact contained 11 repair commits through `a2152f409415f61e5b7e91e34743335e219e7a81`, including the PDF inspector classic-trailer fix and the UI/lifecycle fixture repairs. These commits are source-level repairs only until the new exact-SHA Flutter Quality run completes.

## New work in this run

Added `test/pdf/pdf_output_inspector_generated_pdf_test.dart` in commit:

`454f4bd849c6683b86b913bd8494e80cfe90bbc1`

The new regression coverage adds three explicit gates:

1. Generate a real one-page PDF using the same `package:pdf` dependency used by production and require `PdfOutputInspector.requireUsable` to accept its classic-xref structure.
2. Verify a classic trailer that contains a nested dictionary before `/Root` still resolves `/Root → Catalog → Pages` correctly.
3. Verify the same nested-trailer shape still fails closed when `/Root` is genuinely absent.

This protects the repaired parser from regressing back to the earlier "stop at first `>>`" behavior while preserving fail-closed semantics.

## CI state

Exact SHA `454f4bd849c6683b86b913bd8494e80cfe90bbc1` triggered 25 workflow runs. At checkpoint observation they were queued, so no SUCCESS claim is made.

The GitHub Actions backlog is currently a transient execution/indexing constraint, not a reason to weaken quality gates. The repository was therefore advanced with deterministic regression coverage rather than marking the 17-failure set resolved without a completed exact-SHA run.

## Next dependency-safe continuation

1. Read the first completed Flutter Quality run on the newest exact SHA.
2. If red, download the new `flutter-test-diagnostics` artifact and patch only the remaining exact root causes.
3. If green, record the exact run/job/artifact evidence and move to the newest Daily Message APK Packaging result.
4. Once APK packaging is green, continue with real offline/airplane-mode Daily Message device proof, tracked/signable Android release host, physical ephemeris/EOP/font/UI reference/device evidence, and clean-checkout signed release proof.
5. Do not mark FINAL until all 1,442 RC requirements and mandatory lifecycle/release gates are verified.

**FINAL: NO.**
