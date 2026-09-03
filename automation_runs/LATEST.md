# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-03_0654_rc1437_type2_evaluator_progress.md`

## Bu turda ilerleyen ana bloklar

1. Previous `40da4cad...` baseline'ın 25 workflow'u yeniden okundu; City Catalog Contract'ın gerçekten RED olduğu ve kök nedenin Flutter directory asset declaration false-negative olduğu decoded job log ile kanıtlandı.
2. `SpkType2Evaluator` eklendi: Type-2 INIT/INTLEN/RSIZE/N directory, exact record selection, MID/RADIUS, Chebyshev position ve derivative velocity hesapları fail-closed uygulanıyor.
3. Deterministic synthetic Type-2 matematik testleri eklendi.
4. Gerçek packaged DE440s üzerinde J2000'ı kapsayan Type-2 segment için numerical runtime evaluation testi eklendi; forbidden zero/default state reddediliyor.
5. Dedicated `RC-1437 Runtime Assets` workflow artık fiziksel validator sonrası hem synthetic evaluator testini hem gerçek packaged DE440s Type-2 runtime testini çalıştırıyor.
6. City Catalog validator exact-file veya containing-directory Flutter asset declaration kabul edecek şekilde düzeltildi; SHA/size/record-count/unique-ID/timezone/attribution kontrolleri korunuyor.
7. `planetaryEphemeris.proven` ve requirement ledger değiştirilmedi; independent golden vectors ve body/center chaining henüz eksik olduğundan RC-1437 DONE değildir.

Engineering commit chain:

- `dda4106a1ff861e19491bb522baefced1e4d9dd8`
- `91d54d07f437757106954bb5eb12decd868b908b`
- `89de69cf6aca929c1bca8a497ecde8d3052d0361`
- `d6dfcb3f31b7b7a965f5f544d3a3162e429a81a6`
- `d9ac37b0a043d82f781fbd1596a3ae326a480f35`

Sonraki dependency: exact current HEAD CI completion → body/center graph chaining → independent NAIF/JPL golden vectors + RC-1436 tolerances → strict RC-1437 evidence.

**FINAL: NO.**
