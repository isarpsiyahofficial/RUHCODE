# RUH CODE — MASTER TODO / UYGULAMA SIRASI

**Bağlayıcı kapsam:** RC-0001 → RC-1442  
**Şartname indexi:** [`RUH_CODE_MASTER_INDEX.md`](./RUH_CODE_MASTER_INDEX.md)  
**Durum:** UYGULAMA VE RELEASE PLANI  

Bu liste madde numarası sırasına göre değil **teknik bağımlılık sırasına göre** uygulanır. Hiçbir görev, bağlı olduğu RC requirement’larını iptal etmez veya zayıflatmaz. Bir iş yalnız kodlandığı için DONE değildir; ilgili doğrulama kapıları da geçmelidir.

---

## FAZ 0 — ŞARTNAMEYİ MAKİNE TARAFINDAN İZLENEBİLİR HALE GETİR

- [ ] `RC-0001 → RC-1442` için tek Requirement Traceability Matrix oluştur.
- [ ] Matrix tam olarak 1.442 benzersiz RC ID içersin.
- [ ] Eksik RC ID olduğunda CI başarısız olsun.
- [ ] Duplicate RC ID olduğunda CI başarısız olsun.
- [ ] Her RC için `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` durumu tut.
- [ ] Her RC’yi en az bir TASK ID ile eşleştir.
- [ ] Calculation etkisi olan RC’leri `CALC` etiketiyle işaretle.
- [ ] Interpretation etkisi olan RC’leri `CONTENT` etiketiyle işaretle.
- [ ] UI etkisi olan RC’leri `UI` etiketiyle işaretle.
- [ ] TR/EN etkisi olan RC’leri `I18N` etiketiyle işaretle.
- [ ] Offline etkisi olan RC’leri `OFFLINE` etiketiyle işaretle.
- [ ] Free/PRO etkisi olan RC’leri `ENTITLEMENT` etiketiyle işaretle.
- [ ] Backup etkisi olan RC’leri `BACKUP` etiketiyle işaretle.
- [ ] PDF etkisi olan RC’leri `PDF` etiketiyle işaretle.
- [ ] Security etkisi olan RC’leri `SECURITY` etiketiyle işaretle.
- [ ] Accessibility etkisi olan RC’leri `A11Y` etiketiyle işaretle.
- [ ] Performance etkisi olan RC’leri `PERF` etiketiyle işaretle.
- [ ] Release etkisi olan RC’leri `RELEASE` etiketiyle işaretle.
- [ ] Her RC için gerekli kanıt türünü matrix’e ekle.
- [ ] Zorunlu kanıt yoksa RC’nin DONE olmasını engelle.

## FAZ 1 — AKİLES REFERANSINI AYRIŞTIR VE KİLİTLE

- [ ] Kullanıcının verdiği AKİLES V96 Final 28 paketini referans kaynak olarak arşivle.
- [ ] AKİLES kaynak SHA/hash manifestini oluştur.
- [ ] AKİLES’te kullanılan aktif JS/CSS/ephemeris/timezone dosyalarını envanterle.
- [ ] Ruh Code’a taşınabilecek hesaplama çekirdeklerini işaretle.
- [ ] Web/admin/Cloudflare’a özgü alanları Ruh Code runtime kapsamından ayır.
- [ ] 25.000+ Vedik doğrulama datasetini referans test setine dönüştür.
- [ ] 6.400+ planetary-hour datasetini referans test setine dönüştür.
- [ ] AKİLES hesaplama sonuçlarının Ruh Code regression baseline’ı olarak kullanımını tanımla.
- [ ] AKİLES runtime dependency’si olmadan Ruh Code’un bağımsız çalışacağını garanti et.
- [ ] AKİLES’te yalnız doğrulama amacıyla kullanılan lisanslı kaynakları runtime’a otomatik taşımayı yasakla.

## FAZ 2 — UI BİLGİ MİMARİSİNİ KODDAN ÖNCE TAMAMLA

- [ ] Ana navigasyonu kesinleştir: `Bugün · Araçlar · Kayıtlar · Profil`.
- [ ] Belirsiz `Hesapla` ana navigasyonunu kaldır ve tekrar eklenmesini engelle.
- [ ] `Araçlar` ekranında `Astroloji`, `Numeroloji`, `Spiritüel`, `Kişisel Gelişim` ana yollarını açık göster.
- [ ] Astroloji altında `Batı`, `Vedik`, `Çin`, `BaZi`, `Gezegen Saatleri` yollarını açık göster.
- [ ] Numeroloji altında Pythagorean, Chaldean, Lo Shu ve dönem araçlarını açık ayır.
- [ ] Kayıtlar altında `Profillerim` ve profesyonel kullanıcı için `Danışanlarım` ayrımını kur.
- [ ] Profesyonel çalışma alanını normal kullanıcı navigasyonunu kalabalıklaştırmadan yerleştir.
- [ ] Her route için benzersiz `SCREEN-ID` tanımla.
- [ ] Her dokunulabilir öğe için action/navigation sözleşmesi yaz.
- [ ] Hiçbir chevron, kart, buton veya ikon işlevsiz kalmasın.

## FAZ 3 — TÜM UI REFERANS GÖRSELLERİNİ ÜRET VE ONAYLA

- [ ] Splash ekranı.
- [ ] İlk dil seçimi.
- [ ] Onboarding.
- [ ] Ana profil oluşturma.
- [ ] Doğum saati bilinmiyor state’i.
- [ ] Şehir arama.
- [ ] Aynı isimli şehir disambiguation.
- [ ] Manuel konum seçimi.
- [ ] Bugün ana ekranı.
- [ ] Bugünün Etkileri detay ekranı.
- [ ] Günün Mesajı Free state’i.
- [ ] Günün Mesajı reklamla açılabilir state’i.
- [ ] Günün Mesajı PRO state’i.
- [ ] Haftalık görünüm.
- [ ] Aylık görünüm.
- [ ] Yıllık PRO görünüm.
- [ ] Araçlar ana ekranı.
- [ ] Astroloji araçlar ekranı.
- [ ] Numeroloji araçlar ekranı.
- [ ] Spiritüel araçlar ekranı.
- [ ] Kişisel gelişim araçlar ekranı.
- [ ] Batı doğum bilgileri giriş ekranı.
- [ ] Batı natal chart ana ekranı.
- [ ] Batı yerleşimler ekranı.
- [ ] Batı evler ekranı.
- [ ] Batı açılar ekranı.
- [ ] Batı aspect grid ekranı.
- [ ] Batı teknik derece tablosu.
- [ ] Batı yorum ekranı.
- [ ] Transit ana ekranı.
- [ ] Transit timeline.
- [ ] Synastry kişi seçimi.
- [ ] Synastry sonuç ekranı.
- [ ] Composite ekranı.
- [ ] Davison ekranı.
- [ ] Solar Return ekranı.
- [ ] Lunar Return ekranı.
- [ ] Secondary Progressions ekranı.
- [ ] Solar Arc ekranı.
- [ ] Annual Profections ekranı.
- [ ] Profesyonel Batı ayarları.
- [ ] Ev sistemi seçim ekranı.
- [ ] Orb ayarları.
- [ ] Vedik giriş ekranı.
- [ ] Vedik D1 ekranı.
- [ ] Vedik D9 ekranı.
- [ ] Varga seçim ekranı.
- [ ] Dasha timeline.
- [ ] Mahadasha/Antardasha detay ekranı.
- [ ] Gochara ekranı.
- [ ] Panchanga ekranı.
- [ ] Tithi/Vara/Nakshatra/Yoga/Karana detayları.
- [ ] Ashtakavarga ekranı.
- [ ] Shadbala ekranı.
- [ ] Vedik teknik ayarlar.
- [ ] Çin Astrolojisi sonuç ekranı.
- [ ] BaZi giriş ekranı.
- [ ] BaZi Four Pillars ekranı.
- [ ] Hidden Stems ekranı.
- [ ] Five Elements ekranı.
- [ ] Day Master/Ten Gods ekranı.
- [ ] Da Yun timeline.
- [ ] BaZi yıllık/aylık dönem ekranı.
- [ ] Pythagorean sonuç ekranı.
- [ ] Chaldean sonuç ekranı.
- [ ] Lo Shu sonuç ekranı.
- [ ] Personal Year/Month/Day ekranı.
- [ ] Pinnacles/Challenges timeline.
- [ ] Numeroloji compatibility ekranı.
- [ ] Gezegen Saatleri ana ekranı.
- [ ] Gezegen Saati detay ekranı.
- [ ] Planetary-hour bildirim ayarı.
- [ ] Spiritüel ana ekran.
- [ ] Günün Kartı.
- [ ] 3 Kart Açılımı.
- [ ] Tarot seans kaydı.
- [ ] Niyet ekranı.
- [ ] Şükran Günlüğü.
- [ ] Rüya Günlüğü.
- [ ] Meditasyon alanı.
- [ ] Nefes egzersizi alanı.
- [ ] Kişisel gelişim ana ekranı.
- [ ] Hedefler.
- [ ] Alışkanlıklar.
- [ ] Sabah check-in.
- [ ] Akşam check-in.
- [ ] Haftalık değerlendirme.
- [ ] Aylık değerlendirme.
- [ ] Yaşam Çarkı.
- [ ] Mood/Enerji geçmişi.
- [ ] Kayıtlar ana ekranı.
- [ ] Profillerim ekranı.
- [ ] Danışanlarım ekranı.
- [ ] Yeni danışan ekranı.
- [ ] Danışan detay ekranı.
- [ ] Danışmanlık Hazırlığı.
- [ ] Tek Ekran Danışmanlık Modu.
- [ ] Danışmanlık not ekranı.
- [ ] Seans geçmişi.
- [ ] Yaklaşan seanslar.
- [ ] Professional preset ekranı.
- [ ] Profesyonel yorum kütüphanesi.
- [ ] Kendi yorum şablonu editörü.
- [ ] Öğrenme Modu.
- [ ] Öğretim görünümü.
- [ ] Paylaşım Kartı üreticisi.
- [ ] Profil ekranı.
- [ ] Ayarlar.
- [ ] Dil.
- [ ] Bildirimler.
- [ ] Gizlilik.
- [ ] PIN/Biyometrik koruma.
- [ ] Free/PRO karşılaştırma.
- [ ] Premium satın alma.
- [ ] Reklam unlock state’i.
- [ ] Kilitli PDF state’i.
- [ ] Örnek PDF önizleme.
- [ ] Profesyonel PDF oluşturucu.
- [ ] PDF bölüm seçimi.
- [ ] PDF önizleme.
- [ ] CSV dışa aktarma.
- [ ] CSV içe aktarma.
- [ ] Restore önizleme.
- [ ] Merge/Replace seçimi.
- [ ] Restore başarılı.
- [ ] Restore başarısız/Rollback.
- [ ] Tüm Empty state’ler.
- [ ] Tüm Loading state’ler.
- [ ] Offline state’ler.
- [ ] Geçersiz doğum verisi state’i.
- [ ] Saat bilinmeyen sonuç state’i.
- [ ] Polar-day/polar-night state’i.
- [ ] Bütün Free lock state’leri.
- [ ] Bütün PRO open state’leri.
- [ ] Her referans görsel için sürüm ve hash oluştur.
- [ ] Onaylanan UI görsellerini repository’de versioned reference asset olarak sakla.

## FAZ 4 — DESIGN SYSTEM VE STATİK ASSET SÖZLEŞMESİ

- [ ] Color tokenları sabitle.
- [ ] Primary purple sabitle.
- [ ] Gold accent sabitle.
- [ ] Warm ivory/background tokenlarını sabitle.
- [ ] Text/muted/line renklerini sabitle.
- [ ] Radius sistemi sabitle.
- [ ] Shadow sistemi sabitle.
- [ ] Typography sistemi sabitle.
- [ ] Spacing grid sabitle.
- [ ] Minimum touch target standardı sabitle.
- [ ] Screen-reader semantic standardı sabitle.
- [ ] Onaylı logo SVG kaynağını ekle.
- [ ] Zodiac glyph SVG setini ekle.
- [ ] Planet glyph SVG setini ekle.
- [ ] Numeroloji ikon setini ekle.
- [ ] Lotus/mandala/dekoratif geometrileri SVG olarak ekle.
- [ ] Tarot asset setinin lisans/provenance kaydını oluştur.
- [ ] Fontların lisans/provenance kaydını oluştur.
- [ ] `ASSET_MANIFEST` oluştur.
- [ ] Her asset için hash kaydet.
- [ ] Statik dekoratif geometrinin runtime CustomPainter ile yeniden çizilmesini yasakla.

## FAZ 5 — PROJE İSKELETİ VE OFFLINE-FIRST VERİ KATMANI

- [ ] Flutter proje iskeletini kur.
- [ ] Android release yapılandırmasını kur.
- [ ] iOS’a taşınmayı engellemeyen platform bağımsız domain katmanı kur.
- [ ] Feature-based modüler klasör mimarisini kur.
- [ ] `calculation_core` ayrı katman olsun.
- [ ] `interpretation` ayrı katman olsun.
- [ ] `data` ayrı katman olsun.
- [ ] `ui` ayrı katman olsun.
- [ ] `pdf` ayrı katman olsun.
- [ ] `backup` ayrı katman olsun.
- [ ] `entitlements` ayrı katman olsun.
- [ ] Local transactional database kur.
- [ ] Schema versioning kur.
- [ ] Migration altyapısı kur.
- [ ] Rollback altyapısı kur.
- [ ] Integrity check kur.
- [ ] UUID tabanlı ID standardı kur.
- [ ] Profile modeli.
- [ ] BirthData modeli.
- [ ] Location modeli.
- [ ] Client modeli.
- [ ] CalculationManifest modeli.
- [ ] Consultation modeli.
- [ ] Note modeli.
- [ ] Journal modeli.
- [ ] Goal modeli.
- [ ] Habit modeli.
- [ ] TarotSession modeli.
- [ ] ProfessionalPreset modeli.
- [ ] InterpretationTemplate modeli.
- [ ] FeatureEntitlement modeli.
- [ ] BackupManifest modeli.
- [ ] Locale’den bağımsız enum/ID sözleşmesi kur.

## FAZ 6 — TAKVİM, TARİH VE ZAMAN ÇEKİRDEĞİ

- [ ] Gregorian calendar core oluştur.
- [ ] Leap-year algoritmasını doğru uygula.
- [ ] 1900’ün artık yıl olmadığını test et.
- [ ] 2000’in artık yıl olduğunu test et.
- [ ] 2028-02-29 test et.
- [ ] 2032-02-29 test et.
- [ ] 2036-02-29 test et.
- [ ] 2100’ün artık yıl olmadığını test et.
- [ ] Ay uzunluklarını test et.
- [ ] Weekday algoritmasını test et.
- [ ] `16.08.2026` ve `16.08.2027` bağımsız golden vaka olsun.
- [ ] ISO `YYYY-MM-DD` date-key standardını oluştur.
- [ ] UTC/local datetime dönüşümlerini oluştur.
- [ ] Day rollover testlerini oluştur.
- [ ] Midnight cache invalidation oluştur.
- [ ] DST nonexistent-time vakalarını test et.
- [ ] DST ambiguous-time vakalarını test et.
- [ ] Yarım saat timezone testleri.
- [ ] 45 dakika timezone testleri.
- [ ] UTC+14 testleri.
- [ ] International Date Line testleri.

## FAZ 7 — IANA TIMEZONE + ŞEHİR/KONUM VERİSİ

- [ ] IANA timezone datasetini local ve versioned paketle.
- [ ] Historical timezone/DST desteğini kur.
- [ ] Timezone dataset checksum manifesti oluştur.
- [ ] Offline şehir/ülke/koordinat datasetini seç ve lisansını doğrula.
- [ ] City dataset version/checksum manifesti oluştur.
- [ ] Türkçe şehir alias desteği.
- [ ] İngilizce şehir alias desteği.
- [ ] Aynı isimli şehirleri country/region ile ayır.
- [ ] Search index kur.
- [ ] GPS olmadan manuel konumla tam çalışmayı doğrula.
- [ ] GPS reddedildiğinde fallback çalışsın.
- [ ] Son kullanılan yerler cache’i oluştur.
- [ ] Şehir adı değişse bile kayıtlı IANA timezone ID ve koordinatların korunmasını sağla.

## FAZ 8 — ORTAK ASTRONOMİK CALCULATION CORE

- [ ] Desteklenen tarih aralığını en az 1890–2110 hedefiyle kesinleştir.
- [ ] Ephemeris/data lisans envanterini oluştur.
- [ ] Ephemeris version/checksum manifestini oluştur.
- [ ] Julian Day.
- [ ] UTC/TT gerekli dönüşümleri.
- [ ] Güneş konumu.
- [ ] Ay konumu.
- [ ] Merkür.
- [ ] Venüs.
- [ ] Mars.
- [ ] Jüpiter.
- [ ] Satürn.
- [ ] Uranüs.
- [ ] Neptün.
- [ ] Plüton.
- [ ] Ay düğümleri.
- [ ] Retrograde/station hesapları.
- [ ] Sunrise/sunset.
- [ ] Ay fazı.
- [ ] Her ölçüm için hard accuracy budget belirle.
- [ ] Planet longitude toleransını belirle.
- [ ] ASC/MC toleransını belirle.
- [ ] House cusp toleransını belirle.
- [ ] Sunrise/sunset toleransını belirle.
- [ ] Boundary vaka suite’i oluştur.
- [ ] Locale bağımsız deterministik sonuç testleri.
- [ ] Network tamamen kapalıyken calculation core testleri.
- [ ] AKİLES golden dataset cross-check.

## FAZ 9 — DİNAMİK VECTOR GEOMETRY RENDERER

- [ ] Natal wheel 0–360° coordinate spec oluştur.
- [ ] Zodiac ring renderer.
- [ ] House cusp renderer.
- [ ] Planet position renderer.
- [ ] ASC/MC/DSC/IC renderer.
- [ ] Aspect line renderer.
- [ ] Label collision/stacking algoritması.
- [ ] Zoom/scale davranışı.
- [ ] Western chart golden image suite.
- [ ] Vedik chart renderer.
- [ ] Vedik chart golden image suite.
- [ ] BaZi grid renderer.
- [ ] BaZi grid golden image suite.
- [ ] UI ve PDF renderer’ın aynı calculation object’i kullandığını garanti et.

## FAZ 10 — BATI ASTROLOJİSİ MOTORU

- [ ] Tropical zodiac.
- [ ] ASC.
- [ ] MC.
- [ ] Placidus.
- [ ] Whole Sign.
- [ ] Equal House.
- [ ] Kabul edilen diğer ev sistemleri.
- [ ] Gezegen-sign yerleşimleri.
- [ ] Gezegen-house yerleşimleri.
- [ ] House rulers.
- [ ] Conjunction.
- [ ] Opposition.
- [ ] Square.
- [ ] Trine.
- [ ] Sextile.
- [ ] Minor aspects.
- [ ] Configurable orbs.
- [ ] Element distribution.
- [ ] Modality distribution.
- [ ] Dignity/exaltation/detriment/fall.
- [ ] Aspect grid.
- [ ] Natal chart.
- [ ] Transit chart.
- [ ] Natal × Transit.
- [ ] Synastry.
- [ ] Composite.
- [ ] Davison.
- [ ] Solar Return.
- [ ] Lunar Return.
- [ ] Secondary Progressions.
- [ ] Solar Arc.
- [ ] Annual Profections.
- [ ] Eclipse/return overlays kapsamındaki şartları kapat.
- [ ] Her alt motor için golden dataset.
- [ ] 0° ve 29°59′ sign boundary suite.
- [ ] House cusp boundary suite.
- [ ] Retrograde station suite.

## FAZ 11 — VEDİK ASTROLOJİ MOTORU

- [ ] Sidereal zodiac.
- [ ] Lahiri/Chitrapaksha.
- [ ] Lagna.
- [ ] Graha positions.
- [ ] Rahu/Ketu.
- [ ] Nakshatra.
- [ ] Pada.
- [ ] D1.
- [ ] D2.
- [ ] D3.
- [ ] D4.
- [ ] D7.
- [ ] D9.
- [ ] D10.
- [ ] D12.
- [ ] D16.
- [ ] D20.
- [ ] D24.
- [ ] D30.
- [ ] D60.
- [ ] Vimshottari Dasha.
- [ ] Mahadasha.
- [ ] Antardasha.
- [ ] Pratyantardasha.
- [ ] Gochara.
- [ ] Panchanga.
- [ ] Tithi.
- [ ] Vara.
- [ ] Nakshatra daily.
- [ ] Yoga.
- [ ] Karana.
- [ ] Ashtakavarga.
- [ ] Shadbala.
- [ ] Compatibility.
- [ ] Muhurta kapsamındaki zorunlu maddeleri kapat.
- [ ] Nakshatra boundary suite.
- [ ] Pada boundary suite.
- [ ] 25.000+ AKİLES Vedik regression suite’i geçir.

## FAZ 12 — GEZEGEN SAATLERİ

- [ ] Sunrise → Sunset / 12.
- [ ] Sunset → next Sunrise / 12.
- [ ] Chaldean planetary sequence.
- [ ] Weekday ruler gerçek weekday core’dan gelsin.
- [ ] Current hour.
- [ ] Remaining time.
- [ ] Next hour.
- [ ] Full day/night list.
- [ ] 7×7 interpretation mapping.
- [ ] 29 Şubat testleri.
- [ ] Polar-day/polar-night davranışı.
- [ ] Uydurma saat üretmeme kuralı.
- [ ] 6.400+ AKİLES global suite’i geçir.

## FAZ 13 — ÇİN ASTROLOJİSİ VE BAZI

- [ ] Chinese zodiac animal.
- [ ] Chinese element.
- [ ] Yin/Yang.
- [ ] Chinese New Year boundary engine.
- [ ] BaZi solar-term engine.
- [ ] Year Pillar.
- [ ] Month Pillar.
- [ ] Day Pillar.
- [ ] Hour Pillar.
- [ ] Heavenly Stems.
- [ ] Earthly Branches.
- [ ] Hidden Stems.
- [ ] Five Elements.
- [ ] Day Master.
- [ ] Ten Gods.
- [ ] Da Yun/Luck Pillars.
- [ ] Annual influences.
- [ ] Monthly influences.
- [ ] Compatibility kapsamı.
- [ ] Solar-term boundary golden suite.
- [ ] Day-boundary policy testleri.

## FAZ 14 — NUMEROLOJİ MOTORLARI

- [ ] Pythagorean mapping.
- [ ] Chaldean mapping tamamen ayrı.
- [ ] Lo Shu.
- [ ] Türkçe karakter normalization policy.
- [ ] İngilizce normalization policy.
- [ ] Life Path.
- [ ] Expression/Destiny.
- [ ] Soul Urge.
- [ ] Personality.
- [ ] Birthday Number.
- [ ] Maturity.
- [ ] Balance.
- [ ] Karmic Lessons.
- [ ] Karmic Debt.
- [ ] Hidden Passion.
- [ ] Personal Year.
- [ ] Personal Month.
- [ ] Personal Day.
- [ ] Pinnacles.
- [ ] Challenges.
- [ ] Compatibility.
- [ ] İsim değişikliği karşılaştırma desteği.
- [ ] Her sistem için bağımsız golden suite.

## FAZ 15 — DAILY ENGINE / BUGÜN SİSTEMİ

- [ ] `DailySnapshot` veri modelini oluştur.
- [ ] Snapshot key: date + timezone + location + profile + engineVersion.
- [ ] Gerçek weekday calendar core’dan gelsin.
- [ ] Gerçek Moon sign calculation core’dan gelsin.
- [ ] Gerçek Moon phase calculation core’dan gelsin.
- [ ] Gerçek transitler calculation core’dan gelsin.
- [ ] Gerçek planetary hour calculation core’dan gelsin.
- [ ] Personal Day numerology core’dan gelsin.
- [ ] Gerekli Vedik günlük göstergeleri Vedik core’dan gelsin.
- [ ] 16.08.2026 ve 16.08.2027’nin farklı snapshot üretmesini golden test et.
- [ ] Midnight rollover test et.
- [ ] Timezone değişiminde snapshot invalidation test et.
- [ ] Seyahat nedeniyle natal chart’ın değişmemesini test et.
- [ ] Bugünün Etkileri ile stok Günün Mesajı verisini kesin ayır.

## FAZ 16 — EN AZ 10 YILLIK GÜNÜN MESAJI KATALOĞU

- [ ] İlk katalog başlangıç/bitiş aralığını kesinleştir.
- [ ] Başlangıç hedefi olarak 2026–2036 tüm günleri üret.
- [ ] 4.018 tarih completeness kontrolü yap.
- [ ] Her tarih için 1 TR kayıt zorunlu.
- [ ] Her tarih için 1 EN kayıt zorunlu.
- [ ] En az 8.036 tarih-dil kaydı doğrula.
- [ ] 2028-02-29 mesajı zorunlu.
- [ ] 2032-02-29 mesajı zorunlu.
- [ ] 2036-02-29 mesajı zorunlu.
- [ ] Her kayıt `YYYY-MM-DD` key taşısın.
- [ ] Başlık alanı.
- [ ] Teaser alanı.
- [ ] Full message alanı.
- [ ] Tema etiketi.
- [ ] TR içerik EN’den otomatik çevrilmesin.
- [ ] EN içerik TR’den otomatik çevrilmesin.
- [ ] Exact duplicate kontrolü.
- [ ] Near-duplicate kontrolü.
- [ ] Aynı açılış kalıbı yoğunluğu kontrolü.
- [ ] Yapay/AI hissi veren kalıp yoğunluğu kontrolü.
- [ ] Kesin gelecek/sağlık/hukuk/finans iddialarını temizle.
- [ ] Release tarihinde ileriye en az 10 tam yıl stok olduğunu CI ile kontrol et.
- [ ] Rolling horizon nedeniyle katalog bitişini her release’de ileri taşı.
- [ ] Katalog version/checksum manifesti oluştur.

## FAZ 17 — INTERPRETATION ENGINE VE İÇERİK COVERAGE

- [ ] Western interpretation catalog.
- [ ] Vedic interpretation catalog.
- [ ] BaZi interpretation catalog.
- [ ] Numerology interpretation catalog.
- [ ] Planetary-hour interpretation catalog.
- [ ] TR ve EN katalogları bağımsız olsun.
- [ ] Planet × Sign coverage matrix.
- [ ] Planet × House coverage matrix.
- [ ] Aspect coverage matrix.
- [ ] Transit interpretation coverage matrix.
- [ ] Nakshatra coverage matrix.
- [ ] Dasha coverage matrix.
- [ ] Numerology result coverage matrix.
- [ ] BaZi result coverage matrix.
- [ ] Placeholder leakage testi.
- [ ] Yanlış rule-binding testi.
- [ ] Çelişkili yorum kontrolü.
- [ ] Duplicate/near-duplicate interpretation kontrolü.
- [ ] Calculation verisi yokken yorum üretmeme testi.

## FAZ 18 — GERÇEK UI IMPLEMENTASYONU

- [ ] Önce ortak design components.
- [ ] Navigation shell.
- [ ] Bugün.
- [ ] Araçlar hub.
- [ ] Batı ekranları.
- [ ] Vedik ekranları.
- [ ] Gezegen Saatleri.
- [ ] Çin/BaZi.
- [ ] Numeroloji.
- [ ] Spiritüel.
- [ ] Kişisel Gelişim.
- [ ] Kayıtlar/Profiller.
- [ ] Danışanlar.
- [ ] Profil/Ayarlar.
- [ ] Her ekranı onaylı reference image ile golden test et.
- [ ] Statik geometry farkında asset’i düzelt; kodla yeniden çizme.
- [ ] Dinamik chart farkında renderer matematiğini düzelt.
- [ ] TR ve EN büyük metin overflow testini her ana ekranda çalıştır.
- [ ] Her dokunulabilir öğe için interaction test yaz.

## FAZ 19 — PROFESYONEL ÇALIŞMA AKIŞLARI

- [ ] Client CRUD.
- [ ] Consultation CRUD.
- [ ] Notes CRUD.
- [ ] Tags.
- [ ] Client search.
- [ ] Professional presets.
- [ ] Danışmanlık Hazırlığı.
- [ ] Important transit extraction.
- [ ] Dasha/Gochara preparation.
- [ ] Numerology consultation preparation.
- [ ] Tek Ekran Danışmanlık Modu.
- [ ] Previous session history.
- [ ] Follow-up reminder.
- [ ] Custom interpretation library.
- [ ] Custom interpretation templates.
- [ ] Tarot session workflow.
- [ ] Coach/client goals workflow.
- [ ] Learning Mode.
- [ ] Teaching view.
- [ ] Social/share cards.
- [ ] 1.000 client performance test.
- [ ] 10.000 profile stress test.

## FAZ 20 — LOCAL NOTIFICATIONS

- [ ] Notification category model.
- [ ] Planetary-hour alerts.
- [ ] Moon phase alerts.
- [ ] Transit alerts.
- [ ] Retrograde alerts.
- [ ] Personal-period alerts.
- [ ] Günün mesajı notification.
- [ ] Permission denied fallback.
- [ ] Timezone değişim reschedule.
- [ ] Device reboot behavior.
- [ ] Notification spam safeguards.

## FAZ 21 — FREE / PRO / REKLAM ENTITLEMENT

- [ ] Merkezi Feature ID kataloğu.
- [ ] Free matrix.
- [ ] PRO matrix.
- [ ] Temporary ad-unlock matrix.
- [ ] UI, route ve service aynı entitlement source’a baksın.
- [ ] Free kullanıcı temel doğruluğu kaybetmesin.
- [ ] PRO kullanıcı bütün PRO yollarına erişsin.
- [ ] Offline PRO behavior.
- [ ] Purchase restore.
- [ ] App reinstall restore.
- [ ] Device change restore mağaza imkanları dahilinde.
- [ ] PRO → Free durumunda veri silinmesin.
- [ ] Free → PRO durumunda eski kayıtlar korunsun.
- [ ] Reklam yüklenemezse uygulama crash olmasın.
- [ ] Client-side lisans korumasının sınırları doğru ele alınsın.

## FAZ 22 — CSV / TAM YEDEKLEME VE RESTORE

- [ ] Backup package spec dokümante et.
- [ ] UTF-8 standardı.
- [ ] `schemaVersion`.
- [ ] `appVersion`.
- [ ] `engineVersion`.
- [ ] Export timestamp.
- [ ] Manifest.
- [ ] File checksums.
- [ ] `profiles.csv`.
- [ ] `clients.csv`.
- [ ] `consultations.csv`.
- [ ] `notes.csv`.
- [ ] `calculations.csv`.
- [ ] `calculation_manifests.csv`.
- [ ] `journal_entries.csv`.
- [ ] `goals.csv`.
- [ ] `habits.csv`.
- [ ] `tarot_sessions.csv`.
- [ ] `favorites.csv`.
- [ ] `settings.csv`.
- [ ] Professional templates export.
- [ ] Binary assets ayrı klasör.
- [ ] CSV quote/newline/comma escaping.
- [ ] Unicode/Türkçe karakter round-trip.
- [ ] Null/empty/zero ayrımı.
- [ ] Locale bağımsız number format.
- [ ] ISO date format.
- [ ] Locale bağımsız enum IDs.
- [ ] Import schema validation.
- [ ] Checksum validation.
- [ ] Foreign-key validation.
- [ ] Preview counts.
- [ ] Merge mode.
- [ ] Replace mode.
- [ ] Pre-replace safety snapshot.
- [ ] Transactional import.
- [ ] Failure rollback.
- [ ] Duplicate ID policy.
- [ ] TR → EN restore.
- [ ] EN → TR restore.
- [ ] Old-schema restore.
- [ ] Thousands-of-records stress test.
- [ ] Export → clean install → import golden round-trip.

## FAZ 23 — PROFESYONEL PDF MOTORU

- [ ] PDF tamamen local üretilecek.
- [ ] A4 layout engine.
- [ ] Typography tokens.
- [ ] Unicode TR/EN font support.
- [ ] Vektörel Western chart.
- [ ] Vektörel Vedik chart.
- [ ] BaZi tabloları.
- [ ] Numerology tabloları.
- [ ] Professional cover.
- [ ] Client-friendly cover.
- [ ] Optional professional logo.
- [ ] Optional professional name/brand.
- [ ] Section selector.
- [ ] Section ordering.
- [ ] Empty section suppression.
- [ ] Technical manifest section.
- [ ] Client-friendly simplified section.
- [ ] Custom notes section.
- [ ] Western report template.
- [ ] Vedic report template.
- [ ] Numerology report template.
- [ ] Combined report template.
- [ ] Free sample PDF preview.
- [ ] Demo data gerçek kullanıcı verisine karışmasın.
- [ ] Preview → real PDF layout consistency.
- [ ] Page numbering.
- [ ] Controlled page breaks.
- [ ] Heading orphan prevention.
- [ ] Table split prevention.
- [ ] 5-page test.
- [ ] 25-page test.
- [ ] 50+ page test.
- [ ] Low-memory PDF test.
- [ ] PDF open/parse validation.
- [ ] Visual regression.
- [ ] Chart crop detection.
- [ ] Missing glyph detection.
- [ ] PDF ile UI calculation snapshot eşitliği.

## FAZ 24 — TÜRKÇE / İNGİLİZCE FINAL LOCALIZATION

- [ ] Merkezi terminology glossary.
- [ ] Western terminology glossary.
- [ ] Vedic terminology glossary.
- [ ] Numerology terminology glossary.
- [ ] TR key parity.
- [ ] EN key parity.
- [ ] TR → EN system-text leakage testi.
- [ ] EN → TR system-text leakage testi.
- [ ] Kullanıcı notlarının çevrilmediğini doğrula.
- [ ] Müşteri adlarının localization’dan geçmediğini doğrula.
- [ ] PDF TR/EN parity.
- [ ] Notification TR/EN parity.
- [ ] Daily message TR/EN completeness.
- [ ] Interpretation TR/EN completeness.

## FAZ 25 — GÜVENLİK / GİZLİLİK

- [ ] Secure storage.
- [ ] Keystore tabanlı secret handling.
- [ ] Local DB encryption kararını uygula ve belge.
- [ ] PIN lock.
- [ ] Biometrics.
- [ ] Safe fallback.
- [ ] Production log sanitization.
- [ ] Müşteri adı/log yasağı.
- [ ] Doğum verisi/log yasağı.
- [ ] Consultation note/log yasağı.
- [ ] User full-delete.
- [ ] Client delete.
- [ ] Cascade rules.
- [ ] Export yalnız kullanıcı isteğiyle.
- [ ] Analytics çekirdek kullanım için zorunlu olmasın.

## FAZ 26 — PERFORMANS + ACCESSIBILITY + RESPONSIVE

- [ ] Small Android phone.
- [ ] Large Android phone.
- [ ] Tablet portrait.
- [ ] Tablet landscape.
- [ ] Professional split-screen layout.
- [ ] Large font scaling.
- [ ] Minimum touch targets.
- [ ] Screen reader labels.
- [ ] Contrast checks.
- [ ] Bilginin yalnız renkle verilmediğini doğrula.
- [ ] TR overflow.
- [ ] EN overflow.
- [ ] Keyboard/form behavior.
- [ ] City search performance.
- [ ] Client search performance.
- [ ] Lazy loading.
- [ ] Cache correctness.
- [ ] Cache invalidation on engine version.
- [ ] Low-memory calculation test.
- [ ] Low-memory PDF test.

## FAZ 27 — OFFLINE / SUNUCUSUZ KANIT

- [ ] Network-call inventory oluştur.
- [ ] Her network çağrısının gerekçesini belge.
- [ ] Calculation core’da network çağrısı olmadığını doğrula.
- [ ] PDF’de network çağrısı olmadığını doğrula.
- [ ] CSV’de network çağrısı olmadığını doğrula.
- [ ] Client management’da network çağrısı olmadığını doğrula.
- [ ] Uçak modunda Batı çalışsın.
- [ ] Uçak modunda Vedik çalışsın.
- [ ] Uçak modunda Çin/BaZi çalışsın.
- [ ] Uçak modunda Numeroloji çalışsın.
- [ ] Uçak modunda Gezegen Saatleri çalışsın.
- [ ] Uçak modunda Bugün/DailySnapshot çalışsın.
- [ ] Uçak modunda stok Günün Mesajı çalışsın.
- [ ] Uçak modunda profesyonel kayıtlar çalışsın.
- [ ] Uçak modunda CSV export/import çalışsın.
- [ ] Uçak modunda PDF çalışsın.
- [ ] Yalnız mağaza/reklam/dış paylaşım gibi gerçekten internet isteyen akışlar ayrı kalsın.

## FAZ 28 — CLEAN CHECKOUT / REPRODUCIBLE BUILD

- [ ] Build için gerekli tüm code/config repository’de olsun.
- [ ] Lockfile’lar repository’de olsun.
- [ ] Ephemeris/data manifestleri repository’de olsun.
- [ ] IANA data manifesti repository’de olsun.
- [ ] City dataset manifesti repository’de olsun.
- [ ] UI reference manifesti repository’de olsun.
- [ ] Asset manifesti repository’de olsun.
- [ ] Font manifesti repository’de olsun.
- [ ] Daily message manifesti repository’de olsun.
- [ ] Dependency/license manifesti repository’de olsun.
- [ ] Clean checkout CI job oluştur.
- [ ] Dependency install.
- [ ] Data checksum verification.
- [ ] Asset checksum verification.
- [ ] Message-catalog verification.
- [ ] TR/EN verification.
- [ ] Tests.
- [ ] Release APK build.
- [ ] APK smoke test.
- [ ] Signing secret dışında geliştirici makinesine özgü hiçbir gizli dosya gerekmemeli.

## FAZ 29 — GOLDEN LIFECYCLE TEST

- [ ] Clean install.
- [ ] Dil seç.
- [ ] Profil oluştur.
- [ ] Batı natal chart oluştur.
- [ ] Vedik chart oluştur.
- [ ] Numeroloji oluştur.
- [ ] BaZi oluştur.
- [ ] Gezegen saatini aç.
- [ ] Bugün ekranını doğrula.
- [ ] Müşteri oluştur.
- [ ] Consultation oluştur.
- [ ] Not oluştur.
- [ ] PDF oluştur.
- [ ] Full backup oluştur.
- [ ] App data temizle.
- [ ] Backup restore et.
- [ ] Bütün profile/client/not verilerini karşılaştır.
- [ ] Bütün calculation manifestlerini karşılaştır.
- [ ] Aynı hesaplamaları yeniden doğrula.
- [ ] Restore sonrası tekrar PDF üret.
- [ ] Restore öncesi/sonrası calculation eşitliğini kontrol et.
- [ ] TR Free suite.
- [ ] TR PRO suite.
- [ ] EN Free suite.
- [ ] EN PRO suite.
- [ ] Offline suite.
- [ ] Upgrade/migration suite.

## FAZ 30 — FINAL REQUIREMENT AUDIT VE RELEASE KAPISI

- [ ] Requirement Matrix toplamı tam **1.442** olsun.
- [ ] RC-0001 mevcut olsun.
- [ ] RC-1442 mevcut olsun.
- [ ] Arada hiçbir ID atlanmasın.
- [ ] Duplicate ID olmasın.
- [ ] Hiçbir zorunlu RC `NOT_STARTED` kalmasın.
- [ ] Hiçbir zorunlu RC yalnız `IMPLEMENTED` seviyesinde kalmasın.
- [ ] Bütün zorunlu RC’ler `DONE` olsun.
- [ ] Calculation coverage tam olsun.
- [ ] Interpretation coverage tam olsun.
- [ ] 10-year rolling daily-message horizon yeşil olsun.
- [ ] Daily message exact-date completeness yeşil olsun.
- [ ] Daily message TR/EN parity yeşil olsun.
- [ ] Leap-year suite yeşil olsun.
- [ ] Timezone/DST suite yeşil olsun.
- [ ] Western golden suite yeşil olsun.
- [ ] Vedic golden suite yeşil olsun.
- [ ] Planetary-hour golden suite yeşil olsun.
- [ ] Chinese/BaZi golden suite yeşil olsun.
- [ ] Numerology golden suite yeşil olsun.
- [ ] Dynamic geometry golden suite yeşil olsun.
- [ ] UI visual regression yeşil olsun.
- [ ] UI interaction coverage yeşil olsun.
- [ ] Accessibility suite yeşil olsun.
- [ ] TR/EN leakage suite yeşil olsun.
- [ ] Free/PRO matrix yeşil olsun.
- [ ] Backup round-trip yeşil olsun.
- [ ] PDF visual/data regression yeşil olsun.
- [ ] Security/privacy audit yeşil olsun.
- [ ] Performance suite yeşil olsun.
- [ ] Airplane-mode suite yeşil olsun.
- [ ] Clean-checkout build yeşil olsun.
- [ ] Golden Lifecycle suite yeşil olsun.
- [ ] Release build debug değil gerçek release olsun.
- [ ] Exact commit SHA kaydedilsin.
- [ ] APK SHA/hash kaydedilsin.
- [ ] Dataset sürümleri kaydedilsin.
- [ ] UI reference sürümü kaydedilsin.
- [ ] Requirement coverage raporu release artifact olarak saklansın.
- [ ] Tek bir kritik kapı kırmızıysa `FINAL` etiketi verilmesin.

---

# DONE TANIMI

Bir görev ancak aşağıdaki uygulanabilir kapıların **tamamı** geçerse DONE sayılır:

- Kodlandı.
- Unit/integration/golden testleri geçti.
- Calculation reference doğrulaması geçti (uygunsa).
- Interpretation coverage doğrulaması geçti (uygunsa).
- Onaylı UI reference ile görsel doğrulama geçti (uygunsa).
- Interaction testi geçti (uygunsa).
- Türkçe tamamlandı (uygunsa).
- İngilizce tamamlandı (uygunsa).
- Offline testi geçti (uygunsa).
- Free testi geçti (uygunsa).
- PRO testi geçti (uygunsa).
- Backup round-trip geçti (uygunsa).
- PDF doğrulaması geçti (uygunsa).
- Accessibility doğrulaması geçti (uygunsa).
- Performance doğrulaması geçti (uygunsa).
- Regression testi eklendi.
- Requirement Matrix’te kanıt bağlantısı mevcut.

**Bu kapılar tamamlanmadan Ruh Code için “tamam”, “final” veya “kusursuz” ifadesi kullanılmayacak.**
