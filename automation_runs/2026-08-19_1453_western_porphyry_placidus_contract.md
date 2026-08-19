# Ruh Code Automation Checkpoint — Western Porphyry + Placidus Contract

## Bu turda yapılan gerçek işler

1. `lib/src/calculation_core/western/porphyry_houses.dart` eklendi.
   - ASC/IC/DSC/MC angular cuspları korunuyor.
   - Her ecliptic quadrant üç eşit ecliptic arca bölünüyor.
   - 0°/360° wrap deterministik.
   - Exact cusp longitude ilgili yeni house'a atanıyor.
   - Invalid/non-finite ve degenerate angular geometry reddediliyor.
   - Başka bir house sisteminden Porphyry'ye fallback kararı bu motorun içinde sessizce yapılmıyor.

2. `test/calculation_core/western/porphyry_houses_test.dart` eklendi.
   - Angular cusp koruması.
   - Equal quadrant trisection.
   - Unequal quadrant + zodiac wrap.
   - Exact cusp assignment.
   - Invalid/degenerate input rejection.

3. `evidence/astronomy/western_porphyry_houses.json` eklendi.
   - RC-0060/0061/0262/0268/1436 mapping.
   - Swiss Ephemeris house documentation yalnız reference role'ünde; runtime dependency değil.
   - Independent end-to-end golden proof henüz false.

4. `tools/astronomy/validate_western_porphyry_houses.py` ve `Western Porphyry House Contract` workflow eklendi.

5. Placidus için implementasyondan önce strict contract kilitlendi:
   - `evidence/astronomy/western_placidus_contract.json`
   - `tools/astronomy/validate_western_placidus_contract.py`
   - `.github/workflows/western-placidus-contract.yml`
   - Semidiurnal/seminocturnal arc tanımı.
   - Max 100 iteration contract.
   - Convergence zorunlu.
   - Non-convergence = UNAVAILABLE.
   - Silent fallback yasak.
   - Explicit optional fallback = PORPHYRY.
   - Polar bölgelerde invented cusp yasak.
   - House-cusp acceptance budget 0.05°; independent golden proof zorunlu ve henüz false.

## Referans kararı

Swiss Ephemeris resmi dokümantasyonu Placidus'u semidiurnal/seminocturnal arc bölünmesiyle tanımlıyor, yüksek enlemlerde convergence hassasiyetini ve polar-limit sorununu belgeliyor. Programmer manual, Placidus hesaplanamadığında Porphyry fallback davranışını belgeliyor. Ruh Code bu kaynakları bağımsız reference olarak kullanacak; Swiss Ephemeris'i sessiz runtime dependency yapmayacak.

## Commit zinciri

- Porphyry source: `a925bb2b981a785f5444806070c8feabb12f0188`
- Porphyry tests: `4151e6057b57235995c7c24fd484689a2a6d3419`
- Porphyry evidence: `9e3b0d3d79002d07994e6d47d7c7e846583b3d6b`
- Porphyry validator: `44c5589e1007f5aaf93671bdf1e2437fc98b5c88`
- Porphyry workflow: `5d2ac858c413ae7bd60808aea67e472991628459`
- Placidus contract: `ff758f0a1346d3f219853bfb58620a3942472ed6`
- Placidus validator: `5b617f80475e24559264f20f7f64f80d5fa2c813`
- Placidus workflow: `92dc24123c792552705485bfb7bf90a444d207a6`

## Kanıt durumu

GitHub combined-status endpoint latest exact commit için `statuses=[]` döndürdü. Dolayısıyla workflow SUCCESS uydurulmadı. Flutter unit testleri GitHub runner tarafından görünür biçimde SUCCESS olmadan RC-0060 DONE yapılmayacak. Placidus solver henüz yazılmadığından RC-0054/0265 kesinlikle DONE değil.

## Sıradaki bağımlılık sırası

1. Placidus solver matematiğini strict result type ile uygula: SUCCESS / UNAVAILABLE / explicit PORPHYRY_FALLBACK metadata.
2. Solver convergence testleri: normal latitude, high latitude, near-polar non-convergence/unsupported.
3. Independent Placidus/ASC/MC golden dataset bağla; 0.05° budget'i gerçek reference ile kanıtla.
4. Physical/versioned EOP + offline ephemeris artifact zincirini devam ettir.
5. GeoNames physical source/output SHA ve bulk timezone integrity.
6. Daily Message 8.036 gerçek editoryal kayıt.
7. Yeni `Bugün · Araçlar · Kayıtlar · Profil` APPROVED UI reference seti.

**FINAL DEĞİL.**
