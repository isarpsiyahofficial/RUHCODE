# RUH CODE — MASTER ŞARTNAME EKİ

**Durum:** BAĞLAYICI / PROJE KURALLARI  
**Kapsam:** RC-1421 → RC-1442  
**Ana şartname:** [`RUH_CODE_MASTER_SARTNAME.md`](./RUH_CODE_MASTER_SARTNAME.md)  

Bu ek dosya ana şartnamenin devamıdır. `RC-0001–RC-1420` ile aşağıdaki `RC-1421–RC-1442` maddeleri birlikte tek ve bağlayıcı **1.442 maddelik Ruh Code MASTER şartnamesini** oluşturur. Bu ek ana şartnamedeki hiçbir maddeyi iptal etmez veya zayıflatmaz.

1421. “Bugünün Etkileri” sabit içerik olmayacak; kullanıcının bulunduğu veya aktif olarak seçtiği tarih, saat, timezone ve gerekli konum bilgisi üzerinden gerçek zamanlı hesaplanacak.
1422. Haftanın günü hiçbir yerde elle yazılmış takvim tablosundan alınmayacak; Gregorian takvim motorundan hesaplanacak. 16.08.2026 ile 16.08.2027 tamamen bağımsız günler olarak değerlendirilecek.
1423. Artık yıl sistemi eksiksiz uygulanacak; 29 Şubat yalnız gerçek artık yıllarda bulunacak ve günlük astroloji, numeroloji, gezegen saati, bildirim, günlük kayıt ve mesaj sistemlerinin tamamı 29 Şubat’ı destekleyecek.
1424. Günün mesajları runtime sırasında AI tarafından oluşturulmayacak; uygulamayla birlikte gelen önceden hazırlanmış bir günlük mesaj kataloğu olacak.
1425. İlk yayın paketinde en az 10 yıllık ileri günlük mesaj stoğu bulunacak. Başlangıç hedefi 2026–2036 dönemini tam kapsamak olacak.
1426. Türkçe ve İngilizce günlük mesaj stokları birbirinin makine çevirisi olmayacak. Başlangıç hedefinde 4.018 TR + 4.018 EN olmak üzere en az 8.036 tarih-dil mesaj kaydı bulunacak.
1427. Günlük mesaj kayıtları `YYYY-MM-DD` tarih anahtarıyla tutulacak; rastgele mesaj seçilip “bugünün mesajı” diye gösterilmeyecek.
1428. Tarihe özel stok mesaj ile kişisel astrolojik/numerolojik etki birbirinden ayrılacak. Stok mesaj “günün temel mesajını”, calculation core ise kullanıcıya özel “Bugünkü Etkilerim” bölümünü oluşturacak.
1429. Statik geometrik şekiller, mandalalar, ikonlar, zodiac sembolleri, dekoratif orbitler ve benzeri grafikler kod içerisinde gelişi güzel elle çizilmeyecek; önceden onaylanmış SVG/vector asset olarak uygulamaya eklenecek.
1430. Astroloji çarkı, aspect çizgileri, Vedik chart, BaZi grid gibi veriye göre değişmek zorunda olan geometriler statik resim olmayacak; matematiksel vector renderer ile üretilecek ve golden görüntü testlerinden geçecek.
1431. Onaylanan Ruh Code UI görselleri referans tasarım kabul edilecek; gerçek ekranlar ölçü, boşluk, typography, kart yapısı, ikon, renk, yerleşim ve hiyerarşi açısından görsel regresyon testleriyle karşılaştırılacak.
1432. Alt navigasyondaki belirsiz “Hesapla” kaldırılacak. Ana navigasyon **Bugün · Araçlar · Kayıtlar · Profil** olacak. Araçlar altında neyin hesaplandığı açıkça kategorilere ayrılacak.
1433. Her release tarihinde uygulamanın önünde en az 10 tam yıllık Günün Mesajı stoğu bulunmak zorunda. Takvim stoğu zaman ilerledikçe ileri taşınacak; sabit 2026–2036 aralığıyla kalınmayacak.
1434. Günlük mesaj kataloğunda kapsanan her `YYYY-MM-DD` tarihi için tam olarak bir TR ve bir EN kayıt bulunacak. Eksik tarih, aynı tarih için çift kayıt, boş mesaj veya yanlış tarih anahtarı release blocker olacak.
1435. Ruh Code’un desteklediği tarih aralığı kesin tanımlanacak. Ana hedef en az **1890–2110** olacak. Daha dar çalışan bir motor varsa kullanıcıya açıkça belirtilecek ve sahte sonuç üretilmeyecek.
1436. Her matematiksel motor için ölçülebilir doğruluk toleransı belirlenecek. Gezegen boylamı, ASC/MC, house cusp, sunrise/sunset, planetary hour, Nakshatra/Pada ve benzeri hesapların ayrı toleransları olacak; “yaklaşık doğru” final kriteri olmayacak.
1437. Ephemeris, IANA timezone, şehir/koordinat ve gerekli diğer lokal veri setleri uygulamanın içinde versiyonlanmış, checksum’lı ve offline kullanılabilir olacak. Hangi sürümün hangi release’de kullanıldığı bilinecek.
1438. Logo, zodiac sembolleri, gezegen sembolleri, mandalalar, lotus/geometrik şekiller, Tarot görselleri, ikonlar ve fontlar dahil bütün statik görsel varlıklar onaylı kaynak dosyalarıyla repository’de bulunacak. Kod sırasında gelişi güzel yeniden çizilmeyecek.
1439. Onaylanan bütün UI ekranları ve önemli state’leri repository içinde referans görsel olarak saklanacak. Her görsel ekran ID’si, sürümü ve hash’i taşıyacak; gerçek uygulama bu referanslara karşı visual regression testinden geçecek.
1440. Uygulamadaki her dokunulabilir öğenin navigation/action sözleşmesi bulunacak. Buton, ikon, chevron, kart, sekme veya menü olup hiçbir şey yapmayan öğe bulunamayacak; belirsiz navigasyon isimleri kullanılmayacak.
1441. Accessibility zorunlu olacak. Minimum dokunma alanları, kontrast, dinamik yazı boyutu, screen-reader etiketleri, yalnız renkle bilgi verme yasağı ve büyük fontta taşmama final testine dahil edilecek.
1442. Ruh Code release’i temiz bir GitHub checkout’undan yeniden üretilebilir olmak zorunda. Signing secret dışında build için gerekli kod, veri, UI referansı, ikon, font, ephemeris, timezone verisi, mesaj kataloğu ve configuration repository’de veya kilitli/yasal bağımlılık olarak tanımlı olacak; geliştiricinin bilgisayarında bulunan gizli bir dosyaya bağımlı build kabul edilmeyecek.
