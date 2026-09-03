# Ruh Code — RC-1437 DAF/SPK Index Progress

## Exact baseline re-check

- `RUH_CODE_AUTOMATION_PROGRESS.md`, binding RC-1421→RC-1442 addendum and current `main` were re-read.
- Exact baseline `68b9b2900d3beb889b1a9ebc90c58f2d032ac42c` had 25 workflows; `RC-1437 Runtime Assets` was RED while the existing baseline contracts were otherwise continuing independently.
- Failed job: run `33698129607`, job `100471363763`, step `Validate physical runtime astronomy assets`.

## Root-cause repair

The new RC-1437 validator incorrectly required the literal physical file path to appear in `pubspec.yaml`. Flutter also supports declaring the containing asset directory, and this repository intentionally uses:

- `assets/data/eop/`
- `assets/data/ephemeris/`

The physical packaged-asset tests already verify runtime bundle presence. The validator was corrected to accept either the exact asset path or its containing Flutter asset directory while preserving all physical SHA-256, byte-size, manifest, loader and fail-closed checks.

Commit:

- `7f2f1e77662aa93784b18fcab99c79f5cdf8351d` — `fix(rc1437): honor Flutter directory asset declarations`

## DE440s dependency progress

The DE440s path was advanced beyond byte/header integrity into structural SPK indexing:

- added `lib/src/calculation_core/ephemeris/de440s_daf_parser.dart`;
- parses the DAF 1024-byte file record;
- requires `DAF/SPK`, ND=2 and NI=6;
- handles declared `LTL-IEEE` / `BIG-IEEE` byte order;
- walks linked DAF summary records with cycle/PREV/NEXT validation;
- unpacks SPK target, center, frame, data type and initial/final addresses;
- binds corresponding segment names from name records;
- fails closed for malformed coverage, addresses, empty segment names, invalid control values and out-of-file pointers;
- does **not** claim numerical SPK evaluation or independent golden accuracy.

Commits:

- `4be777af7b32658f2cec74ab3f5823034e3b1c77` — DAF/SPK segment index parser.
- `90fde158acce69ab15ed602cebacf55fb24ca5d6` — packaged DE440s structural index test.
- `40da4cad02cb1e4c5fe2c16f6cc94de3e6a07045` — test import repair.

The packaged test checks a real DE440s asset, validates every parsed segment's structural bounds/provenance fields, requires non-empty segment coverage and verifies at least one segment covers J2000. A corrupt/non-SPK payload is rejected.

## Evidence discipline

- `requirements/requirement_state.csv` was not changed.
- RC-1437 remains **NOT DONE**.
- `planetaryEphemeris.proven` and independent golden-vector flags remain false.
- Parsing the DAF/SPK directory is dependency progress only; the next numerical dependency is SPK type evaluation + body/center chaining + independent golden vectors within explicit RC-1436 tolerances.
- RC-1439, production-signed reproducible release and real-device release evidence remain open.

## CI continuation point

Exact current engineering HEAD: `40da4cad02cb1e4c5fe2c16f6cc94de3e6a07045`.

At checkpoint observation its 25 workflows had been created and were still queued/starting, therefore the new parser/test chain is not counted exact-SHA green yet. The next run must read completion, repair any analyzer/test/runtime-gate regression first, then continue SPK type-2 numerical evaluation and independent golden evidence.

**FINAL: NO.**
