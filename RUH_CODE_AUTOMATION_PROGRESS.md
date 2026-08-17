# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile daha önce kanıtlandı.
- Requirement tooling 1.442 benzersiz RC ID, deterministic classification, task/evidence sözleşmesi ve DONE-kanıt kapısını doğruluyor.
- Faz 1 kısmen ilerledi; AKİLES referans/runtime sınırı belgelendi. Binary ZIP gerektiren exact hash ve dataset dönüştürme işleri açık.
- Faz 2 temel bilgi mimarisi tamamlandı; `Bugün · Araçlar · Kayıtlar · Profil`, alt araç ağaçları, SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3 UI reference/action/asset altyapısı genişletildi.
- UI bilgi mimarisindeki **106 benzersiz SCREEN-ID'nin tamamı** `ui/reference_manifest.csv` içinde takip ediliyor ve gerçek dosya + SHA-256 + açık onay gelene kadar doğru biçimde `PENDING`.
- `ui/state_reference_manifest.csv` içinde **33 zorunlu ekran-state** takip ediliyor.
- Action registry bu turda onboarding/location, Western alt analizler, transit/synastry/return/progression akışları, Vedic detaylar, Chinese/BaZi, numeroloji alt ekranları, spiritüel, kişisel gelişim, profesyonel danışan alanı, ayarlar, backup ve PDF builder akışlarıyla ciddi biçimde genişletildi.
- `tools/ui/validate_ui_contracts.py` artık yalnız 18 öncelikli ekranı değil geniş bir **interactive screen source** kümesini ACTIVE ACTION-ID varlığı açısından zorunlu tutuyor.
- Action type ve offline behavior enum sözleşmeleri validator tarafından kontrol ediliyor.
- `docs/DYNAMIC_GEOMETRY_CONTRACT.md` ve `ui/dynamic_geometry_manifest.csv` eklendi.
- Western natal/aspect/transit/synastry/composite, Vedic D1/D9/Varga, BaZi Pillars/Elements, Lo Shu/Pythagorean ve PDF Western/Vedic dinamik geometrileri için zorunlu `GEOM-*` sözleşmeleri tanımlandı.
- Dinamik renderer'ın calculation core dışında yeniden hesap yapması yasaklandı; UI ve PDF aynı calculation snapshot kaynağını kullanmak zorunda.
- Dinamik geometry kayıtlarında calculation source, deterministic renderer contract ve `golden_required=true` artık CI validator şartı.
- Bu turdaki ana commitler: action expansion `fa4b60d27047eacb38b684868a372ebe26cfe7b1`, geometry manifest `0a32626a21c856ed02e1d1015b44b69260ec9066`, geometry contract `105ba08e634501dbcfda3ca3ba60f164a6ef0722`, validator hardening `1843f1235736b2fd7b4f646d9d3e7be879f62101`.
- GitHub connector bu turun sonunda push-workflow run durumunu doğrudan döndürmediği için son validator commitine **CI success kanıtı henüz yazılmadı**. Bu nedenle bu turdaki yeni kapsam maddeleri yalnız sözleşme/implementation-progress olarak kaydedildi; DONE/FINAL iddiası yapılmadı.

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
- [x] Ana ürün yolları için genişletilmiş action contract envanteri oluşturuldu.
- [ ] Gerçek UI semantic tree oluşmadan bütün mikro-clickable öğelerin exhaustive ACTION-ID eşlemesi final kabul edilemez.

## Faz 3 — kanıtlanmış / uygulanmış ilerleme

- [x] UI referans manifest formatı.
- [x] Static asset manifest formatı.
- [x] 106/106 SCREEN-ID structural reference coverage.
- [x] 33 mandatory state structural coverage.
- [x] APPROVED referans için repository path + SHA-256 zorunluluğu.
- [x] APPROVED asset için repository path + SHA-256 + license + provenance zorunluluğu.
- [x] Statik dekoratif asset ile dinamik calculation geometry ayrımı.
- [x] Geniş product workflow ACTION-ID registry sözleşmesi.
- [x] Interactive action-source validator kapısı kodlandı.
- [x] Dynamic geometry manifest ve renderer contract eklendi.
- [x] 14 zorunlu dynamic geometry contract kimliği tanımlandı.
- [x] Geometry calculation source / renderer mode / golden-required validator kapısı kodlandı.
- [ ] Son validator commitinin GitHub Actions success kanıtı henüz connector üzerinden alınamadı; sonraki turda ilk iş kontrol edilecek.
- [ ] 106 base referans ve 33 state referansı gerçek onaylı dosya + hash olmadığı için APPROVED değil.
- [ ] Logo/zodiac/planet/mandala/lotus/icon/Tarot/font gerçek asset dosyaları ve lisans/provenance henüz mevcut değil.
- [ ] Dynamic renderers henüz IMPLEMENTED/TESTED değil; yalnız SPECIFIED.

## Sıradaki çalışma

1. Exact commit `1843f1235736b2fd7b4f646d9d3e7be879f62101` sonrası UI Contracts sonucunu kontrol et; kırmızıysa validator/action registry/geometry manifesti düzelt.
2. Action registry için ekran başına action-count raporu ve coverage artifact üret; interactive source listesi ile registry arasındaki farkı CI çıktısında görünür kıl.
3. Statik asset manifestine FONT setini ve kullanım/lisans sınıflarını ekle; gerçek dosya gelmeden APPROVED yapma.
4. UI reference görselleri repository içine alınabilir hale geldiğinde yalnız birebir onaylı dosyaları hash'leyip APPROVED yap.
5. Faz 1 binary blocker sürüyorsa açık bırak ve Faz 4 design-token/data-model sözleşmesine geçmeden önce UI contract CI'ını yeşil kanıtla.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 bilgi mimarisi ve geniş action sözleşmesi oluşturuldu. Faz 3'te referans/state/asset altyapısına ek olarak dinamik geometry contract ve geniş interactive action coverage kapısı kodlandı; fakat son CI success kanıtı, gerçek onaylı UI dosyaları/assetler ve gerçek renderer implementasyonları henüz tamamlanmadı. Production uygulama kodlamasına başlanmadı.
