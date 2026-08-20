# Ruh Code automation checkpoint — portable backup ZIP + export symmetry foundation

## Bu turda yapılanlar

- `archive ^4.0.9` dependency eklendi; portable ZIP yalnız local/in-memory encode/decode için kullanılıyor.
- `PortableZipBackupCodec` eklendi.
  - Logical `BackupPackageBytes` tek ZIP byte stream'e dönüşüyor.
  - ZIP decode CRC verify ile çalışıyor.
  - zip-slip / `..` / absolute path / backslash / nested member / directory / symlink reddi var.
  - duplicate member, member count, member size ve expanded total size guard var.
  - `manifest.json` ZIP içinde zorunlu.
- Portable ZIP Flutter testleri, evidence manifesti ve structural validator eklendi.
- `PortableBackupFileStore` eklendi.
  - explicit user-selected path contract;
  - `.ruhcode.zip` canonical suffix;
  - local-only `dart:io` save/open;
  - same-directory `.tmp` write + flush + rename;
  - temp cleanup ve read/write size guard.
- File-store Flutter testleri, evidence ve validator eklendi.
- `LocalDatabaseBackupExporter` eklendi.
  - 14 tablo tek DB transaction snapshot içinde okunuyor.
  - record ID sırası deterministik.
  - aynı `BackupSchemaRegistry` export tarafında da kullanılıyor.
  - Profile nested runtime payload -> canonical CSV mapping mevcut.
  - JSON backup alanlarında recursive sorted-key canonical JSON uygulanıyor.
  - storage key / payload id uyuşmazlığı reddediliyor.
  - `exportPackage` çıktısının strict `BackupPackageReader.preview` tarafından kabul edilmesi teste bağlı.
- Export Flutter testleri, evidence ve validator eklendi.
- `Backup CSV Contract` workflow portable ZIP, file-store ve LocalDatabase export validator/test kapsamını içerecek şekilde genişletildi.

## Commit zinciri

- `d204fed87a59d3a968e7df6cd3411fe8808578d4` archive dependency
- `c3ead898f182b1d6bca6d6be9c7c7ae4ae8d74bb` portable ZIP codec
- `a5ed192068e9f43239f3aee11a05338cedc37ad1` ZIP tests
- `45145051dbe34b996b0191c338c9a632fbf9af86` ZIP evidence
- `98b3d2ea4c0b77e2e1a5791888610e53d63be7f1` ZIP validator
- `900925636653f3bac799097333bf8dabea771de6` ZIP CI wiring
- `f3b887368d6f009549dbc0ad2458fb160bc273db` file store initial
- `b46cb70f4c174de12374cbe98153d730c26304ea` file store import fix
- `796aa75829a6358ff21368d4bd75606881f15887` file store tests
- `5e8732d193344e9475ed20f407390682ad15c2e1` async test correction
- `f3cd25ea64aadbd2fdddeac2178884edc12de26e` file-store evidence
- `569b32e01c9222c6c37e8531354a0a996ff51e1a` file-store validator
- `8bb7753a4bc200a17b891a797ed02e8f03d2f97f` file-store CI wiring
- `9cfb66e25c36344fb96056313657597d6dcd19c8` LocalDatabase exporter
- `ef8f973dd4650691fe0a3731673e6ddb924213dc` exporter tests
- `01bd3b8209ebb91dfd328bc7fd1729ae019c7e5e` exporter evidence
- `da5c90a277163f26b71689ec9616e59eb795c99e` exporter validator
- `c33ce557af0fa80ae48dc10deb0f1a5af5bfe6c9` exporter CI wiring

## Kanıt durumu

- Source-level + test/evidence/validator wiring mevcut.
- GitHub combined status latest commit için individual check göstermedi (`statuses=[]`), bu nedenle SUCCESS uydurulmadı.
- `pubspec.lock` repository'de henüz yok; reproducible clean-checkout final kapısı için gerçek `flutter pub get` sonrası lockfile commit edilmesi gerekli.
- Android document picker/share-sheet entegrasyonu henüz yok.
- 14 tablonun tamamında production SQLite export -> ZIP -> import -> domain equality lifecycle kanıtı henüz yok.

## Sıradaki çalışma

1. Exact workflow kırmızıysa aynı turda düzelt.
2. SQLite FFI üzerinde LocalDatabase export -> BackupPackageWriter -> Portable ZIP -> decode -> preview -> production import symmetry testi.
3. Import sonrası domain/storage equality; aynı backup ikinci import idempotency.
4. TR -> EN / EN -> TR locale-independent restore.
5. Legacy schema migration/adoption fixture.
6. Büyük veri stress export/restore.
7. Android document picker/share-sheet adapterı; core file store platform UI'dan ayrı kalacak.
8. `pubspec.lock` clean-checkout reproducibility kapısı.

**FINAL DEĞİL.**
