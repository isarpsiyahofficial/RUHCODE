#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = (ROOT / "RUH_CODE_MASTER_SARTNAME.md").read_text(encoding="utf-8")
gov = json.loads((ROOT / "governance/release_governance.json").read_text(encoding="utf-8"))
codeowners = (ROOT / ".github/CODEOWNERS").read_text(encoding="utf-8")
pr_template = (ROOT / ".github/pull_request_template.md").read_text(encoding="utf-8")

expected = {
    "RC-1131": "1131. GitHub ana geliştirme kaynağı olacak.",
    "RC-1132": "1132. `main` doğrudan günlük çalışma dalı olarak kullanılmayacak.",
    "RC-1133": "1133. Feature branch mantığı kullanılacak.",
    "RC-1134": "1134. Pull request üzerinden değişiklik takibi yapılacak.",
    "RC-1135": "1135. Kritik calculation core değişiklikleri review gerektirecek.",
    "RC-1136": "1136. CI başarısızken merge engellenecek.",
    "RC-1137": "1137. Release branch veya tag yalnız final kapılarından sonra üretilecek.",
    "RC-1138": "1138. Her release hangi requirement’ların kapandığını raporlayacak.",
    "RC-1139": "1139. Release artifact’ın commit SHA’sı bilinecek.",
    "RC-1140": "1140. Kullanıcıya gönderilen APK’nın hangi commit’ten üretildiği doğrulanabilecek.",
    "RC-1141": "1141. Debug APK final olarak teslim edilmeyecek.",
    "RC-1142": "1142. Release build ayrı test edilecek.",
}
for rc, text in expected.items():
    assert text in spec, f"binding spec drift: {rc}"
assert gov["binding_requirements"] == list(expected), "RC-1131..1142 must remain explicit and ordered"
assert gov["fail_closed"] is True
for key in (
    "primary_development_source", "daily_work_on_main_forbidden", "feature_branch_required",
    "pull_request_required", "calculation_core_independent_review_required", "merge_when_ci_failed_forbidden",
):
    assert gov["github"].get(key) is True, f"missing GitHub governance: {key}"
for key in (
    "release_ref_before_final_gates_forbidden", "closed_requirements_report_required", "exact_commit_sha_required",
    "delivered_apk_commit_trace_required", "debug_apk_final_delivery_forbidden", "release_build_separate_test_required",
    "workflow_run_identity_required", "artifact_sha256_required",
    "signing_identity_or_certificate_digest_required", "requirement_matrix_all_done_required",
    "critical_gates_green_required", "clean_checkout_required", "exact_artifact_verification_required",
):
    assert gov["release"].get(key) is True, f"missing release governance: {key}"
assert "/lib/src/calculation_core/ @isarpsiyahofficial" in codeowners
assert "reviewer other than the author" in pr_template
assert "CI required checks pass before merge" in pr_template
assert "Exact release artifact provenance" in pr_template

# RC-1132/1136: validation jobs must never become source-writing jobs.
# Legacy materialization workflows are deliberately out of scope here; they
# remain separate release blockers and must not be dispatched by this gate.
import re


def require_read_only_validation_workflow(relative_path: str) -> None:
    workflow = (ROOT / relative_path).read_text(encoding="utf-8")
    assert re.search(r"(?m)^permissions:\s*\n  contents:\s*read\s*$", workflow), (
        f"{relative_path}: validation workflow requires contents: read"
    )
    assert len(re.findall(r"(?m)^permissions[ \t]*:", workflow)) == 1, (
        f"{relative_path}: exactly one top-level permissions block is required"
    )
    assert not re.search(r"(?m)^[ \t]+permissions[ \t]*:", workflow), (
        f"{relative_path}: job-level permissions override is forbidden"
    )
    assert not re.search(r"(?m)^\s+[a-z-]+:\s*write\s*$", workflow), (
        f"{relative_path}: write permission is forbidden"
    )
    assert not re.search(
        r"(?im)\bgit\b[^\r\n;&|]*\b(?:push|commit|update-ref|tag)\b|"
        r"\bgh\b[^\r\n;&|]*\b(?:api|merge|sync)\b|"
        r"\bgh\b[^\r\n;&|]*\bworkflow\s+(?:run|enable|disable)\b|"
        r"\bgh\b[^\r\n;&|]*\brun\s+(?:rerun|cancel|delete)\b|"
        r"\bgh\b[^\r\n;&|]*\brelease\s+(?:create|upload|edit|delete|delete-asset)\b|"
        r"\bactions/github-script\b|\b(?:create|update)[_-](?:commit|ref)\b",
        workflow,
    ), f"{relative_path}: source writeback is forbidden"


for workflow_path in (
    ".github/workflows/rc1131-rc1142-release-governance.yml",
    ".github/workflows/rc0951-rc0964-pdf-validation.yml",
):
    require_read_only_validation_workflow(workflow_path)

# RC-1137/1138/1142: signed builds must remain behind exact release gates.
signed_release = (ROOT / ".github/workflows/rc1442-signed-clean-checkout.yml").read_text(encoding="utf-8")
required_signed_steps = (
    "Validate clean-checkout source readiness",
    "Resolve locked dependencies",
    "Analyze release source",
    "Run complete Flutter test suite",
    "Build signed release APK from clean checkout",
)
signed_step_positions = [signed_release.find("      - name: " + step + "\n") for step in required_signed_steps]
assert all(position >= 0 for position in signed_step_positions), "signed release gate step missing"
assert signed_step_positions == sorted(signed_step_positions), "signed release gate order changed"
assert "run: flutter analyze --fatal-infos" in signed_release
assert "run: flutter test --reporter expanded" in signed_release
readiness_source = (ROOT / "tools/requirements/validate_rc1442_release_source_readiness.py").read_text(encoding="utf-8")
assert 'run_strict_validator("tools/requirements/validate_requirement_matrix.py")' in readiness_source
assert '"release:all-1442-requirements-done"' in readiness_source

print("RC-1131..RC-1142 governance contract: PASS")
