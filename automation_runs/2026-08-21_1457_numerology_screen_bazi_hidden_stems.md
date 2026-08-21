# Ruh Code automation checkpoint — 2026-08-21 14:57

## Completed source-level work in this run

### Functional Numerology screen
- Added `lib/src/ui/numerology/numerology_screen.dart`.
- The widget consumes only `NumerologyPresentationModel`; it does not recalculate numerology.
- Added explicit independent TR and EN UI copy for section/metric IDs.
- Unknown locale, section ID, or metric ID fails closed rather than leaking raw technical IDs or cross-language fallback.
- Added a real empty state for the no-calculation condition; no fabricated demo result is shown.
- Routed `RuhFeatureIds.numerologyBasic` from the real Tools navigation path to this functional screen. Until profile/calculation application-service wiring exists, the route shows the honest empty state.
- Added widget tests for TR, EN, empty-state, unsupported locale and unknown ID fail-closed behavior.
- Extended Numerology Presentation evidence, structural validator and CI workflow to include the real screen and tests.

Workflow-target commit: `9997ec65bdd059b12ddb979ba4a1f15a163ff56d`.
GitHub combined-status returned `statuses=[]`; no CI SUCCESS is claimed and no related RC is promoted to DONE.

### BaZi Hidden Stems primitive
- Added `lib/src/calculation_core/bazi/hidden_stems.dart` with explicit ordered Hidden Stems for all 12 Earthly Branches.
- Main qi is always the first ordered stem.
- No school-specific percentage weights are invented in calculation core.
- Returned mappings are immutable and completeness/uniqueness is asserted.
- Added tests covering all branches, canonical single/multi-stem examples, main-qi behavior and immutability.
- Added source-level evidence for RC-0341.
- Extended the BaZi structural validator and CI workflow to run both sexagenary-cycle and Hidden Stems tests.

Workflow-target commit: `be46f497bb146131c35d81a05b5b801d0508de49`.
GitHub combined-status returned `statuses=[]`; no CI SUCCESS is claimed and RC-0341 is not promoted to DONE.

## Explicitly still blocked / not implemented
- Numerology screen still needs real profile-selection/application-service wiring that supplies the canonical snapshot.
- Final Numerology visual design cannot be claimed until APPROVED UI references exist and visual regression passes.
- BaZi civil-date → Year/Month/Day/Hour Pillars remain blocked on verified solar-term/day-boundary data.
- Hidden Stem weighting remains intentionally outside the calculation primitive until a documented policy is selected.
- Physical EOP/ephemeris/Lahiri/GeoNames proof, 8,036 editorial daily messages, APPROVED UI references and production PDF font artifacts remain open blockers.

## Next safe work
1. Add BaZi Ten Gods as a pure Day-Master-vs-stem relationship primitive; do not couple it to date pillar calculation.
2. Bind Numerology screen to a real profile/calculation application service when canonical profile selection is available; do not fabricate values in UI.
3. Expand independent hand-calculated numerology golden fixtures for cycles, Pinnacles/Challenges and compound Karmic Debt provenance.
4. Continue blocker-independent PDF/backup/accessibility contracts.
5. Promote RC state only with visible workflow/test/evidence proof.

**FINAL: NO.**
