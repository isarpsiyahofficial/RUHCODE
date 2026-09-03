# RC-1437 — EOP capability policy checkpoint

## Baseline

- Baseline HEAD: `9ee8540e731a8f4e6307655062477d91cf351076`.
- Baseline exact-HEAD failure query returned no failed workflow run.
- Binding RC state remains broader than this sub-gate; no requirement was marked DONE merely from source changes.

## Implemented in this run

1. Added `lib/src/calculation_core/time/earth_orientation_capability_policy.dart`.
   - Product date range is explicit: `1890-01-01T00:00:00Z` inclusive through `2111-01-01T00:00:00Z` exclusive.
   - Product-range support and physical IERS EOP availability are deliberately separate.
   - Dates inside the product range but outside bundled published EOP coverage return `EOP_OUTSIDE_PUBLISHED_COVERAGE` and fail closed.
   - Dates outside the product range return `OUTSIDE_PRODUCT_DATE_RANGE`.
   - No UTC-for-UT1 substitution, nearest-neighbour lookup, extrapolation, or fabricated future EOP is introduced.
2. Added `test/calculation_core/earth_orientation_capability_policy_test.dart` covering both product boundaries, physical-coverage availability, explicit unavailable behavior, outside-product behavior, and UTC-only input.
3. Updated `requirements/reference_manifests/earth_orientation.json` from stale `pendingRuntimeData: NOT_DONE` to a truthful `BUNDLED_VERIFIED_SUBGATE` physical-IERS state while explicitly keeping `fullRc1437Done: false`.
4. Hardened `tools/time/validate_earth_orientation_contract.py` so it verifies the physical asset byte size and SHA-256 against the manifest/loader and requires the fail-closed product-range policy/tests.
5. Expanded `.github/workflows/earth-orientation-contract.yml` to run the new capability-policy test and the real packaged IERS loader test.

## Physical evidence retained

- Asset: `assets/data/eop/finals2000A.all`
- Bytes: `3763572`
- SHA-256: `e3905ff7a74b791744704aa3e900a2161e96db97a30095d8fc442b04e4cfe058`
- Runtime source/version: `IERS finals2000A.all` / `2026-09-02`

## Commits

- `27f27f70cf6eb48da58fef49578c3add0634bef0` — capability policy
- `c832c12bce880e6b55a089c92c1a3a7fc36a436f` — capability tests
- `609a057f76595eb54cf0e23c9815727939c6c8ca` — manifest alignment
- `bc137293ecfd10175bf8c5a9c46c949687d50905` — physical validator hardening
- `5a1ebf1f47c57107c9955a7f24048ce37b65eefb` — CI gate extension

## State / next dependency

RC-1437 is NOT DONE. This closes the ambiguity around the 1890→2110 product range versus narrower published IERS EOP coverage without inventing data. Next: exact-HEAD CI completion/root-cause repair if red, then broaden independent official ephemeris golden/tolerance coverage beyond the single J2000 Earth→SSB vector, followed by RC-1439 and release/device gates.

**FINAL: NO.**
