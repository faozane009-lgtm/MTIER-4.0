# QA — MATCH et ACADEMY v0.3

## MATCH

- Match lit le snapshot courant de Profil et le catalogue Explorer partagé.
- Les 115 métiers sont identifiés par leurs `occupation_id` canoniques.
- Les facteurs de compatibilité et les écarts de compétences sont explicités.
- Les pondérations 45/30/10/15 sont fixes ; les dimensions absentes ne sont pas redistribuées.
- Le score est un indicateur heuristique et non une probabilité.
- Les titres et domaines suivent la langue active ; les contenus de formation et perspectives restent à localiser.

## ACADEMY

- Academy réutilise Match, Profil, Explorer et les objectifs canoniques Goal.
- Trois parcours de démonstration sont chargés depuis `assets/academy/learning-paths-fr.json`.
- Les parcours, modules, leçons, objectifs d'apprentissage, activités et vérifications disposent de variantes EN/ES en brouillon.
- Les IDs de parcours, modules et leçons restent inchangés.
- Les contenus sont au statut `draft` et ne sont présentés ni comme diplômes ni comme certifications.
- Les leçons consultées sont persistées localement et reprises dans Progress ; Progress affiche leur titre Academy localisé lorsque disponible.
- Aucune écriture Supabase ou opération GitHub n'est effectuée par ces modules.

## Contrôles disponibles

- `python3 tests_explorer_assets.py` : PASS.
- Tests Flutter écrits : `test/academy/academy_localization_test.dart`, `test/match/match_localization_test.dart`, `test/match/match_score_test.dart`.
- Les contrôles JSON/ARB et de références de localisation passent dans l'environnement de préparation.

`flutter analyze`, `flutter test`, build Android et essais sur appareil restent en attente du SDK Flutter dans GitHub Actions. Les traductions EN/ES restent à relire humainement.
