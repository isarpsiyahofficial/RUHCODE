# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-23_0853_single_table_csv_export.md`

## Bu turda ilerleyen ana blok

1. **RC-0794 tek-tabla CSV dışa aktarma**
   - full `.ruhcode.zip` backup'tan ayrı `SingleTableCsvExporter` eklendi
   - yalnız canonical `BackupSchemaRegistry` tabloları kabul ediliyor
   - canonical header + mevcut LocalDatabase export mapping + strict UTF-8 CSV codec yeniden kullanılıyor
   - Türkçe/Unicode, comma/quote/newline ve null round-trip regresyonu eklendi
   - unknown table fail-closed
   - tek tablo export full restorable backup gibi gösterilmiyor
   - exact RC-0794 evidence + MASTER-aware structural validator + Backup CSV CI wiring eklendi
   - async failure matcher yanlış pozitif riski `await expectLater` ile düzeltildi

## Validation limitation

Latest source commit `0d8d6849c8192f5e2e9fe0446e05e79a0189261a` için GitHub combined-status yine `statuses=[]` döndürdü. Exact görünür CI SUCCESS olmadığı için RC-0794 DONE yapılmadı.

## Next safe work

- remaining backup/PDF requirement-bearing evidence ailelerini exact MASTER ownership açısından audit et
- approved font gerektirmeyen PDF parser/data parity sınırlarını genişlet
- UI action/semantics coverage'daki kalan gerçek dead-action veya missing-semantics yüzeylerini tara
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts, Play/rewarded device proof ve clean-checkout release proof açık blocker olarak kalır

**FINAL: NO.**
