# Ruh Code automation checkpoint — production entitlement runtime wiring

## Bu turda yapılan gerçek işler

- `RuhCodeRuntime` production composition root eklendi.
- `SqfliteLocalDatabase` uygulama açılışından önce açılıyor.
- `LocalEntitlementSnapshotStore` gerçek SQLite veritabanına bağlandı.
- `PolicyEntitlementService`, `LocalRollbackResistantEntitlementClock` ile production runtime'a bağlandı.
- Tek `FeatureAccessGuard` uygulama shell'ine dependency olarak geçiriliyor.
- `RuhCodeApp` artık feature guard'ı `MainNavigationShell`'e aktarıyor.
- `main.dart` async bootstrap ile gerçek runtime'ı oluşturuyor.
- `Araçlar` alanındaki devre dışı placeholder kartları kaldırıldı.
- Batı Astrolojisi, Vedik Astroloji, Gezegen Saatleri, Numeroloji ve BaZi route girişleri canonical `RuhFeatureIds` kullanıyor.
- Route açılmadan `FeatureAccessGuard.forRoute()` çalışıyor.
- Açılan özellik ekranı da `FeatureAccessGuard.forUi()` ile ikinci yüzey doğrulaması yapıyor.
- Böylece UI ve route katmanı yerel premium boolean kullanmadan aynı `EntitlementService` kaynağına bağlandı.
- `test/ui/main_navigation_entitlement_wiring_test.dart` ile dört canonical bottom-nav hedefi ve guarded Batı Astrolojisi route akışı test sözleşmesine bağlandı.

## Commitler

- `3e69e723da46d647b6aef8cf8338cb691ac6f0b3` — production entitlement runtime
- `8035ff7b705cf71391b78164a2ca4e7d7c4bf600` — app-shell guard injection
- `4179957588c40e72780719242d60a86bee4a1fa1` — async runtime bootstrap
- `f3d8c8c3085098f77bc137d74c8d972f69d5dd69` — active guarded tools navigation
- `99b4b58ccded86120cdc2b302c2f7918ce40b2b3` — navigation entitlement widget tests
- `67211285ff95bf386e350c4d2f87aed78db2fe03` — test import correction

## Doğrulama durumu

GitHub combined-status exact latest commit için `statuses=[]` döndürdü. Bu nedenle Flutter/GitHub Actions SUCCESS kanıtı uydurulmadı ve ilgili RC maddeleri DONE'a yükseltilmedi.

## Sıradaki işler

1. Bu production composition root için structural/evidence validator ve mevcut entitlement CI workflow kapsamını `lib/main.dart`, `lib/src/app/**`, `lib/src/ui/navigation/**`, `test/ui/main_navigation_entitlement_wiring_test.dart` dosyalarını kapsayacak şekilde genişlet.
2. PRO-only gerçek bir route (professional clients veya PDF export) ekleyip locked/PRO/temporary yüzey davranışını widget testinde doğrula.
3. Service-level gerçek bir operation'ı `FeatureAccessGuard.runService()` üzerinden bağla; UI/route/service üç yüzeyin aynı feature ID ve entitlement snapshot ile davranmasını entegrasyon testine bağla.
4. Google Play ownership restore'u startup bootstrap'ta network/store erişilemezken cached ownership'i silmeyecek şekilde application coordinator üzerinden bağla.
5. Physical/UI/font blocker dışındaki PDF ve backup işlerine devam et.

## Final durumu

FINAL DEĞİL. Bu tur source-level production wiring ilerlemesidir; exact test/workflow kanıtı görülmeden requirement state yükseltilmez.
