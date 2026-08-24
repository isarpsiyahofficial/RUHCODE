# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-24_0655_combined_pdf_visible_ui_route.md`

## Bu turda ilerleyen ana bloklar

1. **Visible combined PDF route**
   - gerçek `CombinedProfessionalPdfBuilderPage`
   - `Profil → Ayarlar → Kombine PDF Raporu`
   - canonical `pdf.professional_export` PRO route guard
   - Free/PRO route widget regression

2. **True multi-system selection**
   - aynı subject için çoklu persisted calculation seçimi
   - en az iki farklı calculation system zorunlu
   - same-system-only seçim state ve visible UI seviyesinde engelli
   - subject discovery de aynı kuralı uygular

3. **TR/EN visible contract**
   - combined section labels Türkçe ve İngilizce ayrı
   - English widget regression Türkçe bölüm sızıntısını reddeder

4. **Exact sealed preview delivery**
   - subject/record/locale/section değişikliği preview'ı invalid eder
   - build ve native Save As/share current selection ile exact sealed preview eşleşmesini tekrar doğrular
   - startup native delivery bridge'i production runtime'a bağlı

5. **Action/accessibility + CI**
   - combined route/preview/create/save/share canonical ACTION-ID'ler
   - action registry + runtime binding manifest
   - 48dp + Semantics kritik kontroller
   - 2.0x text-scale widget contract
   - dört combined Flutter test ailesi dedicated workflow'a bağlı
   - combined runtime validator merkezi Requirements Contract içinde

## Validation limitation

Latest dedicated workflow-target `62ff34493459bd0dc80191b5c76f26993f73f92a` için GitHub combined status `statuses=[]` döndürdü. Exact görünür workflow SUCCESS olmadığı için RC-0903/0904 DONE yapılmadı.

## Next safe work

- combined evidence semantic ownership auditini sürdür
- RC-0905'i persisted Vedik PDF sistemi olmadan sahiplenme
- doğrulanmış Vedik persistence schema yoksa format uydurma
- font/physical-data blocker'ı gerektirmeyen PDF/UI/accessibility/evidence işlerine devam et
- 8.036 editorial daily-message işi için release catalog'u kırmadan staging/editoryal akışı ilerlet

**FINAL: NO.**
