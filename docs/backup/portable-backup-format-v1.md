# Ruh Code Portable Backup Format v1

Format identifier: `ruh-code-portable-backup-v1`

This format is intentionally machine-readable and is not a single opaque proprietary binary. The goal is to keep user data recoverable even if the application is rewritten in the future.

## Package layout

```text
manifest.json
records/
  clients.csv
  profiles.csv
  consultations.csv
  calculations.csv
  notes.csv
  presets.json
assets/
  logos/<asset-id>.<ext>
```

Additional versioned record files may be added while preserving the documented identity/reference rules.

## Professional presets

Professional presets are exported/imported as structured JSON. A preset has a stable `presetId`, a human-readable name, numeric orb settings and user-authored interpretation templates. Orb settings and interpretation templates must not be silently discarded during backup/restore.

## Binary assets

Binary files such as a professional logo are never embedded as base64 in CSV fields. CSV records use a stable reference in the form:

```text
asset:<asset-id>
```

The corresponding binary payload lives below `assets/`. Package-relative paths must not be absolute and must not contain `..` traversal components.

## Reference severity

A missing optional professional logo is recoverable and must be reported as a warning; core customer/profile records remain restorable.

A missing referenced customer/client ID is critical relational corruption. Restore must not silently attach the record to another customer or invent a replacement identity.

## Portability guarantee

CSV and JSON files are UTF-8 machine-readable user-data copies. The application may additionally offer another archive/container representation, but an undocumented opaque proprietary binary must not be the only backup option.

Future Ruh Code implementations must be able to reconstruct the documented records, relationships, preset settings and asset references from this format without depending on the original UI implementation.
