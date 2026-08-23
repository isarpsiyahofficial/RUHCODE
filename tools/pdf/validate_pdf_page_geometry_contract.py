from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "evidence/pdf/page_geometry_contract.json"
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    data = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    require(data.get("requirements") == ["RC-0878", "RC-0879"], "Unexpected PDF page-geometry RC ownership.")
    master = MASTER.read_text(encoding="utf-8")
    require("878. PDF’in telefon ekranına göre değil A4/Letter benzeri gerçek belge ölçülerine göre layout’u olacak." in master, "RC-0878 master text drifted.")
    require("879. Varsayılan profesyonel rapor A4 formatında olabilir." in master, "RC-0879 master text drifted.")

    required_paths = [
        "lib/src/pdf/pdf_page_geometry_inspector.dart",
        "lib/src/pdf/pdf_local_service.dart",
        "test/pdf/pdf_page_geometry_inspector_test.dart",
    ]
    for rel in required_paths:
        require((ROOT / rel).is_file(), f"Missing page-geometry contract path: {rel}")

    inspector = (ROOT / "lib/src/pdf/pdf_page_geometry_inspector.dart").read_text(encoding="utf-8")
    service = (ROOT / "lib/src/pdf/pdf_local_service.dart").read_text(encoding="utf-8")
    tests = (ROOT / "test/pdf/pdf_page_geometry_inspector_test.dart").read_text(encoding="utf-8")

    require("/MediaBox" in inspector, "MediaBox inspection is missing.")
    require("requireExpectedGeometry" in inspector, "Fail-closed page-geometry gate is missing.")
    require("pageGeometryInspector.requireExpectedGeometry" in service, "Production PDF service does not invoke page geometry gate.")
    require("plan.pageSpec.widthMm" in service and "plan.pageSpec.heightMm" in service, "PDF service is not checking the exact planned page dimensions.")
    require("rejects page format drift" in tests, "Page-format drift regression is missing.")
    require("612 792" in tests, "Letter-vs-A4 negative regression is missing.")

    print("PDF page geometry contract: OK")


if __name__ == "__main__":
    main()
