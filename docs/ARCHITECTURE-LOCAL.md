# M-TIER 4.0 — architecture locale

## Entrée et modules

`lib/main.dart` reste le point d'entrée Flutter et déclare les six parties de la bibliothèque applicative. Les fichiers sous `lib/modules/` sont séparés par domaine tout en restant dans la même bibliothèque Dart afin de préserver les widgets privés partagés pendant cette première décomposition.

- `modules/explorer/explorer.dart` : chargement des 115 occupations, profils, parcours, perspectives et fiches détaillées.
- `modules/profile/profile.dart` : saisie et édition du profil, objectifs personnels, métiers suivis et confidentialité.
- `modules/match/match.dart` : moteur de classement et explication des pistes.
- `modules/progress/progress.dart` : objectifs, statuts, preuves privées et journal.
- `modules/academy/academy.dart` : parcours et identifiants de leçons consultées.
- `modules/assistant/assistant.dart` : assistant local déterministe, sans API distante.

## Source de vérité locale

`lib/app/app_state.dart` est l'unique conteneur local réactif. Il porte le profil, les objectifs, les preuves, le journal, les leçons consultées avec leur horodatage, la langue, le thème et l'état d'onboarding. Il persiste un document JSON versionné avec `shared_preferences`.

`lib/models/goal.dart` définit le modèle partagé :

- `id`
- `title`
- `type` : `career`, `learning`, `skill`, `project`
- `status` : `in_progress`, `paused`, `completed`, `archived`
- `occupation_id` facultatif
- `target_date` facultatif
- `created_at`

Profil et Progress écrivent dans la même collection. Match ne prend en compte que les objectifs actifs (`in_progress` et `paused`). Academy et IA lisent cette même collection et les identifiants de leçons consultées.

## Persistance et sécurité

- Le stockage est local à l'appareil ; aucune synchronisation Supabase n'est active.
- Les écritures sont regroupées par un court délai et sérialisées pour éviter qu'une sauvegarde ancienne écrase une suppression récente.
- Le schéma local est versionné ; les objectifs texte hérités du profil sont convertis en `Goal`.
- Une version de données plus récente est protégée contre l'écrasement par cette version de l'application.
- La suppression totale des données locales demande une confirmation.
- Les champs pays, tranche d’âge, niveau d’études et format d’apprentissage ne sont pas préremplis.

## Vérification

Les tests Dart de `Goal` et `AppState` sont exécutés par `flutter test` dans GitHub Actions. Les contrôles Python existants vérifient la présence des contrats et les données Explorer ; ils ne remplacent pas l'analyse Dart ni les tests Flutter.

## Recherche et correspondance

`lib/core/text_normalizer.dart` fournit la normalisation FR/EN/ES commune au moteur Match et aux intentions de l’assistante : accents, stopwords et correspondance par frontières de mots/expressions. `lib/core/assistant_intent.dart` classe les demandes explicites et donne priorité aux formulations défensives pour éviter les faux positifs. Les poids du moteur Match restent 45/30/10/15.
