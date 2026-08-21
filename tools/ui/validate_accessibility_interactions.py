#!/usr/bin/env python3
import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "ui/accessibility_interaction_contract.json"
ACTIONS = ROOT / "ui/action_registry.csv"


def die(message):
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def main():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    if contract.get("requirements") != ["RC-1432", "RC-1440", "RC-1441"]:
        die("accessibility contract must bind exact RC-1432/1440/1441 ownership")

    nav = contract["navigation"]
    a11y = contract["accessibility"]
    reg = contract["interactionRegistry"]

    if nav["primaryTabs"] != ["Bugün", "Araçlar", "Kayıtlar", "Profil"]:
        die("primary navigation drifted from Bugün · Araçlar · Kayıtlar · Profil")
    if nav.get("toolsCategories") != ["Astroloji", "Numeroloji", "Spiritüel", "Kişisel Gelişim"]:
        die("Tools must expose the four canonical top-level categories")
    if nav.get("astrologyChildren") != [
        "Batı Astrolojisi",
        "Vedik Astroloji",
        "Çin Astrolojisi",
        "BaZi",
        "Gezegen Saatleri",
    ]:
        die("Astrology hub child list drifted from the canonical information architecture")
    if "Hesapla" not in nav["forbiddenAmbiguousExactLabels"]:
        die("ambiguous exact Hesapla label must remain forbidden")
    if a11y["minimumTouchTargetDp"] < 48:
        die("minimum touch target must be at least 48dp")
    if a11y["minimumTextContrastRatio"] < 4.5:
        die("normal text contrast contract must be at least 4.5:1")
    if a11y["minimumLargeTextContrastRatio"] < 3.0:
        die("large text contrast contract must be at least 3.0:1")
    if a11y["maximumRequiredTextScaleForNoCriticalOverflow"] < 2.0:
        die("critical UI must tolerate at least 2.0x text scale")
    if not a11y["screenReaderLabelsRequiredForInteractiveControls"]:
        die("screen-reader labels must be mandatory")
    if not a11y["informationMayNotDependOnColorAlone"]:
        die("information may not depend on color alone")
    if reg.get("runtimeBindings") != "ui/runtime_action_bindings.csv":
        die("runtime action binding manifest must remain explicit")
    if reg.get("runtimeActionConstants") != "lib/src/ui/actions/ruh_action_ids.dart":
        die("runtime ACTION-ID source must remain explicit")
    if not reg.get("runtimeBindingMustReferenceActiveRegistryAction"):
        die("runtime binding must reference ACTIVE registry actions")
    if not reg.get("runtimeGuardedFeatureMustMatchRegistryEntitlement"):
        die("runtime guarded features must match registry entitlement")

    allowed_entitlements = set(reg["allowedEntitlements"])
    allowed_offline = set(reg["allowedOfflineBehaviors"])
    active_statuses = set(reg["activeStatuses"])
    forbidden_labels = {x.casefold() for x in nav["forbiddenAmbiguousExactLabels"]}

    rows = list(csv.DictReader(ACTIONS.open(encoding="utf-8", newline="")))
    seen = set()
    active = 0
    for line, row in enumerate(rows, 2):
        action_id = row["action_id"].strip()
        if not re.fullmatch(r"ACTION-[A-Z0-9-]+", action_id):
            die(f"invalid action id on line {line}: {action_id!r}")
        if action_id in seen:
            die(f"duplicate action id: {action_id}")
        seen.add(action_id)

        status = row["status"].strip()
        if status not in active_statuses:
            continue
        active += 1

        label = row["label_or_purpose"].strip()
        target = row["target_screen_id_or_effect"].strip()
        if not label:
            die(f"ACTIVE action has no user-facing purpose: {action_id}")
        if label.casefold() in forbidden_labels:
            die(f"ambiguous exact action label is forbidden: {action_id} -> {label}")
        if not target:
            die(f"ACTIVE action has no target/effect: {action_id}")
        if row["a11y_label_required"].strip().lower() != "true":
            die(f"ACTIVE action must require an accessibility label: {action_id}")
        if row["entitlement"].strip() not in allowed_entitlements:
            die(f"unknown entitlement for {action_id}: {row['entitlement']!r}")
        if row["offline_behavior"].strip() not in allowed_offline:
            die(f"unknown offline behavior for {action_id}: {row['offline_behavior']!r}")

    if active == 0:
        die("action registry contains no ACTIVE actions")

    print(
        f"OK: accessibility/interaction contract validated; active_actions={active}, "
        f"minimum_touch_target={a11y['minimumTouchTargetDp']}dp, "
        f"text_scale={a11y['maximumRequiredTextScaleForNoCriticalOverflow']}x"
    )


if __name__ == "__main__":
    main()
