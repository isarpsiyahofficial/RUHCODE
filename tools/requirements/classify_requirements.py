#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re

ALLOWED_TAGS = {
    'CALC','CONTENT','UI','I18N','OFFLINE','ENTITLEMENT','BACKUP','PDF',
    'SECURITY','A11Y','PERF','RELEASE'
}

TAG_KEYWORDS = {
    'CALC': [
        'hesap', 'calculation', 'astroloji', 'vedik', 'bazi', 'ba zi', 'numeroloji',
        'gezegen', 'planetary', 'transit', 'dasha', 'nakshatra', 'pada', 'ayanamsha',
        'julian', 'zodyak', 'zodiac', 'yükselen', 'asc', 'mc', 'ev sistemi', 'house',
        'aspect', 'açı', 'retrograde', 'sunrise', 'sunset', 'güneş doğ', 'güneş bat',
        'ay faz', 'ephemeris', 'longitude', 'degree', 'derece', 'solar return',
        'lunar return', 'progression', 'synastry', 'composite', 'davison', 'lo shu',
        'chaldean', 'pythagorean', 'tithi', 'karana', 'yoga', 'shadbala', 'ashtakavarga',
        'four pillars', 'day master', 'ten gods', 'luck pillars', 'da yun'
    ],
    'CONTENT': [
        'yorum', 'mesaj', 'interpretation', 'metin', 'içerik', 'teaser', 'günün kartı',
        'tarot', 'affirmation', 'şükran', 'meditasyon', 'nefes', 'spiritüel', 'ruhsal',
        'öğrenme', 'terminology', 'glossary', 'açıklama', 'uyarı dili'
    ],
    'UI': [
        'arayüz', 'ui', 'ekran', 'buton', 'button', 'kart', 'menü', 'navigasyon',
        'navigation', 'görünüm', 'layout', 'responsive', 'ikon', 'icon', 'svg', 'vector',
        'logo', 'renk', 'typography', 'font', 'tasarım', 'design', 'preview', 'önizleme',
        'tab', 'chip', 'grid', 'chart', 'çark', 'wheel', 'renderer', 'zoom', 'taşma'
    ],
    'I18N': [
        'türkçe', 'ingilizce', 'tr ', ' en ', 'dil', 'locale', 'localization', 'çeviri',
        'transliterasyon', 'unicode', 'i18n', 'terminology'
    ],
    'OFFLINE': [
        'offline', 'çevrimdışı', 'uçak modu', 'airplane', 'sunucu gerektirm',
        'server', 'lokal', 'local ', 'cihaz üzerinde', 'network', 'internet gerektirm'
    ],
    'ENTITLEMENT': [
        'free', 'pro', 'premium', 'reklam', 'satın alma', 'restore', 'entitlement',
        'kilit', 'ödüllü reklam', 'monetizasyon', 'subscription', 'tek seferlik'
    ],
    'BACKUP': [
        'backup', 'yedek', 'csv', 'restore', 'import', 'export', 'dışa aktar', 'içe aktar',
        'snapshot', 'migration', 'schema', 'round-trip', 'rollback'
    ],
    'PDF': [
        'pdf', 'rapor', 'report', 'a4', 'sayfa', 'page break', 'kapak'
    ],
    'SECURITY': [
        'güvenlik', 'security', 'gizlilik', 'privacy', 'şifre', 'encrypt', 'keystore',
        'biometric', 'biyometrik', 'pin', 'hassas', 'log', 'checksum', 'hash', 'license',
        'lisans', 'permission', 'izin', 'koruma'
    ],
    'A11Y': [
        'accessibility', 'erişilebilir', 'screen reader', 'kontrast', 'touch target',
        'dokunma alan', 'büyük font', 'font scaling', 'yalnız renkle'
    ],
    'PERF': [
        'performans', 'performance', 'stress', 'binlerce', '10.000', '1.000', 'ram',
        'memory', 'cache', 'lazy', 'pagination', 'hızlı', 'saniye', 'ölçek'
    ],
    'RELEASE': [
        'release', 'final', 'ci', 'github', 'commit', 'sha', 'apk', 'build', 'test',
        'doğrula', 'doğrulan', 'regresyon', 'golden', 'done', 'requirement', 'şartname',
        'audit', 'manifest', 'version', 'sürüm', 'workflow', 'artifact'
    ],
}

# Range policies add domain context that cannot always be inferred from a short sentence.
RANGE_TAGS = [
    (1, 186, {'CALC'}),
    (187, 230, {'CONTENT','UI'}),
    (231, 274, {'UI'}),
    (275, 305, {'ENTITLEMENT','UI'}),
    (306, 341, {'CALC','RELEASE'}),
    (342, 405, {'UI','RELEASE'}),
    (406, 420, {'CONTENT','UI'}),
    (421, 632, {'UI'}),
    (633, 773, {'OFFLINE','RELEASE'}),
    (774, 858, {'BACKUP'}),
    (859, 964, {'PDF','UI'}),
    (965, 1058, {'RELEASE'}),
    (1050, 1079, {'I18N'}),
    (1085, 1105, {'ENTITLEMENT'}),
    (1106, 1122, {'OFFLINE','SECURITY'}),
    (1123, 1176, {'RELEASE'}),
    (1177, 1205, {'SECURITY'}),
    (1206, 1248, {'PERF','BACKUP'}),
    (1249, 1302, {'PDF','UI','ENTITLEMENT'}),
    (1303, 1406, {'RELEASE'}),
    (1407, 1419, {'OFFLINE'}),
    (1420, 1442, {'RELEASE'}),
    (1421, 1428, {'CALC','CONTENT'}),
    (1429, 1431, {'UI'}),
    (1432, 1432, {'UI'}),
    (1433, 1434, {'CONTENT','I18N','RELEASE'}),
    (1435, 1437, {'CALC','OFFLINE','RELEASE'}),
    (1438, 1440, {'UI','RELEASE'}),
    (1441, 1441, {'A11Y','UI','RELEASE'}),
    (1442, 1442, {'RELEASE','OFFLINE'}),
]

EVIDENCE_BY_TAG = {
    'CALC': 'unit+reference-golden',
    'CONTENT': 'catalog-coverage+editorial-review',
    'UI': 'ui-reference+visual-regression+interaction',
    'I18N': 'locale-parity+leakage-test',
    'OFFLINE': 'airplane-mode+network-inventory',
    'ENTITLEMENT': 'free-pro-entitlement-matrix',
    'BACKUP': 'export-import-round-trip+rollback',
    'PDF': 'pdf-parse+data-equality+visual-regression',
    'SECURITY': 'security-privacy-test+manifest-review',
    'A11Y': 'accessibility-audit',
    'PERF': 'performance-stress-benchmark',
    'RELEASE': 'ci-contract+release-evidence',
}


def classify(number: int, text: str) -> tuple[str, str]:
    normalized = ' ' + text.casefold() + ' '
    tags: set[str] = set()

    for start, end, range_tags in RANGE_TAGS:
        if start <= number <= end:
            tags.update(range_tags)

    for tag, keywords in TAG_KEYWORDS.items():
        if any(keyword.casefold() in normalized for keyword in keywords):
            tags.add(tag)

    # Every binding requirement must have an auditable release proof even when its
    # primary domain is product behavior rather than a technical subsystem.
    if not tags:
        tags.add('RELEASE')

    unknown = tags - ALLOWED_TAGS
    if unknown:
        raise ValueError(f'Unknown tags for RC-{number:04d}: {sorted(unknown)}')

    ordered = sorted(tags, key=lambda value: list(EVIDENCE_BY_TAG).index(value))
    evidence = [EVIDENCE_BY_TAG[tag] for tag in ordered]
    return '|'.join(ordered), '|'.join(evidence)


if __name__ == '__main__':
    print('classification policy OK')
