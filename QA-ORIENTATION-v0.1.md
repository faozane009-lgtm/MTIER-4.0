# QA — MATCH / ORIENTATION v0.2

## Comportement présent dans la base de travail

- Match est intégré dans l'onglet Parcours et utilise le snapshot Profil courant ainsi que les 115 métiers canoniques Explorer.
- Les compétences, intérêts, objectifs actifs et métiers suivis sont les seules dimensions de score.
- Les pondérations sont fixes : compétences 45 %, intérêts 30 %, objectifs 10 %, métiers suivis 15 %.
- Les dimensions absentes ne contribuent pas au score et leurs poids ne sont pas redistribués. Un seul intérêt correspondant ne peut donc pas produire un score de 100 %.
- Le score est explicitement présenté comme un indicateur heuristique, jamais comme une probabilité de réussite ou une décision d'orientation.
- Les écarts de compétences, voies de formation et perspectives sont reliés par `occupation_id` au référentiel Explorer.
- Les comparaisons textuelles utilisent la normalisation FR/EN/ES et des frontières de mots ; `Java` ne correspond pas à `JavaScript`.
- Aucun catalogue métier parallèle et aucune écriture Supabase ne sont ajoutés.

## Contrôles disponibles

- `python3 tests_explorer_assets.py` : PASS — 115 occupations, 115 profils et dix fichiers réellement chargés.
- Tests Flutter écrits : `test/match/match_localization_test.dart`, `test/match/match_score_test.dart`, `test/core/text_normalizer_test.dart`.

Les tests Flutter et `flutter analyze` restent en attente d'une exécution réelle dans GitHub Actions ; ils ne sont pas déclarés réussis ici.
