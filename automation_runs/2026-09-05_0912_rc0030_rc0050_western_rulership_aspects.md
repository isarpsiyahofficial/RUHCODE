# RUH CODE — RC-0030 → RC-0050 Western Rulership / Aspects Checkpoint

## Physical promotions verified

- RC-0020 = TESTED + blocked=YES via `5dbb577f8754cb30b888dae415417cd8d6cc139d`.
- RC-0028 = TESTED + blocked=YES via `2940c3534d318ef7b13575deceb716993f21d561`.
- RC-0029 = TESTED + blocked=YES via `38a298e8c2990a2ec0a8d2a37e1bcb82e15eb7af`.
- RC-0030 = TESTED + blocked=YES via physical bot promotion `9158aa0c8853f87c61d19813814fb1dfaa9a929c`.

RC-0030 now has a dedicated production Sun/Moon/Ascendant projection, compiled regressions, binding contract, fail-closed validator and dedicated CI. VERIFIED/DONE remains blocked by end-to-end birth input -> time/location -> ephemeris -> houses/ASC -> Western UI golden/release evidence.

## RC-0031 → RC-0036

Implemented and committed distinct binding/evidence gates for:

- RC-0031 all supplied unique physical body placements.
- RC-0032 planet signs from physical longitude.
- RC-0033 planet degrees and degree-in-sign.
- RC-0034 planet house assignment from actual HouseCusps.
- RC-0035 exactly 12 separately addressable house cusps.
- RC-0036 each house start/cusp degree.

The shared RC-0031..0035 gate still writes each matrix row separately. RC-0036 has its own gate. No physical TESTED promotion commit had appeared at the last check, therefore these rows are not promoted in this checkpoint merely because the code/contract exists.

## RC-0037 — house themes

Added `lib/src/interpretation/western_house_themes.dart` with exactly twelve separately addressable house themes. Every entry has non-empty TR/EN title and description. Content remains in interpretation, outside calculation_core. Added compiled completeness/range tests, binding contract, validator and dedicated CI. Independent bilingual editorial review, final UI/accessibility and release artifact remain blockers. Physical promotion was not yet observed.

## RC-0038 → RC-0040 — rulerships

Added `lib/src/calculation_core/western/rulerships.dart` with explicit traditional and modern schemes, complete twelve-sign catalogs, reverse planet->ruled-sign lookup, house ruler derivation from actual calculated cusp sign, all-house output and fail-closed range behavior.

Traditional/modern differences are explicit: Scorpio Mars vs Pluto, Aquarius Saturn vs Uranus, Pisces Jupiter vs Neptune. Requirements RC-0038/39/40 remain separate contracts/evidence rows. Dedicated compiled gate added; physical promotion was not yet observed.

## RC-0041 → RC-0049 — aspects and orbs

Expanded production aspect runtime to support:

- conjunction 0°
- sextile 60°
- square 90°
- trine 120°
- quincunx 150°
- opposition 180°

Explicit default orb catalog is present and validated. Added `bodyAspectOverrides` so orb values can be distinguished by both planet and aspect. Detection uses shortest physical angular separation and the selected body/aspect orb. Existing custom-orb tests were updated to include quincunx so the new fail-closed complete-map contract does not break old regressions. RC-0041..0049 each have separate binding contracts and a requirement-specific common gate. Physical promotion was not yet observed.

## RC-0050 — applying / exact / separating

Added `AspectPhase { applying, exact, separating }` to production aspect results. Phase is not inferred from labels or wall clock: it uses current physical longitudes plus signed longitude speed. A small forward-time projection determines whether the orb is narrowing or widening; exact has an explicit tolerance. Retrograde relative motion and non-finite fail-closed behavior are compiled regressions.

During review a real data-flow defect was found before promotion: `NatalPlacement` did not preserve `longitudeSpeedDegreesPerDay`, so the aspect layer could not physically consume ephemeris speed. Fixed in commit `07bbab3596179c491299e3001da8c463e3ad430c`. The RC-0050 validator was strengthened in `dff5abeacd69a6b12aa0966dfc880a1c444ff400` to require ephemeris speed preservation, and the workflow was retriggered with the dependency path in `0a00007cf0a1b23848cab76955ae808b3a0a5d80`.

No physical `requirements(rc0050): record applying separating TESTED` commit had appeared at the last check, so RC-0050 is not promoted yet.

## Open global blockers

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Next continuation

1. Re-read matrix/progress/LATEST.
2. Confirm physical promotion/results for RC-0031..0036, RC-0037, RC-0038..0040, RC-0041..0049 and corrected RC-0050.
3. Inspect exact job logs for any red gate, repair root cause and rerun without weakening requirements.
4. Continue dependency order at RC-0051+ only after preserving every prior RC row and blocker.
5. Do not claim FINAL until all 1,442 RCs are DONE and every required release gate is green.

**FINAL: NO.**
