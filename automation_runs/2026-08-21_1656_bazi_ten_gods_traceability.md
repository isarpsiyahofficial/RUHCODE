# Ruh Code Automation Checkpoint — BaZi Ten Gods + Traceability Repair

## Completed source-level work

- Added `lib/src/calculation_core/bazi/ten_gods.dart`.
  - Canonical ten Ten Gods identities are represented explicitly.
  - Classification uses only Wu Xing generate/control direction plus same/opposite Yin/Yang polarity.
  - Jia and Yi regression matrices cover both Yang and Yin Day Master behavior.
  - Every Day Master × target stem combination is covered and each Day Master produces all ten identities.
  - Hidden Stems can be classified in existing canonical main-qi-first order.
  - No civil-date, solar-term, strength-weight, auspiciousness or interpretation policy is invented.

- Added `lib/src/calculation_core/bazi/four_pillars_primitives.dart`.
  - Day Master is the Heavenly Stem of an already-verified Day Pillar.
  - Five Elements visible distribution counts the eight visible pillar symbols without hidden weighting.
  - Hidden Stem element occurrences remain a separate unweighted distribution.
  - Yin/Yang distribution counts the eight visible pillar symbols.
  - No date-to-pillar conversion or school-specific weighting is introduced.

- Added tests, evidence, structural validation and BaZi CI coverage for the new primitives.

## Critical traceability repair

A previous automation mistake used TODO sequence numbers as if they were MASTER requirement IDs. The MASTER specification was re-read directly and the BaZi mappings were corrected:

- `RC-0147` Heavenly Stems
- `RC-0148` Earthly Branches
- `RC-0149` Hidden Stems
- `RC-0150` Five Elements distribution
- `RC-0151` Yin/Yang balance/distribution primitive
- `RC-0152` Day Master
- `RC-0153` Ten Gods

`evidence/bazi/sexagenary_cycle.json`, `hidden_stems.json`, `four_pillars_primitives.json`, and `ten_gods.json` now use these exact IDs. The BaZi structural validator now fails if these evidence files drift to the wrong RC IDs again.

## Workflow target

Latest BaZi workflow-target source commit:

`2e874ac8448f36e9914304406f1f3f73298988f4`

GitHub combined-status returned `statuses=[]`; no Actions SUCCESS is claimed and none of the related RCs are promoted to DONE solely from source-level implementation.

## Next safe work

1. Audit other recently-added evidence files for TODO-index-vs-RC traceability mistakes before more RC state promotion.
2. Add a machine validator that cross-checks evidence requirement IDs against the literal MASTER requirement text/category where deterministic mapping exists.
3. Continue BaZi blocker-independent primitives only where they do not require unverified solar-term/day-boundary rules; do not fabricate Year/Month/Day/Hour Pillar conversion.
4. Continue independent numerology golden fixtures and canonical profile/application-service wiring.
5. Keep physical EOP/ephemeris/Lahiri/GeoNames, approved UI references, production PDF font artifacts and 8,036 editorial Daily Messages as explicit blockers.

**FINAL: NO.**
