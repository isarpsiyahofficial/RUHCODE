# Ruh Code automation checkpoint — 2026-08-22 12:53 TRT

## Bu turda tamamlanan source-level işler

### 1. Professional PDF builder action semantic drift düzeltildi
- Runtime builder artık tarihsel `ACTION-PDF-PREVIEW-CREATE` / `ACTION-PDF-PREVIEW-SHARE` kimliklerini kullanmıyor.
- Canonical builder action kimlikleri oluşturuldu:
  - `ACTION-PDF-BUILDER-CREATE`
  - `ACTION-PDF-BUILDER-SHARE`
- Bu actionlar `SCR-PDF-BUILDER-001` ekranına, PRO entitlement'a ve gerçek `GENERATE_PDF` / `SHARE_PDF` etkilerine bağlandı.
- Base action registry'nin büyük tarihsel yapısını riskli biçimde yeniden yazmamak için açık `ui/action_registry_runtime_extensions.csv` katmanı oluşturuldu.
- `runtime_action_bindings.csv`, `RuhActionIds`, PDF entitlement validator ve accessibility/runtime binding validatorları extension registry'yi birlikte doğrulayacak şekilde güncellendi.
- Legacy preview action ID'lerinin professional builder runtime'a dönmesi fail-closed CI ihlali oldu.
- `pdf-entitlement-contract.yml` extension registry değişikliklerinde de tetikleniyor.

### 2. Versioned persisted Western natal snapshot oluşturuldu
- Gerçek runtime house motorları incelendi:
  - `PlacidusHouseResult` / `PlacidusHouseCusps`
  - `PorphyryHouseCusps`
  - Whole Sign / Equal House `HouseCusps`
- Bu motorların farklı sınıflarını doğrudan serialize etmek yerine kayıpsız ortak persistence projection kuruldu.
- `PersistedWesternNatalSnapshot` schema v1 şunları saklıyor:
  - engineVersion
  - algorithmVersion
  - dataVersion
  - TT Julian Day
  - sourceId
  - requestedHouseSystem
  - effectiveHouseSystem
  - exact 12 house cusp longitude
  - placement body/longitude/house/motion
  - major aspect body-pair/type/exact/separation/delta/orb
- Canonical JSON + SHA-256 seal/verify eklendi.
- PDF geometry için `PdfWesternChartGeometryAdapter.fromPersistedSnapshot()` eklendi. Historical PDF açılışında natal harita yeniden hesaplanmıyor.
- `PersistedWesternNatalPdfReader` calculation type'ı ve CalculationManifest engine/algorithm/data version parity'sini doğruluyor.

### 3. Persisted geometry integrity sertleştirildi
- 12 cusp yalnız longitude aralığında olmakla kalmıyor; on iki non-degenerate forward arc oluşturup tam 360° cycle kapatmak zorunda.
- Saklanan placement `houseNumber`, aynı snapshot'taki cusp geometrisinden yeniden türetilen house numarasıyla birebir eşleşmek zorunda.
- Persisted body adı canonical `AstroBody` setinin dışında olamaz.
- Aspect type canonical `MajorAspect` dışında olamaz.
- Aspect `exactAngleDeg`, aspect type'ın exact açısıyla eşleşmek zorunda.
- Aspect separation, iki persisted placement longitude'u arasındaki gerçek shortest arc ile eşleşmek zorunda.
- `deltaFromExactDeg`, separation/exact-angle geometrisiyle eşleşmek zorunda ve allowed orb'u aşamaz.
- Tamper, duplicate body/aspect pair, invalid cusp/longitude, orphan aspect, house mismatch ve aspect geometry mismatch fail-closed.

### 4. Test/evidence/CI
- `test/pdf/persisted_western_natal_snapshot_test.dart`
- `test/pdf/persisted_western_natal_pdf_test.dart`
- `evidence/pdf/persisted_western_natal_snapshot.json`
- `tools/pdf/validate_persisted_western_natal_snapshot.py`
- `.github/workflows/persisted-western-natal-pdf-contract.yml`

Evidence bilinçli olarak `done=false`:
- exact Flutter/Actions SUCCESS henüz görünür değil,
- physical ephemeris/EOP bağımsız accuracy kanıtı açık,
- approved vector glyph/assets + visual regression açık,
- production Unicode PDF font artifact/license/SHA açık.

## Requirement sahipliği
Bu turdaki Western persistence evidence yalnız şu maddeleri sahipleniyor:
`RC-0724`, `RC-0725`, `RC-0726`, `RC-0727`, `RC-0737`, `RC-0738`, `RC-0870`.
Astronomik doğruluk veya final PDF görsel kalite maddeleri DONE sayılmadı.

## Validation durumu
- Persisted Western workflow-target commit: `30b8e9137251efd87678d5600b91893da61f44bf` için combined status sorgusu `statuses=[]` döndürdü.
- Sonraki geometry-integrity source/evidence/validator değişiklikleri de bu contract'ın path kapsamındadır; görünür exact SUCCESS olmadan requirement state yükseltilmedi.

## Sıradaki güvenli işler
1. Persisted Western snapshot'ın calculation-save boundary'sini tanımla; yeni Western hesap kaydı oluşturulurken snapshot+SHA birlikte yazılmasını zorunlu yap.
2. Persisted snapshot → Western PDF section/table projection ekle; renderer içinde hesaplama yapma.
3. Semantic evidence validator'a yeni Western persistence evidence'ını yalnız MASTER metniyle doğrulanmış RC sahipliğiyle ekle.
4. `pubspec.lock` / clean-checkout, production PDF fontları, physical astronomy artifacts, GeoNames, 8.036 editoryal günlük mesaj ve APPROVED UI blockerları açık kalmaya devam eder.

## Final durumu
FINAL DEĞİL. İlgili requirement'lar source-level ilerledi fakat kanıtsız biçimde DONE'a yükseltilmedi.
