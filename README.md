# M-TIER 4.0 — application Flutter

M-TIER est une application mobile locale d'exploration des métiers, d'orientation, de suivi d'objectifs et d'apprentissage. Le projet contient six modules : Explorer, Profil, Match, Progress, Academy et IA.

## Utilisation depuis un téléphone

Le dépôt est contrôlé et construit par GitHub Actions. Aucun ordinateur ni SDK Flutter local n'est nécessaire pour consulter le résultat de la CI.

1. Ouvrir le dépôt dans l'application GitHub.
2. Ouvrir l'onglet **Actions**.
3. Sélectionner le workflow **M-TIER Flutter CI** puis le dernier lancement.
4. Si une étape échoue, ouvrir cette étape, copier le message d'erreur complet ainsi que les premières lignes de contexte, puis les transmettre pour correction.
5. Si le workflow réussit jusqu'à **Build debug APK**, revenir à la page du lancement et ouvrir **Artifacts**.
6. Télécharger `mtier-debug-apk-...`, extraire l'APK si le téléphone le demande, puis installer l'application. Android peut demander de confirmer l'installation de cette application téléchargée.

L'APK est un build de débogage destiné aux essais, pas une version de publication.

## Reproduire le projet sur un environnement Flutter

La CI génère le dossier Android s'il est absent. Pour une préparation manuelle, depuis la racine du projet, exécuter dans cet ordre :

```bash
flutter create . --platforms=android
python3 scripts/patch_android.py
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Ne pas remplacer `lib/main.dart` par le compteur d'exemple généré par Flutter. Le workflow supprime le test de compteur par défaut s'il est présent.

## Version Flutter de référence

- Contrainte minimale du projet : Flutter stable compatible avec Dart `>=3.4.0 <4.0.0`.
- Premier lancement CI : le canal `stable` est utilisé pour découvrir la version exacte installée. Le journal **Record Flutter and Dart versions** et le résumé du workflow affichent cette version.
- **Épinglage exact en attente du premier lancement CI** : après réception de ce journal, remplacer `channel: stable` par la version exacte dans `.github/workflows/flutter-ci.yml` et inscrire cette version ici. Ne pas deviner la version.

## Android

Le script `scripts/patch_android.py` applique et vérifie dans le manifeste principal la permission INTERNET et le nom d'application `M-TIER`. Il fixe l'identifiant Android à `com.mtier.app` dans `defaultConfig`. Cette permission est présente pour permettre une future version connectée ; elle n'active aucun envoi réseau à elle seule.

## Données, réseau et secrets

- Les données métiers proviennent des assets JSON locaux.
- La génération de localisation Flutter est configurée via `l10n.yaml` et 266 clés de messages ARB FR/EN/ES ; la couverture des contenus métier est complète en brouillon ; les traductions EN/ES doivent encore être relues par des personnes compétentes.
- Le thème sombre est activé par défaut ; les choix sombre/clair/système sont persistés localement.
- Navigation principale : Accueil, Explorer, Parcours (Match + Progress), Academy et Profil ; l’assistante est accessible par un bouton flottant.
- La couverture FR/EN/ES des données suivies est complète : 115 titres et définitions, 345 tâches, 216 familles, 115 profils détaillés, 115 parcours de formation, 115 perspectives et 3 parcours Academy. Les traductions EN/ES restent des brouillons machine non validés par un humain. Voir `docs/LOCALIZATION-STATUS.md`.
- Profil, objectifs canoniques, preuves privées, journal et leçons consultées sont conservés dans un stockage JSON local versionné (`shared_preferences`).
- Les objectifs utilisent un contrat unique `Goal` partagé entre Profil, Match, Progress, Academy et IA.
- Le stockage local peut être effacé depuis Profil après confirmation.
- Cette étape ne configure aucune connexion Supabase et n'effectue aucune écriture réseau.
- Ne jamais committer de clé, mot de passe, fichier `key.properties`, keystore ou fichier `.env` réel.
- Une future configuration de build pourra utiliser des secrets GitHub et des paramètres `--dart-define`. Aucune valeur secrète ne doit être écrite dans le code ou dans ce README.
- Les fichiers `supabase/migrations/` sont conservés comme documents de travail ; cette CI ne les exécute pas.

## Organisation du code

- `lib/app/app_state.dart` : état central et stockage local versionné.
- `lib/models/goal.dart` : modèle Goal partagé par les modules.
- `lib/core/text_normalizer.dart` : normalisation FR/EN/ES pour Match et IA.
- `lib/core/assistant_intent.dart` : détection d’intentions cybersécurité avec priorité au contexte défensif.
- `lib/theme/mtier_theme.dart` : thèmes Material 3 sombre/clair, sombre par défaut.
- `lib/modules/` : fichiers séparés pour Explorer, Profil, Match, Progress, Academy et IA.
- `docs/ARCHITECTURE-LOCAL.md` : contrat de données et règles de persistance locale.
- `QA-INTERCONNEXION-LOCALE-v0.1.md` : checklist, contrôles et défauts corrigés de cette étape.

## Vérifications automatisées

À chaque push et pull request, la CI :

1. installe Flutter stable et affiche sa version ;
2. génère Android si le dossier `android/` est absent ;
3. applique puis vérifie les métadonnées Android ;
4. exécute `scripts/fetch_fonts.sh` seulement s'il existe ;
5. exécute `flutter pub get` et `flutter gen-l10n` seulement si `l10n.yaml` existe ;
6. exécute `tests_explorer_assets.py` et les scripts Python de vérification présents dans `scripts/` ;
7. exécute `flutter analyze`, `flutter test` et `flutter build apk --debug` ;
8. publie l'APK de débogage comme artefact si le fichier a été produit.

Le contrôle `scripts/check_translation_coverage.py` vérifie la couverture et la cohérence structurelle sans prétendre valider la qualité humaine. Le contrôle strict `scripts/check_translations.py` reste bloquant tant que la revue humaine EN/ES n'est pas terminée. Ne pas définir `TRANSLATIONS_COMPLETE=true` avant cette revue.

## État honnête du projet

- Le code Flutter n'a pas été compilé dans l'environnement de préparation. Seule la CI GitHub peut confirmer `flutter analyze`, les tests Dart et le build APK.
- Les six modules sont présents dans le projet ; l’interconnexion locale et le modèle Goal sont en cours de consolidation, puis seront vérifiés par les tests Flutter en CI.
- Les données salariales ne doivent jamais être complétées par estimation inventée ; seules les valeurs vérifiées peuvent être affichées.
- Les traductions automatiques éventuelles doivent rester identifiées comme telles jusqu'à une relecture humaine.
- Supabase et GitHub ne sont pas utilisés comme backend applicatif dans cette étape.

## Dépendances

`pubspec.lock` doit être généré par `flutter pub get` et committé avec le projet pour stabiliser la résolution des dépendances de l'application.
