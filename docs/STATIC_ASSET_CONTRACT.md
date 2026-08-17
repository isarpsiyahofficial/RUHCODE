# RUH CODE — STATIC ASSET CONTRACT

Bu sözleşme `RC-1429`, `RC-1438`, `RC-1439`, `RC-1441` ve ilgili PDF/UI şartlarını uygular.

## 1. Statik ve dinamik geometri ayrımı

- Logo, zodiac glyph seti, planet glyph seti, mandala, lotus, genel ikon seti, Tarot art ve fontlar **statik asset**tir.
- Natal wheel, aspect line, transit/synastry overlay, Vedik D1/D9/Varga, BaZi layout ve calculation sonucuna göre değişen grafikler statik asset değildir; `docs/DYNAMIC_GEOMETRY_CONTRACT.md` kapsamındadır.
- Statik dekorasyonlar runtime sırasında gelişi güzel `CustomPainter`, Canvas veya benzeri kodla yeniden tasarlanamaz.

## 2. APPROVED olma şartı

`ui/asset_manifest.csv` içindeki bir asset ancak aşağıdakilerin tamamı varsa `APPROVED` olabilir:

1. Repository içindeki gerçek dosya/path.
2. Dosyanın SHA-256 değeri.
3. Ticari dağıtım ve yeniden paketlemeyi kapsayan açık lisans bilgisi.
4. Provenance/kaynak bilgisi.
5. Gerekliyse kullanıcı/tasarım onayı.
6. Fontlarda Türkçe ve İngilizce gerekli glyph coverage doğrulaması.

Bu bilgilerden biri eksikse asset `PENDING` kalır. PENDING asset tamamlanmış sayılmaz.

## 3. Zorunlu asset sınıfları

- `LOGO`
- `ZODIAC_GLYPHS`
- `PLANET_GLYPHS`
- `DECORATIVE_GEOMETRY`
- `ICON_SET`
- `TAROT_ART`
- `FONT_SANS`
- `FONT_SERIF`
- `FONT_SYMBOL`

## 4. Font kuralları

- Kullanılan font dosyaları repository üzerinden kullanıcıya ayrıca dağıtılmayacak; yalnız uygulama build girdisi olarak tutulur ve lisans koşullarına uygun biçimde paketlenir.
- Font ailesi runtime network çağrısıyla indirilmek zorunda olmayacak.
- Türkçe karakterler (`ç, ğ, ı, İ, ö, ş, ü`) ve İngilizce Latin kapsamı doğrulanmadan ana font APPROVED olamaz.
- PDF fontları offline gömülebilir/yeniden dağıtılabilir lisansa sahip olmalıdır.
- Symbol fallback font yalnız gerçek ihtiyaç varsa kullanılmalıdır; zodiac/planet sembollerinin ana kaynağı onaylı vector glyph setidir.

## 5. Release kapısı

Final release öncesi bütün kullanılan production statik assetler manifestte `APPROVED` olmalıdır. Kullanılmayan PENDING adaylar production build’e giremez.
