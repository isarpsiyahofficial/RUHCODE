#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import argparse
import csv
import hashlib
import json
import zipfile


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def read_zip_text(path: Path) -> list[str]:
    with zipfile.ZipFile(path) as archive:
        names = [name for name in archive.namelist() if not name.endswith('/')]
        if len(names) != 1:
            raise ValueError(f'Expected one data file in {path.name}, got {names}')
        with archive.open(names[0]) as raw:
            return [line.decode('utf-8').rstrip('\n\r') for line in raw]


def read_text(path: Path) -> list[str]:
    return path.read_text(encoding='utf-8').splitlines()


@dataclass(frozen=True)
class Country:
    code: str
    name: str


@dataclass(frozen=True)
class City:
    geoname_id: str
    name: str
    ascii_name: str
    alternates: tuple[str, ...]
    latitude: float
    longitude: float
    country_code: str
    admin1_code: str
    timezone: str


def parse_countries(lines: list[str]) -> dict[str, Country]:
    result: dict[str, Country] = {}
    for line in lines:
        if not line or line.startswith('#'):
            continue
        fields = line.split('\t')
        if len(fields) < 5:
            continue
        code = fields[0]
        name = fields[4]
        result[code] = Country(code=code, name=name)
    return result


def parse_admin1(lines: list[str]) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in lines:
        fields = line.split('\t')
        if len(fields) < 2:
            continue
        result[fields[0]] = fields[1]
    return result


def parse_alternate_names(lines: list[str]) -> dict[str, set[str]]:
    result: dict[str, set[str]] = {}
    for line in lines:
        fields = line.split('\t')
        if len(fields) < 4:
            continue
        geoname_id = fields[1]
        language = fields[2]
        alternate = fields[3].strip()
        if not alternate:
            continue
        if language in {'link', 'post', 'iata', 'icao', 'faac'}:
            continue
        bucket = result.setdefault(geoname_id, set())
        if len(bucket) < 64:
            bucket.add(alternate)
    return result


def parse_cities(lines: list[str], alternate_names: dict[str, set[str]]) -> list[City]:
    result: list[City] = []
    for line in lines:
        fields = line.split('\t')
        if len(fields) < 18:
            raise ValueError('Invalid GeoNames cities row')
        geoname_id = fields[0]
        name = fields[1]
        ascii_name = fields[2]
        inline_alternates = {value.strip() for value in fields[3].split(',') if value.strip()}
        aliases = set(alternate_names.get(geoname_id, set()))
        aliases.update(inline_alternates)
        aliases.discard(name)
        aliases.discard(ascii_name)
        result.append(
            City(
                geoname_id=geoname_id,
                name=name,
                ascii_name=ascii_name,
                alternates=tuple(sorted(aliases, key=lambda value: value.casefold())),
                latitude=float(fields[4]),
                longitude=float(fields[5]),
                country_code=fields[8],
                admin1_code=fields[10],
                timezone=fields[17],
            )
        )
    return result


def build(args: argparse.Namespace) -> dict[str, object]:
    countries = parse_countries(read_text(args.country_info))
    admin1 = parse_admin1(read_text(args.admin1))
    alternate_names = parse_alternate_names(read_zip_text(args.alternate_names))
    cities = parse_cities(read_zip_text(args.cities), alternate_names)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open('w', encoding='utf-8', newline='') as handle:
        fieldnames = [
            'stable_id',
            'canonical_name',
            'country_code',
            'country_name',
            'admin_area',
            'latitude',
            'longitude',
            'iana_timezone_id',
            'aliases_json',
        ]
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator='\n')
        writer.writeheader()
        for city in sorted(cities, key=lambda item: int(item.geoname_id)):
            country = countries.get(city.country_code)
            country_name = country.name if country else city.country_code
            admin_key = f'{city.country_code}.{city.admin1_code}' if city.admin1_code else ''
            aliases = [city.ascii_name, *city.alternates] if city.ascii_name != city.name else list(city.alternates)
            writer.writerow(
                {
                    'stable_id': f'geonames:{city.geoname_id}',
                    'canonical_name': city.name,
                    'country_code': city.country_code,
                    'country_name': country_name,
                    'admin_area': admin1.get(admin_key, ''),
                    'latitude': format(city.latitude, '.7f').rstrip('0').rstrip('.'),
                    'longitude': format(city.longitude, '.7f').rstrip('0').rstrip('.'),
                    'iana_timezone_id': city.timezone,
                    'aliases_json': json.dumps(aliases, ensure_ascii=False, separators=(',', ':')),
                }
            )

    manifest = {
        'format_version': 1,
        'record_count': len(cities),
        'output_file': args.output.name,
        'output_sha256': sha256(args.output),
        'sources': {
            args.cities.name: sha256(args.cities),
            args.alternate_names.name: sha256(args.alternate_names),
            args.admin1.name: sha256(args.admin1),
            args.country_info.name: sha256(args.country_info),
        },
    }
    args.output_manifest.parent.mkdir(parents=True, exist_ok=True)
    args.output_manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + '\n',
        encoding='utf-8',
    )
    return manifest


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description='Build deterministic offline Ruh Code city catalog from GeoNames files.')
    result.add_argument('--cities', required=True, type=Path)
    result.add_argument('--alternate-names', required=True, type=Path)
    result.add_argument('--admin1', required=True, type=Path)
    result.add_argument('--country-info', required=True, type=Path)
    result.add_argument('--output', required=True, type=Path)
    result.add_argument('--output-manifest', required=True, type=Path)
    return result


if __name__ == '__main__':
    arguments = parser().parse_args()
    produced = build(arguments)
    print(json.dumps(produced, ensure_ascii=False, sort_keys=True))
