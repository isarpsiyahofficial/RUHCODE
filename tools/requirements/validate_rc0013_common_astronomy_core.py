#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0013_common_astronomy_core_contract.json"
EPHEMERIS = ROOT / "lib/src/calculation_core/ephemeris/ephemeris.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    require(contract["rcId"] == "RC-0013", "wrong RC binding")
    require(contract["promotionCeiling"] == "TESTED", "RC-0013 gate must not self-promote above TESTED")

    policy = contract["policy"]
    for key in (
        "sharedCoreRequired",
        "offlinePackagedEphemerisRequired",
        "versionedProvenanceRequired",
        "coverageFailClosedRequired",
        "networkFallbackForbidden",
        "interfaceOnlyIsInsufficient",
    ):
        require(policy.get(key) is True, f"RC-0013 policy weakened: {key}")

    for rel in contract["requiredRuntimeComponents"] + contract["requiredCompiledTests"]:
        path = ROOT / rel
        require(path.is_file() and path.stat().st_size > 0, f"RC-0013 required evidence missing: {rel}")

    source = EPHEMERIS.read_text(encoding="utf-8")
    for needle in (
        "abstract interface class EphemerisProvider",
        "final class EphemerisCoverage",
        "final class EclipticState",
        "void requireContains(double jdTt)",
        "sourceId",
        "dataVersion",
        "checksumSha256",
    ):
        require(needle in source, f"RC-0013 common ephemeris contract missing: {needle}")

    # The common core must expose the shared body model used by downstream systems.
    for body in ("sun", "moon", "mercury", "venus", "mars", "jupiter", "saturn", "uranus", "neptune", "pluto"):
        require(f"  {body}," in source, f"RC-0013 shared body enum missing: {body}")

    loader = (ROOT / "lib/src/calculation_core/ephemeris/de440s_asset_loader.dart").read_text(encoding="utf-8")
    parser = (ROOT / "lib/src/calculation_core/ephemeris/de440s_daf_parser.dart").read_text(encoding="utf-8")
    type2 = (ROOT / "lib/src/calculation_core/ephemeris/spk_type2_evaluator.dart").read_text(encoding="utf-8")
    graph = (ROOT / "lib/src/calculation_core/ephemeris/spk_body_graph_evaluator.dart").read_text(encoding="utf-8")
    require("de440" in loader.lower(), "RC-0013 packaged DE440s loader marker missing")
    require("DAF" in parser or "daf" in parser, "RC-0013 DAF parser marker missing")
    require("Type 2" in type2 or "type 2" in type2.lower() or "Type2" in type2, "RC-0013 SPK Type-2 evaluator marker missing")
    require("evaluate" in graph.lower(), "RC-0013 body graph evaluator is not executable")

    print("RC-0013 common astronomy core contract: OK")


if __name__ == "__main__":
    main()
