# M-TIER 4.0 — QA Progress v0.2

## État de la refonte locale
- Les objectifs de Profil et Progress utilisent désormais le même contrat `Goal` : `id`, `title`, `type`, `status`, `occupation_id`, `target_date`, `created_at`.
- Types pris en charge : `career`, `learning`, `skill`, `project`. Statuts : `in_progress`, `paused`, `completed`, `archived`.
- Les anciens objectifs texte de Profil sont migrés vers des objectifs `learning` au chargement du stockage local.
- Match lit les objectifs depuis la collection canonique ; Academy et IA consomment les mêmes objectifs et identifiants de leçons.
- `AppState` centralise profil, objectifs, preuves privées, journal, leçons consultées et leurs horodatages, langue, thème et état d’onboarding.
- Stockage JSON versionné via `shared_preferences`, sauvegarde différée, repli sur un état vide en cas de lecture invalide et protection contre l’écrasement d’un schéma provenant d’une version plus récente.
- Une action confirmée permet d’effacer toutes les données locales de l’application.
- L’âge, le pays, le niveau d’études et le format d’apprentissage ne sont plus préremplis.

## Contrats d'interconnexion
- Explorer reste la source canonique des métiers et `occupation_id`.
- Profil reste la source des compétences, intérêts, préférences et métiers suivis.
- `Goal` est la source unique des objectifs, consommée par Match, Progress, Academy et IA.
- Academy reste la source des identifiants de leçons consultées ; Progress les lit directement.
- Les preuves et le journal restent privés par défaut. Les objectifs, preuves et notes peuvent être supprimés après confirmation.

## Vérifications effectuées
- Contrôle des 115 métiers, 115 profils et 10 assets de profils effectivement déclarés : PASS.
- Validation des fichiers JSON/ARB, égalité des clés FR/EN/ES et cohérence des paramètres : PASS.
- Validation syntaxique YAML du workflow GitHub Actions : PASS.
- Compilation Python des scripts et test idempotent de `patch_android.py` sur fichiers Android factices : PASS.
- Les anciens contrôles Python par recherche de chaînes ont été retirés ; ils ne vérifiaient pas le comportement Flutter.
- Tests Dart ajoutés pour la sérialisation/migration de `Goal`, le stockage local, l’effacement des données, les modifications Profil et le rafraîchissement widget Profil → Progress : en attente de GitHub Actions.
- `flutter analyze`, `flutter test` et build APK non exécutés dans l'environnement de préparation faute de SDK Flutter.

## Limites non validées
- Flutter/Dart ne sont pas installés dans l'environnement de préparation. `flutter pub get`, `flutter analyze`, `flutter test`, build APK et essais sur appareil restent à confirmer par CI.
- Aucune synchronisation Supabase, authentification ni écriture réseau n'est activée.
- Les contenus Academy restent des prototypes pédagogiques en brouillon.

## CRUD completion update — 23 November 2026

- Les objectifs disposent d'une modification du titre, d'un changement de statut et d'une suppression confirmée.
- Les preuves privées et les notes du journal disposent d'une modification du texte et d'une suppression confirmée.
- Les modifications passent par `AppState.commit()` et sont conservées par le stockage local versionné.
- Les libellés Modifier/Enregistrer et le libellé du champ de modification sont fournis en FR/EN/ES.
- La validation d'interaction réelle reste à effectuer par `flutter test` dans GitHub Actions ; elle n'est pas déclarée exécutée ici.
- Progress résout maintenant les IDs des leçons consultées vers leurs titres localisés Academy quand les données Academy sont disponibles ; l'ID canonique reste conservé pour le suivi partagé.
