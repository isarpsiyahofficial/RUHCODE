# Automation checkpoint — Backup package + transactional import

## Implemented this run

- Strict `BackupPackageManifestV1` parsing and validation.
- Logical multi-file `BackupPackageWriter` producing `manifest.json` + all 14 registered UTF-8 CSV files.
- `BackupPackageReader.preview()` validation order: manifest/schema version → member set → SHA-256/byte length → strict UTF-8 → CSV record count → table schema → cross-table foreign keys.
- Preview is mutation-free and exposes per-table/total record counts.
- `BackupImportCoordinator` with transaction-only mutation after a valid preview.
- Merge uses primary-key upsert and is specified/tested as idempotent for repeated imports.
- Replace creates a pre-import safety snapshot and restores it when transactional mutation fails.
- Added source-level evidence contracts and structural validators for package and transactional import.
- Extended `Backup CSV Contract` workflow to execute both new structural validators and all `test/backup` Flutter tests.

## Commits

- `774131d680b247532c9be5a22042fa766f6b2106` strict manifest parser
- `4890aa8a1b520f5700903cb3be946d4ecc51852d` package writer/reader/preview
- `fc44c9df45c85dd3730083a6f5e9b116627b58cb` package tests correction
- `902b6ef7f09f73fd60549017c02670f4ad0d887c` package evidence
- `02fc8ac66c3c628e9f7acdefa909efbeae4a4bdd` package structural validator
- `93e88ffd0bf5ab757446add029ff4c1f2bdffe06` package CI wiring
- `e9da32525055a98c2956b988740ff9ee1868ba13` transactional import coordinator
- `7a58481896eb347a4028d167af9f3be0efdd5228` merge/replace/rollback/idempotency tests
- `ab0e47ed9de7e59b6eb1b2ba0f26058ec1f3a71a` import evidence
- `108263aff7b0a25fcd92839daae5d940446a826d` import structural validator
- `1356e9c8d3fce55ef99aff9054da0de69bbb26c2` transactional import CI wiring

## Evidence state

- GitHub combined-status for `1356e9c8...` returned no individual statuses, so CI SUCCESS was not invented.
- Backup package/import evidence remains `done=false` until production SQLite adapter, durable snapshot, runtime/CI proof and round-trip suites are complete.

## Next safe work

1. Wire `BackupImportStore` to the production local SQLite persistence layer without bypassing transactions.
2. Add durable safety-snapshot storage and restore semantics.
3. Add actual package/archive/file adapter (ZIP) while keeping logical validation independent of archive format.
4. Add TR→EN / EN→TR round-trip, legacy-schema migration and large-data stress fixtures.
5. Add clean-install export→erase→restore proof.
6. Continue physical astronomy, GeoNames, Daily Message editorial corpus and APPROVED UI-reference blockers in parallel.

**FINAL değil.**
