# M-TIER 4.0 — ORIENTATION v0.1

## Purpose
Produce explainable career exploration suggestions from the current Profile form and the canonical Explorer catalogue. This is guidance, not a psychometric test or a definitive career decision.

## Single sources of truth
- Profile inputs: `ProfilePage._profileSnapshot()` exposed through `ProfileBridge.current`; canonical goals are read from the shared `AppState` Goal collection.
- Occupations and canonical identifiers: `assets/explorer/occupations/occupation_seed_fr_en.json`.
- Detailed skills and professional context: existing `assets/explorer/occupation_profiles/*.json` files loaded by `ExplorerData`.
- Domain names: existing `assets/explorer/explorer_taxonomy.json`.
- Training route: existing `assets/explorer/training_pathways_v3.2.json`.
- General outlook: existing `assets/explorer/employment_outlook_v4.json`.
- The shared key between modules is the exact Explorer `occupation_id` / occupation `id`.

No Orientation-only occupation catalog, profile copy, or mock recommendations are introduced.

## Matching signals
- Skills entered in Profile: 45%.
- Interest domains entered in Profile: 30%.
- Goals entered in Profile: 10%.
- Occupations followed from Explorer in Profile: 15%.

Weights are renormalized over only the dimensions that have user input. Skill comparison and interest/goal text matching are deliberately transparent, lightweight heuristics. Scores are indicative and must not be represented as probabilities or objective suitability measures.

## Result detail
Each recommendation shows its canonical occupation title and ID, matching reasons, skills associated with the occupation that the learner has not listed, Explorer training route when available, and general employment outlook with a warning that it is not localized to the learner's country.

The current education level is surfaced as context for comparing the route; the module does not claim to validate country-specific admission requirements.

## States
- Loading: while the shared Explorer assets load.
- Error: explains that Explorer data could not be loaded.
- Empty: prompts the learner to complete interests, skills, goals, or followed occupations in Profile.
- Results: compares the canonical Explorer catalog and displays the leading 12 matches.

## Integration boundary
Profile changes are reflected in the shared local snapshot; no second profile store is created. Goals are a single canonical collection shared by Profile, Match, Progress, Academy and IA. Supabase and GitHub remain intentionally untouched. Later modules should consume the same canonical `occupation_id`; Formation can use the selected occupation ID and Explorer pathway record as its handoff contract.
