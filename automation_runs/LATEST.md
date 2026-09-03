# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-03_1652_rc1437_eop_capability_policy.md`

## Bu turda ilerleyen ana bloklar

1. Exact baseline `9ee8540e731a8f4e6307655062477d91cf351076` yeniden kontrol edildi; failure-filtered Actions sorgusunda kırmızı run bulunmadı.
2. 1890→2110 ürün tarih aralığı ile daha dar fiziksel IERS EOP kapsamı artık ayrı, versioned runtime capability olarak modelleniyor.
3. Ürün aralığında olup published EOP coverage dışında kalan UT1-dependent hesaplar `EOP_OUTSIDE_PUBLISHED_COVERAGE` ile fail-closed; UTC=UT1 substitution, nearest-neighbour, extrapolation ve fabricated future EOP yok.
4. `earth_orientation_capability_policy_test.dart` ürün sınırlarını, fiziksel coverage durumunu ve fail-closed davranışı doğruluyor.
5. Stale Earth Orientation manifesti gerçek fiziksel IERS durumuna hizalandı: `BUNDLED_VERIFIED_SUBGATE`; `fullRc1437Done=false` korunuyor.
6. Validator fiziksel `finals2000A.all` byte-size/SHA-256 değerlerini manifest ve runtime loader ile çapraz doğruluyor.
7. Earth Orientation CI gate yeni capability testini ve gerçek packaged IERS loader testini çalıştıracak şekilde genişletildi.
8. Requirement ledger değiştirilmedi; RC-1436/RC-1437 bütünüyle DONE sayılmadı.

Sonraki dependency: exact current CI → daha geniş independent official ephemeris golden/tolerance coverage → RC-1439 → signed reproducible release + real-device gates.

**FINAL: NO.**
