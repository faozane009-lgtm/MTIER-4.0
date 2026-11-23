# M-TIER 4.0 — état de localisation FR/EN/ES avant intégration GitHub

Dernière vérification : 23 novembre 2026.

## Couverture mesurée dans les sources

- **Interface Flutter** : 266 clés ARB dans chacune des langues FR/EN/ES. Les ensembles de clés et les métadonnées de paramètres correspondent. Les traductions EN/ES sont des brouillons machine à relire ; aucune validation humaine n'est revendiquée.
- **Domaines Explorer** : 28/28 noms FR/EN/ES présents.
- **Familles Explorer** : 216/216 noms FR/EN/ES présents. Les IDs de familles sont inchangés.
- **Catalogue Explorer** : 115/115 titres et 115/115 définitions courtes présents en FR/EN/ES.
- **Tâches Explorer** : 345/345 traductions EN et 345/345 traductions ES présentes. Les IDs des tâches sont inchangés.
- **Profils détaillés Explorer** : 115/115 profils avec objectifs, missions, contexte, compétences, connaissances et notes de correspondance en FR/EN/ES. Les exigences pays sont traduites pour les 105 profils qui en possèdent dans la source ; 10 profils n'ont pas de champ d'exigences pays source.
- **Parcours de formation Explorer** : 115/115 `pathway` et notes présents en EN/ES.
- **Perspectives Explorer** : 115/115 perspectives qualitatives et notes de localisation présentes en EN/ES. Les tendances globales ne sont pas présentées comme des prévisions nationales.
- **Academy** : 3/3 parcours avec résultats, modules et leçons en FR/EN/ES. Il s'agit de contenus de démonstration en brouillon, pas de certifications ni de programmes officiellement accrédités.
- **Taxonomie et données** : les identifiants canoniques des 115 métiers, 216 familles, tâches, profils, parcours et leçons sont conservés.

## État de validation linguistique

Les 2 106 éléments de revue EN/ES suivis par le gate restent `machine_draft_needs_human_review`. Elles ne sont pas marquées `human_reviewed`. La présence d'une traduction complète ne signifie pas qu'elle a été relue par une personne compétente en langue et dans le domaine métier.

## Contrôles disponibles

- `python3 scripts/audit_localization.py` : rapport de couverture et de statut de revue.
- `python3 scripts/check_translation_coverage.py` : vérifie la présence des champs, la cohérence des IDs, les longueurs de tableaux, les clés ARB et les paramètres. Ce contrôle ne prétend pas effectuer une revue humaine.
- `python3 scripts/check_translations.py` : porte de livraison stricte ; elle reste volontairement bloquée jusqu'à la revue humaine réelle de tous les contenus requis.

## Blocage de livraison

La couverture de traduction FR/EN/ES est complète dans les données suivies par le contrôle de couverture (0 problème de contenu/structure détecté par le gate strict). Les **2 106 validations humaines** restent à effectuer pour les titres, définitions, missions, tâches, profils, familles, parcours, perspectives, cours Academy et textes UI. Ne pas définir `TRANSLATIONS_COMPLETE=true` et ne pas transformer les statuts machine en statuts `human_reviewed` avant cette revue.

Les validations Flutter restent distinctes : `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test` et le build Android doivent être exécutés dans GitHub Actions, car Flutter et Dart ne sont pas installés dans l'environnement de préparation.
