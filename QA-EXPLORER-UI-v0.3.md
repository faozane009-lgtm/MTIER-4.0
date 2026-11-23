# M-TIER 4.0 — Contrôle Explorer v0.9 / Étape 1

Date du contrôle : 2026-11-23  
Base contrôlée : `MTIER-4.0-Integrated-Flutter-v0.9-IA`

## Corrections de l'étape 1

- Ajout de `cross_sector_profiles_v0.3.json` à la liste `profileAssets` effectivement lue par Flutter.
- La liste runtime référence exactement 10 fichiers de profils : 8 lots professionnels, le lot cybersécurité et le lot cross-sector.
- L'adaptateur transforme les profils cybersécurité vers le schéma interne canonique `occupation_id`, compétences `{id, type}` et preuves `{source_id, use}`.
- Les libellés de compétences affichent les slugs sous forme lisible sans modifier leurs identifiants sources.
- Le filtre de domaine affiche `name_fr` depuis la taxonomie Explorer.
- Le manifeste Flutter ne déclare plus les répertoires entiers : seuls les 17 fichiers JSON réellement lus par le code sont déclarés.
- `salary_estimates_v4.json` et `education_localization_v4.json` ne sont pas inclus dans le bundle Flutter. Le texte salarial ne promet plus de sélecteur de pays et n'affiche aucun montant non vérifié.
- Les chargements Explorer et Academy tolèrent les erreurs fichier par fichier, les signalent en mode debug et proposent une nouvelle tentative qui invalide le cache Future.

## Contrôle des données

Le script `tests_explorer_assets.py` lit la liste `profileAssets` de `lib/main.dart` et contrôle les fichiers réellement chargés par l'application :

- 115 métiers dans le seed, avec 115 identifiants uniques.
- 10 fichiers de profils référencés par Flutter.
- 115 profils effectivement appariés aux 115 métiers via ces 10 fichiers.
- Les 10 profils cybersécurité sont identifiés comme utilisant les paires `skills` / `evidence` et la clé `id` source à normaliser.
- 115 parcours, 115 perspectives, 115 fiches de couverture salariale et 115 revues de classification.

## Limites de validation

- Flutter et Dart ne sont pas installés dans l'environnement de préparation. Aucun `flutter analyze`, test Dart/widget ni build Android/iOS n'a été exécuté.
- Le contrôle effectué ici est une vérification Python de l'intégrité JSON et de la cohérence entre les fichiers déclarés et les données sources. Il ne prouve pas la compilation Dart.
- Les migrations Supabase et le dépôt GitHub n'ont pas été modifiés. Aucune écriture réseau n'a été ajoutée.
- Le sélecteur de pays et l'affichage de montants salariaux ne font pas partie de cette étape.
