# RUH CODE automation checkpoint — RC-1436/RC-1437 JPL golden

## Verified baseline

- Binding scope remains RC-0001 → RC-1442 / 1,442 requirements.
- No requirement is marked DONE from source implementation alone.
- `requirements/requirement_state.csv` was not changed in this run.

## Work completed in this run

1. Read current repository/progress/TODO/index and re-checked exact HEAD CI.
2. Exact `6589c814e179c906f28ea5994c13c70f3dd86958` had 26 Actions runs. The RC-1436 materializer itself completed SUCCESS.
3. Decoded job logs proved the official NASA/JPL Horizons vector capture and packaged DE440s accuracy test both passed, but exposed a commit bug: `git diff --quiet -- <path>` treats a newly-created untracked evidence file as unchanged.
4. Fixed `.github/workflows/materialize-rc1436-jpl-golden.yml` fail-closed commit logic in `dc0fa9be9019bc16903976f9d1545b0dfb443f38` by distinguishing tracked+unchanged from untracked/new evidence, staging it, and refusing a no-op staged state.
5. The workflow then physically committed canonical official evidence as `a37b79423d91a964e483b70d569af34e644bdaf4`.
6. Canonical evidence now exists at `evidence/rc1436/jpl_horizons_earth_ssb_j2000.json` with NASA/JPL Horizons API provenance, exact query, response SHA, J2000/TDB/ICRF geometric Earth(399)→SSB(0) vector and captured timestamp.
7. The workflow log proves packaged DE440s matched that official golden under the current raw-state contract: max 0.001 km per position axis and 1e-9 km/s per velocity axis.
8. `RC-1437 Runtime Assets` was strengthened in `c33a29adefbc04cd129a42eb2f194720a0d4233b` to permanently run both the packaged IERS provenance/fail-closed coverage test and the canonical official JPL Horizons accuracy test, in addition to the existing physical asset, Type-2, graph and raw tolerance gates.

## Still open

- One J2000 Earth→SSB golden is strong independent evidence but is not enough to claim every astronomical engine/tolerance in RC-1436 is verified.
- 1890→2110 policy remains open for EOP-dependent calculations. Published IERS data must never be fabricated outside its actual coverage; narrower capability must be explicit/fail-closed.
- RC-1439 physical canonical UI reference set is still NOT_PROVEN.
- Production-secret signed clean-checkout reproducible APK, real-device airplane-mode/accessibility/PDF/Play evidence and final 1,442-RC lifecycle audit remain open.

## Next dependency order

1. Read exact CI for `c33a29adefbc04cd129a42eb2f194720a0d4233b`; repair any red gate.
2. Expand independent official ephemeris golden coverage beyond a single epoch/body and bind it to explicit RC-1436 tolerances.
3. Implement and verify the 1890→2110 EOP/date-range capability policy without fabricated EOP.
4. Continue RC-1439 and other independent release blockers.
5. Do not mark FINAL until all RCs and release gates are verified.

**FINAL: NO.**
