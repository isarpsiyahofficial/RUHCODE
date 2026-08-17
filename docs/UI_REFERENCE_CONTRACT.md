# RUH CODE — UI REFERANS / ASSET SÖZLEŞMESİ

**Faz:** 3  
**Kapsam:** RC-1429, RC-1430, RC-1431, RC-1438, RC-1439, RC-1440, RC-1441  
**Durum:** BAĞLAYICI ALTYAPI — referans görseller eklenmeden ekran DONE değildir.

## 1. Kaynak gerçek

1. `docs/UI_INFORMATION_ARCHITECTURE.md` ekran/route kaynağıdır.
2. `ui/reference_manifest.csv` onaylı ekran görsellerinin makine tarafından okunabilir kaynağıdır.
3. `ui/action_registry.csv` dokunulabilir öğe sözleşmesinin makine tarafından okunabilir kaynağıdır.
4. `ui/asset_manifest.csv` statik görsel varlıkların kaynağıdır.
5. Bir production ekranı yalnız kodlandığı için tamamlanmış sayılmaz; SCREEN-ID + STATE-ID + referans görsel + SHA-256 + action coverage + accessibility sözleşmesi gerekir.

## 2. Referans görsel kimliği

Her görsel şu alanları taşır:

- `screen_id`: `SCR-*` kimliği.
- `state_id`: `DEFAULT`, `FREE`, `PRO`, `EMPTY`, `ERROR`, `OFFLINE`, `LOADING`, `UNKNOWN_BIRTH_TIME`, `LARGE_TEXT` gibi açık state.
- `reference_version`: monoton sürüm (`v1`, `v2`...).
- `reference_path`: repository içindeki dosya yolu.
- `sha256`: dosyanın gerçek SHA-256 değeri.
- `approval_status`: yalnız `PENDING`, `APPROVED`, `REJECTED`.
- `source`: `USER_APPROVED`, `DESIGN_APPROVED` veya açıkça belirtilen başka onay kaynağı.
- `notes`: davranış/layout için kısa bağlayıcı not.

`APPROVED` bir kayıt için `reference_path` veya `sha256` boş olamaz. `PENDING` kayıt ekranın tasarımının henüz tamamlanmadığını açıkça gösterir ve DONE sayılmaz.

## 3. Görsel eşleşme kuralı

Onaylı referans aşağıdaki alanlarda gerçek UI'ın source-of-truth'udur:

- hiyerarşi,
- section sırası,
- kart yerleşimleri,
- spacing,
- typography ölçeği,
- radius,
- ikon/asset seçimi,
- renk tokenları,
- navigasyon yerleşimi,
- Free/PRO kilit sunumu,
- empty/error/offline state yapısı.

Dinamik kullanıcı verisi, tarih, isim ve calculation çıktısı birebir piksel metni değildir; ancak bileşen geometrisi ve hiyerarşi referansa uymalıdır.

## 4. Statik geometri

Logo, zodiac glyph, gezegen glyph, mandala, lotus, decorative orbit, statik yıldız, Tarot yüzü, ikon veya benzeri varlıklar production kodunda gelişi güzel yeniden çizilemez.

Onaylı statik varlık:

1. repository içinde gerçek dosya olarak bulunur,
2. `ui/asset_manifest.csv` kaydı taşır,
3. SHA-256 değeri doğrulanır,
4. lisans/provenance alanı boş değildir,
5. kod yalnız manifestte tanımlı asset'i kullanır.

## 5. Dinamik geometri istisnası

Aşağıdaki çıktılar gerçek calculation verisinden üretildiği için statik resim olamaz:

- Batı natal/transit/synastry/composite chart wheel,
- house cusp çizgileri,
- aspect çizgileri,
- gezegen derece konumları,
- ASC/MC/DSC/IC,
- Vedik chart hücre yerleşimleri,
- BaZi Four Pillars/grid,
- veriye bağlı numeroloji gridleri.

Bunlar deterministik vector renderer ile üretilecek ve ayrıca golden görüntü testine girecektir. Dekorasyon çizme gerekçesiyle bu istisna genişletilemez.

## 6. Action sözleşmesi

Production'da görünen her dokunulabilir öğe `ACTION-ID` taşır. `ui/action_registry.csv` her action için en az şunları tutar:

- kaynak SCREEN-ID,
- action tipi,
- görünür label/semantic amacı,
- hedef SCREEN-ID veya side-effect,
- entitlement gereksinimi,
- offline davranışı,
- accessibility semantic label gereksinimi.

Hedefsiz dekoratif ikon `interactive=false` olmalıdır; kullanıcıya buton gibi gösterilemez.

## 7. Accessibility ilk günden zorunlu

Referans ekran hazırlanırken dahi:

- dokunma hedefi minimum platform standardını karşılar,
- yalnız renkle durum anlatılmaz,
- metin kontrastı kontrol edilir,
- screen-reader semantic label tanımlanabilir yapı kullanılır,
- büyük fontta kritik action kaybolmaz,
- ikon-only action açıklamasız bırakılmaz.

## 8. CI kapısı

`tools/ui/validate_ui_contracts.py` şunları doğrular:

- IA'daki her SCREEN-ID referans manifestinde en az bir kayıt taşır,
- manifestte IA'da olmayan SCREEN-ID bulunmaz,
- `APPROVED` referansın yolu/hash'i boş değildir,
- duplicate `(screen_id,state_id,reference_version)` yoktur,
- action ID duplicate değildir,
- her normal navigasyon ekranında en az bir açık action contract bulunur veya ekran salt-output olarak açıkça işaretlenir,
- asset ID duplicate değildir,
- APPROVED asset path/hash/license/provenance boş değildir.

Bu validator yeşil olmadan Faz 3 altyapısı doğrulanmış sayılmaz; bütün görseller APPROVED olmadan ise Faz 3'ün tasarım üretim kısmı tamamlanmış sayılmaz.
