# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- RC-0061 = IMPLEMENTED + blocked=YES; RC-0062 unresolved promotion.
- RC-0082→0083 = NOT_STARTED/blocked; RC-0086→0087 = IMPLEMENTED + blocked=YES.
- RC-0099→0157 arasında önceki TESTED promotion kanıtları korunuyor; RC-0124→0126 exact AKİLES provenance eksikliği nedeniyle açık.
- RC-0158→0270 = implementation/test zincirleri mevcut; eksik physical promotion ve global blocker'lar korunuyor.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0694 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0695→0754 = IMPLEMENTED + blocked=YES; central/versioned data model ve copy-first migration zinciri mevcut.
- RC-0755→0773 = IMPLEMENTED + blocked=YES; transactional data-safety zinciri mevcut; physical promotion açık.
- RC-0774→0848 = IMPLEMENTED + blocked=YES; portable relational CSV backup/import zinciri mevcut; RC-0848 exact clean-install round-trip açık; physical promotion açık.
- RC-0849→0858 = IMPLEMENTED + blocked=YES; physical promotion `0fc8d876e8349298b432f99f294f5300c4a7a478`.
- RC-0859→0869 = local human-readable PDF release/privacy boundary implementation zinciri mevcut + blocked=YES.
- RC-0870→0877 = vector PDF source/render implementation + regression + exact contract + validator + CI mevcut; rendered golden/zoom/print evidence açık.
- RC-0878→0889 = A4 layout/overflow/pagination implementation zinciri mevcut + blocked=YES.
- RC-0890→0894 = IMPLEMENTED + blocked=YES; physical matrix promotion `2883d2318e5b897ccc1e4191ece4c8631f7846f5`.
- RC-0895→0905 = IMPLEMENTED + blocked=YES; physical matrix promotion `fc97701a02c3c7c47d1733a4a2d4dbfebe8cf305`.
- RC-0906→0932 = IMPLEMENTED + blocked=YES; physical matrix promotion `7fffb162bb7ab7a39c1d0daa42522235741d19b8` doğrulandı.
- RC-0933→0941 = IMPLEMENTED + blocked=YES; physical matrix promotion `608fdaf6293b49ded13e848fd305e730a3bce448` doğrulandı.
- RC-0942→0950 = IMPLEMENTED + blocked=YES; physical matrix promotion `e74625c97586d4b8bc3ab6fef41c9b906bcf8a07` doğrulandı.
- RC-0951→0964 = production validation core + regression + exact contract + validator + dedicated CI mevcut; physical matrix promotion görülmeden lifecycle yükseltilmeyecek.
- RC-0965→0994 = requirement/test traceability audit ve CI hattı eklendi; mevcut eksik test linkleri ve DONE olmayan RC'ler release-mode'u bilinçli biçimde kırmızı tutuyor; lifecycle promotion henüz verilmedi.

## Son çalıştırmada yapılan gerçek geliştirme

### RC-0942→0950 — uzun PDF performansı ve atomik tamamlanma

`lib/src/pdf/pdf_generation_performance.dart` eklendi. 5, 25, 50+ sayfa ve yüzlerce tablo satırı için explicit workload sınıfları var. `PdfPerformanceObservation` peak RSS, elapsed time, UI heartbeat ve device class kanıtı taşımadan performans iddiasına izin vermiyor. `PdfPerformanceBudget` sayfa/row kaybını, RAM bütçesi aşımını, zaman bütçesi aşımını, UI-heartbeat yokluğunu ve cihaz sınıfı eksikliğini fail-closed reddediyor.

`PdfAtomicCompletionGate`, üretim tamamlanmadan hiçbir publication mutation yapmıyor. Renderer exception, truncated PDF veya yetersiz page count durumunda yeni rapor kullanıcıya başarılı çıktı olarak commit edilmiyor. `test/pdf/pdf_generation_performance_rc0942_rc0950_test.dart` gerçek `package:pdf` çıktılarıyla 5/25/52 sayfa, 320 satırlı tablo, completion failure ve successful atomic commit senaryolarını çalıştırıyor.

Dedicated CI/matrix gate geçti ve physical promotion oluştu: `e74625c97586d4b8bc3ab6fef41c9b906bcf8a07` (`requirements(rc0942-rc0950): record PDF performance IMPLEMENTED`).

Açık kanıt: supported eski/orta sınıf Android physical-device peak-RSS ve UI responsiveness run'ı ile exact release artifact performance verification. Bu nedenle TESTED/VERIFIED/DONE değil.

### RC-0951→0964 — PDF release validation / visual regression boundary

`lib/src/pdf/pdf_release_validation.dart` eklendi. Structural usability mevcut `PdfOutputInspector` üzerinden zorunlu. Parsed/rendered evidence modeli required text, chart object count, gerçek rendered page sayısı, text overflow, chart clipping, broken symbol, missing Turkish glyph ve report/subject identity alanlarını ayrı taşıyor.

`PdfReleaseValidationPolicy` şu durumları hard failure yapıyor: gerekli metin yok, gerekli chart yok, render edilen sayfa sayısı PDF page count ile uyuşmuyor, text sayfa dışına taşıyor, chart kırpılıyor, bozuk sembol var, Türkçe glyph eksik veya parsed `subjectId` beklenen danışandan farklı. Sonuncusu kritik veri izolasyonu hatası olarak fail-closed.

Görsel regresyonda versioned reference kimliği zorunlu. Mean/max layout shift için semantik tolerans uygulanıyor; RC-0959 gereği raw pixel difference tek başına hata sayılmıyor. Regression testlerinde yüksek pixel fark + küçük layout shift geçiyor, anlamlı layout shift kırmızı oluyor.

Commits: production `33204569afb58a74818dcd2141046bb8a8ef2287`; regression `4a3eda64b82634ae057d1736613aab4f1e443d86`; exact contract `7c00504ee91b993279864a6194b2c1850168e6ff`; validator `3d35a2d9e05ea1d5f50cf10770ede025a36172ab`; CI `3c336e3b986c6f91e532896cd18cd6e444d178df`.

Açık kanıt: deterministic CI PDF parser/rasterizer adapter, versioned TR/EN reference raster/PDF corpus ve exact-release subject-isolation/rendered golden run. Bunlar olmadan DONE yok.

### RC-0965→0994 — requirement/test traceability ve release fail-closed altyapısı

Mevcut `requirements/requirement_state.csv` + `tools/requirements/validate_requirement_matrix.py` zaten exact ordered RC-0001→RC-1442, source hash binding, lifecycle enum, task/tag/evidence, blocker ve DONE evidence kurallarını fail-closed doğruluyor.

Bunun üzerine `tools/requirements/audit_requirement_test_traceability.py` eklendi. Normal CI bütün test dosyalarını tarıyor; matrix evidence içinde hiçbir test path'i olmayan requirements ile herhangi bir RC/evidence bağı bulunmayan test dosyalarını raporluyor. `--release` modu fail-closed: tek bir RC bile DONE değilse veya test path'i yoksa release kabul edilmiyor. Böylece `IMPLEMENTED` seviyesinin final sanılması ve şartnamenin yalnız doküman olarak kalması engelleniyor.

Commits: traceability audit `0161ede884441c867a47535db37e41713128704b`; contract `e0f4322f2430d09c77a6d0deda709dd741a6f7f5`; CI `8cb2e920a4b8e1691390cada257a2ab78c28b940`.

Açık kanıt: 1.442 requirement'ın tamamında doğrudan test linki henüz yok; per-requirement UI/data model/Free-PRO/TR/EN applicability/evidence tam kapanmış değil. Bu nedenle bu meta blok DONE değildir; release-mode'un kırmızı kalması beklenen doğru davranıştır.

## Açık blocker'lar

RC-0870→0877 için production calculation-result→vector chart projection ve physical golden/zoom/print evidence açık. RC-0878→0889 için rendered TR/EN overflow/widow-orphan/table/page-break goldens açık. RC-0895→0905 için production local logo resolver ve cover/system rendered goldens açık. RC-0906→0932 için gerçek report-builder UI wiring ve rendered preview/final goldens açık. RC-0933→0941 için platform adapter + airplane-mode device kanıtı açık. RC-0942→0950 için physical Android peak-RSS/UI-responsive generation ve exact-release performance evidence açık. RC-0951→0964 için gerçek parser/rasterizer adapter + versioned TR/EN visual reference corpus açık. RC-0965→0994 için test traceability ve applicability coverage henüz tüm 1.442 RC'de tam değil.

Global blocker'lar korunuyor: independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; rendered TR/EN UI/PDF/share cards; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0951→0964 dedicated CI/matrix sonucunu fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt, yeşil promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. RC-0965→0994 traceability CI sonucunu oku; audit scriptindeki gerçek açıkları requirement-by-requirement azalt. Bu blokta final-mode'un mevcut eksikler bitene kadar kırmızı kalması zorunlu.
3. Binding sırada RC-0995+ maddelerini exact metinden yeniden okuyup bağımlılık sırasıyla ilerlet.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapma; eski global blocker'ları kaybetme.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**