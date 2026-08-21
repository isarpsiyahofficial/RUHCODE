# Ruh Code — Numerology Core Automation Run

## Bu turda uygulanan gerçek işler

### Pythagorean profil motoru
- `PythagoreanNameNormalizer` eklendi.
- TR/EN isim matematiği için explicit Türkçe transliterasyon sözleşmesi eklendi: Ç→C, Ğ→G, ı/I/i/İ→I, Ö→O, Ş→S, Ü→U.
- Desteklenmeyen karakterler sessizce silinmiyor veya tahmin edilmiyor; hata veriliyor.
- Canonical Pythagorean A-Z 1..9 döngü tablosu eklendi.
- Life Path, Expression/Destiny, Soul Urge, Personality, Birthday ve Maturity hesapları eklendi.
- Master-number reduction policy mevcut Personal Day reducer ile aynı contract üzerinden kullanılıyor.
- `İbrahim Yeşilyurt` exact regression fixture'ı eklendi.

### Chaldean motoru
- Chaldean name engine Pythagorean harf tablosundan ayrı implement edildi.
- Bağımsız 1..8 Chaldean mapping açık source table olarak tutuluyor.
- Shared olan tek parça explicit TR/EN normalization policy; numeric mapping paylaşılmıyor.
- `İbrahim Yeşilyurt` için exact compound total `42`, reduced number `6` regression testi eklendi.
- RC-0184 (Chaldean'da Pythagorean tablo kullanılmaması) evidence/validator ile kilitlendi.

### Lo Shu motoru
- Exact Gregorian birth-date digit frequency motoru eklendi.
- Zero herhangi bir Lo Shu hücresine remap edilmiyor; açıkça ignore ediliyor.
- Canonical grid `4-9-2 / 3-5-7 / 8-1-6` sabitlendi.
- Pythagorean/Chaldean table bağımlılığı yasaklandı.
- 2028-02-29 leap-day regression eklendi.
- İlk test fixture'ındaki yanlış `2` sayımı aynı turda yakalanıp düzeltildi: doğru frekans 4, non-zero digit count 6.

## Evidence / CI
- `evidence/numerology/pythagorean_profile.json`
- `evidence/numerology/chaldean_name.json`
- `evidence/numerology/lo_shu_grid.json`
- `tools/numerology/validate_pythagorean_profile.py`
- `tools/numerology/validate_chaldean_name.py`
- `tools/numerology/validate_lo_shu_grid.py`
- `.github/workflows/numerology-pythagorean-contract.yml` artık üç structural validator'ı ve tüm `test/calculation_core/numerology` Flutter testlerini çalıştırıyor.

## Requirement etkisi — source-level
- RC-0161, RC-0162, RC-0163, RC-0164, RC-0165
- RC-0166, RC-0167, RC-0168, RC-0169, RC-0170, RC-0171
- RC-0182, RC-0183, RC-0184, RC-0185
- RC-0329

Bu RC'ler yalnız source/evidence seviyesinde ilerledi; exact Flutter CI ve bağımsız numeroloji reference dataset kanıtı alınmadan DONE yapılmadı.

## Ana commit zinciri
- `3a7e3bfa12192cefcaed9d9887678b01b87775aa` — Pythagorean profile engine
- `8227ea61d219dfdf19d7e80ce2ce205038610a43` — Pythagorean tests
- `5751065a88f81b898019147e7652aa2bf2db4141` — Pythagorean evidence
- `7a06d5c7fb611f8c44f7f66659e9cb7d76e8923f` — Pythagorean validator
- `dd07e0626f0bb8723f65afd10510ac21411953ea` — Chaldean engine
- `d76696a6a94bd32feb1a1b5bca346f56beb1a50e` — exact Chaldean regression
- `ff7a663febe7c4c0082972e9e75b622a19c3448c` — Chaldean evidence
- `499da9ab1b63b8a3e66c0b800f936c203ec4751f` — Chaldean validator
- `18b6d71de87800fb3d19e979a6dcb303ae33f2bc` — Lo Shu engine
- `e19228b0ebfaa3cb5319b25b240b977943087fc1` — corrected Lo Shu tests
- `9be31068990e3330762a8908e064537211277790` — Lo Shu evidence
- `2f53d1458c2c21157475296c1b2717abe7f220ba` — Lo Shu validator
- `d0077422974c7ba9690b6e93cd4911514b83758f` — unified numerology core CI contract

## Açık / sıradaki güvenli işler
1. Exact workflow sonucu görünürse kırmızı hatayı aynı turda düzelt; görünmüyorsa SUCCESS uydurma.
2. Personal Year / Personal Month / Personal Day sonuçlarını tek public Pythagorean cycle API'sinde expose et ve existing DailySnapshot adapter ile parity testi ekle.
3. Pinnacles ve Challenges için açık algoritma/policy sözleşmesini yaz ve test et; dönem yaş sınırlarında hangi reduction policy'nin kullanıldığını açıkça kaydet.
4. Karmic Debt, Karmic Lessons, Hidden Passion ve Balance hesaplarını ancak explicit policy/evidence ile ayrı ayrı ekle.
5. Numerology interpretation coverage calculation core'dan ayrı tutulacak.
6. Independent reference dataset olmadan numerology RC'lerini DONE yapma.
7. Fiziksel astronomi, GeoNames, 8.036 editorial Daily Message, APPROVED UI ve production PDF font blocker'ları açık kalmaya devam ediyor.

**FINAL: NO.**