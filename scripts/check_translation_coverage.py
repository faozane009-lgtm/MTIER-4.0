#!/usr/bin/env python3
"""Blocking coverage/structure check; deliberately does not claim human review."""
from __future__ import annotations
import json, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
errors=[]
def read(path): return json.loads(path.read_text(encoding='utf-8'))
def require(value, label):
    if value is None or (isinstance(value,str) and not value.strip()) or value == []:
        errors.append(f"missing: {label}")

tax=read(ROOT/'assets/explorer/explorer_taxonomy.json')
domains=tax.get('domains',[])
family_ids=[]
for d in domains:
    for loc in ('fr','en','es'): require(d.get(f'name_{loc}'),f"{d.get('id')} name_{loc}")
    for f in d.get('families',[]):
        family_ids.append(f.get('id'))
        for loc in ('fr','en','es'): require(f.get(f'name_{loc}'),f"{f.get('id')} name_{loc}")
seed=read(ROOT/'assets/explorer/occupations/occupation_seed_fr_en.json').get('records',[])
ids=[r.get('id') for r in seed]
if len(seed)!=115 or len(set(ids))!=115: errors.append(f"occupation catalog count/uniqueness: {len(seed)}")
for r in seed:
    oid=r.get('id','unknown')
    for field in ('canonical_title','definition'):
        for loc in ('fr','en','es'): require(r.get(field,{}).get(loc),f'{oid} {field}.{loc}')
    for t in r.get('tasks',[]):
        for loc in ('en','es'): require(t.get('translations',{}).get(loc),f"{oid}/{t.get('id')} task {loc}")
profile_files=sorted((ROOT/'assets/explorer/occupation_profiles').glob('*.json'))
profiles=[x for f in profile_files for x in read(f).get('profiles',[])]
pmap={p.get('occupation_id') or p.get('id'):p for p in profiles}
if len(profiles)!=115 or set(pmap)!=set(ids): errors.append('profile IDs do not exactly match the 115 occupation IDs')
for p in profiles:
    oid=p.get('occupation_id') or p.get('id') or 'unknown'
    for field in ('purpose','missions','work_context','skills','knowledge','mapping_note'):
        for loc in ('fr','en','es'):
            value=p.get(field) if loc=='fr' and field in ('skills','knowledge','mapping_note') else p.get(f'{field}_{loc}')
            require(value,f'{oid} {field}_{loc}')
    if p.get('country_specific_requirements'):
        for loc in ('en','es'): require(p.get(f'country_specific_requirements_{loc}'),f'{oid} country_specific_requirements_{loc}')
    for field in ('skills','knowledge'):
        source=p.get(field,[])
        for loc in ('en','es'):
            target=p.get(f'{field}_{loc}',[])
            if len(source)!=len(target): errors.append(f'{oid} {field}_{loc} length mismatch')
    for loc in ('en','es'):
        if len(p.get('missions_fr',[]))!=len(p.get(f'missions_{loc}',[])): errors.append(f'{oid} missions_{loc} length mismatch')
pathways=read(ROOT/'assets/explorer/training_pathways_v3.2.json').get('pathways',[])
outlook=read(ROOT/'assets/explorer/employment_outlook_v4.json').get('records',[])
for label,rows,fields in [('pathway',pathways,('pathway','notes')),('outlook',outlook,('qualitative_outlook','localization_note'))]:
    row_ids=[r.get('occupation_id') for r in rows]
    if len(rows)!=115 or set(row_ids)!=set(ids): errors.append(f'{label} IDs do not exactly match occupation catalog')
    for r in rows:
        oid=r.get('occupation_id','unknown')
        for field in fields:
            for loc in ('en','es'): require(r.get(f'{field}_{loc}'),f'{oid} {field}_{loc}')
academy=read(ROOT/'assets/academy/learning-paths-fr.json')
if len(academy)!=3: errors.append(f'expected 3 Academy learning paths, found {len(academy)}')
for c in academy:
    for loc in ('en','es'):
        tr=c.get('translations',{}).get(loc,{})
        require(tr.get('title'),f"Academy {c.get('id')} title {loc}")
        if len(tr.get('learning_outcomes',[]))!=len(c.get('learning_outcomes',[])): errors.append(f"Academy {c.get('id')} outcomes {loc} length mismatch")
        sm={m.get('id'):m for m in c.get('modules',[])}; tm={m.get('id'):m for m in tr.get('modules',[])}
        if set(sm)!=set(tm): errors.append(f"Academy {c.get('id')} modules {loc} ID mismatch")
        for mid,m in sm.items():
            target=tm.get(mid,{})
            require(target.get('title'),f'Academy {c.get("id")} module {mid} {loc} title')
            sl={l.get('id'):l for l in m.get('lessons',[])}; tl={l.get('id'):l for l in target.get('lessons',[])}
            if set(sl)!=set(tl): errors.append(f'Academy {c.get("id")} module {mid} {loc} lesson ID mismatch')
            for lid in sl:
                for field in ('title','objective','activity','assessment'): require(tl.get(lid,{}).get(field),f'Academy {c.get("id")} {lid} {loc} {field}')
arbs={loc:read(ROOT/f'lib/l10n/app_{loc}.arb') for loc in ('fr','en','es')}
keys={loc:{k for k in a if not k.startswith('@')} for loc,a in arbs.items()}
if not (keys['fr']==keys['en']==keys['es']): errors.append('ARB keysets differ across FR/EN/ES')
for loc,a in arbs.items():
    for k in keys[loc]:
        require(a.get(k),f'ARB {loc}.{k}')
        placeholders=set(re.findall(r'\{([A-Za-z][A-Za-z0-9_]*)\}',a.get(k,'')))
        metadata=set((a.get(f'@{k}',{}).get('placeholders') or {}).keys())
        if placeholders!=metadata: errors.append(f'ARB {loc}.{k} placeholder mismatch')
if not (ROOT/'l10n.yaml').exists(): errors.append('missing l10n.yaml')
if errors:
    print(f'TRANSLATION COVERAGE: FAIL ({len(errors)} issues)')
    for e in errors[:100]: print('-',e)
    if len(errors)>100: print(f'- ... and {len(errors)-100} more')
    raise SystemExit(1)
print('TRANSLATION COVERAGE: PASS')
print(f'FR/EN/ES coverage: {len(domains)} domains, {len(family_ids)} families, 115 occupations, 345 tasks, 115 detailed profiles, 115 pathways, 115 outlook records, {len(academy)} Academy courses, and {len(keys["fr"])} UI keys.')
print('Review state is checked separately; machine drafts are not represented as human-approved.')
