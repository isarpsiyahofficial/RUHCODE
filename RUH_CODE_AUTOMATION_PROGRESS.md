# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile kanıtlandı.
- Requirement tooling 1.442 benzersiz RC ID, deterministic classification, task/evidence sözleşmesi ve DONE-kanıt kapısını doğruluyor.
- Faz 1 kısmen ilerledi; AKİLES referans/runtime sınırı belgelendi. Binary ZIP gerektiren exact hash ve dataset dönüştürme işleri açık.
- Faz 2 temel bilgi mimarisi tamamlandı; `Bugün · Araçlar · Kayıtlar · Profil`, alt araç ağaçları, SCREEN-ID ve temel ACTION-ID sözleşmesi CI ile doğrulandı.
- Faz 3 UI reference/action/asset altyapısı kurulmuş durumda ve bu turda hem ekran kapsamı hem zorunlu state kapsamı sertleştirildi.
- UI bilgi mimarisindeki **106 benzersiz SCREEN-ID'nin tamamı** `ui/reference_manifest.csv` içine alındı. Hepsi gerçek dosya + SHA-256 + açık onay gelene kadar bilinçli olarak `PENDING`.
- Eksik SCREEN-ID artık CI hatası; structural reference coverage **106/106** olmak zorunda.
- `ui/action_registry.csv` **67 açık action contract** içeriyor.
- Bugün, Araçlar, Astroloji, Batı giriş/chart, Vedik giriş/D1, Numeroloji, Gezegen Saatleri, Kayıtlar, Danışanlar, Profil, Ayarlar, Backup, PDF ve PDF Preview için öncelikli action-source coverage bağlandı.
- `ui/state_reference_manifest.csv` eklendi ve **33 zorunlu ekran-state** sözleşmesi oluşturuldu.
- Free/PRO/OFFLINE/FREE_LOCKED/TEMP_UNLOCKED/UNKNOWN_BIRTH_TIME/VALIDATION_ERROR/PARTIAL_UNKNOWN_TIME/POLAR_UNAVAILABLE/EMPTY/ERROR gibi kritik state'ler makine-okunabilir biçimde izleniyor.
- State referansları gerçek görsel + SHA-256 + açık onay olmadan APPROVED yapılamıyor; şu an doğru şekilde `PENDING`.
- `tools/ui/validate_ui_contracts.py` eksik 106-screen coverage, eksik 33-state coverage ve eksik 18-priority action-source coverage durumlarında CI'ı kırıyor.
- Exact commit `ebf49aa8608c7dd61f1a05bdf08d68436da8a876` üzerinde `UI Contracts` run `32063203702` ve `Requirements Contract` run `32063203699` **success**.
- Exact commit `a6950aa5541fe6cbe1f313874d9e8b71c3983c3e` üzerinde `UI Contracts` job `95489466281` **success**; mandatory UI state coverage validator adımı geçti.

## Kanıtlanmış tamamlanan Faz 0

- [x] RC-0001→RC-1442 exact sıra/benzersizlik sözleşmesi.
- [x] Requirement state sözleşmesi.
- [x] Task/evidence eşlemesi.
- [x] CALC/CONTENT/UI/I18N/OFFLINE/ENTITLEMENT/BACKUP/PDF/SECURITY/A11Y/PERF/RELEASE sınıflandırması.
- [x] Kanıtsız DONE yasağı.

## Faz 1 — açık kalanlar

- [x] AKİLES referans rolü ve runtime sınırı.
- [x] Taşınabilecek doğrulama davranışları belirlendi.
- [x] Cloudflare/D1/R2/admin/web alanlarının Ruh Code runtime'a taşınmaması kilitlendi.
- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket aktif repository/workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone dosya envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.

## Faz 2 — durum

- [x] Ana navigasyon ve alt bilgi mimarisi.
- [x] SCREEN-ID sözleşmesi.
- [x] Temel ACTION-ID sözleşmesi.
- [x] UI IA CI kapısı.
- [ ] Bütün ekran içi mikro aksiyonların exhaustive ACTION-ID envanteri henüz tamamlanmadı; referans ekran/state sözleşmeleri ilerledikçe genişletilecek.

## Faz 3 — kanıtlanmış ilerleme

- [x] UI referans manifest formatı oluşturuldu.
- [x] UI action registry formatı oluşturuldu.
- [x] Static asset manifest formatı oluşturuldu.
- [x] APPROVED referans için repository path + SHA-256 zorunlu hale getirildi.
- [x] APPROVED asset için repository path + SHA-256 + license + provenance zorunlu hale getirildi.
- [x] Static geometry ile calculation-data'ya bağlı dynamic geometry ayrımı bağlayıcı sözleşmeye yazıldı.
- [x] Dört ana navigation action'ı registry/CI ile zorunlu hale getirildi.
- [x] **Bütün 106 SCREEN-ID reference manifest tarafından takip ediliyor.**
- [x] Eksik SCREEN-ID reference coverage CI failure haline getirildi.
- [x] Öncelikli 18 ekran için action-source coverage CI failure haline getirildi.
- [x] Action registry 67 açık action contract'a genişletildi.
- [x] **33 zorunlu Free/PRO/offline/error/unknown-time state state manifest tarafından takip ediliyor.**
- [x] Eksik zorunlu state coverage CI failure haline getirildi.
- [x] Mandatory state validator exact commit `a6950aa5541fe6cbe1f313874d9e8b71c3983c3e` üzerinde yeşil geçti.
- [ ] 106 base referans ve 33 state referansı henüz gerçek onaylı dosya + hash olmadığı için APPROVED değil; PENDING olması bilinçli ve doğru.
- [ ] SCREEN-ID başına bütün mikro-action envanteri henüz exhaustive değil.
- [ ] Logo/zodiac/planet/mandala/lotus/icon/Tarot gerçek asset dosyaları ve lisans/provenance henüz mevcut değil.

## Sıradaki çalışma

1. Action registry'yi onboarding/location, Western alt ekranlar, transit/synastry, Vedic detaylar, BaZi, spiritüel ve kişisel gelişim yollarında genişlet.
2. `ACTION-ID` kapsamını ekran başına ölçen coverage raporu üret ve hedeflenen navigation/form ekranlarında sıfır action olmasını CI hatası yap.
3. UI asset sözleşmesini `static decorative` ve `dynamic calculation geometry` sınıfları için ayrı manifest/renderer-contract seviyesine sertleştir.
4. Gerçek statik assetler repository'ye girene kadar APPROVED yapma; lisans/provenance zorunlu kalmalı.
5. Faz 1 binary blocker devam ediyorsa açık bırak ve Faz 3/4 sözleşme altyapısında ilerle.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 temel bilgi mimarisi doğrulandı. Faz 3'te 106/106 ekran, 33 zorunlu state ve 18 öncelikli action-source artık CI tarafından zorunlu tutuluyor; fakat gerçek referans görseller, exhaustive mikro-action kapsamı ve gerçek statik assetler henüz tamamlanmadı. Production uygulama kodlamasına başlanmadı.
