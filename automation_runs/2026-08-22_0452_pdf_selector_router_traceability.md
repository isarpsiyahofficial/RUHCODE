# Ruh Code automation checkpoint — typed PDF selector + router + traceability

## Bu turda yapılan gerçek işler

### 1. Persisted calculation → professional PDF source
- `LocalDatabaseProfessionalPdfSnapshotSource` production adapterı eklendi.
- `calculations` + bağlı `calculation_manifests` aynı LocalDatabase transaction içinde okunuyor.
- storage/payload ID mismatch, missing manifest, manifest ID mismatch, `error` ve `unavailable` validity fail-closed.
- typed `ProfessionalPdfRecordCatalog` newest-first deterministik kayıt listesi sağlıyor.
- `RuhCodeRuntime` bu source'u production composition root içinde oluşturup expose ediyor.

### 2. Typed saved-calculation selector
- `ProfessionalPdfUiRecord`, `ProfessionalPdfRecordActions`, `ProfessionalPdfCatalogActions` eklendi.
- `ProfessionalPdfBuilderPage` ham `Kayıt kimliği` text alanını tamamen kaldırdı.
- Builder artık `Kayıtlı Hesaplama` typed dropdown kullanıyor.
- explicit test actions yoksa production startup'ta tek kez bağlanan `ProfessionalPdfUiRuntimeBindings.records` kaynağını kullanıyor.
- `lib/main.dart`, `runtime.professionalPdfSnapshotSource` üzerinden production catalog'u UI boundary'ye bağlıyor.
- Widget regressions exact selected record ID + section order, no raw ID field ve no-fake-success davranışlarını kapsıyor.

### 3. Fail-closed calculation-type PDF routing
- `PersistedCalculationPdfRouter` eklendi.
- exact `calculationType` → exact registered `PdfService`.
- unknown calculation type `UnsupportedError`.
- duplicate handler registration `StateError`.
- empty handler registry `FormatException`.
- hiçbir calculation payload başka sistemin handler'ına fallback edilmiyor.

### 4. Native PDF delivery
- `PdfPlatformPolicy` + `NativePdfPlatformGateway` eklendi.
- path-free `.pdf` filename, `%PDF-` prefix ve size limit validation.
- OS Save As + native share sheet.
- Ruh Code server hop yok.
- `ProfessionalPdfDeliveryService` yalnız application-service build/inspection sonrası byte teslim ediyor.
- save/share cancellation typed normal sonuç; share unavailable ayrı durum.

### 5. Test / evidence / CI
- persisted source testleri.
- calculation-router testleri.
- native delivery policy testleri.
- typed-selector widget testleri.
- `evidence/pdf/professional_application_service.json` güncellendi; `done=false` korunuyor.
- `tools/pdf/validate_professional_pdf_application.py` source/runtime/UI/router/delivery sözleşmesini ve semantic RC sahipliğini kontrol ediyor.
- `Professional PDF Application Contract` workflow yeni source/test dosyalarını kapsıyor.
- merkezi `tools/requirements/validate_evidence_traceability.py` artık `requirement_ids[]` evidence formatını da okuyabiliyor ve `evidence/pdf/professional_application_service.json` exact RC setini global semantic audit'e dahil ediyor.

## Semantic RC sahipliği

Professional PDF application evidence exact:
- RC-0918
- RC-0936
- RC-0939
- RC-0940
- RC-0950
- RC-0951
- RC-0952
- RC-0953
- RC-0964
- RC-1085
- RC-1086
- RC-1088
- RC-1089

Kaynak seviyesinde ilerleme var; `done=false`.

## Validation görünürlüğü

Professional PDF workflow-target evidence commit `9df3d778fc5dcf09dc91f18d11f3c045b57bfb8f` için GitHub combined-status `statuses=[]` döndürdü.

Central semantic traceability commit `2a0ea7bd0831da3f3f2b27f6b664b1160521a0fe` için de `statuses=[]`.

Bu nedenle SUCCESS veya DONE iddiası yapılmadı.

## Sıradaki güvenli çalışma

1. Persisted calculation type'ları için gerçek production PDF handler composition'ını ilerlet:
   - önce canonical Numerology snapshot payload/schema adapterı,
   - sonra Western snapshot adapterı,
   - unsupported type fail-closed kalsın.
2. `ProfessionalPdfApplicationActions` build side'ını runtime'a yalnız gerçek local renderer + approved font provider mevcut olduğunda bağla; fake/demo production build oluşturma.
3. Native PDF save/share için widget/application delivery UI state'leri ekle; gerçek cihaz kanıtı olmadan DONE verme.
4. PDF font blocker gerektirmeyen data/table/parity testlerini genişlet.
5. Kalan requirement-bearing evidence dosyalarını central semantic RC drift audit'e ekle.
6. Physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial messages, APPROVED UI reference set, production PDF font artifact ve clean-checkout lockfile blocker'ları açık tutulmalı.

**FINAL DEĞİL.**
