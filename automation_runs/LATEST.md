# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-03_0854_rc1437_body_graph_progress.md`

## Bu turda ilerleyen ana bloklar

1. Previous exact `889bb06a...` baseline yeniden okundu; 25 workflow indexlendi ve `RC-1437 Runtime Assets` SUCCESS doğrulandı.
2. `SpkBodyGraphEvaluator` eklendi: target→center zinciri SSB root'a kadar çözülüyor; observer path ayrı çözülüp çıkarılıyor.
3. Missing-center, cycle, unsupported frame ve unsupported SPK type durumları fail-closed yapıldı.
4. Synthetic graph contract testleri Earth→EMB→SSB toplama/çıkarma ve hata yollarını doğruluyor.
5. Gerçek packaged DE440s üzerinde Earth(399)→EMB(3)→SSB(0) J2000 runtime graph testi eklendi.
6. Dedicated `RC-1437 Runtime Assets` workflow artık body/center contract ve real packaged graph testlerini de çalıştırıyor.
7. Independent JPL/NAIF golden vector ve RC-1436 tolerance evidence henüz eklenmedi; bu nedenle `planetaryEphemeris.proven` ve requirement ledger değiştirilmedi.

Engineering commit chain:

- `25cceeec27d2386421b48badd4d45b88e165b781`
- `15e6c583a3dae6a2ceaacb1c47b46fe1fece9e48`
- `faa24c92bd4b0c097d11e28f90d08a688f4984e7`
- `f1bb924d8bd37c793a50c319aed22e082adc955a`
- `dd2394de5097a008d49118de8445fc17fe4ae7f7`

Checkpoint commit:

- `b508a8548800b316cdaa15d1145d11186278f004`

Sonraki dependency: exact current HEAD CI completion → official JPL/NAIF geometric J2000 KM-S golden vectors + provenance → RC-1436 tolerance comparison → strict RC-1437 evidence.

**FINAL: NO.**
