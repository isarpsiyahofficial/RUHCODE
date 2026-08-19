#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "evidence/backup/production_store_contract.json"
STORE = ROOT / "lib/src/backup/local_database_backup_import_store.dart"
DB_CONTRACT = ROOT / "lib/src/data/local/local_database.dart"
SQLITE = ROOT / "lib/src/data/local/sqflite_local_database.dart"
TEST = ROOT / "test/backup/local_database_backup_import_store_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    data = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    require(data.get("contract") == "backup-production-store-v1", "wrong production-store contract id")
    require(data.get("status") == "SOURCE_LEVEL_IMPLEMENTED", "production store source status missing")
    require(data.get("done") is False, "production store must not claim DONE before runtime evidence")

    store = STORE.read_text(encoding="utf-8")
    db_contract = DB_CONTRACT.read_text(encoding="utf-8")
    sqlite = SQLITE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")

    for marker in (
        "implements BackupImportStore",
        "createSafetySnapshot",
        "restoreSafetySnapshot",
        "database.transaction",
        "writeAsString(jsonEncode(tables), flush: true)",
        "_BackupPayloadMapper.toStoragePayload",
    ):
        require(marker in store, f"production backup store missing marker: {marker}")

    for marker in ("readTable", "clearTable"):
        require(marker in db_contract, f"LocalDatabaseTransaction missing {marker}")
        require(marker in sqlite, f"Sqflite transaction missing {marker}")

    for marker in (
        "merge import writes canonical profile payload readable by repositories",
        "durable safety snapshot restores records after destructive mutation",
        "databaseFactoryFfi",
        "CoreRepositories(database).profiles.findById",
    ):
        require(marker in test, f"production backup adapter test missing marker: {marker}")

    print("Backup production-store contract OK")


if __name__ == "__main__":
    main()
