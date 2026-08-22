# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-22_1056_pdf_table_evidence_integrity.md`

## Bu turda ilerleyen ana bloklar

1. **PDF long-table regression hardening**
   - 100 body-row fixture
   - deterministic header repetition
   - exact row-order reconstruction
   - loss/duplication detection
   - input mutation aliasing protection
2. **PDF evidence integrity**
   - stale/nonexistent source/test paths repaired
   - actual current renderer/font/geometry/table filenames recorded
   - table integrity behavior added to contract features
3. **Structural validation hardening**
   - evidence `sources[]` / `tests[]` must be non-empty and unique
   - every evidence source/test path must exist in the repository
   - new long-table regressions are mandatory validator tokens

## Validation limitation

- Latest workflow-target source commit `1d5fde2a951aa9346f1934187a78534b30e5d5a8`: combined-status `statuses=[]`.
- Exact visible SUCCESS olmadan evidence `done=false`; ilgili RC'ler DONE değil.
- Historical `ACTION-PDF-PREVIEW-CREATE` / `ACTION-PDF-PREVIEW-SHARE` registry source-screen semantics are still builder/preview-drifted; RC-1440 DONE değil.

## Next safe work

- PDF preview vs builder create/share action IDs'lerini canonical builder-specific IDs ile full registry + runtime constants + runtime bindings + PDF entitlement validator üzerinde birlikte düzelt
- blocker-independent PDF page/table/parity regressionlarını genişlet
- Western persisted snapshot için açık versioned persistence schema tasarla; mevcut olmayan şema varmış gibi davranma
- remaining semantic evidence ownership/path audit
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts and clean-checkout lockfile remain open blockers

**FINAL: NO.**
