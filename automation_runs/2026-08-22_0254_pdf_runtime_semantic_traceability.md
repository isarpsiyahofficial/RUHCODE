# Ruh Code automation checkpoint — PDF runtime + semantic traceability

## Gerçekleştirilen işler

### 1. Settings → PDF runtime akışı
- `ACTION-SETTINGS-PDF`, `ACTION-PDF-PREVIEW`, `ACTION-PDF-BUILD` canonical runtime action ID setine eklendi.
- Profil → Ayarlar artık placeholder değil; gerçek Settings ekranına gidiyor.
- Settings içindeki `PDF Raporları` aksiyonu gerçek `PdfReportsHubPage` route'una bağlandı.
- FREE `Örnek PDF Önizle` canonical `pdf.sample_preview` feature ID üzerinden `FeatureAccessGuard.forRoute()` kullanıyor.
- PRO `Profesyonel PDF Oluştur` canonical `pdf.professional_export` feature ID üzerinden aynı guard'ı kullanıyor.
- Free kullanıcı profesyonel builder route'una giremiyor; PRO kullanıcı girebiliyor.
- Örnek preview açıkça `Örnek Kişi — Demo Profil` olarak işaretlendi ve gerçek kullanıcı/danışan/kayıt verisiyle ilişkilendirilmediği UI içinde yazılı hale getirildi.
- Dokunulabilir PDF tile'ları Semantics button + minimum 48dp sözleşmesini kullanıyor.

### 2. Runtime action / CI kapıları
- `ui/runtime_action_bindings.csv` Settings/PDF runtime aksiyonlarıyla güncellendi.
- PDF entitlement validator artık registry + feature catalog yanında runtime bindingleri de doğruluyor.
- Validator, demo preview'da örnek kişi ve gerçek veri izolasyon marker'larını zorunlu kılıyor.
- `UI Contracts` artık `lib/src/ui/pdf/**` değişikliklerinde de tetikleniyor.
- `PDF Entitlement Contract` Flutter kurup gerçek Free/PRO widget route matrisini çalıştıracak şekilde genişletildi.
- `Feature Entitlement Contract` runtime PDF UI ve PDF policy validator'ını kapsayacak şekilde genişletildi.

### 3. Semantic RC ownership audit — content / interpretation
- `evidence/content/terminology_glossary.json` içindeki yanlış `RC-0539/0540/0541` sahiplikleri kaldırıldı. MASTER'da bu maddeler terminology değil BaZi profesyonel görünümüyle ilgilidir.
- Terminology evidence artık yalnız gerçek `RC-1059→RC-1065` sahipliğini taşır.
- Merkezi semantic evidence validator terminology ve interpretation claim/quality ailelerine genişletildi.

### 4. Semantic RC ownership audit — Western astronomy
Aşağıdaki evidence dosyalarında eski TODO sıra numaralarının RC sanıldığı sahte sahiplikler temizlendi:
- `western_asc_mc.json`
- `western_aspect_grid.json`
- `western_essential_dignities.json`
- `western_natal_aspects.json`
- `western_natal_distribution.json`
- `western_natal_placements.json`
- `western_placidus_contract.json`
- `western_porphyry_houses.json`

Örnek yakalanan driftler:
- `RC-0274` MASTER'da element dağılımı değil PDF için tekrar hesap yapmama kuralıdır.
- `RC-0275` MASTER'da modality değil Free/PRO'nun aynı uygulamada olmasıdır.
- `RC-0269/0270` Western placement değil numerolog müşteri/karşılaştırma gereksinimleridir.
- `RC-0265` Placidus değil node hesaplama yöntemi seçimidir.

Western astronomy evidence'ları artık gerçek MASTER sahipliklerine indirildi ve merkezi semantic validator'a bağlandı.

## Kaynak commit zinciri
- PDF action IDs: `2f07c7c2bc99c5d553f751912bc6d56089978353`
- PDF runtime page: `9181e4ae09faa20f3eeff44d4fdbeb9ebb5e6dfa`
- Settings runtime wiring: `70c7af5f6f6c8c78eb7d1c76652e6064b5ca1211`
- Runtime action bindings: `0c1893f878e38a96244ca7e9337511502828c6b6`
- Free/PRO widget route tests: `0febe36a188a04f8a08dc13ea00e8bb62f69c10e`
- UI Contracts path/gates: `88736e958ecd72ab41d6c0c5b56bb3a273dcf61a`
- PDF Entitlement workflow: `8d7323e8522773275c738e990c92921716e53050`
- Runtime PDF binding validator: `c921538a600f40354457b011b8b07193166c96a5`
- Entitlement workflow runtime PDF coverage: `d4568b864a489f3e622d74735ad508e88583fdfd`
- Terminology evidence correction: `78503b6a0e751e3dee3ffb5c4f9ef3d877d0a239`
- Content/interpretation traceability extension: `98c0899ab1f014a00d9c6c53b165f62c3d58d066`
- Western evidence corrections: `5e5ee8e...` → `b38254f...`
- Western semantic traceability gate: `e588a40858eec8694bc6d0ea82c1ebeaa4da0843`
- Explicit demo-person marker: `fcaa2082befb14c2fea962e10f3f842374ac1060`
- Demo-data isolation validator: `3a53d7cd409c880412971044a3a44c1cc332aec9`

## Doğrulama durumu
- GitHub combined status exact HEAD için yine `statuses=[]` döndürdü.
- Push-triggered workflow sonucu connector tarafından görünür hale gelmedi.
- Temiz clone + local Python validator çalıştırma denendi; çalışma container'ı `github.com` DNS çözümleyemediği için clone yapılamadı.
- Bu nedenle bu turdaki işler source-level `IMPLEMENTED` ilerleme olarak kabul edilir; CI SUCCESS veya DONE iddiası yapılmaz.

## Sıradaki güvenli işler
1. Semantic evidence audit'i kalan requirement-bearing evidence dosyalarına genişlet; TODO-index→RC drift kalmasın.
2. PDF preview/builder'ı APPROVED UI reference seti geldiğinde exact görsel referanslara bağla; mevcut runtime ekranı nihai tasarım sayma.
3. Profesyonel PDF builder'ı gerçek guarded PDF application service'e bağla; route açık olması gerçek PDF export DONE demek değildir.
4. Backup Settings runtime aksiyonlarını mevcut `BackupApplicationService` ile bağla; cancel/success/invalid-preview/rollback durumlarını gerçek UI'ya taşı.
5. Exact Actions görünürlüğü gelirse PDF/UI/Requirements/Entitlement workflow sonuçlarını incele; kırmızı varsa aynı turda düzelt.
6. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI reference/hash seti, production PDF Unicode fontları ve clean-checkout lockfile blocker'larını açık tut.

**FINAL: NO.**