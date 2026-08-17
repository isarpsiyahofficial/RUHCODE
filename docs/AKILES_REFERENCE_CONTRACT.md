# AKİLES → RUH CODE REFERANS SÖZLEŞMESİ

**Durum:** Faz 1 referans ayrıştırması  
**Amaç:** AKİLES'i Ruh Code için doğrulama kaynağı olarak kullanmak; web uygulamasını veya backend mimarisini kopyalamamak.

## Kaynakta doğrulanmış hesaplama davranışları

AKİLES V96 uygulama raporunda Vedik Doğum Haritası katmanında aşağıdaki davranışların bulunduğu doğrulanmıştır:

- Global doğum yeri araması.
- Koordinat kullanımı.
- IANA zaman dilimi kullanımı.
- Tarihsel saat dönüşümü.
- Lahiri ayanāṃśası.
- Whole Sign ev sistemi.
- Gezegen hesapları.
- Rahu/Ketu.
- Nakshatra ve pada.
- Doğum saati bilinmiyor güvenli davranışı.
- Matematiksel hesap çekirdeğinin düzenlenebilir içerik/metin katmanından ayrılması.

Bu maddeler Ruh Code'da doğrudan kod kopyalama talimatı değildir. Bunlar Ruh Code'un bağımsız hesaplama motorunun regression/golden doğrulama hedefleridir.

## Ruh Code'a taşınabilecek bilgi ve davranış sınıfları

1. Tarih + saat + yer → koordinat + IANA timezone çözümleme mantığı.
2. Tarihsel timezone/DST dönüşüm prensipleri.
3. Lahiri/Chitrapaksha ayanāṃśa doğrulama örnekleri.
4. Whole Sign Vedik ev yerleşim doğrulama örnekleri.
5. Graha, Rahu/Ketu, Nakshatra ve pada sonuçları için golden test vakaları.
6. Doğum saati bilinmiyor olduğunda saat gerektiren sonuçları uydurmama davranışı.
7. Matematiksel sonuç ile yorum/içerik katmanının ayrılması ilkesi.
8. AKİLES'te daha önce doğrulanmış planetary-hour ve zaman-dilimi test sonuçları, kaynak paket erişilebilir olduğunda regression datasetine dönüştürülecek.

## Ruh Code runtime'a taşınmayacak sınıflar

Aşağıdakiler AKİLES web ürününün altyapısıdır ve Ruh Code'un offline-first mobil runtime'ına kopyalanmayacaktır:

- Cloudflare Worker.
- D1 veritabanı.
- R2 depolama.
- Web admin paneli ve gizli admin slugları.
- Public/admin canlı içerik senkronizasyonu.
- Web SEO/sitemap/Product schema katmanları.
- Web ürün kataloğu, WhatsApp/Instagram satış akışları ve QR ürün akışı.
- Çerez/KVKK web katmanı.
- Web medya yönetimi ve web yedekleme bindingleri.

Ruh Code bu katmanlardan bağımsız, cihaz üzerinde çalışan kendi veri modeli, hesaplama çekirdeği, CSV backup/restore ve PDF motoruna sahip olacaktır.

## Lisans ve bağımlılık kuralı

AKİLES'te doğrulama amacıyla kullanılmış bir kütüphane, veri seti veya referans servis Ruh Code runtime'ına otomatik olarak alınamaz. Her kaynak için yeniden dağıtım/ticari kullanım lisansı ayrıca doğrulanacaktır. Lisans belirsizse kaynak yalnız test karşılaştırması için kullanılacak, runtime dependency yapılmayacaktır.

## Golden baseline politikası

- AKİLES'te doğrulanmış bir giriş/sonuç çifti, aynı hesaplama parametreleri korunarak Ruh Code golden testine çevrilebilir.
- Ruh Code sonucu tolerans dışına çıkarsa fark açıklanmadan baseline güncellenemez.
- Yeni algoritma bilinçli olarak farklılaştırılmışsa eski ve yeni metodoloji dokümante edilmelidir.
- AKİLES'teki web UI sonucu değil, matematiksel değerler baseline kabul edilir.

## Kaynak paket erişim durumu

Bu sözleşme eldeki doğrulanmış `AKILES-V96-UYGULAMA-RAPORU.txt` içeriğine dayanarak oluşturulmuştur. Nihai V96 Final 28 ZIP'in binary içeriği bu çalıştırmada aktif dosya alanında bulunmadığından aşağıdaki Faz 1 işleri henüz DONE değildir:

- ZIP SHA-256 manifesti.
- Aktif JS/CSS/ephemeris/timezone dosyalarının exact dosya envanteri.
- 25.000+ Vedik datasetin fiziksel olarak repo referans test formatına dönüştürülmesi.
- 6.400+ planetary-hour datasetin fiziksel olarak repo referans test formatına dönüştürülmesi.

ZIP tekrar erişilebilir olduğunda ilk iş read-only hash/envanter çıkarmak olacak; AKİLES kaynaklarının Ruh Code production kaynak ağacına topluca kopyalanması yasaktır.
