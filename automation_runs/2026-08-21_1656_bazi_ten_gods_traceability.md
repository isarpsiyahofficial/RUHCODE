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

`evidence/bazi/sexagenary_cycle.json`, `hidden_stems.json`, `four_pillars_primitives.json`, and `ten_gods.json` now use these exact IDs.

The structural validator now also parses `RUH_CODE_MASTER_SARTNAME.md` and requires the literal MASTER ownership text for items 147–153 to remain exactly aligned with those evidence IDs. This prevents TODO-index-as-RC drift from silently reappearing.

## Workflow target

Latest BaZi workflow-target source commit:

`eb804117b7bbe0921d2565fbcfc31ebad6e2ab5d`

GitHub combined-status returned `statuses=[]`; no Actions SUCCESS is claimed and none of the related RCs are promoted to DONE solely from source-level implementation.

## Next safe work

1. Audit other recently-added evidence files for TODO-index-vs-RC traceability mistakes before more RC state promotion.
2. Generalize literal MASTER ownership validation to other evidence families where deterministic mapping exists.
3. Continue BaZi blocker-independent primitives only where they do not require unverified solar-term/day-boundary rules; do not fabricate Year/Month/Day/Hour Pillar conversion.
4. Continue independent numerology golden fixtures and canonical profile/application-service wiring.
5. Keep physical EOP/ephemeris/Lahiri/GeoNames, approved UI references, production PDF font artifacts and 8,036 editorial Daily Messages as explicit blockers.

**FINAL: NO.**
