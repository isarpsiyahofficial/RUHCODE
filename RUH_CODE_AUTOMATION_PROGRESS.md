# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile kanıtlandı.
- `tools/requirements/validate_requirements.py` tam 1.442 sıralı/benzersiz RC sözleşmesini doğruluyor.
- `tools/requirements/classify_requirements.py` bütün requirement'ları deterministik olarak `CALC / CONTENT / UI / I18N / OFFLINE / ENTITLEMENT / BACKUP / PDF / SECURITY / A11Y / PERF / RELEASE` sınıflarına ayırıyor.
- `tools/requirements/build_requirement_matrix.py` her RC için task ID, durum, tag ve gerekli kanıt türünü üretiyor; `UNCLASSIFIED` veya `TBD` kanıt sözleşmesine izin vermiyor.
- `requirements/requirement_state.csv` yalnız gerçek ilerleme override'ları için kalıcı state deposu olarak korunuyor.
- `.github/workflows/requirements-contract.yml` 1.442 satırın sınıflandırıldığını ve DONE durumunun kanıt linki olmadan kullanılamadığını kontrol ediyor.
- GitHub Actions `Requirements Contract` run #7 exact commit `d1c006950f6d5d5566331996bfcf43b99dd8316b` üzerinde başarıyla geçti.
- Faz 1 kısmen ilerledi.
- `docs/AKILES_REFERENCE_CONTRACT.md` oluşturuldu; AKİLES'ten doğrulama amacıyla taşınabilecek hesaplama davranışları ile Ruh Code runtime'a taşınmayacak Cloudflare/D1/R2/admin/web katmanları ayrıldı.
- Faz 2 temel bilgi mimarisi oluşturuldu.
- `docs/UI_INFORMATION_ARCHITECTURE.md` dört ana navigasyonu (`Bugün · Araçlar · Kayıtlar · Profil`), Astroloji/Numeroloji/Spiritüel/Kişisel Gelişim alt ağaçlarını, profesyonel kayıt alanını, SCREEN-ID'leri ve temel ACTION-ID sözleşmesini tanımlıyor.
- `tools/ui/validate_information_architecture.py` aynı SCREEN-ID'nin iki farklı route'a bağlanmasını, eksik ana navigation/action sözleşmesini ve action hedefi olmayan ekran referansını engelliyor.
- `.github/workflows/ui-information-architecture.yml` eklendi.
- İlk UI IA CI çalışması duplicate-reference validator hatasını yakaladı; validator düzeltildi.
- GitHub Actions `UI Information Architecture` run #2 exact commit `73c7851b1c6cac5244e61c804087b53d5aa84a21` üzerinde başarıyla geçti.

## Faz 0 — kanıtlanmış tamamlanan görevler

- [x] `RC-0001 → RC-1442` için tek makine üretimli Requirement Traceability Matrix altyapısı oluşturuldu.
- [x] Matrix sözleşmesinin tam 1.442 benzersiz RC ID içermesi CI ile doğrulandı.
- [x] Eksik RC ID olduğunda validator/CI başarısız olacak.
- [x] Duplicate RC ID olduğunda validator/CI başarısız olacak.
- [x] Her RC için `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` durum sözleşmesi oluşturuldu.
- [x] Her RC için varsayılan benzersiz `TASK-RC-xxxx` eşlemesi oluşturuldu.
- [x] CALC / CONTENT / UI / I18N / OFFLINE / ENTITLEMENT / BACKUP / PDF / SECURITY / A11Y / PERF / RELEASE etiketleme politikaları tamamlandı.
- [x] Her RC için gerekli kanıt türü deterministik olarak tanımlandı.
- [x] `UNCLASSIFIED` ve `TBD` evidence CI tarafından yasaklandı.
- [x] Kanıt bağlantısı bulunmayan bir RC'nin `DONE` olmasını engelleyen sözleşme korundu.

## Faz 1 — mevcut ilerleme

- [x] AKİLES'in Ruh Code için referans rolü tanımlandı; doğrudan runtime kopyası olmayacağı kilitlendi.
- [x] Taşınabilecek doğrulama davranışları belirlendi: global konum, koordinat, IANA timezone, tarihsel saat dönüşümü, Lahiri, Whole Sign, graha, Rahu/Ketu, Nakshatra/pada, saat bilinmiyor davranışı ve calculation/content ayrımı.
- [x] Ruh Code runtime'a taşınmayacak web altyapısı belirlendi: Cloudflare Worker, D1, R2, admin, SEO/sitemap, ürün satış akışları, web medya/yedekleme bindingleri.
- [x] Lisansı doğrulanmamış AKİLES dependency/veri setlerinin runtime'a otomatik taşınması yasaklandı.
- [ ] AKİLES V96 Final 28 ZIP binary paketi aktif çalışma alanında bulunmadığı için exact SHA-256 manifesti çıkarılamadı.
- [ ] Exact aktif JS/CSS/ephemeris/timezone dosya envanteri ZIP yeniden erişilebilir olduğunda çıkarılacak.
- [ ] 25.000+ Vedik doğrulama dataseti fiziksel referans test formatına dönüştürülecek.
- [ ] 6.400+ planetary-hour dataseti fiziksel referans test formatına dönüştürülecek.

## Faz 2 — mevcut ilerleme

- [x] Ana navigasyon `Bugün · Araçlar · Kayıtlar · Profil` olarak sözleşmeye bağlandı.
- [x] Belirsiz `Hesapla` ana navigasyonundan vazgeçildi.
- [x] Araçlar altında Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim ayrımı tanımlandı.
- [x] Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri yolları açık tanımlandı.
- [x] Numeroloji alt yolları tanımlandı.
- [x] Kayıtlar altında Profillerim / Danışanlarım ayrımı tanımlandı.
- [x] Profesyonel çalışma alanı ana alt navigasyonu kalabalıklaştırmadan Kayıtlar içine yerleştirildi.
- [x] Ana ve alt ekranlar için benzersiz SCREEN-ID sözleşmesi oluşturuldu.
- [x] Temel dokunulabilir navigasyonlar için ACTION-ID sözleşmesi oluşturuldu.
- [x] UI bilgi mimarisi CI kapısı yeşil.
- [ ] Bütün ekran içi mikro aksiyonların exhaustive ACTION-ID envanteri Faz 3 referans ekranlarıyla birlikte genişletilecek.

## Sıradaki çalışma

AKİLES ZIP erişilebilir değilse Faz 1'in binary gerektiren dört maddesini açık bırak. Faz 2'de exhaustive mikro-action registry için altyapıyı genişlet ve Faz 3 için referans görsel manifest/specification yapısını kur. Onaylı UI görselleri repository'ye eklendikçe SCREEN-ID + asset hash + state eşlemesini CI ile zorunlu hale getir.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmi; Faz 2 temel bilgi mimarisi CI ile doğrulandı. Production uygulama kodlamasına başlanmadı.
