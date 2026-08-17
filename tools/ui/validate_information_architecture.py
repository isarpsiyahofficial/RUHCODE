#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
DOC = ROOT / 'docs' / 'UI_INFORMATION_ARCHITECTURE.md'
text = DOC.read_text(encoding='utf-8')

# Parse screen table rows as SCREEN-ID -> route. The same screen may be referenced in
# more than one section, but it may never resolve to two different routes.
screen_rows = re.findall(r'^\| `(SCR-[A-Z0-9-]+)` \|\s*([^|]+?)\s*\|', text, re.M)
screen_routes: dict[str, str] = {}
for screen_id, route in screen_rows:
    route = route.strip().strip('`')
    previous = screen_routes.get(screen_id)
    if previous is not None and previous != route:
        raise SystemExit(f'Conflicting route for {screen_id}: {previous!r} vs {route!r}')
    screen_routes[screen_id] = route

canonical_screens = set(screen_routes)
action_rows = re.findall(r'^\| `(ACTION-[A-Z0-9-]+)` \|', text, re.M)
if len(action_rows) != len(set(action_rows)):
    dupes = sorted({x for x in action_rows if action_rows.count(x) > 1})
    raise SystemExit(f'Duplicate canonical ACTION-ID: {dupes}')
canonical_actions = set(action_rows)

required_nav = {
    'SCR-TODAY-001', 'SCR-TOOLS-001', 'SCR-RECORDS-001', 'SCR-PROFILE-001'
}
if not required_nav <= canonical_screens:
    raise SystemExit(f'Missing required main navigation screens: {sorted(required_nav - canonical_screens)}')

required_actions = {
    'ACTION-NAV-TODAY', 'ACTION-NAV-TOOLS', 'ACTION-NAV-RECORDS', 'ACTION-NAV-PROFILE'
}
if not required_actions <= canonical_actions:
    raise SystemExit(f'Missing required main navigation actions: {sorted(required_actions - canonical_actions)}')

# Every action target SCREEN-ID mentioned in the action table must exist in the screen registry.
action_table = re.search(r'## Action sözleşmesi.*?(?=\n## Test sözleşmesi)', text, re.S)
if not action_table:
    raise SystemExit('Action contract section missing')
for target in re.findall(r'`(SCR-[A-Z0-9-]+)`', action_table.group(0)):
    if target not in canonical_screens:
        raise SystemExit(f'Action points to undefined screen: {target}')

main_nav_line = re.search(r'\*\*Bağlayıcı navigasyon:\*\*\s*`([^`]+)`', text)
if not main_nav_line:
    raise SystemExit('Binding navigation declaration missing')
nav = [part.strip() for part in main_nav_line.group(1).split('·')]
if nav != ['Bugün', 'Araçlar', 'Kayıtlar', 'Profil']:
    raise SystemExit(f'Unexpected binding navigation: {nav}')

print(f'OK: UI IA contract validated; unique_screens={len(canonical_screens)}, actions={len(canonical_actions)}, nav={nav}')
