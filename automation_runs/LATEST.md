# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-22_0452_persisted_pdf_source_native_delivery.md`

## Bu turda ilerleyen ana bloklar

1. **Production persisted calculation → PDF snapshot source**
   - calculation + CalculationManifest aynı LocalDatabase transaction içinde okunuyor
   - missing/mismatched/unavailable/error provenance fail-closed
   - typed newest-first saved-calculation catalog
   - `RuhCodeRuntime` composition root bağlantısı
2. **Native PDF delivery**
   - `.pdf` file-name/path policy
   - validated PDF bytes → OS Save As
   - native share sheet; Ruh Code server hop yok
   - cancellation/unavailable typed sonuçlar
3. **Tests / evidence / CI contract**
   - persisted source atomicity/fail-closed regressions
   - native save/share policy regressions
   - semantic evidence RC-0936/0939/0940 dahil genişletildi
   - Professional PDF Application workflow yeni kaynak/testleri kapsıyor

## Validation limitation

- Workflow-target commit `72c2e6f7269a90200f6538d2932b828081b72b5d` için GitHub combined-status yine `statuses=[]` döndürdü.
- Exact SUCCESS görünmeden source-level evidence `done=false` ve ilgili RC'ler DONE değil.

## Next safe work

- typed saved-calculation catalog'u ProfessionalPdfBuilderPage içinde gerçek selector'a bağla; ham record ID alanını kaldır
- app/navigation composition'a record catalog actions geçir
- supported persisted calculation type → PdfReportContentAdapter routing; unknown type fail-closed
- production font blocker gerektirmeyen PDF data/table/interaction testlerini genişlet
- remaining semantic evidence RC ownership audit
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts and clean-checkout lockfile remain open blockers

**FINAL: NO.**
