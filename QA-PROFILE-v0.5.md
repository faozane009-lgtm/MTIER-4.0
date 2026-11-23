# QA PROFIL v0.5 — contrôle de l'interface et liaison Explorer

## Comportement présent dans la base de travail

- Le Profil expose les sections d'informations générales, formation, intérêts, compétences, préférences d'apprentissage, objectifs, métiers suivis et confidentialité.
- Le code pays est facultatif et contrôlé à deux lettres ; aucune valeur de pays ou tranche d'âge n'est imposée.
- Le sélecteur de métiers utilise le catalogue Explorer et conserve les identifiants canoniques `occupation_id`.
- Les objectifs utilisent le modèle `Goal` partagé avec Match, Progress, Academy et IA.
- Le snapshot Profil est synchronisé explicitement avec `AppState` lors des modifications ; aucun effet secondaire n'est déclenché depuis `build()`.
- Les données Profil et objectifs sont persistées localement dans le stockage JSON versionné `shared_preferences`.
- L'aperçu JSON présente le snapshot local ; aucune sauvegarde serveur n'est prétendue.
- Les consentements restent séparés et la visibilité par défaut est privée.

## Contrôles exécutés dans l'environnement de préparation

- `python3 tests_explorer_assets.py` : PASS — 115 occupations et 115 profils chargés par les dix assets déclarés dans Flutter.
- `python3 -m json.tool assets/profile/profile.schema.json` : PASS.
- Vérification des déclarations JSON et ARB : PASS.

Les anciens scripts `tests_profile_package.py` et autres assertions textuelles ont été supprimés : ils ne constituaient pas des tests Flutter et pouvaient donner une fausse impression de validation.

## Limites non validées

- `flutter analyze`, `flutter test`, build APK et test sur appareil non exécutés : Flutter/Dart ne sont pas installés dans l'environnement de préparation.
- Aucun compte, authentification ou synchronisation Supabase n'est intégré à cette étape.
- Les traductions EN/ES des contenus détaillés Explorer ne sont pas terminées ; voir `docs/LOCALIZATION-STATUS.md`.

## Verdict

Le contrat local Profil–Explorer et le modèle partagé Goal sont préparés. Le module n'est pas déclaré certifié avant les tests Flutter réels et la revue complète des contenus localisés.
