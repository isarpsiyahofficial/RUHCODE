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
    "workflow_run_identity_required", "artifact_sha256_required", "requirement_matrix_all_done_required",
    "critical_gates_green_required", "clean_checkout_required", "exact_artifact_verification_required",
):
    assert gov["release"].get(key) is True, f"missing release governance: {key}"
assert "/lib/src/calculation_core/ @isarpsiyahofficial" in codeowners
assert "reviewer other than the author" in pr_template
assert "CI required checks pass before merge" in pr_template
assert "Exact release artifact provenance" in pr_template
print("RC-1131..RC-1142 governance contract: PASS")
