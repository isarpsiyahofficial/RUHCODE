# RUH CODE — Requirement Lifecycle Traceability Checkpoint

## Bu turda yapılan gerçek değişiklikler

- `RUH_CODE_MASTER_TODO.md` FAZ 0 yeniden bağlayıcı kaynak olarak kontrol edildi.
- Mevcut matrix/validator durum modelinin TODO ile uyumsuz olduğu tespit edildi: matrix `OPEN / IN_PROGRESS / BLOCKED / DONE` kullanırken bağlayıcı model `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` istiyor.
- `tools/requirements/materialize_requirement_matrix.py` eklendi.
  - RC-0001..RC-1442 bağlayıcı şartname satırlarını exact sıra ile parse eder.
  - Her RC'yi ayrı `TASK-RC-xxxx` ile eşler.
  - Requirement metninden fail-closed/conservative etki tag'leri üretir (`CALC`, `CONTENT`, `UI`, `I18N`, `OFFLINE`, `ENTITLEMENT`, `BACKUP`, `PDF`, `SECURITY`, `A11Y`, `PERF`, `RELEASE`; eşleşmeyenler `TRACE`).
  - Her RC için zorunlu `evidence_type` üretir.
  - Legacy `OPEN` durumunu `NOT_STARTED` olarak taşır; blocker lifecycle statüsünden ayrılır.
  - Binding source filename/number ve normalized requirement text SHA-256 değerini matrix'e bağlar.
  - Kanıtsız legacy `DONE` satırını korumaz.
- `tools/requirements/validate_requirement_matrix.py` güçlendirildi.
  - Exact 1.442 RC, sıra, duplicate/gap kontrolü korunuyor.
  - Yalnız `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` kabul ediliyor.
  - Her RC için geçerli TASK ID, tag, evidence type ve source binding zorunlu.
  - `TESTED / VERIFIED / DONE` evidence link olmadan kabul edilmiyor.
  - Blocker `blocked=YES/NO` + blocker açıklamasıyla ayrı doğrulanıyor; `DONE` blocked olamaz.
  - Requirement text SHA-256 binding spec değişirse stale matrix CI'da kırılır.
- `.github/workflows/requirement-matrix-contract.yml` canonical materializer + validator zincirine geçirildi.
  - Push'ta canonical matrix üretilir, doğrulanır ve yalnız gerçekten değişmişse bot commit edilir.
  - Pull request'te committed matrix'in canonical olmaması doğrudan failure'dır.

## Commit zinciri

- `9a1bd8f4d9fbece519a862145128d56e4b9f4c4e` — canonical requirement matrix materializer.
- `c3be12f9e57c3769468b1fc408209d7c2462a3c7` — lifecycle/source/evidence validator.
- `88680dba8023349e4e3d4e8840f745c2bda55537` — canonicalize+validate CI workflow.

## Doğrulama durumu

`Requirement Matrix Contract` run `33799695465` exact `88680dba...` için tetiklendi. Son gözlemde runner bekliyordu (`queued`); sonuç uydurulmadı. Canonical bot matrix commit'i henüz fiziksel olarak görülmeden FAZ 0 tam PASS sayılmıyor.

## Requirement state güvenliği

Bu turda hiçbir RC kanıtsız DONE yapılmadı. Önceki matrix'teki 1.442 `OPEN` satır canonical materialization gerçekleştiğinde güvenli biçimde `NOT_STARTED` olacaktır. Geçmiş source/test çalışmaları daha sonra RC bazında evidence reconciliation ile lifecycle boyunca yükseltilecektir; mevcut kodun varlığı tek başına DONE değildir.

## Açık bağımlılık

1. Exact Requirement Matrix Contract çalışmasını tamamlanmış olarak doğrula; kırmızıysa failing step'i düzelt.
2. Canonical 1.442-row matrix bot commit'inin fiziksel olarak main'de bulunduğunu doğrula.
3. Ardından mevcut gerçek kanıtları RC bazında reconcile ederek `IMPLEMENTED → TESTED → VERIFIED → DONE` yükseltmelerini yalnız evidence ile yap.
4. RC-1436/1437 multi-vector official JPL coverage, RC-1439 physical UI refs, signed reproducible release ve real-device gates paralel açık kalır.

**FINAL: NO.**
