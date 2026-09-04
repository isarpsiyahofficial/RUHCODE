# Automation checkpoint — RC-0014 physical body provider

## Binding state re-read

- Canonical matrix was re-read from `requirements/requirement_state.csv` before promotion decisions.
- RC-0013 remains `TESTED + blocked=YES`.
- RC-0014, RC-0015 and RC-0016 remain `NOT_STARTED` until their own evidence gates physically promote them.
- No requirement was marked DONE in this run.

## RC-0014 implementation added

A production `De440sEphemerisProvider` now bridges the existing packaged DE440s loader/parser/SPK Type-2/body-graph stack to the shared `EphemerisProvider` interface.

The provider:

- loads and integrity-verifies the packaged offline DE440s kernel;
- maps Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune and Pluto to explicit NAIF targets;
- evaluates geometric states relative to Earth (`399`);
- converts explicit TT Julian Day to the kernel ET/TDB independent variable without UTC/network fallback;
- rotates J2000 ICRF equatorial position and velocity into J2000 ecliptic output;
- emits longitude, latitude, distance and longitude velocity with DE440s provenance;
- derives a fail-closed common packaged coverage window;
- explicitly rejects mean/true lunar nodes so RC-0015 cannot be faked by body substitution.

Implementation commits in this work chain include:

- `4b624b3710853835083063aadd8d57304f6663a7` — production provider
- `a60ab7ad05caa1cdf634281594b8af04fe02e1d1` — compiled packaged-provider tests
- `6d4c0fdbd6b35a9ae35ee983c857b29c7fd8bd01` — binding RC-0014 contract
- `9a8261e9d6f443363e8d5c8d14ad1837862334f9` — fail-closed requirement validator
- `88c0fd115681fa167a740a79af2a459bb860dd0c` — dedicated CI gate
- `f78a4bc79e2b6899a357d3d00a01a4d3979b0adb` — strict-double coverage arithmetic hardening

## Runtime/CI evidence policy

`test/calculation_core/de440s_ephemeris_provider_test.dart` executes all ten RC-0014 physical bodies at J2000 through the packaged provider, verifies finite/ranged physical outputs, confirms node substitution is rejected, confirms coverage is fail-closed, and confirms physical velocity feeds the motion classification path.

`.github/workflows/rc0014-physical-body-positions.yml` additionally runs the existing independent packaged-kernel JPL/Horizons regression. Successful workflow execution may promote RC-0014 only to `TESTED`; it records `blocked=YES` for independent official multi-body longitude/latitude golden coverage and later release astronomy accuracy gates.

At checkpoint time the first dedicated RC-0014 workflow for `88c0fd...` was still pending/queued in GitHub Actions. The later `f78a4bc...` hardening commit triggers a fresh exact-HEAD validation. Therefore RC-0014 is deliberately left `NOT_STARTED` in the physical matrix until a successful promotion commit is observed.

## RC-0015 scan

A repository search found no executable `trueNode` implementation. Only declaring node enum/interface concepts is insufficient, so RC-0015 was not promoted. A dedicated lunar-node algorithm plus authoritative golden/reference evidence is required.

## Continuation

1. Read the exact `f78a4bc...` RC-0014 workflow result; if red, inspect job logs, fix root cause and rerun through a new exact HEAD.
2. If green, verify the bot promotion commit physically changed RC-0014 to `TESTED + blocked=YES`; do not infer it from workflow status alone.
3. Implement RC-0015 as a separate executable lunar-node engine only with authoritative formula/golden provenance; do not substitute SPK body mappings.
4. Implement RC-0016 as a separate sampled physical-motion gate after the provider path is green.
5. Keep RC-1436/1437 broader astronomy golden/tolerance, RC-1439 physical UI, signed clean-checkout artifact and real-device release evidence open.

**FINAL: NO.**
