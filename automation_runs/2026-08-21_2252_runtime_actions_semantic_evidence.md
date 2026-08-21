# Ruh Code automation checkpoint — 2026-08-21 22:52

## Scope advanced in this run

This run continued from the latest requirement/a11y checkpoint and deliberately avoided promoting any RC to DONE without visible workflow evidence.

### Runtime UI / RC-1432 / RC-1440 / RC-1441

- Corrected the live Tools information architecture to the canonical hierarchy: `Araçlar → Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim`; Astrology then exposes Western, Vedic, Chinese, BaZi and Planetary Hours.
- Kept the primary bottom navigation exactly `Bugün · Araçlar · Kayıtlar · Profil`; ambiguous exact `Hesapla` remains absent.
- Added canonical runtime `ACTION-*` constants and `ui/runtime_action_bindings.csv`.
- Added structural validation tying each implemented runtime action to an ACTIVE action-registry row.
- Added Feature-ID/access-tier parity validation between runtime bindings, action registry and `RuhFeatureCatalog`.
- Found and corrected a real access drift: action registry defined BaZi basic as PRO while the runtime Feature Catalog defined it Free. Runtime now matches the registry: Chinese basic is Free, BaZi basic is PRO.
- Added explicit Semantics button labels and a 48dp minimum height wrapper for current action tiles.
- Expanded widget contracts for four top-level Tools categories, Tools→Astrology navigation, Chinese Free/BaZi PRO behavior, Settings, semantics, minimum action height and a 360×800 / 2.0x text-scale critical navigation path.
- Removed internal development wording from the user-facing Settings placeholder.

### Semantic evidence ownership audit

The central `tools/requirements/validate_evidence_traceability.py` contract now covers Numerology, BaZi, PDF, Backup and Entitlement evidence families.

Fixed concrete evidence overclaims found during the audit:

1. `evidence/pdf/numerology_data_adapter.json` incorrectly claimed RC-1224 and RC-1225, which are calculation-cache key/invalidation requirements. They were removed; the adapter now owns only the PDF/numerology requirements it actually proves.
2. `evidence/backup/schema_registry_contract.json` claimed RC-0788 (`tarot_cards.csv`) although the current portable schema has no standalone `tarot_cards.csv`. RC-0788 was removed from that evidence and left as an explicit unresolved product/schema decision rather than being falsely marked covered.
3. `evidence/backup/full_lifecycle_contract.json` claimed RC-1442 clean-checkout reproducibility, which a backup lifecycle test cannot prove. RC-1442 was removed from that evidence.
4. `evidence/entitlements/feature_policy_contract.json` previously had no exact RC ownership. It now conservatively binds the data-preservation, central Feature-ID, Free/PRO, temporary entitlement, local clock protection, store restore, offline-PRO and offline-start requirements that its source/tests actually address. RC-1102/1103 ad-SDK behavior remains explicitly unclaimed until a production ad adapter/real-device proof exists.

### PDF evidence freshness

- Refreshed `evidence/pdf/report_planning_contract.json` so it no longer says a local PDF byte renderer is absent.
- Current blockers remain explicit: approved Unicode fonts/license/hash, real 5/25/50+ production renders, production Western painter/glyphs, Vedic vector chart, BaZi tables, low-memory/parser/glyph/crop/visual regression, approved PDF references and exact workflow SUCCESS.

## Validation status

- GitHub combined-status for the UI contract target still returned no individual statuses (`statuses=[]`).
- A clean local clone/test attempt was blocked by the execution environment failing to resolve `github.com`; this was not treated as project success or project failure.
- No CI SUCCESS was invented.
- No affected requirement was promoted to DONE solely from source-level implementation.

## Open blockers / next work

1. Resolve the remaining action-registry PDF policy inconsistency before binding the Settings/PDF production UI: sample PDF preview must remain Free while actual professional generation is PRO.
2. Continue semantic evidence audit across remaining contracts, especially backup subcontracts, interpretation/content, astronomy and release/build evidence.
3. Decide/implement the RC-0788 standalone `tarot_cards.csv` behavior without making it silently mandatory for existing schema-v1 backups.
4. Replace placeholder category/feature screens with approved production references while preserving the canonical ACTION/Feature-ID bindings.
5. Obtain exact Flutter/UI/entitlement workflow evidence; fix any real red checks before state promotion.
6. Physical astronomy/EOP/ephemeris/Lahiri/GeoNames, 8,036 editorial daily messages, approved UI PNG references, production PDF fonts and clean-checkout `pubspec.lock` remain release blockers.

**FINAL: NO.**
