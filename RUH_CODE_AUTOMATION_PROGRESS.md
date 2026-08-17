# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile kanıtlandı.
- Requirement tooling 1.442 benzersiz RC ID, deterministic classification, task/evidence sözleşmesi ve DONE-kanıt kapısını doğruluyor.
- Faz 1 kısmen ilerledi; AKİLES referans/runtime sınırı belgelendi. Binary ZIP gerektiren exact hash ve dataset dönüştürme işleri açık.
- Faz 2 temel bilgi mimarisi tamamlandı; `Bugün · Araçlar · Kayıtlar · Profil`, alt araç ağaçları, SCREEN-ID ve temel ACTION-ID sözleşmesi CI ile doğrulandı.
- Faz 3 UI reference/action/asset altyapısı kurulmuş durumda ve bu turda kapsama sertleştirildi.
- UI bilgi mimarisindeki **106 benzersiz SCREEN-ID'nin tamamı** `ui/reference_manifest.csv` içine alındı. Hepsi gerçek dosya + SHA-256 + açık onay gelene kadar bilinçli olarak `PENDING`.
- Eksik SCREEN-ID artık yalnız raporlanmıyor; `tools/ui/validate_ui_contracts.py` bunu CI hatası yapıyor. Dolayısıyla reference-manifest structural coverage artık **106/106** olmak zorunda.
- `ui/action_registry.csv` 19 temel aksiyondan **67 aksiyona** genişletildi.
- Bugün, Araçlar, Astroloji, Batı giriş/chart, Vedik giriş/D1, Numeroloji, Gezegen Saatleri, Kayıtlar, Danışanlar, Profil, Ayarlar, Backup, PDF ve PDF Preview için öncelikli action-source coverage bağlandı.
- Validator 18 öncelikli action-source ekranının tamamında action coverage zorunlu kılıyor.
- Her action için accessibility etiketi sözleşmesi doğrulanıyor.
- Exact commit `ebf49aa8608c7dd61f1a05bdf08d68436da8a876` üzerinde `UI Contracts` run `32063203702` **success** ile tamamlandı.
- Aynı exact commit üzerinde `Requirements Contract` run `32063203699` **success** ile tamamlandı.

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
- [x] UI Contracts exact commit `ebf49aa8608c7dd61f1a05bdf08d68436da8a876` üzerinde yeşil geçti.
- [ ] 106 referansın hiçbiri henüz gerçek onaylı dosya + hash olmadığı için APPROVED değil; PENDING olması bilinçli ve doğru.
- [ ] Default dışındaki FREE/PRO/EMPTY/ERROR/OFFLINE/LOCKED gibi ekran-state referansları henüz exhaustive manifestte değil.
- [ ] SCREEN-ID başına bütün mikro-action envanteri henüz exhaustive değil.
- [ ] Logo/zodiac/planet/mandala/lotus/icon/Tarot gerçek asset dosyaları ve lisans/provenance henüz mevcut değil.

## Sıradaki çalışma

1. Faz 3'te `state manifest` sözleşmesini ekle: hangi ekranların DEFAULT dışında FREE/PRO/EMPTY/ERROR/OFFLINE/LOCKED state referansı gerektirdiğini makine-okunabilir hale getir.
2. Reference validator'a zorunlu state coverage kontrolü ekle; state dosyaları gerçek görsel ve açık onay gelene kadar PENDING kalmalı.
3. Action registry'yi onboarding/location, Western alt ekranlar, transit/synastry, Vedic detaylar, BaZi, spiritüel ve kişisel gelişim yollarında genişlet.
4. Statik assetler gerçek dosya/lisans/provenance olmadan APPROVED yapılmasın.
5. Faz 1 binary blocker devam ediyorsa açık bırak ve Faz 3/4 sözleşme altyapısında ilerle.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 temel bilgi mimarisi doğrulandı. Faz 3'te bütün 106 ekran artık manifest tarafından izleniyor ve öncelikli action coverage CI ile zorunlu; fakat gerçek referans görseller, ekran-state kapsamı ve gerçek statik assetler henüz tamamlanmadı. Production uygulama kodlamasına başlanmadı.
