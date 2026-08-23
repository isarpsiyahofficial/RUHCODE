# Ruh Code — 2026-08-23 22:53 — Combined PDF composition checkpoint

## Bu turda yapılan gerçek çalışma

### 1. RC-0903 için gerçek multi-system composition çekirdeği

`lib/src/pdf/pdf_combined_report.dart` eklendi.

- Kombine rapor artık yalnız `PdfReportKind.combined` enumundan ibaret değil.
- En az iki farklı calculation system zorunlu.
- Her child sistem kendi bağımsız `PdfSnapshotIdentity` kimliğini taşır.
- Child snapshot'lar aynı `subjectKind + subjectId` değerine ait değilse composition fail-closed.
- Child render section'ın digest'i kendi child snapshot digest'iyle uyuşmuyorsa fail-closed.
- İki sistem aynı PDF section ID'sini sahiplenirse fail-closed.
- Child sistemlerin `cover` veya `technical_manifest` üretmesine izin verilmez; bu ortak bölümler combined report tarafından yalnız bir kez üretilir.
- Child snapshot'lar yeniden hesaplanmaz veya başka sistem gibi yorumlanmaz.
- Exact child identity setinden deterministik SHA-256 composite snapshot kimliği oluşturulur.
- Oluşan projection `PdfReportKind.combined` ile mevcut local A4 renderer sınırına bağlanabilir.

### 2. Regression testleri

`test/pdf/pdf_combined_report_test.dart` eklendi.

Test sözleşmesi:

- aynı subject'e ait Western + Numerology member'larının deterministic composition'ı,
- input sırası ters çevrilse bile aynı composite digest,
- tek sistemin reddedilmesi,
- farklı subject'lerin reddedilmesi,
- section ID collision reddi,
- child snapshot digest drift reddi,
- child cover/technical-manifest sahipliğinin reddi.

### 3. Evidence ve MASTER semantic gate

`evidence/pdf/combined_report_contract.json` yalnız `RC-0903` sahipliğiyle eklendi.

Bu turda bilinçli olarak `RC-0904` veya `RC-0905` sahiplenilmedi. Explicit localized system-heading separation production child projectionsına bağlanmadan bu maddeler açık kalacak.

`tools/pdf/validate_pdf_combined_report.py`:

- evidence'ın yalnız RC-0903 sahiplenmesini,
- MASTER'da RC-0903 literal semantiğini,
- combined composition source/test contract tokenlarını,
- evidence source/test path bütünlüğünü,
- `done=false` ve açık blocker bulunmasını

doğrular.

### 4. CI kapıları

- `.github/workflows/pdf-combined-report-contract.yml` eklendi.
- Merkezi `.github/workflows/requirements-contract.yml` içine combined PDF semantic ownership validator eklendi.

## Commit zinciri

- `be2998825bd2f79c3f2f52e284f8e42c57e4f56c` — combined projection/source contract
- `5c06fb95771680ea2d87dc4681f162c5381b33c4` — combined regression tests
- `dac2b2a43ad50ff4a4b2d66264a7682549cf0914` — RC-0903 evidence
- `7fe7d367652399ea4e1f421ef05bac0c06e6d6c2` — MASTER-aware validator
- `7e6283cc6ba33f74cb5dac7932f5e80325d7d118` — dedicated workflow
- `d840f9105fac59cd020f6ee132bec040903d0014` — central Requirements Contract wiring

## Kanıt sınırı

Exact latest commit için GitHub combined status `statuses=[]` döndürdü. Bu nedenle CI SUCCESS varsayılmadı ve RC-0903 DONE yapılmadı.

## RC-0903 için hâlâ açık işler

1. Persisted Western ve persisted Pythagorean calculation kayıtlarını gerçek multi-record snapshot source üzerinden compositor'a bağlamak.
2. Child sistem başlıklarını TR/EN açık sistem ayrımıyla production projection'a bağlamak; bundan sonra RC-0904/0905 değerlendirilebilir.
3. Approved production fontlarla gerçek combined PDF byte üretim testi.
4. Full parser/device-open ve visual regression.
5. Exact görünür CI success.

## Sonraki güvenli iş

- production multi-record combined snapshot source,
- persisted Western/Numerology projection bridge,
- explicit localized system-heading contract,
- ardından font gerektirmeyen combined data/subject parity testlerini genişlet.

**FINAL: NO.**
