#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
DOC = ROOT / 'docs' / 'UI_INFORMATION_ARCHITECTURE.md'
text = DOC.read_text(encoding='utf-8')

screen_ids = re.findall(r'`(SCR-[A-Z0-9-]+)`', text)
action_ids = re.findall(r'`(ACTION-[A-Z0-9-]+)`', text)

# Tables may refer to the same SCREEN-ID more than once (e.g. route definition + action target).
# The canonical screen declaration is any table row whose first cell is the SCREEN-ID.
canonical_screens = re.findall(r'^\| `(SCR-[A-Z0-9-]+)` \|', text, re.M)
canonical_actions = re.findall(r'^\| `(ACTION-[A-Z0-9-]+)` \|', text, re.M)

if len(canonical_screens) != len(set(canonical_screens)):
    dupes = sorted({x for x in canonical_screens if canonical_screens.count(x) > 1})
    raise SystemExit(f'Duplicate canonical SCREEN-ID: {dupes}')
if len(canonical_actions) != len(set(canonical_actions)):
    dupes = sorted({x for x in canonical_actions if canonical_actions.count(x) > 1})
    raise SystemExit(f'Duplicate canonical ACTION-ID: {dupes}')

required_nav = {
    'SCR-TODAY-001', 'SCR-TOOLS-001', 'SCR-RECORDS-001', 'SCR-PROFILE-001'
}
if not required_nav <= set(canonical_screens):
    raise SystemExit(f'Missing required main navigation screens: {sorted(required_nav - set(canonical_screens))}')

required_actions = {
    'ACTION-NAV-TODAY', 'ACTION-NAV-TOOLS', 'ACTION-NAV-RECORDS', 'ACTION-NAV-PROFILE'
}
if not required_actions <= set(canonical_actions):
    raise SystemExit(f'Missing required main navigation actions: {sorted(required_actions - set(canonical_actions))}')

# Every action target SCREEN-ID mentioned in the action table must exist canonically.
action_table = re.search(r'## Action sözleşmesi.*?(?=\n## Test sözleşmesi)', text, re.S)
if not action_table:
    raise SystemExit('Action contract section missing')
for target in re.findall(r'`(SCR-[A-Z0-9-]+)`', action_table.group(0)):
    if target not in set(canonical_screens):
        raise SystemExit(f'Action points to undefined screen: {target}')

# The banned ambiguous bottom-navigation label must not be part of the binding main nav declaration.
main_nav_line = re.search(r'\*\*Bağlayıcı navigasyon:\*\*\s*`([^`]+)`', text)
if not main_nav_line:
    raise SystemExit('Binding navigation declaration missing')
nav = [part.strip() for part in main_nav_line.group(1).split('·')]
if nav != ['Bugün', 'Araçlar', 'Kayıtlar', 'Profil']:
    raise SystemExit(f'Unexpected binding navigation: {nav}')

print(f'OK: UI IA contract validated; screens={len(canonical_screens)}, actions={len(canonical_actions)}, nav={nav}')
