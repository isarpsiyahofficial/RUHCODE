# Ruh Code automation checkpoint — Western equal houses

## Completed source-level work

- Added strict `EqualHouseSystems` runtime for **Whole Sign** and **Equal House**.
- Runtime accepts only a separately verified ascendant longitude in `[0,360)`; it does not calculate or invent ASC.
- Produces exactly 12 normalized cusps, 30° apart.
- Whole Sign house 1 starts at the ascendant sign boundary.
- Equal House house 1 starts at the exact ascendant longitude.
- Exact-cusp ownership and 0°/360° wrap behavior are explicitly defined.
- Planet/ecliptic longitude → house-number assignment is deterministic.
- Invalid and non-finite inputs fail instead of being silently normalized.
- Added boundary-focused Flutter tests.
- Added machine-readable contract, structural validator, and dedicated GitHub Actions workflow.

## Commit

`18072e32188369f349e262ce50ff254fd8ee8b51`

## Requirement status

This is **source-level progress only**. RC-0055/RC-0056 are not marked DONE because the upstream ASC/MC angle engine and independent golden accuracy evidence are still missing. `accuracy.proven` intentionally remains `false`.

## Continue from here

1. Implement a strict angle-input/provenance model so verified ASC/MC values cannot be confused with placeholders.
2. Implement ASC/MC only after formula/reference and independent golden cases are locked; do not guess formulas.
3. Add Placidus only with explicit polar/unavailable behavior and independent reference evidence.
4. Continue physical IERS EOP, offline ephemeris, GeoNames, Lahiri, and 8,036-message blockers in parallel when artifacts become available.
5. Verify the new `Western Equal House Contract` and Flutter Quality checks on the exact commit when GitHub exposes the check results.

**FINAL değil.**