# Ruh Code — Offline Ephemeris / EOP Runtime Strategy

Status: **binding implementation strategy, not proof of final accuracy**.

## 1. Planetary/lunar ephemeris candidate

Primary runtime candidate: unmodified JPL/NASA NAIF generic SPK based on **DE440**.

Reasons:
- JPL documents DE440 as covering 1550–2650, which fully contains Ruh Code's current 1890–2110 product target.
- JPL SSD publishes the official DE440 BSP location.
- NAIF rules explicitly allow anyone to download/use kernels placed on the NAIF server, permit redistribution of unmodified NAIF-distributed kernels, and allow commercial use of SPICE components without licensing fees subject to NAIF's published rules.

Official references:
- https://ssd.jpl.nasa.gov/doc/de440_de441.html
- https://ssd.jpl.nasa.gov/announcements/an20210412a.html
- https://naif.jpl.nasa.gov/naif/data_generic.html
- https://naif.jpl.nasa.gov/naif/rules.html

### Hard runtime rules

1. No network lookup is permitted in calculation runtime.
2. The shipped kernel must be unmodified if redistributed under the NAIF kernel redistribution rule.
3. The exact downloaded artifact SHA-256, byte size, source URL, retrieval date, kernel comments/provenance and project release version must be recorded before `proven=true` is allowed.
4. Absence/corruption/out-of-coverage must fail closed; no zero-coordinate, nearest-date or web fallback.
5. A DE440 kernel is not itself proof that Ruh Code's coordinate transformations and astrology outputs meet accuracy budgets. Independent golden comparisons remain mandatory.

## 2. SPICE Toolkit distinction

The kernel redistribution rule and Toolkit redistribution rule are not the same. NAIF allows redistribution of unmodified kernels; redistribution of the unmodified Toolkit as a mirror is restricted, while inclusion of Toolkit modules as part of a customer-built SPICE-based tool is described as appropriate under NAIF's rules.

Ruh Code should prefer the smallest legally clear integration that can read the required SPK data offline. Any third-party Dart/native SPK reader must have its own dependency/license review. Do not assume the kernel's redistribution permission automatically applies to a third-party library.

## 3. Earth orientation / UT1

IERS is the authoritative runtime/reference source for observed/predicted Earth Orientation Parameters.

Official references:
- https://datacenter.iers.org/eop.php
- https://datacenter.iers.org/productMetadata.php?id=6

Important coverage constraint:
- IERS `finals2000A.all` contains rapid/final EOP from 1973 onward and predictions extend only about one year, not to 2110.
- Therefore Ruh Code must **not fabricate future UT1−UTC/EOP values** to satisfy the 1890–2110 product date range.

### Required policy

- Dates covered by a bundled, checksum-verified IERS observation/prediction dataset may use that EOP data.
- Dates outside physical EOP coverage require a separately documented astronomical historical/future time-scale model (for example a Delta-T model where technically appropriate), with its own validity interval, uncertainty/accuracy budget and independent references.
- Modeled values must be labeled as modeled internally and must never be represented as observed IERS values.
- Exact high-precision features whose accuracy cannot be met outside data/model validity must return partial/unavailable rather than a plausible-looking false result.

## 4. Acceptance sequence

The ephemeris/EOP requirement is DONE only when all of the following are true:

1. Exact physical runtime artifacts are present.
2. SHA-256 and provenance manifests match the shipped bytes.
3. Redistribution/licensing inventory is complete.
4. Offline loader rejects corrupted/out-of-range data.
5. Sun/Moon/planet/node states are independently cross-checked.
6. ASC/MC/house and solar-event outputs meet their hard accuracy budgets.
7. Golden dataset runner passes with `--require-actual` and no UNVERIFIED records.
8. Clean checkout can reproduce the same validated data manifest and release artifact.

Until then the implementation remains source-level and **must not be marked DONE**.
