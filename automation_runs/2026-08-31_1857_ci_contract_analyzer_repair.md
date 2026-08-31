# RUH CODE — CI contract/analyzer repair checkpoint

## Binding scope

- RC-0001 → RC-1442 remains binding.
- No requirement was marked DONE without its required proof.

## Exact baseline re-check

Baseline HEAD `33cee79ff671fc4a5dbc9614b549786cb05121e1` had 23 workflow runs. Two critical gates were confirmed red after their queued runs completed:

- Requirements Contract — failure
- Flutter Quality — failure

Requirements decoded log failed at evidence semantic ownership: `evidence/pdf/report_planning_contract.json` was missing semantic ownership for RC-0903.

Flutter Quality decoded log failed at `flutter analyze --fatal-infos` with 29 diagnostics; tests were skipped because analyze failed.

## Applied repairs

1. Added RC-0903 to `evidence/pdf/report_planning_contract.json` requirement ownership while keeping the evidence `done:false` and RC-0903 release blocker explicit.
2. Re-exported `BackupImportMode` from `backup_import_coordinator.dart`, restoring the public coordinator import surface used by backup lifecycle tests without duplicating the enum.
3. Added explicit `pdf_data_contract.dart` imports to numerology PDF/UI tests that use `PdfSubjectKind`.
4. Exposed `PdfReportOptions` through `pdf_report_contract.dart` so persisted PDF tests using that contract import resolve the options type.
5. Removed invalid `const` from the combined PDF adapter `StateError`.
6. Repaired PDF asset-font test imports: removed unnecessary `dart:typed_data`, imported `FlutterError` from Flutter foundation.
7. Removed stale unused `pdf_report_contract.dart` import from `persisted_calculation_pdf_router.dart`.
8. Removed the stale `pdf_report_contract.dart` import from `persisted_calculation_pdf_router_test.dart`; the test now consumes `PdfReportOptions` from the canonical `pdf_service.dart` import.
9. Removed stale `backup_schema.dart` and `backup_service.dart` imports from `backup_import_coordinator_test.dart`; `BackupImportMode` now comes through the coordinator public surface.

These repairs target the confirmed analyzer/contract failures; they are not counted as a green CI result until the newest exact-head workflows complete successfully.

## Remaining known Flutter Quality debt from the baseline log

- invalid `const StateError` in persisted combined/numerology/western PDF sources
- `pdf_output_inspector.dart` unnecessary non-null assertion
- backup settings stale import
- deprecated DropdownButtonFormField `value` usages
- remaining analyzer diagnostics must be taken from the newest exact-head decoded log rather than assumed from the baseline

## Editorial ledger

No new daily-message rows were claimed in this checkpoint. Verified ledger remains 7730 / 8036, next exact editorial start `2036-08-01`.

## Final state

FINAL: NO.
