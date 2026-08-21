from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/interpretation/interpretation_claims.dart"
TEST = ROOT / "test/interpretation/interpretation_claims_test.dart"
EVIDENCE = ROOT / "evidence/interpretation/claim_aggregation.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "InterpretationClaimPolarity",
        "InterpretationTopicState",
        "InterpretationClaim",
        "InterpretationTopicGroup",
        "InterpretationClaimAggregator",
        "hasConflictingFactors",
        "supportive",
        "challenging",
        "mixed",
        "sourceFactorIds",
        "Duplicate interpretation claimId",
    ):
        require(token in source, f"claim aggregation source missing token: {token}")

    for token in (
        "mixed topic preserves supportive and challenging factors separately",
        "aligned and neutral-only topics remain distinct",
        "aggregation is deterministic by topic and claim ID",
        "invalid or duplicate claim provenance fails closed",
    ):
        require(token in test, f"claim aggregation test missing regression: {token}")

    require(evidence.get("contract_id") == "INTERPRETATION-CLAIM-AGGREGATION-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-1070", "RC-1072", "RC-1077", "RC-1078"):
        require(rc in evidence.get("requirements", []), f"missing requirement mapping: {rc}")

    invariants = " ".join(evidence.get("invariants", []))
    require("never invents one definitive conclusion" in invariants, "single-certainty prohibition missing")
    require("preserve every claim and source factor separately" in invariants, "factor-preservation invariant missing")

    print("interpretation claim aggregation structural contract: OK")


if __name__ == "__main__":
    main()
