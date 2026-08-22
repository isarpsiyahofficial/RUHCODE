#!/usr/bin/env python3
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
EVIDENCE = ROOT / "evidence/ui/backup_restore_preview_accessibility_contract.json"
PAGE = ROOT / "lib/src/ui/backup/backup_settings_page.dart"
IDS = ROOT / "lib/src/ui/actions/ruh_action_ids.dart"
EXT = ROOT / "ui/action_registry_runtime_extensions.csv"
BINDINGS = ROOT / "ui/runtime_action_bindings.csv"
TEST = ROOT / "test/ui/backup/backup_accessibility_test.dart"

EXPECTED = {832, 833, 834, 835, 836, 837, 838, 839, 1440, 1441}
MASTER_KEYWORDS = {
    832: "önizleme gösterilecek",
    833: "Kaç profil",
    834: "Kaç müşteri",
    835: "Kaç danışmanlık",
    836: "Kaç günlük kaydı",
    837: "Kaç hesaplama",
    838: "Birleştir",
    839: "Mevcut veriyi değiştir",
    1440: "her dokunulabilir öğenin navigation/action sözleşmesi",
    1441: "Accessibility zorunlu olacak",
}


def require_text(path: Path, tokens):
    text = path.read_text(encoding="utf-8")
    for token in tokens:
        if token not in text:
            raise AssertionError(f"{path.relative_to(ROOT)} missing required token: {token}")
    return text


def load_master():
    raw = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    return {int(n): body.strip() for n, body in re.findall(r"^(\d+)\.\s+(.+)$", raw, re.MULTILINE)}


def main():
    payload = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    requirements = payload.get("requirements", [])
    parsed = {int(value[3:]) for value in requirements if re.fullmatch(r"RC-\d{4}", value)}
    if parsed != EXPECTED:
        raise AssertionError(f"Evidence RC ownership mismatch: expected={sorted(EXPECTED)}, actual={sorted(parsed)}")
    if payload.get("done") is not False:
        raise AssertionError("Restore-preview accessibility evidence must remain done=false until visible CI/device proof exists")

    master = load_master()
    for rc, keyword in MASTER_KEYWORDS.items():
        if keyword.casefold() not in master[rc].casefold():
            raise AssertionError(f"MASTER drift at RC-{rc:04d}: expected keyword {keyword!r}")

    require_text(PAGE, [
        "RuhActionIds.backupRestoreMerge",
        "RuhActionIds.backupRestoreReplace",
        "FocusTraversalGroup",
        "OrderedTraversalPolicy",
        "NumericFocusOrder(1)",
        "NumericFocusOrder(2)",
        "Semantics(",
        "BoxConstraints(minHeight: 48)",
        "BackupImportMode.merge",
        "BackupImportMode.replace",
        "profiles.csv",
        "clients.csv",
        "consultations.csv",
        "journal_entries.csv",
        "calculations.csv",
    ])
    require_text(IDS, [
        "ACTION-BACKUP-RESTORE-MERGE",
        "ACTION-BACKUP-RESTORE-REPLACE",
    ])
    require_text(TEST, [
        "backupRestoreMerge",
        "backupRestoreReplace",
        "bySemanticsLabel('Birleştir')",
        "bySemanticsLabel('Değiştir')",
        "greaterThanOrEqualTo(48)",
        "NumericFocusOrder",
        "BackupImportMode.merge",
        "BackupImportMode.replace",
    ])

    extension_rows = {row["action_id"]: row for row in csv.DictReader(EXT.open(encoding="utf-8", newline=""))}
    binding_rows = {row["action_id"]: row for row in csv.DictReader(BINDINGS.open(encoding="utf-8", newline=""))}
    for action_id, label, effect in [
        ("ACTION-BACKUP-RESTORE-MERGE", "Birleştir", "EFFECT:RESTORE_BACKUP_MERGE"),
        ("ACTION-BACKUP-RESTORE-REPLACE", "Değiştir", "EFFECT:RESTORE_BACKUP_REPLACE"),
    ]:
        row = extension_rows.get(action_id)
        if row is None:
            raise AssertionError(f"Missing runtime action registry row: {action_id}")
        if row["source_screen_id"] != "SCR-BACKUP-001" or row["label_or_purpose"] != label:
            raise AssertionError(f"Incorrect restore action registry semantics: {action_id}")
        if row["target_screen_id_or_effect"] != effect or row["status"] != "ACTIVE":
            raise AssertionError(f"Restore action must be ACTIVE with exact effect: {action_id}")
        if row["a11y_label_required"].lower() != "true" or row["offline_behavior"] != "AVAILABLE":
            raise AssertionError(f"Restore action accessibility/offline contract drift: {action_id}")
        binding = binding_rows.get(action_id)
        if binding is None or binding["binding_file"] != "lib/src/ui/backup/backup_settings_page.dart":
            raise AssertionError(f"Missing runtime binding for {action_id}")
        if binding["status"] != "IMPLEMENTED":
            raise AssertionError(f"Runtime binding not implemented: {action_id}")

    print("OK: backup restore preview merge/replace accessibility and action contract validated")


if __name__ == "__main__":
    main()
