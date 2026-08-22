#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def fail(message: str) -> None:
    raise SystemExit(f"Runtime backup wiring failed: {message}")


def require(path: str, fragments: tuple[str, ...]) -> None:
    source = (ROOT / path).read_text(encoding="utf-8")
    for fragment in fragments:
        if fragment not in source:
            fail(f"{path} missing required fragment: {fragment!r}")


def main() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    version_match = re.search(r"^version:\s*([^\s]+)\s*$", pubspec, re.MULTILINE)
    if not version_match:
        fail("pubspec version is missing")
    app_version = version_match.group(1)

    metadata = (ROOT / "lib/src/app/build_metadata.dart").read_text(encoding="utf-8")
    if f"static const appVersion = '{app_version}';" not in metadata:
        fail("RuhCodeBuildMetadata.appVersion drifted from pubspec.yaml")
    if "static const engineVersion = 'ruh-core.v1';" not in metadata:
        fail("canonical engine version is missing")

    require(
        "lib/src/data/local/sqflite_local_database.dart",
        (
            "String get openedDatabasePath",
            "_openedDatabasePath = resolvedPath;",
            "_openedDatabasePath = null;",
        ),
    )
    require(
        "lib/src/app/app_runtime.dart",
        (
            "final BackupApplicationActions backupActions;",
            "LocalDatabaseBackupExporter(database: database)",
            "LocalDatabaseBackupImportStore(",
            "p.dirname(database.openedDatabasePath)",
            "ruh_code_backup_safety_snapshots",
            "NativeBackupPlatformGateway()",
            "BackupImportCoordinator(store: backupImportStore)",
        ),
    )
    require("lib/main.dart", ("backupActions: runtime.backupActions",))
    require(
        "lib/src/ui/navigation/main_navigation_shell.dart",
        (
            "RuhActionIds.settingsBackup",
            "Yedekleme ve Aktarma",
            "BackupSettingsPage(backupActions: backupActions!)",
        ),
    )
    require(
        "lib/src/ui/backup/backup_settings_page.dart",
        (
            "RuhActionIds.backupExport",
            "RuhActionIds.backupImport",
            "backupUiCopy[_ruhLocale]!",
            "phaseForSaveResult(result)",
            "stateForPickResult(result)",
            "if (selection == null || !selection.preview.valid) return;",
            "phaseForRestoreError(error)",
            "RuhCodeBuildMetadata.appVersion",
            "RuhCodeBuildMetadata.engineVersion",
        ),
    )
    require(
        "lib/src/ui/backup/backup_ui_contract.dart",
        (
            "BackupUiPhase.rollbackRestored",
            "BackupUiPhase.rollbackFailed",
            "veri bütünlüğü kontrol edilmeli",
            "Data integrity must be checked",
            "? BackupUiPhase.rollbackRestored\n        : BackupUiPhase.rollbackFailed",
        ),
    )

    with (ROOT / "ui/runtime_action_bindings.csv").open(encoding="utf-8", newline="") as handle:
        rows = {row["action_id"]: row for row in csv.DictReader(handle)}
    expected = {
        "ACTION-SETTINGS-BACKUP": ("settingsBackup", "lib/src/ui/navigation/main_navigation_shell.dart", "NAVIGATION"),
        "ACTION-BACKUP-EXPORT": ("backupExport", "lib/src/ui/backup/backup_settings_page.dart", "BACKUP"),
        "ACTION-BACKUP-IMPORT": ("backupImport", "lib/src/ui/backup/backup_settings_page.dart", "BACKUP"),
    }
    for action_id, values in expected.items():
        row = rows.get(action_id)
        if row is None:
            fail(f"runtime binding missing: {action_id}")
        actual = (row["constant_name"], row["binding_file"], row["binding_kind"])
        if actual != values or row["status"] != "IMPLEMENTED":
            fail(f"runtime binding drift for {action_id}: {row}")

    print(
        "Runtime backup wiring OK: SQLite export/import, durable snapshot, native gateway, "
        "TR/EN state contract and Settings actions are connected."
    )


if __name__ == "__main__":
    main()