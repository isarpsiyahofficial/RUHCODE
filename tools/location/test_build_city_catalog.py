#!/usr/bin/env python3
from pathlib import Path
import csv
import importlib.util
import json
import sys
import tempfile
import unittest
import zipfile

MODULE_PATH = Path(__file__).with_name('build_city_catalog.py')
spec = importlib.util.spec_from_file_location('build_city_catalog', MODULE_PATH)
assert spec and spec.loader
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)


def write_zip(path: Path, member_name: str, text: str) -> None:
    with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        archive.writestr(member_name, text.encode('utf-8'))


def fixture_files(root: Path):
    cities = root / 'cities500.zip'
    aliases = root / 'alternateNamesV2.zip'
    admin1 = root / 'admin1CodesASCII.txt'
    country = root / 'countryInfo.txt'
    write_zip(
        cities,
        'cities500.txt',
        '745044\tİstanbul\tIstanbul\tStamboul\t41.0138\t28.9497\tP\tPPLA\tTR\t\t34\t\t\t\t14804116\t\t\tEurope/Istanbul\t2025-01-01\n'
        '4250542\tSpringfield\tSpringfield\t\t39.8017\t-89.6437\tP\tPPLA2\tUS\t\tIL\t\t\t\t114394\t\t\tAmerica/Chicago\t2025-01-01\n',
    )
    write_zip(
        aliases,
        'alternateNamesV2.txt',
        '1\t745044\ten\tConstantinople\t0\t0\t0\t0\t\n'
        '2\t745044\ttr\tİstanbul\t1\t0\t0\t0\t\n',
    )
    admin1.write_text('TR.34\tIstanbul\tIstanbul\t745042\nUS.IL\tIllinois\tIllinois\t4896861\n', encoding='utf-8')
    country.write_text(
        '#ISO\tISO3\tISO-Numeric\tfips\tCountry\n'
        'TR\tTUR\t792\tTU\tTürkiye\n'
        'US\tUSA\t840\tUS\tUnited States\n',
        encoding='utf-8',
    )
    return cities, aliases, admin1, country


class CityCatalogBuilderTest(unittest.TestCase):
    def test_fixture_build_is_deterministic_and_preserves_timezone_aliases(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            cities, aliases, admin1, country = fixture_files(root)
            output = root / 'cities.csv'
            manifest = root / 'manifest.json'
            args = module.argparse.Namespace(
                cities=cities,
                alternate_names=aliases,
                admin1=admin1,
                country_info=country,
                output=output,
                output_manifest=manifest,
            )
            first = module.build(args)
            first_bytes = output.read_bytes()
            second = module.build(args)

            self.assertEqual(first, second)
            self.assertEqual(first_bytes, output.read_bytes())
            self.assertEqual(first['record_count'], 2)
            self.assertEqual(first['output_sha256'], second['output_sha256'])
            self.assertTrue(first['alternate_names_enrichment'])

            with output.open(encoding='utf-8', newline='') as handle:
                rows = list(csv.DictReader(handle))
            self.assertEqual(rows[0]['stable_id'], 'geonames:745044')
            self.assertEqual(rows[0]['canonical_name'], 'İstanbul')
            self.assertEqual(rows[0]['country_name'], 'Türkiye')
            self.assertEqual(rows[0]['admin_area'], 'Istanbul')
            self.assertEqual(rows[0]['iana_timezone_id'], 'Europe/Istanbul')
            self.assertIn('Constantinople', json.loads(rows[0]['aliases_json']))
            self.assertEqual(rows[1]['iana_timezone_id'], 'America/Chicago')

    def test_default_build_uses_inline_aliases_without_full_alternate_archive(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            cities, _, admin1, country = fixture_files(root)
            output = root / 'cities.csv'
            manifest = root / 'manifest.json'
            args = module.argparse.Namespace(
                cities=cities,
                alternate_names=None,
                admin1=admin1,
                country_info=country,
                output=output,
                output_manifest=manifest,
            )
            result = module.build(args)
            self.assertFalse(result['alternate_names_enrichment'])
            self.assertNotIn('alternateNamesV2.zip', result['sources'])
            with output.open(encoding='utf-8', newline='') as handle:
                rows = list(csv.DictReader(handle))
            self.assertIn('Stamboul', json.loads(rows[0]['aliases_json']))
            self.assertIn('Istanbul', json.loads(rows[0]['aliases_json']))

    def test_duplicate_zip_members_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'bad.zip'
            with zipfile.ZipFile(path, 'w') as archive:
                archive.writestr('a.txt', 'a')
                archive.writestr('b.txt', 'b')
            with self.assertRaises(ValueError):
                module.read_zip_text(path)


if __name__ == '__main__':
    unittest.main()
