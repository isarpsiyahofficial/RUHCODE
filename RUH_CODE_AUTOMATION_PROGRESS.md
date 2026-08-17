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
- Action registry onboarding/location, Western alt analizler, transit/synastry/return/progression akışları, Vedic detaylar, Chinese/BaZi, numeroloji alt ekranları, spiritüel, kişisel gelişim, profesyonel danışan alanı, ayarlar, backup ve PDF builder akışlarını kapsıyor.
- `tools/ui/validate_ui_contracts.py` geniş interactive screen source kümesini ACTIVE ACTION-ID varlığı açısından zorunlu tutuyor.
- Action type ve offline behavior enum sözleşmeleri validator tarafından kontrol ediliyor.
- `docs/DYNAMIC_GEOMETRY_CONTRACT.md` ve `ui/dynamic_geometry_manifest.csv` mevcut.
- Western natal/aspect/transit/synastry/composite, Vedic D1/D9/Varga, BaZi Pillars/Elements, Lo Shu/Pythagorean ve PDF Western/Vedic dinamik geometrileri için zorunlu `GEOM-*` sözleşmeleri tanımlı.
- Dinamik renderer'ın calculation core dışında yeniden hesap yapması yasaklandı; UI ve PDF aynı calculation snapshot kaynağını kullanmak zorunda.
- Dinamik geometry kayıtlarında calculation source, deterministic renderer contract ve `golden_required=true` validator şartı.
- Bu turda `tools/ui/report_action_coverage.py` eklendi. UI CI artık ekran/action source başına ACTIVE action sayısı, action type, offline davranış ve accessibility-label kapsamını CSV artifact olarak üretmek üzere yapılandırıldı.
- `ui/asset_manifest.csv` FONT_SANS / FONT_SERIF / FONT_SYMBOL sınıflarıyla genişletildi. Gerçek font dosyası, yeniden dağıtım lisansı, provenance ve hash olmadan APPROVED yapılamaz.
- `docs/STATIC_ASSET_CONTRACT.md` eklendi; logo/zodiac/planet/mandala/lotus/icon/Tarot/font gibi statik assetlerin dinamik calculation geometry’den ayrımı kilitlendi.
- `tools/ui/validate_static_assets.py` eklendi; zorunlu statik asset sınıfları ve üç font contract kaydı CI sözleşmesine bağlandı.
- Faz 4 için `ui/design_tokens.json` ve `docs/DESIGN_SYSTEM_CONTRACT.md` eklendi.
- Design token kaynağında AKİLES mantığıyla uyumlu warm ivory `#FBF8F3`, primary purple `#4C2A91`, strong purple `#6B42E6`, gold `#C89338`, text/muted/line renkleri, spacing/radius grid, typography asset ID’leri ve `Bugün · Araçlar · Kayıtlar · Profil` navigation contract sabitlendi.
- Minimum interactive touch target 48dp olarak kilitlendi; bu değer güncel Android accessibility guidance ile uyumludur.
- `tools/ui/validate_design_tokens.py` eklendi ve UI workflow design token drift kontrolüne genişletildi.
- Bu turdaki ana commitler: action report `550817293945baafb7533538836f09324f723ec7`, coverage artifact workflow `1f5b571de640fec8160063a619878e36d65a51cf`, font manifest `b911fa68f2573a57ec098045d2738db03a05cde7`, static asset contract `a15c844edb0b2e89729c0645fc8dcb5d92883ac3`, static validator `3e8b76a1cd79cebabe562de93f45342cf6a69579`, design tokens `b9f541f3abc37bc4ee045ddf48e597baa4235dd2`, design contract `295b6d2ccbeaa2e0c091c334b4fa0a65931a06d6`, token validator `dad65cf0c8b1c3ae6041fa24b7d2e5cddb5f9530`, UI workflow update `c4f769310999c39ea29e6c39dcbca772188aa1a4`.
- GitHub connector mevcut push-workflow run listesini bu turda doğrudan döndürmediği için yeni UI CI zincirinin SUCCESS kanıtı henüz yazılmadı. Sözleşme/validator değişiklikleri DONE olarak yükseltilmedi; bir sonraki tur exact commit üzerinde tekrar kontrol edecek.

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

## Faz 3 — uygulanmış ilerleme

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
- [x] Action coverage CSV artifact üretici kodlandı.
- [ ] En son UI workflow zincirinin GitHub Actions SUCCESS kanıtı connector üzerinden henüz alınamadı.
- [ ] 106 base referans ve 33 state referansı gerçek onaylı dosya + hash olmadığı için APPROVED değil.
- [ ] Logo/zodiac/planet/mandala/lotus/icon/Tarot/font gerçek asset dosyaları ve lisans/provenance henüz mevcut değil.
- [ ] Dynamic renderers henüz IMPLEMENTED/TESTED değil; yalnız SPECIFIED.

## Faz 4 — uygulanmış / açık

- [x] Machine-readable design token kaynağı oluşturuldu.
- [x] Primary purple / strong purple / gold / warm ivory / text / muted / line tokenları sözleşmeye bağlandı.
- [x] Spacing grid sözleşmeye bağlandı.
- [x] Radius sistemi sözleşmeye bağlandı.
- [x] Minimum 48dp touch target sözleşmeye bağlandı.
- [x] Semantic accessibility standardı dokümante edildi.
- [x] Ana navigation token contract sabitlendi.
- [x] Font asset sınıfları manifestte takip ediliyor.
- [x] Statik dekorasyonun runtime’da gelişi güzel yeniden çizilmesi yasaklandı.
- [ ] Gerçek logo SVG yok.
- [ ] Gerçek zodiac SVG seti yok.
- [ ] Gerçek planet SVG seti yok.
- [ ] Gerçek numeroloji ikon seti yok.
- [ ] Gerçek lotus/mandala SVG assetleri yok.
- [ ] Tarot asset lisansı/provenance henüz onaylı değil.
- [ ] Font dosyaları/lisansları/provenance henüz onaylı değil.
- [ ] Shadow tokenları semantik seviyede; gerçek renderer/app component değerleri uygulama iskeleti kurulunca doğrulanmalı.
- [ ] Onaylı asset hashleri gerçek dosyalar gelmeden doldurulmayacak.

## Sıradaki çalışma

1. Exact commit `c4f769310999c39ea29e6c39dcbca772188aa1a4` sonrası UI Contracts workflow sonucunu yeniden kontrol et; kırmızıysa validator/report/workflow zincirini düzelt.
2. UI action coverage artifact gerçekten oluşuyorsa artifact içeriğini doğrula ve progress kanıtına bağla.
3. Gerçek onaylı UI/asset dosyaları hâlâ yoksa PENDING bırak; sahte asset üretip APPROVED yapma.
4. Faz 4 structural token contract yeşil kanıtlandıktan sonra Faz 5 Flutter/offline-first proje iskeletine geç.
5. Faz 1 binary blocker sürüyorsa açık bırak; hesaplama golden dataset iddiası yapma.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 bilgi mimarisi ve geniş action sözleşmesi oluşturuldu. Faz 3 structural UI/action/geometry sözleşmeleriyle, Faz 4 ise design token ve static-asset/font sözleşmeleriyle ilerledi. Ancak en son UI CI success kanıtı, gerçek onaylı UI referans görselleri, gerçek production statik assetler ve gerçek renderer/application implementasyonları henüz tamamlanmadı. Production Flutter uygulama iskeletine henüz başlanmadı.
