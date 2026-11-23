#!/usr/bin/env python3
"""Blocking release gate for fully reviewed FR/EN/ES app and content localization."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
review_pending: list[str] = []


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


taxonomy = read_json(ROOT / "assets/explorer/explorer_taxonomy.json")
for domain in taxonomy.get("domains", []):
    for locale in ("en", "es"):
        if not domain.get(f"name_{locale}"):
            errors.append(f"{domain.get('id')}: missing domain name {locale}")
        if domain.get("translation_status", {}).get(locale) != "human_reviewed":
            review_pending.append(f"{domain.get('id')}: domain {locale} is not human-reviewed")
    for family in domain.get("families", []):
        family_id = family.get("id", "unknown-family")
        for locale in ("en", "es"):
            if not family.get(f"name_{locale}"):
                errors.append(f"{family_id}: missing family name {locale}")
            if family.get("translation_status", {}).get(locale) != "human_reviewed":
                review_pending.append(f"{family_id}: family {locale} is not human-reviewed")

seed = read_json(ROOT / "assets/explorer/occupations/occupation_seed_fr_en.json")["records"]
if len(seed) != 115:
    errors.append(f"Expected 115 occupations, found {len(seed)}")
for record in seed:
    occupation_id = record.get("id", "unknown")
    for field in ("canonical_title", "definition"):
        for locale in ("fr", "en", "es"):
            if not (record.get(field, {}).get(locale) or "").strip():
                errors.append(f"{occupation_id}: missing {field}.{locale}")
    statuses = record.get("translation_status", {})
    for locale in ("en", "es"):
        if statuses.get(locale) != "human_reviewed":
            review_pending.append(f"{occupation_id}: {locale} is not human-reviewed")
    for task in record.get("tasks", []):
        for locale in ("en", "es"):
            if not (task.get("translations", {}).get(locale) or "").strip():
                errors.append(f"{occupation_id}/{task.get('id')}: missing task {locale}")
            if task.get("translation_status", {}).get(locale) != "human_reviewed":
                review_pending.append(f"{occupation_id}/{task.get('id')}: task {locale} is not human-reviewed")

profile_files = sorted((ROOT / "assets/explorer/occupation_profiles").glob("*.json"))
profiles = [profile for path in profile_files for profile in read_json(path).get("profiles", [])]
for profile in profiles:
    profile_id = profile.get("occupation_id") or profile.get("id") or "unknown-profile"
    for field in ("purpose", "missions", "work_context", "skills", "knowledge", "mapping_note", "country_specific_requirements"):
        for locale in ("fr", "en", "es"):
            base_fields = ("skills", "knowledge", "mapping_note", "country_specific_requirements")
            value = profile.get(field) if locale == "fr" and field in base_fields else profile.get(f"{field}_{locale}")
            source_exists = bool(profile.get(field) if field in base_fields else profile.get(f"{field}_fr"))
            if source_exists and not value:
                errors.append(f"{profile_id}: missing {field}_{locale}")
    for locale in ("en", "es"):
        if profile.get("translation_status", {}).get(locale) != "human_reviewed":
            review_pending.append(f"{profile_id}: profile {locale} is not human-reviewed")

pathways_path = ROOT / "assets/explorer/training_pathways_v3.2.json"
if pathways_path.exists():
    pathways = read_json(pathways_path).get("pathways", [])
    for pathway in pathways:
        occupation_id = pathway.get("occupation_id", "unknown")
        for field in ("pathway", "notes"):
            for locale in ("en", "es"):
                if not (pathway.get(f"{field}_{locale}") or "").strip():
                    errors.append(f"{occupation_id}: missing {field}_{locale}")
        for locale in ("en", "es"):
            if pathway.get("translation_status", {}).get(locale) != "human_reviewed":
                review_pending.append(f"{occupation_id}: pathway {locale} is not human-reviewed")

outlook_path = ROOT / "assets/explorer/employment_outlook_v4.json"
if outlook_path.exists():
    outlook_records = read_json(outlook_path).get("records", [])
    for outlook in outlook_records:
        occupation_id = outlook.get("occupation_id", "unknown")
        for field in ("qualitative_outlook", "localization_note"):
            for locale in ("en", "es"):
                if outlook.get(f"{field}_fr") and not (outlook.get(f"{field}_{locale}") or "").strip():
                    errors.append(f"{occupation_id}: missing {field}_{locale}")
        for locale in ("en", "es"):
            if outlook.get("translation_status", {}).get(locale) != "human_reviewed":
                review_pending.append(f"{occupation_id}: outlook {locale} is not human-reviewed")

academy_path = ROOT / "assets/academy/learning-paths-fr.json"
if academy_path.exists():
    academy = read_json(academy_path)
    for index, course in enumerate(academy):
        for locale in ("en", "es"):
            translated = course.get("translations", {}).get(locale, {})
            if not translated.get("title") or not translated.get("learning_outcomes"):
                errors.append(f"Academy course {index}: missing {locale} title/outcomes")
            if course.get("translation_status", {}).get(locale) != "human_reviewed":
                review_pending.append(f"Academy course {index}: {locale} is not human-reviewed")
            source_modules = {module.get("id"): module for module in course.get("modules", [])}
            translated_modules = {module.get("id"): module for module in translated.get("modules", [])}
            for module_id, source_module in source_modules.items():
                target_module = translated_modules.get(module_id)
                if not target_module or not target_module.get("title"):
                    errors.append(f"Academy {course.get('id')}/{module_id}: missing {locale} module title")
                    continue
                target_lessons = {lesson.get("id"): lesson for lesson in target_module.get("lessons", [])}
                for lesson in source_module.get("lessons", []):
                    target_lesson = target_lessons.get(lesson.get("id"), {})
                    for field in ("title", "objective", "activity", "assessment"):
                        if not target_lesson.get(field):
                            errors.append(f"Academy {course.get('id')}/{lesson.get('id')}: missing {locale} {field}")

arb_keys: dict[str, set[str]] = {}
arb_data: dict[str, dict] = {}
for locale in ("fr", "en", "es"):
    arb_path = ROOT / f"lib/l10n/app_{locale}.arb"
    if not arb_path.exists():
        errors.append(f"Missing UI localization file app_{locale}.arb")
        continue
    arb = read_json(arb_path)
    arb_data[locale] = arb
    arb_keys[locale] = {key for key in arb if not key.startswith("@@")}
    for key, value in arb.items():
        if key.startswith("@") or not isinstance(value, str):
            continue
        placeholders = set(re.findall(r"\{([A-Za-z][A-Za-z0-9_]*)\}", value))
        metadata = set((arb.get(f"@{key}", {}).get("placeholders") or {}).keys())
        if placeholders != metadata:
            errors.append(f"UI ARB placeholder mismatch for {key} in {locale}: text={sorted(placeholders)}, metadata={sorted(metadata)}")
if len(arb_keys) == 3:
    reference = arb_keys["fr"]
    for locale in ("en", "es"):
        if arb_keys[locale] != reference:
            missing = sorted(reference - arb_keys[locale])
            extra = sorted(arb_keys[locale] - reference)
            errors.append(f"UI ARB key mismatch for {locale}: missing={missing}, extra={extra}")
    for key in sorted(reference):
        metadata_key = f"@{key}"
        reference_metadata = arb_data["fr"].get(metadata_key)
        if reference_metadata is not None:
            for locale in ("en", "es"):
                if arb_data[locale].get(metadata_key) != reference_metadata:
                    errors.append(f"UI ARB placeholder metadata mismatch for {key} in {locale}")
if not (ROOT / "l10n.yaml").exists():
    errors.append("Missing l10n.yaml generation configuration")

review_status_path = ROOT / "assets/localization/review_status.json"
if not review_status_path.exists():
    errors.append("Missing assets/localization/review_status.json")
else:
    review_status = read_json(review_status_path)
    for locale in ("en", "es"):
        status = review_status.get("locales", {}).get(locale, {}).get("status")
        if status != "human_reviewed":
            review_pending.append(f"UI locale {locale} is not human-reviewed (status={status})")

if errors or review_pending:
    print(f"TRANSLATION GATE: BLOCKED ({len(errors)} content/structure issues; {len(review_pending)} human-review items pending)")
    for error in errors[:80]:
        print(f"- CONTENT: {error}")
    if len(errors) > 80:
        print(f"- ... and {len(errors) - 80} more content/structure issues")
    for item in review_pending[:80]:
        print(f"- REVIEW: {item}")
    if len(review_pending) > 80:
        print(f"- ... and {len(review_pending) - 80} more human-review items")
    raise SystemExit(1)

print("TRANSLATION GATE: PASS — FR/EN/ES UI and all required content are complete and human-reviewed.")
