# Ruh Code — Automation Checkpoint — 2026-08-24 06:55

## Bu turda yapılan gerçek çalışma

### Combined PDF görünür Flutter akışı

- `CombinedProfessionalPdfBuilderPage` eklendi.
- Gerçek subject seçimi (`profile` / `client`) production combined catalog üzerinden geliyor.
- Aynı subject için persisted calculation kayıtları çoklu seçilebiliyor.
- Kombine rapor için yalnız iki kayıt değil, en az iki **farklı calculation sistemi** zorunlu hale getirildi.
- Western + Pythagorean için seçilebilir gerçek handler bölümleri UI'da gösteriliyor.
- Subject/record/locale/section değişikliği sealed preview token'ı geçersiz kılıyor.
- Preview kartı exact systems, sections, locale ve combined snapshot digest'i gösteriyor.

### Gerçek route + PRO guard

- `RuhCodeApp` içine `/pdf/combined` route'u eklendi.
- `Profil → Ayarlar → Kombine PDF Raporu` görünür action'ı eklendi.
- Route açılmadan önce canonical `pdf.professional_export` PRO guard kontrol ediliyor.
- Free kullanıcı için route fail-closed kalıyor.

### Exact preview-token native delivery

- Combined Save As/share UI adapter'ı eklendi.
- Production startup `combinedProfessionalPdfDelivery` servisini UI runtime'a bağlıyor.
- Save/share öncesinde `CombinedPdfSelectionState.sealedPreviewForDelivery()` current selection ile preview'ın exact eşleşmesini tekrar doğruluyor.
- Native delivery kendi başına PDF üretmiyor; aynı sealed preview tekrar application service `buildFromPreview` zincirine giriyor.
- Cancelled/unavailable sonuçlar success olarak gösterilmiyor.

### Action / accessibility sözleşmesi

Yeni canonical runtime action'lar:

- `ACTION-PDF-COMBINED`
- `ACTION-PDF-COMBINED-PREVIEW`
- `ACTION-PDF-COMBINED-CREATE`
- `ACTION-PDF-COMBINED-SAVE`
- `ACTION-PDF-COMBINED-SHARE`

Hepsi action registry + runtime binding manifestine bağlandı. Critical controls Semantics ve minimum 48dp target kullanıyor.

### Test / CI contract

- `combined_pdf_selection_state_test.dart` exact delivery preview ve same-system rejection için genişletildi.
- `combined_pdf_builder_page_test.dart` eklendi:
  - gerçek multi-record seçim akışı,
  - preview oluşturma,
  - preview invalidation,
  - exact sealed preview'ın share adapterına aktarılması,
  - 48dp kritik action kontrolü,
  - 2.0x text-scale smoke contract.
- `validate_combined_pdf_ui_runtime.py` görünür page/route, PRO guard, runtime delivery binding, action registry ve widget testlerini zorunlu kılacak şekilde genişletildi.
- `Combined PDF UI Runtime Contract` workflow'u iki Flutter testini birlikte çalıştıracak şekilde genişletildi.
- Aynı validator merkezi `Requirements Contract` içine de bağlandı.

## Requirement durumu

`RC-0903` ve `RC-0904` source-level olarak daha güçlü kanıta bağlıdır fakat **DONE değildir**.

`RC-0905` bilinçli olarak açık tutulur; persisted Vedik PDF sistemi olmadan sahiplenilmez.

`RC-1440/RC-1441` için combined UI action/accessibility kanıtı ilerlemiştir fakat genel requirement'ların tüm uygulama çapı henüz tamamlanmadığı için DONE değildir.

## Validation limitation

Requirements workflow-target commit `8f5271d45865d00fb6ae405e7cdb7aae6ac9bf4a` için GitHub combined status yine `statuses=[]` döndürdü. Exact visible CI SUCCESS olmadığı için TESTED/VERIFIED/DONE seviyesi uydurulmadı.

## Açık blocker'lar

- approved production Unicode PDF font binary + license + immutable SHA,
- combined real byte renderer (font zinciri hazır olana kadar fail-closed),
- APPROVED final UI reference/hash seti + visual regression,
- physical ephemeris/EOP/Lahiri/GeoNames artifacts,
- 8.036 gerçek editoryal Günün Mesajı,
- Play/rewarded real-device proof,
- clean-checkout/reproducible release APK.

## Next safe work

1. Combined builder'ın selected-system sayısını UI disabled-state'e de bağla; same-system selection hata butonu yerine önceden anlaşılır olsun.
2. Combined builder TR/EN section labels'ı tam locale-aware yap; mevcut section catalog TR label alanını EN'de göstermesin.
3. Combined route için Free/PRO route widget regression ekle.
4. Combined UI evidence'ı semantic traceability family içinde exact RC ownership ile yeniden kontrol et.
5. Blocker gerektirmeyen PDF/UI/accessibility işlerine devam et.

**FINAL: NO.**
