# Ruh Code — 2026-08-21 11:20 checkpoint

## Bu turda tamamlanan source-level işler

1. Canonical Pythagorean numerology snapshot eklendi.
   - `lib/src/calculation_core/numerology/pythagorean_snapshot.dart`
   - Profile + extended name + Pinnacles/Challenges + optional Personal Year/Month/Day + exact Karmic Debt provenance tek snapshot'ta birleşiyor.
   - UI/PDF/interpretation katmanlarının aynı sonuç nesnesini tüketebilmesi hedeflendi.
   - Explicit target date yoksa cihaz tarihi uydurulmuyor.

2. Snapshot consistency ve provenance testleri eklendi.
   - `test/calculation_core/numerology/pythagorean_snapshot_test.dart`
   - 16.08.2026 ve 16.08.2027 exact tarih olarak ayrı tutuluyor.
   - Target date değişince static profile değerlerinin değişmediği kontrol ediliyor.

3. Snapshot evidence + structural validator + CI kapısı eklendi.
   - `evidence/numerology/pythagorean_snapshot.json`
   - `tools/numerology/validate_pythagorean_snapshot.py`
   - `.github/workflows/numerology-snapshot-contract.yml`

4. Kalan CivilDate constructor regression'larından biri Lo Shu testlerinde yakalanıp düzeltildi.
   - Eski `const CivilDate(year: ..., month: ..., day: ...)` kullanımı gerçek `CivilDate(y,m,d)` sözleşmesine geçirildi.

5. Runtime motorunun kendi sonucunu referans olarak kullanmayan, elle hesaplanmış bağımsız numeroloji golden fixture seti eklendi.
   - `evidence/numerology/golden_vectors_v1.json`
   - Pythagorean, Chaldean ve Lo Shu için ayrı fixture'lar.
   - 2028-02-29 Lo Shu leap-day fixture'ı dahil.
   - `test/calculation_core/numerology/golden_vectors_test.dart`
   - `tools/numerology/validate_golden_vectors.py`
   - `.github/workflows/numerology-golden-contract.yml`

6. Canonical Pythagorean snapshot için deterministik SHA-256 calculation identity eklendi.
   - `lib/src/calculation_core/numerology/pythagorean_snapshot_fingerprint.dart`
   - Translation/interpretation prose calculation digest'e dahil edilmiyor.
   - Profile/cycle değerleri ve reduction trace/provenance dahil ediliyor.
   - Target date veya name/calculation değişince digest değişiyor.
   - `test/calculation_core/numerology/pythagorean_snapshot_fingerprint_test.dart`
   - `evidence/numerology/pythagorean_snapshot_fingerprint.json`
   - `tools/numerology/validate_pythagorean_snapshot_fingerprint.py`
   - Snapshot CI workflow fingerprint kapısıyla genişletildi.

7. Numeroloji PDF veri adaptörü eklendi.
   - `lib/src/pdf/pdf_numerology_data.dart`
   - PDF numeroloji değerleri canonical snapshot'tan projekte ediliyor; yeniden hesaplanmıyor.
   - PDF identity canonical snapshot SHA-256 digest'i kullanıyor.
   - `PdfReportDataValidator.requireUiPdfSnapshotParity` ile UI/PDF aynı calculation identity üzerinden doğrulanabilir.
   - User/demo sınırları render öncesi korunuyor.
   - `test/pdf/pdf_numerology_data_test.dart`
   - `evidence/pdf/numerology_data_adapter.json`
   - `tools/pdf/validate_numerology_data_adapter.py`
   - Professional PDF CI workflow numerology parity validator'ı kapsayacak şekilde genişletildi.

## Bu turdaki önemli commitler

- `4c7a98d578a1f1be7ed96c40f9f1081263458747` canonical Pythagorean snapshot
- `ac7a748e288deec77ba1686c9da9f11fea9b12e8` snapshot tests
- `9383030ad17f1cfa211390a6472052eafccb8483` snapshot evidence
- `6f093b8c6742bac87473f3f4d7e3382981e9654b` snapshot validator
- `f0006568c7c6522106896480d7dbcefca8debcf6` snapshot CI
- `f09aaf93ed17b76f0761d90763e9b457e34f82f7` Lo Shu CivilDate regression fix
- `7f2d14c76fafadeeab6f399acfd72b873244ae05` hand-calculated golden vectors
- `2b849419d8686b34777c95a1588330f9faf6ba60` golden regression test
- `09637fd9117344ea2132ee1e7599f2744f44fdbe` golden validator
- `358c4b6594edc79a59f22cc9a8e7e3ac99ebf9fc` golden CI
- `af183ac7b3ab75d47fc063430089a8eb50e0a6eb` snapshot SHA-256 fingerprint
- `c7115805bad0df1085d5d576aaeff12b55b39329` fingerprint tests
- `d147e4ce7fa1b0a9d83a22a16cbec60eca11a489` fingerprint evidence
- `fc11214e2e19688cac7bd1f26e519c259a36f517` fingerprint validator
- `4a36aa4698922a5585d7798db282e92ffc846b22` snapshot CI fingerprint wiring
- `838cf622037cdb06b4fef10166d7ca0a6593a486` numerology PDF adapter
- `4fae654b80f81ad558c3256d801666ff3c74e5c1` PDF parity tests
- `6da0a82f2a3bf56c87f196ca95f9631b70c1d458` PDF numerology evidence
- `812bad352971c7bd1ea1c80d5c333f8ef5fb8254` PDF numerology validator
- `0c6ca87f4759803f8397fc0c821496954adea57d` PDF CI numerology parity wiring

## Kanıt durumu

- `4a36aa4698922a5585d7798db282e92ffc846b22` için GitHub combined-status: `statuses=[]`.
- `0c6ca87f4759803f8397fc0c821496954adea57d` için GitHub combined-status: `statuses=[]`.
- Bu nedenle snapshot/golden/PDF parity RC'leri yalnız source-level ilerlemiş sayılır; CI SUCCESS veya DONE iddiası yapılmadı.

## Açık blocker'lar aynen korunuyor

- Fiziksel/versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- Pre-1972 Delta-T/time-scale yaklaşımı.
- Fiziksel ve ticari yeniden dağıtıma uygun offline ephemeris runtime artifact.
- Independent astronomy accuracy proof.
- Production Lahiri/Chitrapaksha artifact.
- Physical GeoNames source/output hash ve bulk IANA integrity.
- 4.018 TR + bağımsız 4.018 EN gerçek editoryal Günün Mesajı.
- APPROVED UI reference PNG/state seti.
- Production Unicode PDF font binary/license/hash artifact.
- Exact visible Flutter/GitHub Actions SUCCESS kanıtı.

## Sıradaki güvenli çalışma

1. Numerology canonical snapshot/fingerprint'i actual UI presentation modeline bağla; UI'nin ayrı numerology recalc yapmasını engelle.
2. Numerology PDF payload'ını gerçek PDF numerology table renderer'a bağla; physical font olmadığı sürece render DONE deme.
3. Numerology golden fixture kapsamını Balance/Karmic Lessons/Hidden Passion/Personal Cycles/Pinnacles/Challenges/Karmic Debt için genişlet.
4. Faz 13 Çin Astrolojisi/BaZi tarafında blocker-independent calendar/stem-branch arithmetic ve strict boundary contracts'a başla; doğrulanmamış solar-term datası uydurma.
5. Güncel source tree'de kalan obsolete CivilDate constructor örneklerini yakala ve düzelt.
6. Exact workflow sonucu görünür hale gelirse kırmızıları aynı turda düzelt; görünmüyorsa SUCCESS uydurma.
7. Requirement state'i yalnız gerçek test/workflow/evidence kanıtı sonrası yükselt.

**FINAL: HAYIR.**
