# M-TIER 4.0 — contrôle pré-GitHub

Date : 23 novembre 2026  
Base : `MTIER-4.0-CANONICAL-v0.9`  
Statut : corrections locales et couverture de traduction terminées en brouillon ; validation Flutter réelle et revue humaine non réalisées.

## Corrections appliquées

1. **Explorer — chargement exact** : la liste des 10 fichiers `profileAssets` inclut les profils transversaux. Le contrôle Python compare désormais les IDs réellement chargés par le code Flutter aux 115 IDs canoniques.
2. **Taxonomie** : 28 domaines et 216 familles disposent de libellés FR/EN/ES ; les IDs de familles sont conservés. Le filtre de domaine et le moteur Match utilisent les libellés localisés.
3. **Profils détaillés** : 115 profils ont les champs EN/ES pour présentation, missions, contexte, compétences, connaissances et notes de correspondance. Les formats de compétences en tuples cybersécurité sont conservés et affichés proprement.
4. **Match** : compétences, familles, parcours et perspectives sont lus dans la langue active. Les poids restent fixes à 45/30/10/15 ; les dimensions absentes ne sont pas redistribuées. Un test couvre l'utilisation des compétences anglaises.
5. **Academy** : la carte de métier utilise désormais le parcours et les notes dans la langue active.
6. **Explorer** : les statuts de correspondance et de rédaction (`candidate_lookup_required`, `candidate_search_reference`, `draft_needs_expert_review`) sont affichés avec des libellés localisés, au lieu de codes techniques anglais.
7. **Profil / état partagé** : `AppState.setProfile()` notifie les consommateurs et planifie la persistance via le contrat central ; le formulaire Profil ne double plus la notification. Un test dédié a été ajouté.
8. **Messages de localisation** : l'avertissement Explorer indique correctement que les traductions EN/ES existent en brouillon et attendent une revue humaine ; il ne prétend plus que les contenus détaillés sont absents.
9. **Documentation** : README, base canonique, journal de traduction, état projet et rapport de localisation ont été actualisés.

## Couverture FR/EN/ES vérifiée

- 28 domaines ; 216 familles.
- 115 titres ; 115 définitions courtes ; 345 tâches.
- 115 profils détaillés.
- 115 parcours de formation ; 115 perspectives et notes de localisation.
- 3 parcours Academy.
- 266 clés ARB dans chaque langue, ensembles de clés identiques et paramètres cohérents.

Les exigences pays sont traduites pour les 105 profils qui possèdent ce champ dans les sources ; aucun champ réglementaire n'a été inventé pour les 10 autres.

## Résultats des contrôles exécutés

| Contrôle | Résultat |
|---|---|
| `scripts/check_translation_coverage.py` | PASS |
| `tests_explorer_assets.py` | PASS — 115 profils via les 10 chemins réellement chargés ; 216 familles ; 115 parcours et perspectives |
| Analyse syntaxique JSON/ARB | PASS — 53 fichiers ; 0 clé dupliquée |
| `python3 -m compileall -q scripts tests_explorer_assets.py` | PASS |
| `python3 -m py_compile scripts/patch_android.py` | PASS |
| `scripts/check_translations.py` | BLOQUÉ — 0 problème de contenu/structure ; 2 106 éléments de revue humaine EN/ES en attente |

## Contrôles non exécutés

Flutter et Dart ne sont pas installés dans l'environnement de préparation. Par conséquent, aucun résultat n'est revendiqué pour `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, ni pour un test sur appareil.

## Conditions avant une release localisée

- Effectuer la revue humaine des 2 106 éléments EN/ES et mettre à jour les statuts uniquement après validation réelle.
- Lancer la CI GitHub et corriger tout problème Dart/Flutter ou Android révélé par les vrais outils.
- Réaliser les tests d'interface, d'accessibilité, de responsive 360 dp et les parcours de bout en bout.
- Compléter et faire valider les contenus pédagogiques Academy au-delà des trois parcours de démonstration actuels.
- Garder Supabase inchangé jusqu'à la phase dédiée et à l'approbation explicite.

Aucun push GitHub, commit, PR, déploiement Supabase ou build APK n'a été effectué pendant cette préparation.
