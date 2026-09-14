#!/usr/bin/env python3
"""Fail-closed structural/release validator for binding RC-1421..RC-1442."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1421_rc1442_release_closure_contract.json'
DAILY = ROOT / 'requirements/content_manifests/daily_messages.json'
ACCURACY = ROOT / 'requirements/reference_manifests/astronomy_accuracy_budgets.json'
REFS = ROOT / 'requirements/reference_manifests/rc1439_reference_images.json'
NAV = ROOT / 'lib/src/ui/navigation/main_navigation_shell.dart'
ACTIONS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'
TODAY = ROOT / 'lib/src/application/daily/today_temporal_contract.dart'


def load(path: Path) -> dict:
    if not path.is_file():
        raise AssertionError(f'missing required JSON: {path.relative_to(ROOT)}')
    return json.loads(path.read_text(encoding='utf-8'))


def require_file(rel: str) -> None:
    p = ROOT / rel
    if not p.exists():
        raise AssertionError(f'missing evidence path: {rel}')


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--release', action='store_true')
    ap.add_argument('--json-output', type=Path)
    args = ap.parse_args()
    blockers: list[str] = []
    verified: list[str] = []
    try:
        contract = load(CONTRACT)
        expected = [f'RC-{i:04d}' for i in range(1421, 1443)]
        actual = list(contract.get('requirements', {}))
        assert actual == expected, f'exact ordered RC set mismatch: {actual}'
        for rc, paths in contract['requirements'].items():
            assert paths, f'{rc} has no evidence paths'
            for rel in paths:
                require_file(rel)
        verified.append('exact ordered RC-1421..RC-1442 evidence map is structurally complete')

        today = TODAY.read_text(encoding='utf-8')
        for token in (
            'TodayTemporalContext', 'GregorianCalendarPolicy', 'isLeapYear',
            'RuhSupportedDateRange', 'minimumYear = 1890', 'maximumYear = 2110',
            'StockDailyMessage', 'PersonalTodayEffects', 'TodayContentBundle',
        ):
            assert token in today, f'missing Today temporal token: {token}'
        verified.append('Today/Gregorian/leap/date-range/content-separation production contract exists')

        daily = load(DAILY)
        assert daily['lookup_key'] == 'YYYY-MM-DD|locale'
        assert daily['locales'] == ['tr', 'en']
        assert daily['initial_coverage_start'] == '2026-01-01'
        assert daily['initial_coverage_end'] == '2036-12-31'
        assert daily['initial_days'] == 4018
        assert daily['initial_total_records'] == 8036
        assert daily['rolling_release_horizon_years'] >= 10
        assert daily['runtime_ai_generation_allowed'] is False
        assert daily['random_fallback_allowed'] is False
        assert daily['machine_translation_between_tr_en_allowed'] is False
        verified.append('daily-message schema declares exact date keys, TR/EN independence and rolling horizon')
        if daily.get('status') != 'RELEASE_AUDIT_COMPLETE':
            blockers.append(f"daily-message status is {daily.get('status')!r}, not RELEASE_AUDIT_COMPLETE")

        accuracy = load(ACCURACY)
        budgets = accuracy.get('budgets', {})
        for key in (
            'sunGeocentricLongitudeMaxAbsErrorDegrees',
            'moonGeocentricLongitudeMaxAbsErrorDegrees',
            'planetGeocentricLongitudeMaxAbsErrorDegrees',
            'ascendantLongitudeMaxAbsErrorDegrees',
            'mcLongitudeMaxAbsErrorDegrees',
            'houseCuspLongitudeMaxAbsErrorDegrees',
            'sunriseSunsetMaxAbsErrorSeconds',
            'planetaryHourBoundaryMaxAbsErrorSeconds',
            'nakshatraLongitudeMaxAbsErrorDegrees',
            'padaLongitudeMaxAbsErrorDegrees',
        ):
            assert key in budgets, f'missing measurable accuracy budget: {key}'
        verified.append('per-engine measurable accuracy budgets are declared')
        if accuracy.get('proven') is not True:
            blockers.append('astronomy accuracy budgets are declared but proven=false')

        refs = load(REFS)
        images = refs.get('images', [])
        if refs.get('status') != 'BUNDLED_VERIFIED' or not images:
            blockers.append('RC-1439 physical UI reference images are not BUNDLED_VERIFIED')
        else:
            verified.append(f'{len(images)} physical UI reference images registered')

        nav = NAV.read_text(encoding='utf-8')
        actions = ACTIONS.read_text(encoding='utf-8')
        for label in ("label: 'Bugün'", "label: 'Araçlar'", "label: 'Kayıtlar'", "label: 'Profil'"):
            assert label in nav, f'missing canonical navigation label: {label}'
        assert "label: 'Hesapla'" not in nav, 'ambiguous Hesapla bottom-navigation label remains'
        for token in ('navigationToday', 'navigationTools', 'navigationRecords', 'navigationProfile', 'allRuntimeBindings'):
            assert token in actions, f'missing action-registry token: {token}'
        assert 'Semantics(' in nav and 'minHeight: 48' in nav
        verified.append('canonical four-tab navigation, action IDs, semantics and 48dp target floor exist')

        declared_blockers = contract.get('releaseBlockers', {})
        if not isinstance(declared_blockers, dict):
            raise AssertionError('releaseBlockers must be an object')
        blockers.extend(f'{rc}: {reason}' for rc, reason in declared_blockers.items())

        # Structural validation of existing specialist gates. They may themselves
        # remain fail-closed; this validator must never reinterpret red evidence as DONE.
        for cmd in (
            [sys.executable, 'tools/content/validate_daily_message_contract.py'],
            [sys.executable, 'tools/astronomy/validate_accuracy_budget_contract.py'],
            [sys.executable, 'tools/requirements/validate_rc1439_reference_images.py', '--allow-incomplete'],
            [sys.executable, 'tools/requirements/validate_requirement_matrix.py'],
        ):
            proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
            if proc.returncode != 0:
                raise AssertionError(f"specialist validator failed: {' '.join(cmd)}\n{proc.stdout}\n{proc.stderr}")
        verified.append('existing daily-message, accuracy, reference-image and 1,442-row matrix gates execute')

    except (AssertionError, KeyError, json.JSONDecodeError) as exc:
        print(f'RC1421_RC1442_FAIL: {exc}', file=sys.stderr)
        return 1

    # Deduplicate while preserving order.
    blockers = list(dict.fromkeys(blockers))
    payload = {
        'range': 'RC-1421..RC-1442',
        'structuralReady': True,
        'releaseReady': not blockers,
        'verified': verified,
        'blockers': blockers,
    }
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    if args.release and blockers:
        print(f'RC1421_RC1442_RELEASE_BLOCKED: {len(blockers)} blocker(s)', file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
