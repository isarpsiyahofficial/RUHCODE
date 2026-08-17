# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı ve CI ile kanıtlandı.
- `tools/requirements/validate_requirements.py` tam 1.442 sıralı/benzersiz RC sözleşmesini doğruluyor.
- `tools/requirements/classify_requirements.py` bütün requirement'ları deterministik olarak `CALC / CONTENT / UI / I18N / OFFLINE / ENTITLEMENT / BACKUP / PDF / SECURITY / A11Y / PERF / RELEASE` sınıflarına ayırıyor.
- `tools/requirements/build_requirement_matrix.py` her RC için task ID, durum, tag ve gerekli kanıt türünü üretiyor; `UNCLASSIFIED` veya `TBD` kanıt sözleşmesine izin vermiyor.
- `requirements/requirement_state.csv` yalnız gerçek ilerleme override'ları için kalıcı state deposu olarak korunuyor.
- `.github/workflows/requirements-contract.yml` bütün tag sınıflarının kullanıldığını, tag dışına çıkılmadığını, 1.442 satırın sınıflandırıldığını ve DONE durumunun kanıt linki olmadan kullanılamadığını kontrol ediyor.
- GitHub Actions `Requirements Contract` run #7, exact commit `d1c006950f6d5d5566331996bfcf43b99dd8316b` üzerinde başarıyla geçti.
- Faz 1 başlatıldı.
- `docs/AKILES_REFERENCE_CONTRACT.md` oluşturuldu; AKİLES'ten doğrulama amacıyla taşınabilecek hesaplama davranışları ile Ruh Code runtime'a taşınmayacak Cloudflare/D1/R2/admin/web katmanları ayrıldı.

## Faz 0 — kanıtlanmış tamamlanan görevler

- [x] `RC-0001 → RC-1442` için tek makine üretimli Requirement Traceability Matrix altyapısı oluşturuldu.
- [x] Matrix sözleşmesinin tam 1.442 benzersiz RC ID içermesi CI ile doğrulandı.
- [x] Eksik RC ID olduğunda validator/CI başarısız olacak.
- [x] Duplicate RC ID olduğunda validator/CI başarısız olacak.
- [x] Her RC için `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` durum sözleşmesi oluşturuldu.
- [x] Her RC için varsayılan benzersiz `TASK-RC-xxxx` eşlemesi oluşturuldu.
- [x] CALC etiketleme politikası tamamlandı.
- [x] CONTENT etiketleme politikası tamamlandı.
- [x] UI etiketleme politikası tamamlandı.
- [x] I18N etiketleme politikası tamamlandı.
- [x] OFFLINE etiketleme politikası tamamlandı.
- [x] ENTITLEMENT etiketleme politikası tamamlandı.
- [x] BACKUP etiketleme politikası tamamlandı.
- [x] PDF etiketleme politikası tamamlandı.
- [x] SECURITY etiketleme politikası tamamlandı.
- [x] A11Y etiketleme politikası tamamlandı.
- [x] PERF etiketleme politikası tamamlandı.
- [x] RELEASE etiketleme politikası tamamlandı.
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

## Sıradaki çalışma

Önce Faz 1'de erişilebilir kaynaklarla yapılabilen manifest/test-format altyapısını hazırlamaya devam et. AKİLES ZIP erişilebilir değilse Faz 1'in binary gerektirmeyen sözleşme işlerini tamamla ve ardından Faz 2 UI bilgi mimarisi için route/SCREEN-ID/action sözleşmesi iskeletini oluştur. ZIP yeniden erişilebilir olduğunda hash/envanter/dataset çıkarımına geri dön.

## Final durumu

**FINAL DEĞİL.** Faz 0 tamamlandı; Faz 1 kısmen ilerledi. Uygulama production kodlamasına başlanmadı.
