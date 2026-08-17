# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile kanıtlandı.
- Requirement tooling 1.442 benzersiz RC ID, deterministic classification, task/evidence sözleşmesi ve DONE-kanıt kapısını doğruluyor.
- Faz 1 kısmen ilerledi; AKİLES referans/runtime sınırı belgelendi. Binary ZIP gerektiren exact hash ve dataset dönüştürme işleri açık.
- Faz 2 temel bilgi mimarisi tamamlandı; `Bugün · Araçlar · Kayıtlar · Profil`, alt araç ağaçları, SCREEN-ID ve temel ACTION-ID sözleşmesi CI ile doğrulandı.
- Faz 3 UI reference/action/asset **altyapısı** bu turda oluşturuldu.
- `docs/UI_REFERENCE_CONTRACT.md` eklendi; RC-1429/1430/1431/1438/1439/1440/1441 için statik asset, dinamik geometri, referans görsel, action ve accessibility sözleşmesi bağlandı.
- `ui/reference_manifest.csv` eklendi. Mevcut konsept ekranlar bilinçli olarak `PENDING`; gerçek dosya + SHA-256 + açık onay olmadan `APPROVED` yapılamaz.
- `ui/action_registry.csv` eklendi; dört ana navigasyon, Araçlar ana kategorileri, Astroloji giriş yolları, Kayıtlar ve Profil/PDF temel aksiyonları makine-okunabilir hale getirildi.
- `ui/asset_manifest.csv` eklendi; logo, zodiac/planet glyph, mandala/lotus, genel ikon ve Tarot assetleri `PENDING` olarak izleniyor. Lisans/provenance doğrulanmadan APPROVED olamaz.
- `tools/ui/validate_ui_contracts.py` eklendi; duplicate/unknown SCREEN-ID, duplicate ACTION-ID, hedefi olmayan action, APPROVED referans/asset path+hash eksikliği, asset license/provenance eksikliği ve hash mismatch durumlarını engelliyor.
- `.github/workflows/ui-contracts.yml` eklendi.
- GitHub Actions `UI Contracts` run #1 exact commit `f150fd67322545171a5fa476e6712984113dcc16` üzerinde **success** ile tamamlandı.

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
- [ ] Bütün ekran içi mikro aksiyonların exhaustive ACTION-ID envanteri, her ekranın onaylı referansı üretildikçe genişletilecek.

## Faz 3 — bu turdaki kanıtlanmış ilerleme

- [x] UI referans manifest formatı oluşturuldu.
- [x] UI action registry formatı oluşturuldu.
- [x] Static asset manifest formatı oluşturuldu.
- [x] APPROVED referans için repository path + SHA-256 zorunlu hale getirildi.
- [x] APPROVED asset için repository path + SHA-256 + license + provenance zorunlu hale getirildi.
- [x] Static geometry ile calculation-data'ya bağlı dynamic geometry ayrımı bağlayıcı sözleşmeye yazıldı.
- [x] Dört ana navigation action'ı registry/CI ile zorunlu hale getirildi.
- [x] UI contract validator CI'da yeşil geçti.
- [ ] Bütün SCREEN-ID'ler için referans görseller repository'ye henüz eklenmedi.
- [ ] PENDING referansların kullanıcı/design onayı alınmadan APPROVED yapılmayacak.
- [ ] Mevcut konsept görsellerin kaynak dosyaları GitHub repository içinde bulunmadığı için hash'li onay verilemedi.
- [ ] SCREEN-ID başına bütün mikro-action envanteri referans ekranlarla beraber tamamlanacak.
- [ ] Logo/zodiac/planet/mandala/lotus/icon/Tarot gerçek asset dosyaları ve lisans/provenance henüz mevcut değil.

## Sıradaki çalışma

1. Faz 3'te SCREEN-ID coverage üreticisi/validator'ı ekle: IA'daki ekranlar ile referans manifest kapsamını sayısal raporla ve eksik ekranları açıkça listele; PENDING'in DONE olmadığını koru.
2. Referans dosyaları mevcut değilse tasarım dosyası uydurup APPROVED yapma. Bunun yerine ekran spec/state sözleşmelerini genişlet.
3. Exhaustive action registry'yi Today, Tools, Western Input/Chart, Vedic D1, Numerology, Planetary Hours, Clients, PDF ve Settings referans ekranlarından başlayarak genişlet.
4. Statik assetler gerçek dosya/lisans/provenance olmadan APPROVED yapılmasın.
5. Faz 1 binary blocker devam ediyorsa açık bırak ve Faz 3/4 altyapısında ilerle.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 temel bilgi mimarisi doğrulandı; Faz 3'ün manifest/CI altyapısı yeşil fakat referans görsel ve gerçek asset üretim/onay kapsamı tamamlanmadı. Production uygulama kodlamasına başlanmadı.
