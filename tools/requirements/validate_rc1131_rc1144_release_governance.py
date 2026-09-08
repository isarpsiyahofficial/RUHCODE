#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POLICY = ROOT / "governance/release_governance_policy.json"
CONTRACT = ROOT / "requirements/contracts/rc1131_rc1144_release_governance_contract.json"
CODEOWNERS = ROOT / ".github/CODEOWNERS"
WORKFLOW = ROOT / ".github/workflows/rc1131-rc1144-release-governance.yml"

SHA_RE = re.compile(r"^[0-9a-f]{40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def fail(message: str) -> None:
    raise SystemExit(f"RC1131_RC1144_FAIL: {message}")


def load_json(path: Path):
    if not path.exists():
        fail(f"missing {path.relative_to(ROOT)}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"invalid JSON {path.relative_to(ROOT)}: {exc}")


def validate_static() -> None:
    policy = load_json(POLICY)
    required_true = [
        "featureBranchRequired", "pullRequestRequired", "calculationCoreReviewRequired",
        "requiredCiBeforeMerge", "releaseOnlyAfterFinalGates", "releaseManifestRequired",
        "releaseBuildRequiresSeparateTest", "minifiedBuildRequiresBehaviorParity",
        "r8ReflectionRegressionRequired", "branchProtectionExternalSettingRequired",
    ]
    if policy.get("dailyDevelopmentOnMainAllowed") is not False:
        fail("daily development on main must be forbidden")
    if policy.get("debugArtifactMayBeFinal") is not False:
        fail("debug artifacts must never be final")
    for key in required_true:
        if policy.get(key) is not True:
            fail(f"policy must set {key}=true")
    fields = set(policy.get("releaseManifestFields", []))
    required_fields = {"commitSha", "artifactName", "artifactSha256", "buildMode", "requirementsClosed", "ciRunUrl", "minificationEnabled", "obfuscationEnabled"}
    if not required_fields.issubset(fields):
        fail(f"manifest field coverage incomplete: {sorted(required_fields-fields)}")
    if policy.get("allowedFinalBuildModes") != ["release"]:
        fail("only release build mode may be final")
    if not CONTRACT.exists() or not WORKFLOW.exists():
        fail("contract/workflow missing")
    if not CODEOWNERS.exists():
        fail("CODEOWNERS missing")
    codeowners = CODEOWNERS.read_text(encoding="utf-8")
    if "lib/src/calculation_core/" not in codeowners:
        fail("calculation core CODEOWNERS rule missing")


def validate_manifest(path: Path, artifact: Path | None) -> None:
    data = load_json(path)
    sha = str(data.get("commitSha", ""))
    if not SHA_RE.fullmatch(sha):
        fail("release manifest commitSha must be exact 40-char lowercase SHA")
    if data.get("buildMode") != "release":
        fail("final artifact must be a release build")
    name = str(data.get("artifactName", ""))
    if not name or "debug" in name.lower():
        fail("debug/unnamed artifact cannot be final")
    digest = str(data.get("artifactSha256", ""))
    if not SHA256_RE.fullmatch(digest):
        fail("artifactSha256 must be exact lowercase SHA-256")
    closed = data.get("requirementsClosed")
    if not isinstance(closed, list) or not all(re.fullmatch(r"RC-\d{4}", str(x)) for x in closed):
        fail("requirementsClosed must be an RC-ID list")
    if not str(data.get("ciRunUrl", "")).startswith("https://github.com/"):
        fail("ciRunUrl must identify GitHub CI evidence")
    if data.get("releaseBuildTested") is not True:
        fail("release build requires separate test evidence")
    if data.get("minificationEnabled") is True and data.get("minifiedBehaviorParityPassed") is not True:
        fail("minified release lacks behavior-parity evidence")
    if data.get("r8ReflectionRegressionPassed") is not True:
        fail("R8/reflection regression evidence is required")
    if data.get("finalReleaseGatesPassed") is not True:
        fail("release/tag cannot be promoted before final gates")
    if artifact is not None:
        if not artifact.exists() or not artifact.is_file():
            fail("artifact file missing")
        actual = hashlib.sha256(artifact.read_bytes()).hexdigest()
        if actual != digest:
            fail("artifact SHA-256 does not match manifest")


def validate_ci_context() -> None:
    event = os.getenv("GITHUB_EVENT_NAME", "")
    ref = os.getenv("GITHUB_REF", "")
    actor = os.getenv("GITHUB_ACTOR", "")
    if event == "push" and ref == "refs/heads/main" and actor not in {"github-actions[bot]", "dependabot[bot]"}:
        fail("direct human push to main violates RC-1132/1134 governance; use feature branch + PR")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--artifact", type=Path)
    parser.add_argument("--ci-context", action="store_true")
    args = parser.parse_args()
    validate_static()
    if args.ci_context:
        validate_ci_context()
    if args.manifest:
        validate_manifest(args.manifest, args.artifact)
    elif args.artifact:
        fail("--artifact requires --manifest")
    print("RC1131_RC1144_OK")


if __name__ == "__main__":
    main()
