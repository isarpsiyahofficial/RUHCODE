#!/usr/bin/env python3
import importlib.util
import json
import pathlib
import tempfile

MODULE_PATH = pathlib.Path(__file__).with_name("run_accuracy_golden.py")
spec = importlib.util.spec_from_file_location("run_accuracy_golden", MODULE_PATH)
mod = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(mod)


def dataset(records):
    return {
        "datasetId": "test-independent-reference",
        "version": "1",
        "source": {
            "name": "test fixture",
            "url": "https://example.invalid/reference",
            "retrievedAtUtc": "2026-08-18T00:00:00Z",
            "sha256": "0" * 64,
        },
        "license": {"name": "test-only", "redistributionAllowed": False},
        "generatedAtUtc": "2026-08-18T00:00:00Z",
        "records": records,
    }


base = {
    "instantUtc": "2026-08-18T00:00:00Z",
    "unit": "deg",
    "tolerance": 0.02,
}

data = dataset([
    {**base, "id": "wrap", "metric": "moon_longitude_deg", "expected": 359.99, "actual": 0.01},
    {**base, "id": "pass", "metric": "sun_longitude_deg", "expected": 10.0, "actual": 10.009},
    {**base, "id": "unverified", "metric": "planet_longitude_deg", "expected": 20.0},
])
mod.validate_shape(data)
results = {r.record_id: r for r in mod.score(data)}
assert abs(results["wrap"].error - 0.02) < 1e-9
assert results["wrap"].status == "PASS"
assert results["pass"].status == "PASS"
assert results["unverified"].status == "UNVERIFIED"

bad = dataset([{**base, "id": "fail", "metric": "sun_longitude_deg", "expected": 1.0, "actual": 1.5}])
assert mod.score(bad)[0].status == "FAIL"

try:
    mod.validate_shape(dataset([
        {**base, "id": "dup", "metric": "sun_longitude_deg", "expected": 1.0},
        {**base, "id": "dup", "metric": "sun_longitude_deg", "expected": 2.0},
    ]))
except ValueError as exc:
    assert "duplicate record id" in str(exc)
else:
    raise AssertionError("duplicate IDs must be rejected")

print("accuracy golden runner self-test: PASS")
