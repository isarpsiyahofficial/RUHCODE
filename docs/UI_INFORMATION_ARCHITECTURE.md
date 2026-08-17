# RUH CODE — UI BİLGİ MİMARİSİ VE ROUTE SÖZLEŞMESİ

**Durum:** Faz 2 temel sözleşmesi  
**Bağlayıcı navigasyon:** `Bugün · Araçlar · Kayıtlar · Profil`  

## Ana kurallar

1. Alt navigasyonda belirsiz `Hesapla` sekmesi bulunmaz.
2. Dört ana sekme sabittir: `Bugün`, `Araçlar`, `Kayıtlar`, `Profil`.
3. Profesyonel alan ana navigasyona beşinci bir sekme olarak eklenmez; `Kayıtlar` içinde bağlama göre görünür.
4. Her ekran benzersiz `SCREEN-ID` taşır.
5. Her dokunulabilir öğe bir `ACTION-ID` ve hedef davranış taşır.
6. `ACTION-ID` tanımı olmayan buton, kart, chevron, sekme veya ikon production UI'a giremez.
7. Free/PRO kilidi route'u görünmez kılmak yerine entitlement state ile açıkça yönetir; erişilemeyen özellikte kullanıcı nedenini görür.
8. Doğum saati bilinmiyorsa saat gerektiren route'lar sahte sonuç göstermez.

## Ana navigasyon

| SCREEN-ID | Route | Başlık | Amaç |
|---|---|---|---|
| `SCR-TODAY-001` | `/today` | Bugün | Günlük kişisel merkez |
| `SCR-TOOLS-001` | `/tools` | Araçlar | Tüm hesaplama/çalışma araçlarının açık kategorileri |
| `SCR-RECORDS-001` | `/records` | Kayıtlar | Profiller, danışanlar, seanslar ve kayıtlı çalışmalar |
| `SCR-PROFILE-001` | `/profile` | Profil | Kullanıcı profili, premium ve ayarlar |

## Araçlar ana ağacı

`SCR-TOOLS-001` dört ana kategori gösterir:

- `ACTION-TOOLS-ASTROLOGY` → `SCR-ASTROLOGY-001`
- `ACTION-TOOLS-NUMEROLOGY` → `SCR-NUMEROLOGY-001`
- `ACTION-TOOLS-SPIRITUAL` → `SCR-SPIRITUAL-001`
- `ACTION-TOOLS-GROWTH` → `SCR-GROWTH-001`

### Astroloji

| SCREEN-ID | Route | Erişim |
|---|---|---|
| `SCR-ASTROLOGY-001` | `/tools/astrology` | Astroloji araç merkezi |
| `SCR-WESTERN-INPUT-001` | `/tools/astrology/western/input` | Batı doğum bilgileri |
| `SCR-WESTERN-CHART-001` | `/tools/astrology/western/chart` | Natal harita |
| `SCR-WESTERN-PLACEMENTS-001` | `/tools/astrology/western/placements` | Yerleşimler |
| `SCR-WESTERN-ASPECTS-001` | `/tools/astrology/western/aspects` | Açılar |
| `SCR-WESTERN-HOUSES-001` | `/tools/astrology/western/houses` | Evler |
| `SCR-WESTERN-TECH-001` | `/tools/astrology/western/technical` | Teknik tablo |
| `SCR-WESTERN-INTERP-001` | `/tools/astrology/western/interpretation` | Yorum |
| `SCR-TRANSIT-001` | `/tools/astrology/transits` | Transit sonucu |
| `SCR-TRANSIT-TIMELINE-001` | `/tools/astrology/transits/timeline` | Transit zaman çizelgesi |
| `SCR-SYNASTRY-SELECT-001` | `/tools/astrology/synastry/select` | İki profil seçimi |
| `SCR-SYNASTRY-RESULT-001` | `/tools/astrology/synastry/result` | Synastry sonucu |
| `SCR-COMPOSITE-001` | `/tools/astrology/composite` | Composite |
| `SCR-DAVISON-001` | `/tools/astrology/davison` | Davison |
| `SCR-SOLAR-RETURN-001` | `/tools/astrology/solar-return` | Solar Return |
| `SCR-LUNAR-RETURN-001` | `/tools/astrology/lunar-return` | Lunar Return |
| `SCR-PROGRESSIONS-001` | `/tools/astrology/progressions` | Secondary Progressions |
| `SCR-SOLAR-ARC-001` | `/tools/astrology/solar-arc` | Solar Arc |
| `SCR-PROFECTIONS-001` | `/tools/astrology/profections` | Annual Profections |
| `SCR-WESTERN-SETTINGS-001` | `/tools/astrology/western/settings` | Ev sistemi/orb/pro ayarları |
| `SCR-VEDIC-INPUT-001` | `/tools/astrology/vedic/input` | Vedik doğum bilgileri |
| `SCR-VEDIC-D1-001` | `/tools/astrology/vedic/d1` | D1/Rasi |
| `SCR-VEDIC-D9-001` | `/tools/astrology/vedic/d9` | D9/Navamsa |
| `SCR-VEDIC-VARGAS-001` | `/tools/astrology/vedic/vargas` | Varga seçimi |
| `SCR-VEDIC-DASHA-001` | `/tools/astrology/vedic/dasha` | Vimshottari Dasha |
| `SCR-VEDIC-DASHA-DETAIL-001` | `/tools/astrology/vedic/dasha/detail` | Maha/Antar/Pratyantar detay |
| `SCR-VEDIC-GOCHARA-001` | `/tools/astrology/vedic/gochara` | Gochara |
| `SCR-VEDIC-PANCHANGA-001` | `/tools/astrology/vedic/panchanga` | Panchanga |
| `SCR-VEDIC-STRENGTH-001` | `/tools/astrology/vedic/strength` | Ashtakavarga/Shadbala |
| `SCR-VEDIC-SETTINGS-001` | `/tools/astrology/vedic/settings` | Ayanamsha/teknik ayarlar |
| `SCR-CHINESE-001` | `/tools/astrology/chinese` | Çin astrolojisi temel sonuç |
| `SCR-BAZI-INPUT-001` | `/tools/astrology/bazi/input` | BaZi veri girişi |
| `SCR-BAZI-PILLARS-001` | `/tools/astrology/bazi/pillars` | Four Pillars |
| `SCR-BAZI-ELEMENTS-001` | `/tools/astrology/bazi/elements` | Five Elements |
| `SCR-BAZI-TENGODS-001` | `/tools/astrology/bazi/ten-gods` | Ten Gods |
| `SCR-BAZI-LUCK-001` | `/tools/astrology/bazi/luck` | Da Yun/Luck Pillars |
| `SCR-PLANETARY-HOURS-001` | `/tools/astrology/planetary-hours` | Gezegen Saatleri |
| `SCR-PLANETARY-HOURS-NOTIFY-001` | `/tools/astrology/planetary-hours/notifications` | Gezegen saati bildirimleri |

### Numeroloji

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-NUMEROLOGY-001` | `/tools/numerology` | Numeroloji araç merkezi |
| `SCR-NUMEROLOGY-INPUT-001` | `/tools/numerology/input` | İsim/tarih veri girişi |
| `SCR-PYTHAGOREAN-001` | `/tools/numerology/pythagorean` | Pythagorean sonuç |
| `SCR-CHALDEAN-001` | `/tools/numerology/chaldean` | Chaldean sonuç |
| `SCR-LOSHU-001` | `/tools/numerology/lo-shu` | Lo Shu sonuç |
| `SCR-NUM-PERIODS-001` | `/tools/numerology/periods` | Personal Year/Month/Day |
| `SCR-NUM-TIMELINE-001` | `/tools/numerology/timeline` | Pinnacles/Challenges |
| `SCR-NUM-COMPAT-001` | `/tools/numerology/compatibility` | Karşılaştırma |

### Spiritüel

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-SPIRITUAL-001` | `/tools/spiritual` | Spiritüel araç merkezi |
| `SCR-TAROT-DAILY-001` | `/tools/spiritual/tarot/daily` | Günün Kartı |
| `SCR-TAROT-THREE-001` | `/tools/spiritual/tarot/three-card` | 3 Kart Açılımı |
| `SCR-TAROT-SESSION-001` | `/tools/spiritual/tarot/session` | Seans kaydı |
| `SCR-INTENTION-001` | `/tools/spiritual/intention` | Niyet |
| `SCR-GRATITUDE-001` | `/tools/spiritual/gratitude` | Şükran Günlüğü |
| `SCR-DREAM-001` | `/tools/spiritual/dreams` | Rüya Günlüğü |
| `SCR-MEDITATION-001` | `/tools/spiritual/meditation` | Meditasyon |
| `SCR-BREATH-001` | `/tools/spiritual/breath` | Nefes egzersizi |

### Kişisel Gelişim

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-GROWTH-001` | `/tools/growth` | Kişisel gelişim merkezi |
| `SCR-GOALS-001` | `/tools/growth/goals` | Hedefler |
| `SCR-HABITS-001` | `/tools/growth/habits` | Alışkanlıklar |
| `SCR-CHECKIN-AM-001` | `/tools/growth/check-in/morning` | Sabah check-in |
| `SCR-CHECKIN-PM-001` | `/tools/growth/check-in/evening` | Akşam check-in |
| `SCR-WEEKLY-REVIEW-001` | `/tools/growth/weekly-review` | Haftalık değerlendirme |
| `SCR-LIFE-WHEEL-001` | `/tools/growth/life-wheel` | Yaşam çarkı |
| `SCR-MOOD-001` | `/tools/growth/mood` | Mood/enerji geçmişi |

## Bugün ağacı

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-TODAY-001` | `/today` | Günlük ana ekran |
| `SCR-TODAY-EFFECTS-001` | `/today/effects` | Hesaplanmış Bugünkü Etkiler |
| `SCR-TODAY-MESSAGE-001` | `/today/message` | Tarihe bağlı stok Günün Mesajı |
| `SCR-TODAY-WEEK-001` | `/today/week` | Bu Hafta |
| `SCR-TODAY-MONTH-001` | `/today/month` | Bu Ay |
| `SCR-TODAY-YEAR-001` | `/today/year` | Bu Yıl / PRO |

`Bugünkü Etkiler` ve `Günün Mesajı` aynı veri kaynağı değildir. İlki calculation core, ikincisi exact-date katalog kaydı kullanır.

## Kayıtlar / profesyonel çalışma alanı

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-RECORDS-001` | `/records` | Kayıt merkezi |
| `SCR-PROFILES-001` | `/records/profiles` | Profillerim |
| `SCR-PROFILE-DETAIL-001` | `/records/profiles/:id` | Profil detay |
| `SCR-CLIENTS-001` | `/records/clients` | Danışanlarım |
| `SCR-CLIENT-NEW-001` | `/records/clients/new` | Yeni danışan |
| `SCR-CLIENT-DETAIL-001` | `/records/clients/:id` | Danışan detay |
| `SCR-CONSULT-PREP-001` | `/records/clients/:id/preparation` | Danışmanlık hazırlığı |
| `SCR-CONSULT-LIVE-001` | `/records/clients/:id/session` | Tek Ekran Danışmanlık Modu |
| `SCR-CONSULT-HISTORY-001` | `/records/clients/:id/history` | Seans geçmişi |
| `SCR-PRO-PRESETS-001` | `/records/pro/presets` | Profesyonel presetler |
| `SCR-PRO-LIBRARY-001` | `/records/pro/library` | Kişisel yorum kütüphanesi |
| `SCR-PRO-SHARE-001` | `/records/pro/share-card` | Paylaşım kartı |
| `SCR-LEARNING-001` | `/records/learning` | Öğrenme/öğretim görünümü |

## Profil / ayarlar

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-PROFILE-001` | `/profile` | Profil |
| `SCR-SETTINGS-001` | `/profile/settings` | Ayarlar |
| `SCR-LANGUAGE-001` | `/profile/settings/language` | Türkçe / English |
| `SCR-NOTIFICATIONS-001` | `/profile/settings/notifications` | Bildirimler |
| `SCR-PRIVACY-001` | `/profile/settings/privacy` | Gizlilik |
| `SCR-APP-LOCK-001` | `/profile/settings/app-lock` | PIN/biyometrik kilit |
| `SCR-PREMIUM-001` | `/profile/premium` | Free/PRO karşılaştırma ve satın alma |
| `SCR-BACKUP-001` | `/profile/backup` | Yedekleme ve aktarma |
| `SCR-BACKUP-IMPORT-001` | `/profile/backup/import` | Restore dosya seçimi |
| `SCR-BACKUP-PREVIEW-001` | `/profile/backup/preview` | Restore önizleme |
| `SCR-PDF-001` | `/profile/reports` | PDF raporları |
| `SCR-PDF-BUILDER-001` | `/profile/reports/builder` | Profesyonel PDF oluşturucu |
| `SCR-PDF-PREVIEW-001` | `/profile/reports/preview` | PDF önizleme |

## Onboarding / sistem ekranları

| SCREEN-ID | Route | Amaç |
|---|---|---|
| `SCR-SPLASH-001` | `/splash` | Açılış |
| `SCR-ONBOARD-LANGUAGE-001` | `/onboarding/language` | İlk dil seçimi |
| `SCR-ONBOARD-INTRO-001` | `/onboarding/intro` | Kısa onboarding |
| `SCR-ONBOARD-PROFILE-001` | `/onboarding/profile` | İlk kişisel profil |
| `SCR-LOCATION-SEARCH-001` | `/location/search` | Şehir arama |
| `SCR-LOCATION-DISAMBIG-001` | `/location/disambiguate` | Aynı isimli şehir ayrımı |
| `SCR-LOCATION-MANUAL-001` | `/location/manual` | Manuel konum |
| `SCR-STATE-OFFLINE-001` | system state | Offline bilgi state'i |
| `SCR-STATE-ERROR-001` | system state | Genel güvenli hata state'i |
| `SCR-STATE-EMPTY-001` | system state | Empty state |

## Action sözleşmesi — temel zorunlu aksiyonlar

| ACTION-ID | Kaynak | Sonuç |
|---|---|---|
| `ACTION-NAV-TODAY` | alt navigasyon | `SCR-TODAY-001` |
| `ACTION-NAV-TOOLS` | alt navigasyon | `SCR-TOOLS-001` |
| `ACTION-NAV-RECORDS` | alt navigasyon | `SCR-RECORDS-001` |
| `ACTION-NAV-PROFILE` | alt navigasyon | `SCR-PROFILE-001` |
| `ACTION-TOOLS-ASTROLOGY` | Araçlar kartı | `SCR-ASTROLOGY-001` |
| `ACTION-TOOLS-NUMEROLOGY` | Araçlar kartı | `SCR-NUMEROLOGY-001` |
| `ACTION-TOOLS-SPIRITUAL` | Araçlar kartı | `SCR-SPIRITUAL-001` |
| `ACTION-TOOLS-GROWTH` | Araçlar kartı | `SCR-GROWTH-001` |
| `ACTION-ASTRO-WESTERN` | Astroloji kartı | `SCR-WESTERN-INPUT-001` |
| `ACTION-ASTRO-VEDIC` | Astroloji kartı | `SCR-VEDIC-INPUT-001` |
| `ACTION-ASTRO-CHINESE` | Astroloji kartı | `SCR-CHINESE-001` |
| `ACTION-ASTRO-BAZI` | Astroloji kartı | `SCR-BAZI-INPUT-001` |
| `ACTION-ASTRO-PLANETARY-HOURS` | Astroloji kartı | `SCR-PLANETARY-HOURS-001` |
| `ACTION-RECORDS-PROFILES` | Kayıtlar kartı | `SCR-PROFILES-001` |
| `ACTION-RECORDS-CLIENTS` | Kayıtlar kartı | `SCR-CLIENTS-001`; entitlement gerekiyorsa kilit açıklaması |
| `ACTION-PROFILE-SETTINGS` | Profil | `SCR-SETTINGS-001` |
| `ACTION-PROFILE-BACKUP` | Profil/Ayarlar | `SCR-BACKUP-001` |
| `ACTION-PROFILE-PDF` | Profil/Ayarlar | `SCR-PDF-001` |

## Test sözleşmesi

- `SCREEN-ID` duplicate olamaz.
- Ana dört route her build'de erişilebilir olmalı.
- `Hesapla` alt-nav etiketi kaynakta bulunursa navigation contract CI kırılmalı.
- Action registry'de hedefi olmayan `ACTION-ID` olamaz.
- UI üzerinde tanımlanan her clickable semantic node bir `ACTION-ID` ile eşleşmelidir.
- Free/PRO nedeniyle engellenen aksiyon `no-op` olamaz; kilit state veya satın alma açıklamasına gitmelidir.
- Back navigation kullanıcıyı veri kaybına uğratmamalıdır.

Bu dosya Faz 3'te üretilecek referans görsellerin ekran envanterinin kaynak sözleşmesidir.
