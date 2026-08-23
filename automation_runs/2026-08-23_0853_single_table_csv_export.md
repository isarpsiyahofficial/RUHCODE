# Ruh Code Automation Checkpoint — Single-table CSV export

## İlerleyen blok

RC-0794 için full `.ruhcode.zip` yedekten ayrı, canonical tek-tabla UTF-8 CSV dışa aktarma yolu eklendi.

- `SingleTableCsvExporter` yalnız `BackupSchemaRegistry` içinde kayıtlı bir tablo adını kabul eder.
- CSV başlığı canonical schema kolonlarından gelir.
- Veri satırları mevcut `LocalDatabaseBackupExporter` mapping'ini yeniden kullanır; ikinci bir locale-sensitive export şeması oluşturulmadı.
- `RuhCsvDocumentCodec` kullanıldığı için comma/quote/newline, Unicode ve null-vs-empty sözleşmesi full backup CSV katmanıyla aynıdır.
- Unknown table fail-closed.
- Tek tablo export, full restorable backup gibi gösterilmez; `.ruhcode.zip` package writer çağrılmaz.
- UTF-8/Türkçe/newline/null regression testi eklendi.
- Async failure testi `await expectLater(Future, throwsA(...))` ile düzeltildi.
- `evidence/backup/single_table_csv_export.json` yalnız `RC-0794` sahiplenir ve `done=false` kalır.
- `tools/backup/validate_single_table_csv_export.py` MASTER madde 794 metnini literal olarak doğrular.
- Backup CSV Contract workflow'una yeni validator ve test dosyası yolu bağlandı.

## Validation limitation

Workflow-target/latest source commit `0d8d6849c8192f5e2e9fe0446e05e79a0189261a` için GitHub combined-status `statuses=[]` döndürdü. Exact görünür Flutter/Actions SUCCESS olmadığı için RC-0794 DONE yapılmadı.

## Next safe work

1. Tek-tabla CSV export'u kullanıcıya açık bir seçim/action yüzeyine bağlamadan önce UI bilgi mimarisinde full backup ile karışmayacak konumu belirle; gereksiz yeni ana menü oluşturma.
2. Remaining backup/PDF evidence semantic ownership auditine devam et.
3. Approved font gerektirmeyen PDF parser/data parity sınırlarını genişlet.
4. Physical artifacts, 8.036 editorial daily messages, APPROVED UI refs ve production fontlar için sahte kanıt üretme.

**FINAL: NO.**
