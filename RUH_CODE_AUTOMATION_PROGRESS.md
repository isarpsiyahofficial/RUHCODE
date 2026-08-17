# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 başlatıldı.
- `tools/requirements/validate_requirements.py` eklendi.
- `tools/requirements/build_requirement_matrix.py` eklendi.
- `requirements/requirement_state.csv` kalıcı durum override deposu eklendi.
- `.github/workflows/requirements-contract.yml` eklendi.
- GitHub Actions `Requirements Contract` run #1 başarıyla geçti (`7bf0b567dcecf812ed738f3e22fe343d87b0980b`).
- CI şu anda bağlayıcı iki şartname dosyasından tam 1.442 sıralı/benzersiz RC bulunduğunu kanıtlıyor.
- Matrix üreticisi her RC için varsayılan `NOT_STARTED` durumu ve benzersiz `TASK-RC-xxxx` kimliği üretiyor.
- Kalıcı state dosyasında bir RC `DONE` yapılırsa tanımlı kanıt türü ve kanıt bağlantısı olmadan matrix üretimi başarısız oluyor.

## Faz 0 — kanıtlanmış tamamlanan görevler

- [x] `RC-0001 → RC-1442` için tek makine üretimli Requirement Traceability Matrix altyapısı oluşturuldu.
- [x] Matrix sözleşmesinin tam 1.442 benzersiz RC ID içermesi CI ile doğrulandı.
- [x] Eksik RC ID olduğunda validator/CI başarısız olacak.
- [x] Duplicate RC ID olduğunda validator/CI başarısız olacak.
- [x] Her RC için `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` durum sözleşmesi oluşturuldu.
- [x] Her RC için varsayılan benzersiz `TASK-RC-xxxx` eşlemesi oluşturuldu.
- [ ] CALC etiketlemesi tamamlanmadı.
- [ ] CONTENT etiketlemesi tamamlanmadı.
- [ ] UI etiketlemesi tamamlanmadı.
- [ ] I18N etiketlemesi tamamlanmadı.
- [ ] OFFLINE etiketlemesi tamamlanmadı.
- [ ] ENTITLEMENT etiketlemesi tamamlanmadı.
- [ ] BACKUP etiketlemesi tamamlanmadı.
- [ ] PDF etiketlemesi tamamlanmadı.
- [ ] SECURITY etiketlemesi tamamlanmadı.
- [ ] A11Y etiketlemesi tamamlanmadı.
- [ ] PERF etiketlemesi tamamlanmadı.
- [ ] RELEASE etiketlemesi tamamlanmadı.
- [ ] Her RC için gerekli kanıt türü henüz tek tek sınıflandırılmadı.
- [x] Kanıtı tanımlanmamış veya kanıt bağlantısı bulunmayan bir RC'nin `DONE` olmasını engelleyen sözleşme eklendi.

## Sıradaki çalışma

Faz 0 devam edecek. Öncelik, `RC-0001 → RC-1442` gereksinimlerini içeriklerine göre tek tek sınıflandırarak doğru `CALC / CONTENT / UI / I18N / OFFLINE / ENTITLEMENT / BACKUP / PDF / SECURITY / A11Y / PERF / RELEASE` etiketlerini ve gerekli kanıt türlerini `requirements/requirement_state.csv` içine yerleştirmektir. Sınıflandırma tamamlanmadan Faz 0 tam DONE kabul edilmeyecek.

## Final durumu

**FINAL DEĞİL.** Uygulama kodlamasına geçilmedi; yalnız şartname izlenebilirlik altyapısının ilk doğrulanmış kısmı tamamlandı.
