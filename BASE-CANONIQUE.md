# M-TIER 4.0 — registre de la base canonique

Date : 23 novembre 2026

## Décision
La base canonique de travail est l’archive `MTIER-4.0-CANONICAL-v0.9.zip`, construite le 23 novembre 2026 à partir du projet Flutter intégré et des corrections successives des six modules, de l’interconnexion locale, de la navigation, du thème, de la sécurité IA et de la localisation. Les archives sources antérieures sont conservées et ne sont pas écrasées. Cette archive est la seule base de travail destinée à la préparation pré-GitHub.

## Comparaison effectuée
- Étape 0 : 80 fichiers.
- Étape 1 Explorer : 78 fichiers.
- Fichiers propres à l’étape 0 : `.github/workflows/flutter-ci.yml`, `scripts/patch_android.py`.
- Fichiers propres à l’étape 1 : aucun.
- Fichiers applicatifs modifiés entre les deux archives : aucun.
- Différences documentaires/configuration : `README.md`, `.gitignore`.

## Contrôles réalisés dans cet environnement
- `tests_explorer_assets.py` : PASS, 115 métiers, 115 profils, 10 fichiers effectivement déclarés dans `profileAssets`, 115 parcours, perspectives, couvertures salariales et revues de classification.
- Les anciens scripts Python qui ne vérifiaient que la présence de chaînes dans le code ont été retirés ; ils ne constituaient pas des tests Flutter exécutables.
- `tests_explorer_assets.py` reste le contrôle structurel Python des assets.
- `python3 -m py_compile scripts/patch_android.py` : PASS.

## Limites non validées
Flutter et Dart ne sont pas installés dans l’environnement de préparation. Aucun `flutter pub get`, `flutter analyze`, `flutter test`, build APK ou test sur appareil n’est déclaré réussi. Le workflow CI est préparé mais n’a pas été exécuté sur un dépôt GitHub vérifié. Aucun commit ni push n’a été effectué.

## Règles de conservation
- Cette copie est la source de travail canonique pour les prochaines étapes.
- Les archives sources restent intactes.
- Ne pas connecter ni modifier Supabase avant l’étape backend autorisée.
- Ne pas inventer de données salariales.
- Conserver les identifiants canoniques des 115 métiers.

## Mise à jour de travail — interconnexion locale / modèle Goal
- Ajout de `lib/app/app_state.dart` comme source centrale réactive et stockage JSON local versionné.
- Ajout de `lib/models/goal.dart` avec les types `career`, `learning`, `skill`, `project` et les statuts canoniques.
- Profil et Progress utilisent la même collection d'objectifs ; Match lit cette collection. Academy et IA lisent les mêmes objectifs et leçons consultées.
- Les profils et objectifs sont restaurés au démarrage ; les objectifs texte hérités sont convertis en `Goal`.
- Les préférences langue/thème et l’état d’onboarding sont restaurés et persistés ; les contrôles globaux de langue et de thème sont présents.
- Ajout d’une suppression confirmée de toutes les données locales.
- Ajout des tests Dart `test/models/goal_test.dart`, `test/app/app_state_test.dart`, `test/modules/shared_state_test.dart` et `test/core/text_normalizer_test.dart`. Ils ne sont pas exécutés dans cet environnement faute de Flutter/Dart.
- Ajout de `shared_preferences: ^2.3.2` ; `pubspec.lock` devra être généré par le premier `flutter pub get` CI et conservé.

## Décomposition du code Flutter
- Le monolithe `lib/main.dart` a été décomposé en six fichiers de modules sous `lib/modules/`, en conservant une bibliothèque Dart commune pour éviter de casser les références privées inter-modules pendant la refonte.
- Le point d'entrée, la navigation et le composant de carte partagé restent dans `lib/main.dart`.
- Le contrat de cette organisation est documenté dans `docs/ARCHITECTURE-LOCAL.md`.

- Rapport détaillé de la phase : `QA-INTERCONNEXION-LOCALE-v0.1.md`.

## Fiabilité Match / IA
- Ajout de `lib/core/text_normalizer.dart` : normalisation FR/EN/ES, accents, stopwords et frontières de mots.
- Le moteur Match conserve les pondérations 45/30/10/15, ne redistribue pas les poids absents et ne confond plus une compétence comme Java avec JavaScript par simple sous-chaîne.
- Les intentions sensibles IA utilisent des expressions complètes ; une question de défense n'est pas classée comme attaque simplement parce qu'elle mentionne des attaques.
- Test unitaire `test/core/text_normalizer_test.dart` ajouté ; exécution en attente de GitHub Actions.

- Les horodatages des leçons consultées sont conservés dans le stockage local et affichés dans Progress.
- Profil et Progress partagent les objectifs ; Progress permet de modifier, changer le statut et supprimer les objectifs, et de modifier/supprimer les preuves et notes après confirmation.

- Ajout de `lib/core/assistant_intent.dart` et `test/core/assistant_intent_test.dart` : les intentions explicitement offensives sont distinguées des demandes de protection, avec priorité au contexte défensif.

- La couverture FR/EN/ES est maintenant présente pour les 115 titres/définitions, 345 tâches, 216 familles, 115 profils détaillés, 115 parcours de formation, 115 perspectives et 3 parcours Academy. Tous les ajouts EN/ES restent des brouillons machine à relire.

- Un sélecteur global FR/EN/ES est raccordé à `AppState.language`; les titres métiers, profils détaillés, parcours, perspectives, cours Academy et réponses IA suivent la langue active. L'avertissement localisé précise que les traductions EN/ES sont complètes en brouillon mais attendent une revue humaine.
- Les trois parcours Academy ont des traductions EN/ES brouillon pour les objectifs, modules et leçons, sans changement des IDs.

- Première couche Flutter `gen-l10n` ajoutée : `l10n.yaml`, ARB FR/EN/ES et `flutter_localizations`. Les ARB couvrent 266 clés de messages ; les références utilisées par Dart et les paramètres ont été vérifiés. La couverture métier EN/ES est complète en brouillon ; la revue humaine reste à faire.

- Test de localisation `test/l10n/app_localizations_test.dart` ajouté pour les ressources ARB FR/EN/ES.

- Les ARB FR/EN/ES couvrent 266 clés de messages (métadonnées exclues) et sont reliés à `MaterialApp` via `AppLocalizations`; la couverture métier est complète en brouillon, la revue linguistique humaine reste en attente.

- Thème M-TIER Material 3 créé dans `lib/theme/mtier_theme.dart` : sombre par défaut, clair et système ; préférence persistée et menu global ajoutés. Le détail des tokens est dans `docs/DESIGN-SYSTEM.md`.

- Navigation réorganisée en cinq destinations (Accueil, Explorer, Parcours avec Match/Progress, Academy, Profil) et assistante accessible depuis un FAB. Le tableau de bord lit les données partagées sans statistiques fictives.

## Mise à jour de localisation — 23 novembre 2026

- Traductions EN/ES ajoutées pour les 345 tâches, les 115 profils détaillés, les 115 parcours de formation et les 115 perspectives.
- Traductions EN/ES ajoutées pour les 216 familles de métiers de la taxonomie.
- `scripts/check_translation_coverage.py` ajouté : il vérifie couverture, IDs, longueurs de tableaux et ARB sans simuler une validation humaine.
- `scripts/check_translations.py` reste volontairement strict et bloqué tant que la revue humaine n'est pas effectuée.
- Le moteur Match utilise maintenant les compétences, familles, parcours et perspectives dans la langue active ; le test `Match uses the active language for occupation skills` a été ajouté.
- L'avertissement Explorer a été corrigé : il ne prétend plus que les contenus détaillés sont absents, mais indique qu'ils sont traduits en brouillon et attendent une revue humaine.
