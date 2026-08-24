# Ruh Code Automation Checkpoint — 2026-08-24 02:55

## Bu turda uygulanan gerçek işler

- Western natal persistence artık yeni kayıtlar için açık `subjectKind=profile|client` saklıyor. Astronomik snapshot SHA içeriği değiştirilmedi; ownership metadata sealed chart payload'ın dışında tutuluyor.
- Legacy Western kayıtlarında `subjectKind` yoksa yalnız `profile` kabul ediliyor. Eski kaydı client diye tahmin etme yok. Bilinmeyen subject kind fail-closed.
- `PersistedWesternCombinedMemberProjector` hard-coded `profile` kullanmayı bıraktı ve persisted reader'ın doğruladığı gerçek subject kind'ı kullanıyor.
- Yeni `CombinedProfessionalPdfApplicationService` eklendi:
  - canonical `pdf.professional_export` PRO service guard,
  - aynı stable subject kind + ID için record candidate filtreleme,
  - minimum iki persisted record,
  - TR/EN locale normalization,
  - exact preview token: record IDs + locale + subject + composite SHA + systems + ordered sections,
  - build sırasında tüm kayıtları tekrar okuyup preview/build digest/system/section drift fail-closed kontrolü.
- Combined application-service regression testleri eklendi:
  - exact preview→build parity,
  - persisted digest değişirse build reddi,
  - Free/locked durumda projection başlamadan service guard reddi.
- Western PDF testlerine explicit client, legacy profile ve invalid subject-kind regresyonları eklendi.
- Combined evidence `RC-0903/0904` ile sınırlı tutuldu. `RC-0905` bilinçli olarak sahiplenilmedi; gerçek Vedik/Western çapraz sistem render kanıtı henüz yok.
- MASTER-aware combined validator yeni subject-kind + PRO guard + preview/build parity sözleşmelerini zorunlu kılacak şekilde sertleştirildi.
- Dedicated combined workflow yeni application-service ve Western subject-kind testlerini çalıştıracak şekilde genişletildi.
- Merkezi Requirements Contract'a persisted combined projection/application validator eklendi.

## Commit zinciri

- `be701b8e491530c4fd0f12fabcb13eb5f4236697` — explicit Western subject kind persistence.
- `86362e2b0707d0c727b8cd8fcbb324e200a77a29` — backward-compatible Western subject-kind reader.
- `998147edffde92d00f17c2baea97f65d9337ff50` — combined Western projector real subject kind.
- `edd34a30ddc00fd0dccbbb644e2b5076aab356d5` / `08deae3cb8a9d2278bfc2d7d4c21d265a3812de1` — combined application service + import fix.
- `8b06d06365dd8225af3774036531da3b94182790` / `dffa71f423e4dc5a2fcbcdff758a48ba8938837b` — application tests + valid fixed SHA fixtures.
- `31e0f99e773c046008dcd7b6332a6354a7fab06b` — evidence update.
- `6c919aca5879f23222690d75cf3563bd96a9a98e` — hardened semantic validator.
- `3874c5b126b08e1a035ad61ce2191b68d169ee11` — Western subject-kind tests.
- `411b7965106767e38095456b10a81bfe706f305e` — dedicated workflow expansion.
- `6accc318df7b3515e682b67f45445e01d7f3bacf` — central Requirements Contract gate.

## Doğrulama durumu

GitHub combined-status, workflow-target commit `6accc318df7b3515e682b67f45445e01d7f3bacf` için yine `statuses=[]` döndürdü. Exact Flutter/Actions SUCCESS görünmediği için `RC-0903/0904` DONE yapılmadı; evidence `done=false` kaldı.

## Açık blocker / sıradaki işler

1. Combined application service'i production runtime composition'a ve gerçek multi-select PDF builder UI'a bağla; approved font yokken sahte üretim yapma.
2. Multi-select UI'da yalnız aynı subject kind + stable subject ID kayıtlarını göster; record set değişince preview token invalid olsun.
3. Combined PDF için gerçek delivery/save/share zincirini preview token üzerinden bağla.
4. `RC-0905` için Vedik persisted PDF sistemi geldiğinde Western/Vedik system-kind isolation kanıtı oluştur; o zamana kadar sahiplenme.
5. Production Unicode PDF font artifact/lisans/SHA, full-parser/device-open, 5/25/50+ render ve visual regression blocker'larını açık tut.
6. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI referansları, Play/rewarded real-device ve clean-release kanıtlarına paralel devam et.

**FINAL: NO.**
