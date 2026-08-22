# Ruh Code automation checkpoint — persisted Numerology PDF handler

## Gerçek ilerleme

- `numerology.pythagorean` persisted calculation type için production-oriented PDF handler eklendi.
- Handler doğum tarihi/ad girdisinden numerolojiyi yeniden hesaplamıyor; kaydedilmiş canonical snapshot JSON'unu tüketiyor.
- Persisted canonical JSON için SHA-256 zorunlu ve render öncesi yeniden doğrulanıyor.
- Snapshot fingerprint schema, engine ID ve engine version doğrulanıyor.
- `CalculationManifest.engineVersion` ile canonical snapshot engine version uyuşmazsa fail-closed.
- `profile/client` subject kind açık payload alanı; demo veya belirsiz subject production handler'a sessizce çevrilmiyor.
- Canonical snapshot içindeki profil, extended-name, Pinnacles/Challenges ve varsa Personal Year/Month/Day değerleri doğrudan PDF metric satırlarına projekte ediliyor.
- TR/EN PDF başlık ve metric etiketleri ayrı sözleşme olarak tanımlandı.
- Handler mevcut `PdfLocalReportService` ve local renderer zincirine bağlı; server hop yok.
- Tamper, engine-version drift ve yanlış calculation-type için regression testleri eklendi.
- Ayrı evidence, structural validator ve `Persisted Pythagorean PDF Contract` GitHub Actions workflow'u eklendi.

## Commit zinciri

- `07cc8e857e7ab6efb403c6aa88166d25012c1ad5` — persisted handler source
- `913a3dba4a1ec5842f29839f0c2bbca0025e7b9a` — fail-closed tests / fixture correction
- `e806a34eb14e1bfc17ebed1cb50f84e87bdacdf6` — evidence contract
- `d017298bc50acfa0a9bfd4539115b0d4e9d325a9` — structural validator
- `9636cf115283679def8b2e8922d53fc549077551` — CI workflow

## Validation limitation

GitHub combined-status for workflow-target commit `9636cf115283679def8b2e8922d53fc549077551` returned `statuses=[]`. Therefore no CI SUCCESS is claimed and evidence remains `done=false`.

## Still open

- Production runtime router registration must wait for the approved production Unicode `PdfFontBundleProvider`; fake/demo fonts are forbidden.
- Persisted Western payload schema/handler remains open; do not infer a schema that is not saved by the calculation pipeline.
- Real approved TR/EN font binaries + license + immutable SHA remain open.
- 5/25/50+ real rendered PDFs, glyph/crop/parser and visual-regression evidence remain open.
- Physical astronomy/GeoNames artifacts, 8.036 editorial daily messages, APPROVED UI reference set and clean-checkout lockfile remain open blockers.

**FINAL: NO.**
