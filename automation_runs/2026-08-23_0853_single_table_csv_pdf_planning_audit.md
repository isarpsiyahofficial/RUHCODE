# Ruh Code Automation Checkpoint — RC-0794 + PDF planning semantic audit

## 1. RC-0794 single-table CSV export

- Full `.ruhcode.zip` backup'tan ayrı `SingleTableCsvExporter` eklendi.
- Yalnız canonical `BackupSchemaRegistry` tabloları kabul ediliyor.
- Header canonical schema'dan, satırlar mevcut `LocalDatabaseBackupExporter` mapping'inden geliyor.
- Strict UTF-8 `RuhCsvDocumentCodec` kullanılıyor; Unicode, comma/quote/newline ve null ayrımı korunuyor.
- Unknown table fail-closed.
- Tek CSV export full restorable backup gibi davranmıyor ve package writer çağırmıyor.
- Regression test + exact RC-0794 evidence + MASTER-aware validator eklendi.
- Backup CSV Contract ve merkezi Requirements Contract bu validator'ı çalıştıracak şekilde güncellendi.
- Async failure regression matcher `await expectLater` ile güvenli hale getirildi.

## 2. PDF report-planning semantic ownership audit

`evidence/pdf/report_planning_contract.json` MASTER şartnameyle tekrar çaprazlandı.

- `RC-0929` PDF preview requirement'ı bu evidence'dan çıkarıldı.
- Gerekçe: report planner/renderer sözleşmesi preview UI'ın gerçekten var olduğunu veya preview↔real PDF layout parity'sini kanıtlamıyor.
- RC-0929 release blocker olarak açıkça kaydedildi.
- `RC-0865` production Unicode font ve `RC-0956` real visual-regression requirement'ları da bu evidence tarafından sahiplenilmiyor.
- `tools/pdf/validate_pdf_report_planning_semantics.py` exact ownership setini ve MASTER literal semantiğini fail-closed kontrol ediyor.
- Merkezi Requirements Contract bu yeni PDF semantic validator'ı çalıştıracak şekilde güncellendi.

## Validation limitation

Latest workflow-target source commit `eb32a0315cc49f69b430da5d6c30f1de632b578f` için GitHub combined-status yine `statuses=[]` döndürdü. Exact görünür CI SUCCESS olmadığı için RC-0794 veya PDF planning requirement'ları DONE yapılmadı.

## Next safe work

1. Remaining PDF evidence ailelerinde aynı overclaim/drift taramasına devam et.
2. RC-0954 required-text proof için ham PDF byte string araması gibi sahte yöntem kullanma; güvenilir content/parser boundary olmadan açık tut.
3. UI runtime action/semantics coverage'da gerçek dead action taramasına devam et.
4. APPROVED UI refs, production PDF fonts, physical astronomy/GeoNames artifacts, 8.036 editorial daily messages ve device proofs blocker olarak açık kalır.

**FINAL: NO.**
