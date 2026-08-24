# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-24_0255_combined_pdf_application_subject_kind.md`

## Bu turda ilerleyen ana bloklar

1. **Western profile/client subject identity**
   - yeni Western kayıtları explicit `subjectKind=profile|client` taşıyor
   - legacy subjectKind'sız Western kayıtları yalnız `profile` olarak korunuyor
   - unknown subject kind fail-closed
   - combined Western projector artık hard-coded profile kullanmıyor

2. **Combined professional PDF application service**
   - canonical PRO service guard
   - aynı subject kind + stable subject ID için filtered record catalog
   - exact multi-record preview token
   - preview token record IDs + locale + subject + composite SHA + systems + ordered sections saklıyor
   - build kayıtları yeniden okuyup snapshot/system/section drift varsa fail-closed

3. **Regression/evidence/CI**
   - preview→build exact parity testi
   - preview sonrası persisted digest drift rejection testi
   - Free/locked service-guard testi
   - Western client/legacy-profile/invalid-subject-kind testleri
   - combined evidence yalnız RC-0903/0904 sahipleniyor
   - RC-0905 gerçek Vedik/Western isolation kanıtı olmadan açık tutuluyor
   - dedicated combined workflow ve merkezi Requirements Contract genişletildi

## Validation limitation

Exact workflow-target commit `6accc318df7b3515e682b67f45445e01d7f3bacf` için GitHub combined-status `statuses=[]` döndürdü. Bu nedenle CI SUCCESS varsayılmadı ve ilgili RC'ler DONE yapılmadı.

## Next safe work

- combined application service'i production runtime + gerçek multi-select builder UI'a bağla
- multi-select değişince preview invalidation ve exact record-set UI parity ekle
- combined native Save As/share delivery zincirini preview token üzerinden bağla
- RC-0905'i Vedik persisted PDF mevcut olmadan sahiplenme
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts, Play/rewarded device proof ve clean-checkout release proof blocker olarak kalır

**FINAL: NO.**
