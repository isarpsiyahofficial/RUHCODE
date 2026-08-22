# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-22_0254_pdf_runtime_semantic_traceability.md`

## Bu turda ilerleyen ana bloklar

1. **Settings → PDF runtime**
   - Profil → Ayarlar artık gerçek Settings ekranına gider.
   - `PDF Raporları` gerçek runtime route'una bağlıdır.
   - FREE `Örnek PDF Önizle` canonical `pdf.sample_preview` feature ID + `FeatureAccessGuard` kullanır.
   - PRO `Profesyonel PDF Oluştur` canonical `pdf.professional_export` feature ID + aynı guard kullanır.
   - Demo preview açıkça `Örnek Kişi — Demo Profil` olarak işaretlenir ve gerçek kullanıcı/danışan/kayıt verisi içermediğini belirtir.
   - Runtime action registry/bindings ve Free/PRO widget route testleri genişletildi.

2. **PDF/UI CI sözleşmeleri**
   - UI Contracts `lib/src/ui/pdf/**` değişikliklerini kapsar.
   - PDF Entitlement Contract runtime bindings + Flutter Free/PRO route matrisini çalıştıracak şekilde genişletildi.
   - Feature Entitlement Contract runtime PDF UI/policy doğrulamasını kapsar.
   - PDF policy validator demo-data isolation marker'larını ve exact runtime bindingleri zorunlu kılar.

3. **Semantic RC ownership audit**
   - Terminology evidence'daki yanlış `RC-0539/0540/0541` sahiplikleri kaldırıldı; gerçek sahiplik `RC-1059→1065` olarak kilitlendi.
   - Interpretation evidence aileleri merkezi semantic validator'a eklendi.
   - Western astronomy evidence'larında eski TODO sıra numaralarının RC sanıldığı yanlış `RC-02xx` sahiplikleri temizlendi.
   - ASC/MC, aspect grid, dignity, natal aspect, distribution, placement, Placidus ve Porphyry evidence'ları gerçek MASTER maddelerine indirildi ve merkezi validator'a bağlandı.

## Validation limitation
- Exact HEAD için GitHub combined status yine `statuses=[]` gösterdi.
- Container üzerinden clean clone denemesi `github.com` DNS çözümleme hatası nedeniyle çalışmadı.
- Bu nedenle CI SUCCESS veya affected RC DONE iddiası yapılmadı.

## Next safe work
- semantic RC audit'i kalan requirement-bearing evidence dosyalarına genişlet
- professional PDF builder'ı gerçek guarded PDF application service'e bağla
- Settings backup aksiyonlarını mevcut BackupApplicationService'e bağla ve cancel/success/invalid-preview/rollback UI state'lerini gerçek runtime'a taşı
- APPROVED UI references geldiğinde runtime UI'yi görsel golden sözleşmesine bağla
- Actions görünür olduğunda exact PDF/UI/Requirements/Entitlement run'larını doğrula ve kırmızıyı aynı turda düzelt
- fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI reference/hash, production Unicode PDF fontları ve clean-checkout lockfile blocker'larını açık tut

**FINAL: NO.**