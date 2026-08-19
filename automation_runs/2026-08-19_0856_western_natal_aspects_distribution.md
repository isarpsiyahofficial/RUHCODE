# Ruh Code automation checkpoint — Western natal derived data

## Implemented in this run

- Added deterministic natal major-aspect engine for conjunction, sextile, square, trine and opposition.
- Added configurable per-aspect `AspectOrbPolicy` with strict validation.
- Added 0°/360° seam handling, inclusive orb boundary tests, outside-boundary rejection and deterministic pair ordering.
- Added `WesternNatalChartAssembler` combining houses, placements and aspects from one TT/source/version provenance snapshot.
- Added source tests for aspect behavior and chart assembly.
- Added `western_natal_aspects` evidence manifest, structural validator and dedicated GitHub Actions contract.
- Added deterministic Fire/Earth/Air/Water and Cardinal/Fixed/Mutable distribution engine derived from the exact natal placement set.
- Added explicit `PlacementWeightPolicy`; incomplete, negative/non-finite or all-zero policy cannot silently pass.
- Added distribution unit tests, evidence manifest, structural validator and dedicated GitHub Actions contract.

## Requirement mapping advanced at source level

- Natal aspects/orbs: RC-0037, RC-0038, RC-0039, RC-0040, RC-0041, RC-0043, RC-0044, RC-0051, RC-0271, RC-0272, RC-0273, RC-0278.
- Element/modality: RC-0045, RC-0046, RC-0047, RC-0274, RC-0275.

These requirements are **not marked DONE** because physical ephemeris provenance, independent astronomical accuracy evidence and visible exact-commit Flutter/Actions success evidence are still required where applicable.

## Commits

- Aspect engine: `38ecbcca73c579a7d6c5c2386cd7c79caf4ae356`
- Aspect tests: `74bda0ca42db1f5ff5c48e9f00fe9dd06c1ac4e6`
- Natal chart assembler: `5daa6f6feaad830dfab5d54c06581ee1f633eb50`
- Natal chart tests: `937b8f873ed2b3b513da8437c8cdcd2491f5788b`
- Aspect evidence: `ea232595f75cb7a800960f9af09a2cb163dc3381`
- Aspect validator: `f50cfd8be2f532f01ae950cf20ff6cec9bc62a97`
- Aspect workflow: `3b9239a05c89f5e5191fb5bba9e6ae4b05ca8db2`
- Main progress checkpoint: `008182f40c990e2a74e56f2b515bb9f4bce2bd08`
- Distribution engine: `39eb07bf438528753a0f3cf75daf50e673049a09`
- Distribution tests: `705932268838d1dd3b28b13a238cf64022556f96`
- Distribution evidence: `24f15184e0655cc7daf02b7b780687a3a7abf977`
- Distribution validator: `2d1ef1f1e8f9fc7eb001eb778101ad96c246900d`
- Distribution workflow: `7d1440c0cc900d42fa5d444d57e57d9cdabeab3f`

## Next safe dependency order

1. Obtain visible exact-commit status for the Western natal contracts and fix any failures that become visible.
2. Add aspect-grid data structure derived from the same `NatalAspectSet` without duplicating calculations.
3. Add classic dignity/rulership data contract only after terminology/algorithm policy is explicit; do not invent disputed defaults.
4. Continue physical IERS EOP, offline ephemeris and independent golden accuracy evidence in parallel.
5. Do not mark astronomical RCs DONE until provenance + accuracy + CI evidence is present.

**FINAL değil.**
