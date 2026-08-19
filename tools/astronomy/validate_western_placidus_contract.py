#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "evidence" / "astronomy" / "western_placidus_contract.json"
PLACIDUS_SOURCE = ROOT / "lib" / "src" / "calculation_core" / "western" / "placidus_houses.dart"
PLACIDUS_TEST = ROOT / "test" / "calculation_core" / "western" / "placidus_houses_test.dart"
PORPHYRY_SOURCE = ROOT / "lib" / "src" / "calculation_core" / "western" / "porphyry_houses.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (MANIFEST, PLACIDUS_SOURCE, PLACIDUS_TEST, PORPHYRY_SOURCE):
        require(path.is_file(), f"missing required Placidus artifact: {path}")

    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    require(data.get("contract") == "western_placidus_houses", "wrong contract id")
    require(data.get("version") == 2, "unexpected contract version")

    requirements = set(data.get("requirements", []))
    for rc in {"RC-0054", "RC-0061", "RC-0262", "RC-0265", "RC-1436"}:
        require(rc in requirements, f"missing requirement mapping: {rc}")

    definition = data.get("definition", {})
    require(definition.get("basis") == "semidiurnal and seminocturnal arc division", "wrong Placidus basis")
    cusps = definition.get("cusps", {})
    require(cusps.get("11") == "2/3 of semidiurnal arc completed", "missing cusp 11 definition")
    require(cusps.get("12") == "1/3 of semidiurnal arc completed", "missing cusp 12 definition")
    require(cusps.get("2") == "2/3 of seminocturnal arc completed", "missing cusp 2 definition")
    require(cusps.get("3") == "1/3 of seminocturnal arc completed", "missing cusp 3 definition")

    solver = data.get("solver_contract", {})
    require(solver.get("iterative") is True, "Placidus solver must be iterative")
    require(solver.get("max_iterations") == 100, "iteration ceiling must be 100")
    require(solver.get("convergence_required") is True, "convergence must be mandatory")
    require(solver.get("non_convergence_result") == "UNAVAILABLE", "non-convergence must be unavailable")
    require(solver.get("silent_fallback_forbidden") is True, "silent fallback must be forbidden")
    require(solver.get("optional_explicit_fallback") == "PORPHYRY", "explicit fallback must be Porphyry")
    require(solver.get("source") == "lib/src/calculation_core/western/placidus_houses.dart", "wrong source path")
    require(solver.get("tests") == "test/calculation_core/western/placidus_houses_test.dart", "wrong test path")

    source = PLACIDUS_SOURCE.read_text(encoding="utf-8")
    for token in (
        "maxIterations = 100",
        "convergenceDegrees",
        "PlacidusResultStatus",
        "PlacidusFallbackPolicy.explicitPorphyry",
        "effectiveSystem: 'PORPHYRY'",
        "effectiveSystem: 'UNAVAILABLE'",
        "_solvePoleHeightCusp",
        "_eclipticIntersection",
        "divisor: 3.0",
        "divisor: 1.5",
    ):
        require(token in source, f"Placidus source missing required behavior token: {token}")
    require("Swiss Ephemeris runtime" in source, "source must state that Swiss is not a runtime dependency")

    tests = PLACIDUS_TEST.read_text(encoding="utf-8")
    for token in ("ordinary latitude", "polar-circle", "explicit and visible", "exact cusp"):
        require(token in tests, f"Placidus tests missing coverage marker: {token}")

    polar = data.get("polar_contract", {})
    require(polar.get("invented_cusps_forbidden") is True, "invented polar cusps must be forbidden")
    require(polar.get("fallback_must_be_visible_in_result_metadata") is True, "fallback provenance must be visible")

    accuracy = data.get("accuracy", {})
    require(accuracy.get("house_cusp_budget_degrees") == 0.05, "wrong cusp accuracy budget")
    require(accuracy.get("independent_golden_required") is True, "independent golden must be required")
    require(accuracy.get("independent_golden_proven") is False, "golden proof cannot be claimed yet")

    require(data.get("runtime_dependency_on_swiss_ephemeris") is False,
            "Swiss Ephemeris must remain reference-only")
    require(data.get("implementation_ready") is True, "source implementation must be marked ready")
    require(data.get("status") == "SOURCE_LEVEL_IMPLEMENTED", "wrong source-level status")
    require(data.get("done") is False, "Placidus must not be DONE before golden/CI/EOP evidence")
    require(len(data.get("done_blockers", [])) >= 3, "explicit DONE blockers must remain recorded")

    print("western Placidus source-level contract: OK")


if __name__ == "__main__":
    main()
