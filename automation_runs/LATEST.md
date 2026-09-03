# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-03_0854_rc1437_body_graph_progress.md`

## Bu turda ilerleyen ana bloklar

1. Previous exact `889bb06a...` baseline yeniden okundu; 25 workflow indexlendi ve `RC-1437 Runtime Assets` SUCCESS doğrulandı.
2. `SpkBodyGraphEvaluator` eklendi: target→center zinciri SSB root'a kadar çözülüyor; observer path ayrı çözülüp çıkarılıyor.
3. Missing-center, cycle, unsupported frame ve unsupported SPK type durumları fail-closed yapıldı.
4. Synthetic graph contract testleri Earth→EMB→SSB toplama/çıkarma ve hata yollarını doğruluyor.
5. Gerçek packaged DE440s üzerinde Earth(399)→EMB(3)→SSB(0) J2000 runtime graph testi eklendi.
6. Dedicated `RC-1437 Runtime Assets` workflow body/center contract ve real packaged graph testlerini de çalıştırıyor.
7. RC-1436 bağlayıcı ölçülebilir-tolerans şartı yeniden doğrulandı.
8. Official NASA/JPL Horizons Earth(399)/SSB(0) J2000 state vectorünü exact query + API signature + raw-response SHA-256 provenance ile materyalize eden fail-closed script ve workflow eklendi. Live canonical golden henüz capture edilmedi; sayı uydurulmadı.
9. `planetaryEphemeris.proven` ve requirement ledger değiştirilmedi.

Engineering commit chain:

- `25cceeec27d2386421b48badd4d45b88e165b781`
- `15e6c583a3dae6a2ceaacb1c47b46fe1fece9e48`
- `faa24c92bd4b0c097d11e28f90d08a688f4984e7`
- `f1bb924d8bd37c793a50c319aed22e082adc955a`
- `dd2394de5097a008d49118de8445fc17fe4ae7f7`
- `9fabd5ff33071a1440f8d3ffca86bf290a0004a0`
- `f83417c7dcf4bbe0a0df1c367d1d7700427c277f`

Checkpoint update:

- `9e3245dfe7303c8adf88c11bfb6fd463826ddef0`

Sonraki dependency: exact body-graph CI completion → live official Horizons canonical golden → explicit RC-1436 comparator/tolerance evidence → strict RC-1437 evidence.

**FINAL: NO.**
