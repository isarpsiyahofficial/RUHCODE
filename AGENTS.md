# RUH CODE — AGENT / DEVELOPMENT RULES

Ruh Code için bağlayıcı ana sözleşme toplam **RC-0001 → RC-1442** kapsamıdır.

## Kaynaklar

- RC-0001 → RC-1420: [`RUH_CODE_MASTER_SARTNAME.md`](./RUH_CODE_MASTER_SARTNAME.md)
- RC-1421 → RC-1442: [`RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`](./RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md)
- Tek kapsam indexi: [`RUH_CODE_MASTER_INDEX.md`](./RUH_CODE_MASTER_INDEX.md)
- Bağımlılık sıralı çalışma planı: [`RUH_CODE_MASTER_TODO.md`](./RUH_CODE_MASTER_TODO.md)

Bu iki şartname dosyası birlikte tek ve bağlayıcı **1.442 maddelik Ruh Code MASTER şartnamesidir**.

## Zorunlu kurallar

- Kodlama, mimari, test, UI, veri modeli, hesaplama doğruluğu, yorum içeriği, offline çalışma, PDF, CSV, monetizasyon, güvenlik, accessibility, performans ve release kararları RC-0001 → RC-1442 kapsamına uymak zorundadır.
- Hiçbir RC maddesi açık proje kararı olmadan atlanamaz, silinemez, zayıflatılamaz veya kapsam dışı kabul edilemez.
- Yeni çalışma başlamadan önce ilgili RC maddeleri ve `RUH_CODE_MASTER_TODO.md` içindeki bağımlılık sırası kontrol edilmelidir.
- Bir özellik yalnız ekranı açıldığı veya kodu yazıldığı için tamamlanmış kabul edilemez; şartnamenin gerektirdiği test ve doğrulama kapıları da geçmelidir.
- Statik logo, ikon, zodiac/planet sembolleri, mandala, lotus ve dekoratif geometriler onaylı/versioned asset olarak kullanılmalıdır; uygulama sırasında gelişi güzel yeniden çizilmemelidir.
- Astroloji wheel, aspect, Vedik chart ve BaZi grid gibi veriye bağlı geometriler deterministik ve test edilmiş vector renderer ile üretilmelidir.
- Onaylı UI reference görselleri bağlayıcıdır; kod sırasında kafaya göre alternatif UI üretilmemelidir.
- Ana navigasyon `Bugün · Araçlar · Kayıtlar · Profil` olarak korunmalıdır; belirsiz `Hesapla` ana navigasyonu yeniden eklenmemelidir.
- `Bugünün Etkileri` gerçek tarih/saat/timezone/konum ve calculation core’dan hesaplanır; stok Günün Mesajı ile karıştırılamaz.
- Günün Mesajı runtime AI üretimi değildir; tarih anahtarlı lokal stoktur ve her release tarihinde ileriye en az on tam yıllık TR+EN kapsama sahip olmalıdır.
- Kritik hesaplama doğruluğu, Türkçe/İngilizce paritesi, offline davranış, Free/PRO erişimi, backup/restore, PDF, interaction ve accessibility ilgili şartlara göre korunmalıdır.
- Ruh Code’un çekirdek ürünü zorunlu backend/API maliyetine bağımlı hale getirilemez.
- Temiz GitHub checkout’undan signing secret dışında geliştirici makinesine özel gizli dosya gerektirmeden reproducible release build alınabilmelidir.
- Zorunlu şartlar eksikken veya kritik doğrulamalar kırmızı iken proje ya da modül `FINAL` olarak etiketlenemez.
- Şartname ile kod arasında çelişki varsa açıkça yeni proje kararı verilmedikçe şartname esas alınır.
