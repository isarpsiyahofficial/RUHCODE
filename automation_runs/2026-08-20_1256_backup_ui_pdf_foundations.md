# Ruh Code automation checkpoint — backup UI + PDF foundations

## Bu turda uygulananlar

### Backup UI / restore safety
- `lib/src/ui/backup/backup_ui_contract.dart` eklendi ve mevcut service API'leriyle uyumlu hale getirildi.
- TR/EN için tam yedek oluşturma, paylaşma, yedek seçme, merge, replace ve vazgeçme copy sözleşmesi eklendi.
- İptal, invalid backup, preview-ready, restore, share-unavailable ve rollback-restored durumları birbirinden ayrıldı.
- `BackupImportCoordinator` replace hatalarında artık `BackupRestoreException` ile rollback'in gerçekten başarıp başarmadığını üst katmana taşıyor.
- UI yalnız `rollbackRestored == true` olduğunda “güvenlik kopyası geri yüklendi” durumu gösterebilir.
- Rollback'in kendisi başarısızsa UI bunu restored diye gösteremez.
- Backup UI testleri, evidence ve structural validator eklendi.
- Backup CI workflow'u UI contract validator ve `test/ui/backup` testlerini kapsayacak şekilde genişletildi.

### Profesyonel PDF Faz 23 başlangıcı
- `PdfPageSpec.a4`: 210×297 mm ve deterministik margin/content alanı sözleşmesi eklendi.
- Typography hierarchy tokenları eklendi ve doğrulanıyor.
- Canonical PDF section ID'leri eklendi.
- Section selection sırası korunuyor; boş bölümler bastırılıyor.
- Professional / client-friendly cover stili ayrıldı.
- Optional professional branding metadata sözleşmesi eklendi.
- PDF locale v1 yalnız `tr` ve `en` kabul ediyor.
- Sample PDF yalnız demo data origin ile, gerçek rapor yalnız user data origin ile üretilebilir.
- `PdfSnapshotIdentity` eklendi: subject + engine/algorithm/data version + lowercase SHA-256 snapshot digest.
- Tüm PDF section data aynı exact snapshot digest'e bağlı olmak zorunda.
- Başka müşteri/snapshot verisinin section seviyesinde karışması render öncesinde reddediliyor.
- UI ve PDF calculation snapshot digest eşitliği için açık parity guard eklendi.
- PDF planning/data unit testleri, evidence, structural validator ve `Professional PDF Contract` workflow'u eklendi.

## Bu turdaki önemli düzeltme
İlk backup UI source yazımında mevcut API ile iki isim uyuşmazlığı tespit edildi (`preview.isValid` yerine `preview.valid`; import result üzerinde olmayan success/rollback alanları). Dosya hemen gerçek mevcut contract'a göre düzeltildi. Rollback bilgisinin result'ta hiç bulunmaması ayrıca mimari açık olarak ele alındı ve typed `BackupRestoreException` ile kapatıldı.

## Bilinçli olarak DONE yapılmayanlar
- Backup UI için exact Flutter/Actions SUCCESS kanıtı görünür değil.
- `ui/action_registry.csv` içinde eski `CSV Dışa Aktar / CSV İçe Aktar` wording hâlâ bulunuyor; portable `.ruhcode.zip` davranışıyla uyumlu registry migrasyonu açık.
- Backup için Android gerçek cihaz Save As / picker / native share smoke kanıtı yok.
- Approved backup UI referans PNG/state seti yok.
- PDF için production byte renderer henüz yok.
- Unicode TR/EN font asset + license/hash manifesti yok.
- Western/Vedic chart vector embedding yok.
- Pagination/orphan/table-split/5-25-50+ page/memory/parse/render/visual-regression kanıtları yok.
- `pubspec.lock` hâlâ yok; clean-checkout reproducibility kapanmadı.
- Fiziksel IERS EOP, gerçek offline ephemeris, GeoNames physical artifact, 8.036 gerçek editoryal Günün Mesajı ve APPROVED UI referans seti blocker'ları devam ediyor.

## Sonraki bağımlılık sırası
1. Primary `ui/action_registry.csv` portable-backup wording/action IDs ile migrate edilecek.
2. Backup UI controller/widget yalnız APPROVED reference geldiğinde gerçek layout'a bağlanacak; önce action/state contract korunacak.
3. PDF için local-only renderer dependency ve font-asset lisans/hash sözleşmesi kurulacak.
4. Production PDF renderer: A4 MultiPage, Unicode font, cover/section/page number/pagination.
5. Aynı calculation snapshot'tan Western/Vedic vector chart adapterları bağlanacak.
6. PDF byte parse + 5/25/50+ page + low-memory + visual regression kapıları kurulacak.
7. Paralelde fiziksel dataset/content/UI blocker'ları uygun olduğunda kapatılacak.

## Final durumu
FINAL değil. RC-0001→RC-1442 requirement setinin tamamı DONE ve bütün release kapıları yeşil olmadan FINAL etiketi kullanılamaz.
