#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
ADDENDUM = ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md'
SOURCE = ROOT / 'lib/src/calculation_core/chinese/chinese_year.dart'
TEST = ROOT / 'test/calculation_core/chinese/chinese_year_test.dart'
EVIDENCE = ROOT / 'evidence/chinese/chinese_year_contract.json'
EXPECTED = {137, 138, 139, 140, 141, 142}


def require(text: str, token: str, label: str) -> None:
    if token not in text:
        raise AssertionError(f'{label}: required token missing: {token!r}')


def master_items() -> dict[int, str]:
    text = MASTER.read_text(encoding='utf-8') + '\n' + ADDENDUM.read_text(encoding='utf-8')
    items = {
        int(number): body.strip()
        for number, body in re.findall(r'^(\d+)\.\s+(.+)$', text, re.MULTILINE)
    }
    if set(items) != set(range(1, 1443)):
        raise AssertionError('MASTER sequence is not exactly RC-0001..RC-1442')
    return items


def main() -> None:
    items = master_items()
    keywords = {
        137: '12 hayvan',
        138: 'Çin burcu',
        139: 'Çin elementi',
        140: 'Yin/Yang',
        141: 'Çin Yeni Yılı',
        142: 'BaZi, basit Çin burcundan tamamen ayrı',
    }
    for rc, keyword in keywords.items():
        if keyword.casefold() not in items[rc].casefold():
            raise AssertionError(
                f'RC-{rc:04d} MASTER ownership drift; missing {keyword!r}: {items[rc]}'
            )

    source = SOURCE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    payload = json.loads(EVIDENCE.read_text(encoding='utf-8'))

    requirements = payload.get('requirements')
    if not isinstance(requirements, list):
        raise AssertionError('evidence requirements[] is required')
    actual = {int(token[3:]) for token in requirements if isinstance(token, str) and re.fullmatch(r'RC-\d{4}', token)}
    if actual != EXPECTED or len(requirements) != len(EXPECTED):
        raise AssertionError(
            f'Chinese year evidence RC ownership mismatch; expected={sorted(EXPECTED)} actual={sorted(actual)}'
        )

    for token in (
        'enum ChineseZodiacAnimal',
        'rat,', 'ox,', 'tiger,', 'rabbit,', 'dragon,', 'snake,',
        'horse,', 'goat,', 'monkey,', 'rooster,', 'dog,', 'pig,',
        'enum ChineseFiveElement',
        'enum ChinesePolarity',
        'ChineseNewYearBoundaryProvider',
        'boundaryForGregorianYear',
        'guessing or Gregorian-year fallback is forbidden',
        '_jiaZiAnchorYear = 1984',
        'date.compareTo(boundary) < 0 ? date.year - 1 : date.year',
        'stemIndex.isEven ? ChinesePolarity.yang : ChinesePolarity.yin',
    ):
        require(source, token, 'source')

    # RC-0142: basic Chinese zodiac must remain a separate module and must not
    # import the BaZi Four Pillars implementation.
    if re.search(r"^import\s+['\"][^'\"]*bazi/", source, re.MULTILINE):
        raise AssertionError('basic Chinese zodiac engine must not import BaZi runtime code')

    for token in (
        'CivilDate(2024, 2, 10)',
        'CivilDate(2025, 1, 29)',
        'CivilDate(2026, 2, 17)',
        'uses previous Chinese year before Chinese New Year boundary',
        'switches Chinese zodiac exactly on Chinese New Year boundary',
        'fails closed when a verified Chinese New Year boundary is unavailable',
    ):
        require(test, token, 'test')

    fixtures = payload.get('referenceFixtures')
    expected_fixtures = {
        2024: '2024-02-10',
        2025: '2025-01-29',
        2026: '2026-02-17',
    }
    if not isinstance(fixtures, list) or len(fixtures) != len(expected_fixtures):
        raise AssertionError('evidence must retain exactly the three reviewed boundary fixtures')
    observed = {item.get('year'): item.get('chineseNewYear') for item in fixtures if isinstance(item, dict)}
    if observed != expected_fixtures:
        raise AssertionError(f'Chinese New Year fixture drift: {observed!r}')

    if payload.get('done') is not False:
        raise AssertionError('Chinese year evidence must remain done=false until full offline boundary proof exists')

    blockers = '\n'.join(str(item) for item in payload.get('remainingBeforeDone', [])).casefold()
    if 'complete verified offline chinese new year boundary dataset' not in blockers:
        raise AssertionError('evidence must keep the full offline boundary dataset blocker explicit')

    print('OK: Chinese zodiac year contract preserves 12 animals, element/polarity, exact CNY boundary handling, and BaZi separation')


if __name__ == '__main__':
    main()
