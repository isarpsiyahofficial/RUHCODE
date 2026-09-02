# RUH CODE — RC-1442 Release Source Gate Checkpoint

Exact verified baseline before this run: `5bb271ef3376d179f5246a6de48a8637926b623f`.

## CI re-verification

- GitHub Actions query for this exact SHA returned **24 successful workflow runs**.
- Failure query returned **0**.
- In-progress query returned **0**.
- Therefore the previously pending source/CI repairs are no longer treated as queued. This does **not** by itself make all RC requirements DONE.

## RC-1442 work implemented in this run

### Fail-closed source readiness validator

Added `tools/requirements/validate_rc1442_release_source_readiness.py`.

It requires, before a source tree can claim readiness for a signed release build:

- tracked Android settings/root/app Gradle files (Groovy or Kotlin DSL),
- tracked `gradle.properties`, Android manifest and `MainActivity`,
- tracked Gradle wrapper including wrapper JAR,
- explicit Android `namespace` and `applicationId`, equal to each other and not `com.example*`,
- tracked `pubspec.yaml` and `pubspec.lock`,
- TR and EN Daily Message asset declarations,
- strict/default RC-1437 validator PASS,
- strict/default RC-1439 validator PASS.

The validator explicitly scopes its success to **source readiness only**. Signing, exact artifact reproducibility and real-device evidence remain separate required proof.

Commits:

- `6855d64ae1629a61deb2fc95ce42ed979751e568` — initial RC-1442 source validator.
- `7454525fd008d288be252248d561ff7a86ae4db2` — hardened Gradle host detection for Kotlin/Groovy layouts and root/app Gradle files.

### Release-tag/manual workflow gate

Added `.github/workflows/rc1442-release-source-readiness.yml`.

- Runs on manual dispatch and `v*` release tags.
- Uses a clean GitHub checkout.
- Executes the RC-1442 validator fail-closed.
- Uploads JSON readiness evidence even when validation fails.
- It intentionally does not make ordinary development pushes red while known physical-data/reference blockers remain.

Commit:

- `e8f3166ae2e5d5f231d8371787b155d5d7e2e67b`.

## Blocker re-verification

`android/` is still not tracked on the current repository tree (GitHub contents lookup returned 404). Therefore RC-1442 cannot pass yet. No application ID was invented.

RC-1437 and RC-1439 remain fail-closed until their physical/versioned/checksummed data/reference evidence exists.

## Requirement discipline

- `RC-0001 → RC-1442` remains the exact binding scope.
- `requirements/requirement_state.csv` was not modified.
- No RC was marked DONE solely because a validator/workflow was added.

## Next continuation

1. Read exact CI for the new engineering HEAD and fix any regression if present.
2. Materialize a canonical tracked Android production host only when a stable application identity is established; do not use a generated temporary host as release evidence.
3. Continue RC-1437 physical city/ephemeris/EOP bundling and RC-1439 canonical physical reference assets independently.
4. After source readiness passes, run signed clean-checkout reproducibility and real-device offline/accessibility/release evidence.

**FINAL: NO.**
