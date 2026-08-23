#!/usr/bin/env python3
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
EVIDENCE = ROOT / "evidence/backup/single_table_csv_export.json"
SOURCE = ROOT / "lib/src/backup/single_table_csv_exporter.dart"
TEST = ROOT / "test/backup/single_table_csv_exporter_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


master = MASTER.read_text(encoding="utf-8")
evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))
source = SOURCE.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")

m = re.search(r"^794\.\s+(.+)$", master, re.MULTILINE)
require(m is not None, "RC-0794 master requirement is missing")
require("belirli bir tabloyu tek CSV" in m.group(1), "RC-0794 semantic ownership drifted")
require(evidence.get("requirement_ids") == ["RC-0794"], "single-table CSV evidence must own only RC-0794")
require(evidence.get("done") is False, "RC-0794 cannot be DONE without exact CI evidence")

for token in (
    "class SingleTableCsvExporter",
    "BackupSchemaRegistry.table(fileName)",
    "RuhCsvDocumentCodec",
    "utf8.encode",
    "recordCount",
):
    require(token in source, f"single-table CSV source contract missing: {token}")

require("LocalDatabaseBackupExporter" in source, "single-table export must reuse canonical database mapping")
require("writer.write" not in source, "single-table CSV export must not masquerade as a full backup package")

for token in (
    "settings.csv",
    "Merhaba, İstanbul",
    "RuhCsvDocumentCodec().decode",
    "made_up.csv",
    "throwsA(isA<ArgumentError>())",
):
    require(token in test, f"single-table CSV regression coverage missing: {token}")

print("single-table CSV export contract: OK")
