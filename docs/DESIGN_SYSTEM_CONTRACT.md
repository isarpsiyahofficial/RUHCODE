# RUH CODE — DESIGN SYSTEM CONTRACT

Bu sözleşme Faz 4 design-system görevlerinin temel kaynağıdır. `ui/design_tokens.json` makine-okunabilir token kaynağıdır.

## Görsel dil

- Ruh Code sade, anlaşılır, premium ve sakin görünür.
- AKİLES mantığındaki sıcak açık zemin + mor ana vurgu + ölçülü altın vurgu korunur.
- Gereksiz bilgi kutuları, yapay zekâ hissi veren açıklamalar, sahte teknik jargon ve ekranda değer üretmeyen dekoratif metin kullanılmaz.
- Aynı component farklı modüllerde rastgele farklı görsel kimliğe bürünmez.

## Renk sistemi

- Warm ivory background: `#FBF8F3`
- Surface: `#FFFFFF`
- Soft surface: `#F5EEE6`
- Primary text: `#25173E`
- Muted text: `#6D617D`
- Line: `#E9DDCE`
- Primary purple: `#4C2A91`
- Strong purple: `#6B42E6`
- Gold accent: `#C89338`
- Success: `#12AD62`
- Danger: `#C23B53`

Bu değerler tekil ekranlar içinde tekrar hard-code edilmez; token kaynağından alınır.

## Spacing ve radius

- Spacing grid: 4 / 8 / 12 / 16 / 24 / 32 dp.
- Radius: 8 / 12 / 16 / 22 / 28 dp ve gerçek pill gerektiğinde 999.
- Card, sheet, chip ve button radius kullanımları component seviyesinde standardize edilir.

## Typography

- UI ana fontu `ASSET-FONT-SANS-PRIMARY` üzerinden çözülür.
- PDF’de yalnız gerekli başlıklarda `ASSET-FONT-SERIF-REPORT` kullanılabilir.
- Symbol fallback yalnız gerekli durumda `ASSET-FONT-SYMBOL-FALLBACK` kullanır.
- Gerçek font dosyaları lisans, provenance, hash ve Türkçe/İngilizce glyph coverage doğrulanmadan APPROVED değildir.

## Accessibility

- Her interaktif öğe minimum 48×48 dp focusable/touch target sağlar.
- Görsel ikon 24 dp olsa bile dokunulabilir alan 48 dp’den küçük olamaz.
- Her anlamlı kontrol semantic role ve erişilebilir isim taşır.
- Yalnız renkle anlam aktarılmaz.
- Büyük font scaling, Türkçe ve İngilizce taşma testleri release kapısına dahildir.

## Alt navigasyon

Ana navigasyon yalnız şu dört ürün alanını taşır:

1. Bugün
2. Araçlar
3. Kayıtlar
4. Profil

Belirsiz `Hesapla` ana sekmesi kullanılmaz. Hesap türü Araçlar bilgi mimarisinde açık isimle seçilir.

## Asset ve geometri

- Statik asset kuralları: `docs/STATIC_ASSET_CONTRACT.md`.
- Dinamik calculation geometry kuralları: `docs/DYNAMIC_GEOMETRY_CONTRACT.md`.
- Onaylanan ekran referansları: `ui/reference_manifest.csv` ve `ui/state_reference_manifest.csv`.

## Final şartı

Gerçek uygulama ekranları onaylı referans görsellere, tokenlara ve action sözleşmesine karşı test edilmeden design-system işi final kabul edilmez.
