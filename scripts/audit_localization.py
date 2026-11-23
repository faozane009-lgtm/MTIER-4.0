#!/usr/bin/env python3
"""Report real FR/EN/ES content coverage without treating fallback as translation."""
from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPLORER = ROOT / "assets/explorer"


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


seed = read_json(EXPLORER / "occupations/occupation_seed_fr_en.json")["records"]
profile_files = sorted((EXPLORER / "occupation_profiles").glob("*.json"))
profiles = []
for path in profile_files:
    profiles.extend(read_json(path).get("profiles", []))
academy = read_json(ROOT / "assets/academy/learning-paths-fr.json")
taxonomy = read_json(EXPLORER / "explorer_taxonomy.json")

print(f"Explorer occupations: {len(seed)}")
for field in ("canonical_title", "definition"):
    print(f"  {field}: " + ", ".join(
        f"{locale}={sum(locale in item.get(field, {}) for item in seed)}/{len(seed)}"
        for locale in ("fr", "en", "es")
    ))

task_locales = Counter(task.get("locale", "unknown")
                       for occupation in seed
                       for task in occupation.get("tasks", []))
print(f"  tasks by source locale: {dict(task_locales)}")
for locale in ("en", "es"):
    translated_tasks = sum(bool(task.get("translations", {}).get(locale)) for occupation in seed for task in occupation.get("tasks", []))
    reviewed_tasks = sum(task.get("translation_status", {}).get(locale) == "human_reviewed" for occupation in seed for task in occupation.get("tasks", []))
    print(f"  tasks {locale}: {translated_tasks}/345; human-reviewed {reviewed_tasks}/345")
print("  occupation translation review states: " + str(dict(Counter(record.get("translation_status", {}).get(locale, "missing") for record in seed for locale in ("en", "es")))))
domains = taxonomy.get('domains', [])
families = [family for domain in domains for family in domain.get('families', [])]
print(f"Explorer domains: {len(domains)}; EN={sum(bool(d.get('name_en')) for d in domains)}; ES={sum(bool(d.get('name_es')) for d in domains)}; human-reviewed EN/ES={sum(d.get('translation_status', {}).get('en') == 'human_reviewed' for d in domains)}/{len(domains)} and {sum(d.get('translation_status', {}).get('es') == 'human_reviewed' for d in domains)}/{len(domains)}")
print(f"Explorer families: {len(families)}; EN={sum(bool(f.get('name_en')) for f in families)}; ES={sum(bool(f.get('name_es')) for f in families)}; human-reviewed EN/ES={sum(f.get('translation_status', {}).get('en') == 'human_reviewed' for f in families)}/{len(families)} and {sum(f.get('translation_status', {}).get('es') == 'human_reviewed' for f in families)}/{len(families)}")
print(f"Detailed profiles: {len(profiles)}")
for field in ("purpose", "missions", "work_context"):
    print(f"  {field}: " + ", ".join(
        f"{locale}={sum(bool(profile.get(f'{field}_{locale}')) for profile in profiles)}/{len(profiles)}"
        for locale in ("fr", "en", "es")
    ))
for field in ("skills", "knowledge", "mapping_note", "country_specific_requirements"):
    source = sum(bool(profile.get(field)) for profile in profiles)
    print(f"  {field}: FR/source={source}/{len(profiles)}; EN={sum(bool(profile.get(f'{field}_en')) for profile in profiles)}/{len(profiles)}; ES={sum(bool(profile.get(f'{field}_es')) for profile in profiles)}/{len(profiles)}")
print("  profile review states: " + str(dict(Counter(profile.get("translation_status", {}).get(locale, "missing") for profile in profiles for locale in ("en", "es")))))
pathways = read_json(EXPLORER / "training_pathways_v3.2.json").get("pathways", [])
outlook = read_json(EXPLORER / "employment_outlook_v4.json").get("records", [])
print(f"Training pathways: {len(pathways)}; pathway EN={sum(bool(p.get('pathway_en')) for p in pathways)}; ES={sum(bool(p.get('pathway_es')) for p in pathways)}; notes EN={sum(bool(p.get('notes_en')) for p in pathways)}; ES={sum(bool(p.get('notes_es')) for p in pathways)}; human-reviewed EN/ES={sum(p.get('translation_status', {}).get('en') == 'human_reviewed' for p in pathways)}/{len(pathways)} and {sum(p.get('translation_status', {}).get('es') == 'human_reviewed' for p in pathways)}/{len(pathways)}")
print(f"Employment outlook: {len(outlook)}; outlook EN={sum(bool(p.get('qualitative_outlook_en')) for p in outlook)}; ES={sum(bool(p.get('qualitative_outlook_es')) for p in outlook)}; localization notes EN={sum(bool(p.get('localization_note_en')) for p in outlook)}; ES={sum(bool(p.get('localization_note_es')) for p in outlook)}; human-reviewed EN/ES={sum(p.get('translation_status', {}).get('en') == 'human_reviewed' for p in outlook)}/{len(outlook)} and {sum(p.get('translation_status', {}).get('es') == 'human_reviewed' for p in outlook)}/{len(outlook)}")
print(f"Academy learning paths: {len(academy)}")
for locale in ("en", "es"):
    translated = sum(bool(course.get("translations", {}).get(locale, {}).get("title")) for course in academy)
    reviewed = sum(course.get("translation_status", {}).get(locale) == "human_reviewed" for course in academy)
    print(f"  Academy {locale}: {translated}/{len(academy)} course structures (human-reviewed {reviewed}/{len(academy)})")
arb_files = {locale: read_json(ROOT / f"lib/l10n/app_{locale}.arb") for locale in ("fr", "en", "es")}
ui_keys = {locale: {key for key in content if not key.startswith("@")} for locale, content in arb_files.items()}
print(f"UI ARB message keys (metadata excluded): FR={len(ui_keys['fr'])}; EN={len(ui_keys['en'])}; ES={len(ui_keys['es'])}; keysets_match={ui_keys['fr'] == ui_keys['en'] == ui_keys['es']}")
review_path = ROOT / "assets/localization/review_status.json"
if review_path.exists():
    review = read_json(review_path).get("locales", {})
    print("UI review states: " + ", ".join(f"{locale}={review.get(locale, {}).get('status', 'missing')}" for locale in ("en", "es")))
print("Coverage status: audit only; missing fields are not considered translated or approved.")
