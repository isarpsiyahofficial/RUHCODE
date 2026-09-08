import hashlib
import importlib.util
import json
import os
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools/requirements/validate_rc1131_rc1144_release_governance.py"
spec = importlib.util.spec_from_file_location("validator", SCRIPT)
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class ReleaseGovernanceTests(unittest.TestCase):
    def test_static_policy_is_valid(self):
        validator.validate_static()

    def test_valid_release_manifest_and_artifact(self):
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            artifact = td / "ruhcode-release.apk"
            artifact.write_bytes(b"verified-release-artifact")
            manifest = td / "manifest.json"
            manifest.write_text(json.dumps({
                "commitSha": "a" * 40,
                "artifactName": artifact.name,
                "artifactSha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
                "buildMode": "release",
                "requirementsClosed": ["RC-1138", "RC-1139"],
                "ciRunUrl": "https://github.com/example/repo/actions/runs/1",
                "releaseBuildTested": True,
                "minificationEnabled": True,
                "obfuscationEnabled": True,
                "minifiedBehaviorParityPassed": True,
                "r8ReflectionRegressionPassed": True,
                "finalReleaseGatesPassed": True
            }), encoding="utf-8")
            validator.validate_manifest(manifest, artifact)

    def test_debug_artifact_is_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            artifact = td / "app-debug.apk"
            artifact.write_bytes(b"debug")
            manifest = td / "manifest.json"
            manifest.write_text(json.dumps({
                "commitSha": "b" * 40,
                "artifactName": artifact.name,
                "artifactSha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
                "buildMode": "release",
                "requirementsClosed": [],
                "ciRunUrl": "https://github.com/example/repo/actions/runs/2",
                "releaseBuildTested": True,
                "minificationEnabled": False,
                "obfuscationEnabled": False,
                "r8ReflectionRegressionPassed": True,
                "finalReleaseGatesPassed": True
            }), encoding="utf-8")
            with self.assertRaises(SystemExit):
                validator.validate_manifest(manifest, artifact)

    def test_wrong_artifact_digest_is_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            artifact = td / "app-release.apk"
            artifact.write_bytes(b"release")
            manifest = td / "manifest.json"
            manifest.write_text(json.dumps({
                "commitSha": "c" * 40,
                "artifactName": artifact.name,
                "artifactSha256": "0" * 64,
                "buildMode": "release",
                "requirementsClosed": [],
                "ciRunUrl": "https://github.com/example/repo/actions/runs/3",
                "releaseBuildTested": True,
                "minificationEnabled": False,
                "obfuscationEnabled": False,
                "r8ReflectionRegressionPassed": True,
                "finalReleaseGatesPassed": True
            }), encoding="utf-8")
            with self.assertRaises(SystemExit):
                validator.validate_manifest(manifest, artifact)

    def test_direct_human_push_to_main_is_rejected(self):
        old = {k: os.environ.get(k) for k in ("GITHUB_EVENT_NAME", "GITHUB_REF", "GITHUB_ACTOR")}
        try:
            os.environ["GITHUB_EVENT_NAME"] = "push"
            os.environ["GITHUB_REF"] = "refs/heads/main"
            os.environ["GITHUB_ACTOR"] = "human-user"
            with self.assertRaises(SystemExit):
                validator.validate_ci_context()
        finally:
            for key, value in old.items():
                if value is None:
                    os.environ.pop(key, None)
                else:
                    os.environ[key] = value


if __name__ == "__main__":
    unittest.main()
