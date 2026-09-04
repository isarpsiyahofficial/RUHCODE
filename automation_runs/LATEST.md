# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-05_0252_rc0025_rc0028_progress.md`

## Bu turda doğrulanmış ilerleme

1. RC-0025'in ilk kırmızı CI root cause'u exact logdan bulundu: production source calendar-boundary ownership'i semantic olarak ayırmasına rağmen validator explicit `Chinese New Year` açıklaması istiyordu. Production sözleşme açıklaması `f5ee2924eb5c1112f38237a2a6e8b3f87df21d55` ile düzeltildi. Corrected run concurrency kuyruğunda job başlamadan cancelled olduğu için RC-0025 hâlâ physical promotion bekliyor.
2. RC-0026 kırmızı CI root cause'u düzeltildi: test var olmayan `CalculationValidity.invalid` kullanıyordu; canonical `CalculationValidity.error` ile düzeltildi (`0fd2332c753ae830793ed28bce1471aa76cb3e4c`). Bot promotion `5b4083585337774d709f783bfb309bd6d5ed11a2` ile **RC-0026 = TESTED + blocked=YES** fiziksel olarak doğrulandı.
3. RC-0027 için numeroloji production ağacının Western/Vedic/Chinese/BaZi/ephemeris hesaplama yollarından bağımsızlığını tarayan fail-closed contract + validator + CI eklendi. Pythagorean/Chaldean/Lo Shu compiled golden vectors aynı gate'te çalıştırılıyor. Promotion henüz fiziksel görülmedi.
4. RC-0028 için Western/Vedic/Chinese/BaZi/Numerology named system root'ları arasında cross-system calculation importlarını yasaklayan architecture contract + validator + representative compiled regression CI eklendi. Promotion henüz fiziksel görülmedi.
5. RC-0020 corrected solar-events gate physical promotion eksikliği açık tutuluyor; hiçbir pending requirement yalnız kod yazıldığı için yükseltilmedi.

Sonraki dependency: RC-0025 corrected physical rerun/promotion → RC-0027/28 exact CI + promotion/root-cause → RC-0020 physical promotion → RC-0029+.

**FINAL: NO.**
