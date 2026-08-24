# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-24_0655_combined_pdf_visible_ui_route.md`

## Bu turda ilerleyen ana bloklar

1. **Visible combined PDF route**
   - gerçek `CombinedProfessionalPdfBuilderPage`
   - `Profil → Ayarlar → Kombine PDF Raporu`
   - canonical `pdf.professional_export` PRO route guard

2. **True multi-system selection**
   - aynı subject için çoklu persisted calculation seçimi
   - en az iki farklı calculation system zorunlu
   - same-system-only selection fail-closed
   - subject discovery aynı kuralı önceden uygular

3. **Exact sealed preview delivery**
   - subject/record/locale/section değişikliği preview'ı invalid eder
   - build ve native Save As/share current selection ile exact sealed preview eşleşmesini tekrar doğrular
   - startup native delivery bridge'i production runtime'a bağlar

4. **Action/accessibility**
   - combined route/preview/create/save/share için canonical ACTION-ID'ler
   - action registry + runtime binding manifest
   - 48dp + Semantics kritik kontroller
   - 2.0x text-scale widget contract

5. **CI / evidence**
   - state ve visible builder widget testleri
   - Combined PDF UI Runtime Contract genişletildi
   - combined UI validator merkezi Requirements Contract'a bağlandı

## Validation limitation

Requirements workflow-target `8f5271d45865d00fb6ae405e7cdb7aae6ac9bf4a` için GitHub combined status `statuses=[]` döndürdü. Exact görünür workflow SUCCESS olmadığı için RC-0903/0904 DONE yapılmadı.

## Next safe work

- selected-system sayısını visible disabled-state'e bağla
- combined section etiketlerini tam TR/EN locale-aware yap
- Free/PRO route widget regression ekle
- combined evidence semantic ownership auditini sürdür
- RC-0905'i persisted Vedik PDF olmadan sahiplenme
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts, Play/rewarded device proof ve clean-checkout release proof blocker olarak kalır

**FINAL: NO.**
