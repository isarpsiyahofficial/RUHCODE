# RUH CODE — RC-0008 → RC-0017 verified promotion checkpoint

## Authoritative re-read

This run re-read the master TODO/index, binding specification, current repository state, progress log and physical `requirements/requirement_state.csv` before promoting or reporting any requirement.

## Physically observed matrix promotions

The dedicated CI/matrix-writer chain has now produced physical matrix evidence for all of the following:

- RC-0008 = TESTED + blocked=YES
- RC-0009 = TESTED
- RC-0010 = TESTED
- RC-0011 = TESTED + blocked=YES
- RC-0012 = TESTED + blocked=YES
- RC-0017 = TESTED + blocked=YES

No VERIFIED/DONE state is inferred from implementation alone.

## RC-0008 / RC-0009 / RC-0010

Dedicated files added this run:

- `requirements/contracts/rc0008_rc0010_time_determinism_contract.json`
- `tools/requirements/validate_rc0008_rc0010_time_determinism.py`
- `.github/workflows/rc0008-rc0010-time-determinism.yml`

The gate checks explicit time inputs, forbids `DateTime.now()` in the calculation-core time module, requires bundled IANA tzdb and runs compiled DST/historical regressions. RC-0008 remains blocked until validated location coordinates + explicit time/timezone are proven to propagate end-to-end into astronomical calculations.

Key workflow commit: `069b427e4d793c851e95e1f13d7c6718d02e68f1`.

## RC-0011 / RC-0012

Dedicated files added this run:

- `requirements/contracts/rc0011_rc0012_location_identity_contract.json`
- `tools/requirements/validate_rc0011_rc0012_location_identity.py`
- `.github/workflows/rc0011-rc0012-location-identity.yml`

The gate chains the physical city-catalog validator and compiled city regressions. It proves coordinates and IANA timezone are distinct required fields and same-name city records retain stable identity + visible country/admin disambiguation. Both requirements remain blocked until birth-place selection UI/runtime evidence proves the selected stable city identity, coordinates and timezone propagate together.

Commits:

- `f38a5c96ec4272cf9d68a01ed9406e9439d1e4e0`
- `6402aad9eb059e9d34b697c6ba9eac8cf7837969`
- `2e69ecd906e16d4224350cfbe963837d3e872816`

Physical matrix promotion is now present for RC-0011 and RC-0012.

## RC-0017

Existing central Julian Day implementation and USNO reference evidence were not treated as complete merely because they existed. This run added a requirement-specific binding and promotion gate:

- `requirements/contracts/rc0017_julian_time_core_contract.json`
- `tools/requirements/validate_rc0017_julian_time_core.py`
- `.github/workflows/rc0017-julian-time-core.yml`

The gate runs the existing USNO reference validator and compiled `test/calculation_core/julian_day_test.dart` regressions, covering USNO reference values, J2000, second-level progression and UTC input discipline.

Workflow commit: `d4251b26efcfc7fdce499554d0b0d3d517aac9b9`.
Physical promotion commit: `4da48b2530b4c83de2645dc8dfee78a0c801f8bf` (`requirements(rc0017): record Julian time core TESTED`).

RC-0017 remains blocked from VERIFIED/DONE until broader astronomical timescale accuracy/release evidence is closed.

## Requirements intentionally not promoted

- RC-0007 remains NOT_STARTED because exact AKİLES provenance/method-comparison evidence is still missing.
- RC-0013 through RC-0016 remain NOT_STARTED. Shared ephemeris interfaces and packaged astronomy code exist, but a requirement is not promoted until its actual common-core/physical-position/node/motion behavior is individually bound to sufficient compiled/independent evidence.
- RC-0018+ remain untouched unless individually proven.

## Open release dependencies

RC-1436/1437 broad independent astronomy golden/tolerance coverage, RC-1439 physical UI reference evidence, production-signed reproducible clean-checkout artifact, and real-device offline/accessibility/PDF/Play lifecycle gates remain open.

## Next continuation

1. Inspect and individually bind RC-0013→RC-0016 against the real packaged ephemeris implementation and independent reference evidence; do not promote interface-only evidence.
2. Preserve RC-0005/0006/0007 AKİLES blockers without stalling independent work.
3. Continue RC-0003 physical promotion/editorial provenance, RC-1436/1437 astronomy accuracy, RC-1439 UI references and exact release/device gates.
4. Never claim FINAL before all 1,442 rows are DONE and the exact release artifact passes every mandatory gate.

**FINAL: NO.**
