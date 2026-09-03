# RUH CODE — RC-1437 BODY/CENTER GRAPH CHECKPOINT

## Baseline verification

- Previous engineering HEAD `889bb06a2b0a52d7ec04ea0c04a1809ddda4566a` was re-read before modification.
- GitHub Actions indexed 25 workflows for that exact SHA.
- `RC-1437 Runtime Assets` run `33713302483` completed `SUCCESS`.
- No failure or in-progress conclusion was found in the exact-SHA run set at the time of verification.
- `requirements/requirement_state.csv` remains a sparse override ledger with no RC status overrides; no requirement is promoted merely because source exists.

## Implemented in this run

### SPK body/center graph evaluator

Added `lib/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart`.

The evaluator:

- resolves a target to NAIF ID 0 (solar-system barycenter) by following packaged SPK target→center edges,
- resolves observer independently and subtracts observer state,
- accepts NAIF ID 0 as the only implicit zero-state root,
- uses last matching segment in the single packaged kernel as segment priority,
- requires coverage at the exact requested ET,
- requires J2000 frame ID 1 on every traversed edge,
- requires SPK Type 2 on every traversed edge,
- rejects missing center paths,
- rejects target/center cycles,
- rejects unsupported frame and data type instead of approximating or substituting.

Engineering commits:

- `25cceeec27d2386421b48badd4d45b88e165b781`
- `15e6c583a3dae6a2ceaacb1c47b46fe1fece9e48`

### Deterministic graph contract tests

Added `test/calculation_core/spk_body_graph_evaluator_test.dart`.

Coverage includes:

- synthetic Earth→EMB→SSB state addition,
- target-relative-to-observer subtraction,
- reverse observer relation,
- missing-center fail-closed behavior,
- explicit graph-cycle rejection,
- unsupported-frame rejection,
- unsupported-SPK-type rejection.

Commit: `faa24c92bd4b0c097d11e28f90d08a688f4984e7`.

### Real packaged DE440s graph runtime test

Added `test/calculation_core/de440s_body_graph_runtime_test.dart`.

The test loads the physical bundled DE440s kernel, parses the real DAF index and resolves:

- Earth (399) relative SSB (0),
- Earth-Moon barycenter (3) relative SSB (0),
- Earth (399) relative EMB (3),

at J2000 ET=0. It requires finite state components and verifies the physical chaining identity `Earth/SSB = EMB/SSB + Earth/EMB` for position and velocity.

This is runtime-integrity evidence only; it is not an independent astronomical accuracy golden.

Commit: `f1bb924d8bd37c793a50c319aed22e082adc955a`.

### CI binding

`.github/workflows/rc1437-runtime-assets.yml` now runs:

1. physical astronomy asset validator,
2. SPK Type-2 contract tests,
3. SPK body/center graph contract tests,
4. real packaged Type-2 runtime evaluation,
5. real packaged DE440s body-graph runtime evaluation.

Commit: `dd2394de5097a008d49118de8445fc17fe4ae7f7`.

The exact `dd2394de...` run set is indexed as 25 workflows but remained queued when re-read in this automation run. Therefore these new changes are still not claimed exact-SHA green.

## RC-1436 independent official golden-vector provenance

Binding RC-1436 was re-read: every mathematical engine requires measurable tolerances; an unbounded “approximately correct” criterion is forbidden.

Added `tools/data/materialize_jpl_horizons_golden.py` in commit `9fabd5ff33071a1440f8d3ffca86bf290a0004a0`.

The materializer is fail-closed and captures an official NASA/JPL Horizons Earth(399)/SSB(0) state at J2000 using an explicit query contract:

- `EPHEM_TYPE=VECTORS`,
- `VEC_TABLE=2` (x,y,z,vx,vy,vz),
- `CENTER=@0`,
- `TLIST=2451545.0`, `TLIST_TYPE=JD`, `TIME_TYPE=TDB`,
- `REF_SYSTEM=ICRF`, `REF_PLANE=FRAME`,
- `VEC_CORR=NONE`,
- `OUT_UNITS=KM-S`,
- CSV output.

It requires the official `NASA/JPL Horizons API` signature, exactly one `$$SOE/$$EOE` vector row, finite non-zero state data, and records the exact request URL/query, API version/signature, raw response SHA-256, capture timestamp and parsed vector. Numeric vectors are explicitly non-editable provenance data.

Added `.github/workflows/materialize-rc1436-jpl-golden.yml` in commit `f83417c7dcf4bbe0a0df1c367d1d7700427c277f`.

That workflow is manual/fail-closed, validates the generated evidence shape/provenance and commits the canonical evidence file only after a successful live official JPL capture. The connected GitHub action surface available in this run exposes workflow reads/re-runs but no workflow-dispatch write action, so the live capture was not falsely claimed as executed here.

No guessed, cached, search-snippet or third-party vector was committed. `planetaryEphemeris.proven` remains false until the canonical official evidence exists and the runtime comparator passes explicit tolerances.

## Status

- Body/center graph source: IMPLEMENTED.
- Synthetic graph fail-closed coverage: IMPLEMENTED, pending exact new-head CI completion.
- Real packaged graph execution: IMPLEMENTED, pending exact new-head CI completion.
- Official JPL golden materializer/provenance gate: IMPLEMENTED.
- Live official JPL canonical golden evidence: OPEN.
- RC-1436 tolerance binding/comparator: OPEN.
- 1890→2110 EOP/versioned range policy: OPEN.
- RC-1437: NOT DONE.
- RC-1439: NOT DONE.
- RC-1442: NOT DONE.
- Requirement ledger: unchanged.

## Next dependency

1. Read exact current engineering CI completion and repair any graph/runtime/analyzer failure in-place.
2. Execute the official Horizons materializer through the repository workflow when workflow-dispatch capability is available; require canonical evidence + raw-response hash.
3. Add the packaged DE440s body-graph comparator and explicit RC-1436 tolerance evidence against that independent vector.
4. Keep `planetaryEphemeris.proven=false` until independent accuracy evidence passes.
5. Continue 1890→2110 EOP policy, strict RC-1439 and release/device blockers independently.

**FINAL: NO.**
