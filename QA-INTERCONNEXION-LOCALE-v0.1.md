# M-TIER 4.0 — QA interconnexion locale et préparation pré-GitHub

Date : 23 novembre 2026

## Résultat réel

La base de travail contient les six modules, un état central local, un modèle Goal partagé, la persistance versionnée, la navigation en cinq destinations et les premières ressources de localisation FR/EN/ES. Plusieurs défauts de l'audit ont été corrigés dans le code. Le projet n'est **pas certifié Flutter** et ne doit pas encore être envoyé sur GitHub comme livraison prête.

## Checklist fonctionnelle préparée

- [x] `AppState` centralise le profil, les objectifs, les preuves, le journal, les leçons consultées, la langue, le thème et l'onboarding.
- [x] Le modèle `Goal` partage les types `career`, `learning`, `skill`, `project` et les statuts `in_progress`, `paused`, `completed`, `archived`.
- [x] Profil et Progress utilisent la même collection d'objectifs ; Match et IA lisent cette source commune.
- [x] Les IDs de leçons Academy et leurs horodatages sont partagés avec Progress.
- [x] Les données locales sont versionnées, restaurées et migrées ; les écritures sont sérialisées.
- [x] Une version de schéma local plus récente est protégée contre l'écrasement par une version plus ancienne.
- [x] Une restauration JSON corrompue vide les collections en mémoire plutôt que de conserver un état partiel ; les erreurs de stockage sont affichées via des messages localisés.
- [x] Les objectifs peuvent être créés, modifiés, changer de statut et être supprimés après confirmation.
- [x] Les preuves privées et les notes du journal peuvent être créées, modifiées et supprimées après confirmation.
- [x] L'effacement local total est protégé par confirmation.
- [x] Aucun âge, pays, niveau d’études ou format d’apprentissage n’est imposé par défaut.
- [x] Le snapshot Profil est synchronisé explicitement lors des changements, sans mutation depuis `build()`.
- [x] Match conserve les pondérations 45/30/10/15 et ne redistribue plus les dimensions absentes.
- [x] Une seule dimension Match ne peut plus produire artificiellement 100 % ; l'interface rappelle que le score n'est pas une probabilité.
- [x] Les intentions offensives explicites IA priment sur les mots génériques de défense dans les demandes mixtes.
- [x] Progress affiche le titre Academy localisé des leçons consultées lorsque les ressources sont disponibles.
- [x] Les anciens scripts Python qui ne faisaient que rechercher des chaînes dans le code ont été supprimés.

## Tests Flutter écrits — exécution en attente

- `test/models/goal_test.dart`
- `test/app/app_state_test.dart`
- `test/modules/shared_state_test.dart`
- `test/core/text_normalizer_test.dart`
- `test/core/assistant_intent_test.dart`
- `test/academy/academy_localization_test.dart`
- `test/l10n/app_localizations_test.dart`
- `test/theme/mtier_theme_test.dart`
- `test/home/navigation_responsive_test.dart`
- `test/explorer/domain_localization_test.dart`
- `test/match/match_localization_test.dart`
- `test/match/match_score_test.dart`

## Contrôles exécutés dans l'environnement de préparation

- `python3 tests_explorer_assets.py` : PASS — 115 métiers, 115 profils chargés par les dix assets référencés dans Flutter, 115 parcours, 115 perspectives, 115 enregistrements de couverture salariale et 115 revues de classification.
- Tous les fichiers JSON et ARB : parsing PASS.
- 265 clés de messages ARB FR/EN/ES : ensembles identiques, paramètres vérifiés ; toutes les références de localisation détectées dans Dart existent dans les ARB.
- `python3 -m py_compile scripts/*.py tests_explorer_assets.py` : PASS.
- `scripts/audit_localization.py` : exécuté ; compteurs et lacunes mesurés.
- `.github/workflows/flutter-ci.yml` : YAML parse PASS.
- `scripts/patch_android.py` : compilation Python PASS ; test sur manifeste et Gradle Kotlin DSL factices PASS, y compris idempotence.

Ces contrôles Python/JSON/YAML ne prouvent pas que le code Dart compile.

## Corrections principales → fichiers

| Défaut / risque | Correction | Fichiers principaux |
|---|---|---|
| Deux sources d'objectifs | Modèle Goal canonique et collection commune | `lib/models/goal.dart`, `lib/app/app_state.dart`, `lib/modules/profile/profile.dart`, `lib/modules/progress/progress.dart` |
| État perdu au redémarrage | Stockage JSON versionné, migration, écritures sérialisées | `lib/app/app_state.dart`, `pubspec.yaml` |
| Profil modifié depuis `build()` | Synchronisation explicite à chaque modification | `lib/modules/profile/profile.dart` |
| Score Match trompeur sur profil partiel | Pondérations fixes, poids absents non redistribués et avertissement | `lib/modules/match/match.dart`, `lib/l10n/app_*.arb`, `test/match/match_score_test.dart` |
| Faux négatif IA sur requête mixte | Intention offensive explicite évaluée avant vocabulaire défensif | `lib/core/assistant_intent.dart`, `test/core/assistant_intent_test.dart` |
| Progress sans édition complète | Édition, statut et suppression des objectifs ; édition/suppression des preuves et notes | `lib/modules/progress/progress.dart`, `lib/l10n/app_*.arb` |
| Leçons affichées par ID opaque | Résolution vers le titre Academy localisé | `lib/modules/progress/progress.dart`, `lib/modules/academy/academy.dart` |
| Chaînes d'erreur ou de confirmation non localisées | Messages ARB FR/EN/ES | `lib/l10n/app_*.arb`, modules concernés |

## Localisation — état bloquant

- 115 titres et 115 définitions courtes Explorer présents en FR/EN/ES ; les versions EN/ES restent des brouillons non vérifiés.
- 28 noms de domaines présents en FR/EN/ES ; EN/ES non relus.
- 345 tâches Explorer : FR présent, EN/ES absents.
- 115 profils détaillés : purpose, missions, contexte, compétences, connaissances, notes de correspondance et exigences pays ; les équivalents EN/ES restent absents.
- 115 parcours de formation Explorer et 115 perspectives professionnelles : français présent, EN/ES absents.
- 3 parcours Academy avec variantes EN/ES en brouillon, sans revue humaine.
- 265 messages ARB par langue ; EN/ES marqués `machine_draft_needs_human_review` dans `assets/localization/review_status.json`.
- `scripts/check_translations.py` reste bloquant et a retourné **BLOCKED — 4 874 écarts** au dernier contrôle. Ne pas définir `TRANSLATIONS_COMPLETE=true`.

Le détail des compteurs et des règles de statut est dans `docs/LOCALIZATION-STATUS.md` et `docs/TRANSLATION-LOG.md`.

## Non exécuté / non revendiqué

- Flutter et Dart ne sont pas installés dans l'environnement de préparation ; l'accès réseau ne permet pas de télécharger le SDK.
- `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test` et `flutter build apk --debug` n'ont pas été exécutés.
- Le workflow GitHub est préparé, mais aucun run GitHub Actions n'a eu lieu.
- Aucun commit, push ou pull request n'a été effectué.
- Aucune migration Supabase n'a été modifiée ou exécutée ; aucune connexion backend n'a été utilisée.
- Aucun APK/AAB signé, test sur téléphone, déploiement de site ou mécanisme de mise à jour n'est livré.

## Décision

**Ne pas envoyer la base sur GitHub comme version prête.** Les traductions détaillées et leurs revues sont encore bloquantes. Après leur achèvement, le dépôt sera initialisé sur une branche de travail, puis la CI devra confirmer `flutter analyze`, tous les tests et le build Android avant toute phase Supabase.
