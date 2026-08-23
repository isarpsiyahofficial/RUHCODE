# Ruh Code Automation Checkpoint — Persisted Combined PDF Bridge

## Bu turda tamamlanan source-level çalışma

- `PersistedCombinedPdfProjectionSource` eklendi.
- Bir combined rapor artık birden fazla exact persisted calculation record ID yükleyebiliyor.
- Duplicate/blank record ID, missing record, unsupported calculation type, duplicate projector ve owner/subject drift fail-closed.
- Concrete `PersistedWesternCombinedMemberProjector` eklendi; mevcut sealed Western natal snapshot + SHA/provenance doğrulamasını ve persisted Western section projection'ını yeniden kullanıyor.
- Concrete `PersistedPythagoreanCombinedMemberProjector` eklendi; canonical persisted numerology JSON SHA-256, schema, engine/version provenance doğrulamasından sonra gerçek numerology rows üretiyor; numeroloji tekrar hesaplanmıyor.
- TR/EN system heading ayrımı eklendi: Batı Astrolojisi / Western Astrology ve Numeroloji / Numerology başlıkları child section title'larına açık prefix olarak giriyor.
- Combined cover + technical labels TR/EN ayrı tutuluyor.
- Persisted PDF snapshot source interface görünürlüğü explicit export ile düzeltildi.
- Multi-record bridge için regression testi eklendi: deterministic composition, different-subject rejection, duplicate ID ve unsupported locale.
- `evidence/pdf/persisted_combined_projection.json`, MASTER-aware structural validator ve dedicated GitHub Actions workflow eklendi.

## Requirement etkisi

- RC-0903: gerçek persisted multi-system composition source-level ilerledi.
- RC-0904: combined raporda sistemleri açık başlıklarla ayıran TR/EN production projection source-level ilerledi.
- Evidence `done=false`; requirement'lar DONE yapılmadı.

## Commit zinciri

- `8eb35f1c0b2606afa7bf7fb5ddb5cbc4a203562f` — persisted Western + Pythagorean combined bridge
- `3254f188d47aecd0f94b1c3800389250579828f5` — persisted snapshot source interface export fix
- `ac89d8bfd63e6f112bca579bd2514d074e4c34c5` — combined projection regression tests
- `1e861f306215c9713d3c8b41103a4a550fbc77d8` — evidence
- `2309540994809e579c6bcda6be9c210ee9e08d7c` — MASTER-aware validator
- `70e04b338d2aa84b3de841fedf3cf1cea8e6091f` — dedicated CI contract

## Validation limitation

GitHub combined-status exact workflow-target commit `70e04b338d2aa84b3de841fedf3cf1cea8e6091f` için yine `statuses=[]` döndürdü. Bu nedenle Flutter/CI SUCCESS varsayılmadı.

## Açık sınırlar / blocker

- Persisted combined source henüz production PDF builder/runtime multi-record seçim akışına bağlanmadı.
- Western combined member şu anda persisted Western sözleşmesindeki mevcut subject modeline göre profile identity kullanıyor; profesyonel client ownership için explicit persisted subject-kind sözleşmesi ayrıca doğrulanmalı.
- Approved production Unicode PDF font artifact + lisans/hash yok.
- Final visual regression ve gerçek cihaz PDF open/save/share kanıtı yok.
- Physical ephemeris/EOP/Lahiri/GeoNames, 8.036 gerçek editoryal Günün Mesajı, APPROVED UI reference seti, Play/rewarded gerçek cihaz kanıtı ve clean-checkout release kapıları açık.

## Next safe work

1. Combined multi-record request/application service ekle; record ID listesini PRO guard üzerinden persisted projection source + `PdfCombinedReportService` zincirine bağla.
2. Builder UI için aynı-subject filtered multi-select record catalog contract kur.
3. Persisted Western payload'da profile/client subject-kind sahipliğini versioned biçimde açıklaştır; client combined raporlarında fail-closed yanlış kimlik riskini kaldır.
4. Combined preview → build exact record-set + locale + section parity testi ekle.
5. RC-0905 semantic metnini MASTER'dan exact doğrulayıp yalnız gerçekten uygulanırsa evidence sahipliğine ekle.

**FINAL: NO.**
