# Ruh Code automation checkpoint — persisted PDF source + native delivery

## Bu turda yapılan gerçek işler

- `LocalDatabaseProfessionalPdfSnapshotSource` eklendi.
  - `calculations` kaydı ile bağlı `calculation_manifests` kaydını **aynı LocalDatabase transaction** içinde okur.
  - storage ID / payload ID uyuşmazlığını reddeder.
  - eksik manifesti reddeder.
  - `unavailable` ve `error` validity durumlarını profesyonel PDF girdisi olarak reddeder.
  - raw UI verisinden snapshot uydurmaz.
- `ProfessionalPdfRecordCatalog` ve typed `PersistedCalculationPdfSummary` eklendi.
  - kayıtlar newest-first deterministik sıralanır.
- `RuhCodeRuntime` production persisted PDF source'u composition root içinde oluşturup expose ediyor.
- `PdfPlatformPolicy` + `NativePdfPlatformGateway` eklendi.
  - `.pdf` dosya adı/path-injection kontrolü.
  - `%PDF-` byte kontrolü ve 128 MiB platform sınırı.
  - OS Save As ve native share sheet.
  - Ruh Code server hop'u yok.
- `ProfessionalPdfDeliveryService` eklendi.
  - yalnız `ProfessionalPdfApplicationService` tarafından build + structural inspection geçirmiş byte'ları teslim eder.
  - Save As/share iptali normal typed `cancelled` sonucu.
  - share unavailable ayrı durum.
- `ProfessionalPdfCatalogActions` ile typed persisted-calculation catalog UI boundary'si oluşturuldu; widget içine LocalDatabase tipi sızmıyor.
- Yeni regresyon testleri:
  - calculation + manifest atomic load;
  - missing manifest fail-closed;
  - unavailable calculation fail-closed;
  - typed/newest-first catalog;
  - PDF filename/path/non-PDF policy;
  - save cancellation;
  - dismissed/unavailable share.
- `evidence/pdf/professional_application_service.json`, structural validator ve `Professional PDF Application Contract` workflow'u yeni kaynak/testleri kapsayacak şekilde genişletildi.

## Semantic RC sahipliği

Source-level evidence şu RC'leri sahipleniyor ve MASTER literal marker'ları validator tarafından kontrol ediliyor:

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

`done=false` korunuyor.

## Workflow durumu

Workflow-target commit: `72c2e6f7269a90200f6538d2932b828081b72b5d`

GitHub combined-status sorgusu bu exact commit için yine `statuses=[]` döndürdü. Bu nedenle SUCCESS/DONE iddiası yapılmadı.

## Sıradaki güvenli çalışma

1. `ProfessionalPdfCatalogActions` typed saved-calculation listesini `ProfessionalPdfBuilderPage` içine gerçek selector olarak bağla; ham record ID alanını kaldır.
2. `RuhCodeApp` / navigation composition'a record-catalog action'ını aktar.
3. Desteklenen persisted calculation type'ları için gerçek `PdfReportContentAdapter<PersistedCalculationPdfSnapshot>` routing/adapter sözleşmesini kur; bilinmeyen calculation type fail-closed olsun.
4. Production font blocker gerektirmeyen PDF data/table/interactions testlerini genişlet.
5. Kalan requirement-bearing evidence dosyalarının semantic RC ownership audit'ini sürdür.
6. Requirement state yalnız görünür workflow/test/evidence kanıtıyla yükseltilsin.

## Açık ana blocker'lar

- production Unicode PDF font binary + license/hash
- approved UI reference/hash seti
- physical ephemeris/EOP/Lahiri/GeoNames artifacts
- 8.036 gerçek editoryal Günün Mesajı
- clean-checkout `pubspec.lock` + release build kanıtı
- real-device PDF Save As/share smoke kanıtı

**FINAL DEĞİL.**
