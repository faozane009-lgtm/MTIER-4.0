import json
import re
from pathlib import Path

ROOT = Path(__file__).parent
BASE = ROOT / 'assets' / 'explorer'
MAIN = (ROOT / 'lib' / 'main.dart').read_text(encoding='utf-8')


def load(path):
    return json.loads((BASE / path).read_text(encoding='utf-8'))


# Verify the exact profile files loaded by the Flutter runtime, not every JSON
# file that happens to exist in the assets directory.
profile_assets_match = re.search(
    r'const profileAssets = <String>\[(.*?)\];', MAIN, flags=re.DOTALL
)
assert profile_assets_match, 'profileAssets list not found in lib/main.dart'
profile_assets = re.findall(r"'([^']+\.json)'", profile_assets_match.group(1))
assert len(profile_assets) == 10, profile_assets

seed = load('occupations/occupation_seed_fr_en.json')['records']
ids = [item['id'] for item in seed]
assert len(seed) == 115, len(seed)
assert len(set(ids)) == 115
assert all('en' in item.get('canonical_title', {}) and 'es' in item.get('canonical_title', {}) for item in seed)
assert all('en' in item.get('definition', {}) and 'es' in item.get('definition', {}) for item in seed)
assert all(item.get('translation_status', {}).get('en') == 'machine_draft_needs_human_review' and item.get('translation_status', {}).get('es') == 'machine_draft_needs_human_review' for item in seed)
taxonomy = load('explorer_taxonomy.json')
assert len(taxonomy['domains']) == 28
assert all(domain.get('name_en') and domain.get('name_es') for domain in taxonomy['domains'])
assert all(domain.get('translation_status', {}).get('en') == 'machine_draft_needs_human_review' and domain.get('translation_status', {}).get('es') == 'machine_draft_needs_human_review' for domain in taxonomy['domains'])
families = [family for domain in taxonomy['domains'] for family in domain.get('families', [])]
family_ids = [family.get('id') for family in families]
assert len(families) == 216, len(families)
assert len(set(family_ids)) == 216, 'Duplicate family IDs'
assert all(family.get('name_en') and family.get('name_es') for family in families)
assert all(family.get('translation_status', {}).get('en') == 'machine_draft_needs_human_review' and family.get('translation_status', {}).get('es') == 'machine_draft_needs_human_review' for family in families)

profiles = {}
for relative_path in profile_assets:
    path = ROOT / relative_path
    assert path.is_file(), f'Loaded profile asset does not exist: {relative_path}'
    data = json.loads(path.read_text(encoding='utf-8'))
    for profile in data.get('profiles', []):
        key = profile.get('occupation_id') or profile.get('id')
        if key:
            profiles[key] = profile

missing = sorted(set(ids) - set(profiles))
assert not missing, f'Occupations without a profile loaded by the app: {missing}'
assert len(profiles) == 115, len(profiles)
assert all(profile.get('translation_status', {}).get('en') == 'machine_draft_needs_human_review' and profile.get('translation_status', {}).get('es') == 'machine_draft_needs_human_review' for profile in profiles.values())
assert all(profile.get('purpose_en') and profile.get('purpose_es') and profile.get('missions_en') and profile.get('missions_es') and profile.get('work_context_en') and profile.get('work_context_es') and profile.get('skills_en') and profile.get('skills_es') and profile.get('knowledge_en') and profile.get('knowledge_es') and profile.get('mapping_note_en') and profile.get('mapping_note_es') for profile in profiles.values())

cyber_path = ROOT / 'assets/explorer/occupation_profiles/cybersecurity_profiles_v0.1.json'
cyber_profiles = json.loads(cyber_path.read_text(encoding='utf-8'))['profiles']
assert len(cyber_profiles) == 10
assert all('id' in profile and 'occupation_id' not in profile for profile in cyber_profiles)
assert all(
    isinstance(entry, list) and len(entry) == 2
    for profile in cyber_profiles
    for entry in profile.get('skills', [])
)
assert all(
    isinstance(entry, list) and len(entry) == 2
    for profile in cyber_profiles
    for entry in profile.get('evidence', [])
)

for filename, key in [
    ('training_pathways_v3.2.json', 'pathways'),
    ('employment_outlook_v4.json', 'records'),
    ('salary_coverage_by_occupation_v4.json', 'coverage'),
    ('classification_review_v4.json', 'records'),
]:
    records = load(filename)[key]
    indexed = {record['occupation_id'] for record in records}
    assert indexed == set(ids), (
        filename,
        sorted(set(ids) - indexed),
    )

pathways = load('training_pathways_v3.2.json')['pathways']
outlook = load('employment_outlook_v4.json')['records']
assert len(pathways) == len(outlook) == 115
assert all(record.get('pathway_en') and record.get('pathway_es') and record.get('notes_en') and record.get('notes_es') for record in pathways)
assert all(record.get('qualitative_outlook_en') and record.get('qualitative_outlook_es') and record.get('localization_note_en') and record.get('localization_note_es') for record in outlook)
assert all(record.get('translation_status', {}).get('en') == 'machine_draft_needs_human_review' and record.get('translation_status', {}).get('es') == 'machine_draft_needs_human_review' for record in pathways + outlook)

print(
    'PASS: 115 occupations; 115 profiles loaded through the exact 10 Flutter '
    'profileAssets; 216 translated taxonomy families; cybersecurity tuple formats identified; 115 pathways and outlooks translated EN/ES; 115 salary coverage records and 115 classification reviews; translation drafts retain explicit review status.'
)
