# Ruh Code — Automation Checkpoint — 2026-08-24 06:55

## Bu turda yapılan gerçek çalışma

### Combined PDF görünür Flutter akışı

- `CombinedProfessionalPdfBuilderPage` eklendi.
- Gerçek subject seçimi (`profile` / `client`) production combined catalog üzerinden geliyor.
- Aynı subject için persisted calculation kayıtları çoklu seçilebiliyor.
- Kombine rapor için yalnız iki kayıt değil, en az iki **farklı calculation sistemi** zorunlu.
- Subject discovery iki aynı-system kaydı kombine rapora uygun subject olarak göstermiyor.
- UI Preview butonu da iki farklı sistem seçilmeden aktif olmuyor; kullanıcıya açık yönlendirme gösteriliyor.
- Western + Pythagorean için seçilebilir gerçek handler bölümleri UI'da gösteriliyor.
- Bölüm adları TR/EN locale'e göre ayrı gösteriliyor (`Yerleşimler/Placements`, `Evler/Houses`, `Açılar/Aspects`, `Numeroloji/Numerology`, `Hesaplama Bilgileri/Calculation Details`).
- Subject/record/locale/section değişikliği sealed preview token'ı geçersiz kılıyor.
- Preview kartı exact systems, sections, locale ve combined snapshot digest'i gösteriyor.

### Gerçek route + PRO guard

- `RuhCodeApp` içine `/pdf/combined` route'u eklendi.
- `Profil → Ayarlar → Kombine PDF Raporu` görünür action'ı eklendi.
- Route açılmadan önce canonical `pdf.professional_export` PRO guard kontrol ediliyor.
- Ayrı widget regression Free kullanıcının route'a giremediğini ve PRO kullanıcının gerçek builder route'una ulaştığını doğruluyor.

### Exact preview-token native delivery

- Combined Save As/share UI adapter'ı eklendi.
- Production startup `combinedProfessionalPdfDelivery` servisini UI runtime'a bağlıyor.
- Save/share öncesinde `CombinedPdfSelectionState.sealedPreviewForDelivery()` current selection ile preview'ın exact eşleşmesini tekrar doğruluyor.
- Native delivery aynı sealed preview'ı tekrar application service `buildFromPreview` zincirine sokuyor.
- Cancelled/unavailable sonuçlar success olarak gösterilmiyor.

### Action / accessibility sözleşmesi

Canonical runtime action'lar:

- `ACTION-PDF-COMBINED`
- `ACTION-PDF-COMBINED-PREVIEW`
- `ACTION-PDF-COMBINED-CREATE`
- `ACTION-PDF-COMBINED-SAVE`
- `ACTION-PDF-COMBINED-SHARE`

Hepsi action registry + runtime binding manifestine bağlı. Kritik kontroller Semantics ve minimum 48dp target kullanıyor.

### Test / CI contract

- `combined_pdf_selection_state_test.dart`: exact delivery preview + preview invalidation + same-system rejection.
- `combined_pdf_builder_page_test.dart`: multi-record seçim + preview + exact share token + 48dp + 2.0x text scale.
- `combined_pdf_route_entitlement_test.dart`: Free route reddi + PRO route erişimi.
- `combined_pdf_localization_gate_test.dart`: same-system UI disable + English section labels.
- `validate_combined_pdf_ui_runtime.py` görünür page/route, PRO guard, runtime delivery binding, action registry ve dört test ailesini zorunlu kılıyor.
- `Combined PDF UI Runtime Contract` dört Flutter testini birlikte çalıştıracak şekilde genişletildi.
- Aynı validator merkezi `Requirements Contract` içine bağlı.

## Requirement durumu

`RC-0903` ve `RC-0904` source-level olarak daha güçlü kanıta bağlıdır fakat **DONE değildir**.

`RC-0905` bilinçli olarak açık tutulur; persisted Vedik PDF sistemi olmadan sahiplenilmez.

`RC-1440/RC-1441` için combined UI action/accessibility kanıtı ilerlemiştir fakat uygulama çapındaki requirement'lar tamamlanmadığı için DONE değildir.

## Validation limitation

Latest dedicated workflow-target commit `62ff34493459bd0dc80191b5c76f26993f73f92a` için GitHub combined status `statuses=[]` döndürdü. Exact görünür CI SUCCESS olmadığı için TESTED/VERIFIED/DONE seviyesi uydurulmadı.

## Açık blocker'lar

- approved production Unicode PDF font binary + license + immutable SHA,
- combined real byte renderer (font zinciri hazır olana kadar fail-closed),
- APPROVED final UI reference/hash seti + visual regression,
- physical ephemeris/EOP/Lahiri/GeoNames artifacts,
- 8.036 gerçek editoryal Günün Mesajı,
- Play/rewarded real-device proof,
- clean-checkout/reproducible release APK.

## Next safe work

1. Combined UI evidence semantic ownership auditini sürdür; RC-0905'i persisted Vedik PDF olmadan sahiplenme.
2. Persisted Vedik PDF için doğrulanmış persistence schema yoksa veri formatı uydurma; blocker olarak bırak.
3. Font/physical-data blocker'ı gerektirmeyen PDF/UI/accessibility/evidence işlerine devam et.
4. Günün Mesajı editorial catalog işini parça parça ilerletirken release completeness gate'i kırmadan staging/editoryal akış kullan.

**FINAL: NO.**
