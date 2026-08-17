# RUH CODE — DYNAMIC GEOMETRY CONTRACT

**Kapsam:** RC-1429, RC-1430, RC-1431, RC-1438, RC-1439  
**Durum:** Bağlayıcı renderer sözleşmesi

## Amaç

Ruh Code içinde iki farklı görsel sınıfı kesin olarak ayrılır:

1. **Statik tasarım varlıkları:** logo, zodiac glyph seti, gezegen glyph seti, mandala, lotus, uygulama ikonları, Tarot sanatları ve benzeri tasarım öğeleri. Bunlar `ui/asset_manifest.csv` üzerinden onaylı dosya + SHA-256 + lisans + provenance ile yönetilir. Kod içinde gelişi güzel yeniden çizilmez.
2. **Hesaplama verisine bağlı dinamik geometri:** natal chart, aspect çizgileri, transit/synastry/composite çarkları, Vedik D1/D9/Varga chartları, BaZi sütun/grid yapıları ve hesaplanan numeroloji görselleri. Bunlar sabit PNG/SVG sonucu değildir; doğrulanmış calculation snapshot'tan deterministik renderer ile üretilir.

## Zorunlu kurallar

- Dinamik renderer hiçbir astronomik/numerolojik değeri kendi içinde yeniden hesaplayamaz; yalnız calculation core tarafından verilen doğrulanmış snapshot nesnesini tüketir.
- UI renderer ve PDF renderer aynı calculation snapshot kimliğini kullanmalıdır. Aynı hesap için ekranda başka, PDF'de başka derece/yerleşim gösterilemez.
- `0°..360°` dönüşümleri tek merkezi koordinat sözleşmesine bağlı olmalıdır.
- ASC/MC/DSC/IC, house cusp, planet longitude ve aspect endpoint değerleri kaynak snapshot dışında türetilemez.
- Planet/label collision çözümü gerçek dereceyi değiştiremez; yalnız label'ın görsel ofsetini değiştirebilir.
- Aspect çizgisinin rengi/kalınlığı presentation kuralıdır; aspect türü ve orb değeri calculation object'ten gelir.
- Vedik chart renderer D1/D9/Varga hesaplarını yeniden üretmez; seçili Varga snapshot'ını hücrelere yerleştirir.
- BaZi renderer stem/branch/hidden-stem verisini üretmez; motor çıktısını düzenler.
- Lo Shu veya numeroloji görseli dekoratif rastgele sayı kullanamaz.
- Dinamik geometri için screenshot benzerliği tek başına doğruluk kanıtı değildir. Her renderer hem data-binding testi hem golden visual test taşımalıdır.
- Golden test değişikliği calculation sonucu değişmeden ortaya çıktıysa bilinçli UI değişikliği olarak review edilmelidir; sessizce baseline yenilenemez.
- Calculation sonucu değiştiyse önce calculation golden suite doğrulanmadan geometry golden baseline güncellenemez.
- Renderer floating-point/ölçek davranışı cihaz modeline göre semantik konum değiştiremez.
- Statik dekoratif geometry bu manifest içine alınmaz; `ui/asset_manifest.csv` içinde tutulur.

## Makine-okunabilir kaynak

`ui/dynamic_geometry_manifest.csv` zorunlu dinamik renderer envanteridir. Her satır:

- benzersiz `GEOM-*` kimliği,
- kategori,
- kaynak SCREEN-ID,
- calculation snapshot kaynağı,
- renderer sözleşmesi,
- golden test zorunluluğu,
- durum,
- açıklama

taşır.

`SPECIFIED`, yalnız sözleşmenin tanımlandığı anlamına gelir; renderer'ın yazıldığı veya test edildiği anlamına gelmez. Production renderer ve golden test gerçekten mevcut olmadan `IMPLEMENTED`, `TESTED` veya `VERIFIED` sayılmaz.
