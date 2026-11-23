# M-TIER 4.0 — état du chantier canonique

Date du relevé : 23 novembre 2026. Cette page distingue les fichiers préparés des validations qui nécessitent une exécution réelle dans GitHub Actions.

## Réalisé dans cette livraison

- Base canonique de travail : `MTIER-4.0-CANONICAL-v0.9.zip`, projet Flutter intégré avec workflow CI/Android et corrections locales pré-GitHub.
- État local partagé réactif pour profil, objectifs, réalisations, journal, leçons consultées, langue et thème.
- Modèle `Goal` commun avec types, statuts et `occupation_id` facultatif.
- Match fondé sur le profil et le catalogue Explorer partagés ; normalisation accentuée et correspondances par frontières de mots.
- IA reliée aux données partagées et aux modules ; réponses FR/EN/ES principales et filtre cybersécurité défensif.
- Academy reliée à Match, Profil et Progress ; IDs de leçons conservés et horodatages locaux.
- Progress avec objectifs, réalisations et journal locaux ; édition, changement de statut et suppression présents dans l’interface (tests Flutter encore à exécuter).
- Accueil basé sur les données réelles ; cinq destinations de navigation ; Match et Progress regroupés dans Parcours ; IA accessible par FAB.
- Thèmes Material 3 sombre par défaut, clair et système ; préférence persistée.
- Couverture FR/EN/ES présente pour 115 titres/définitions, 345 tâches, 28 domaines, 216 familles, 115 profils détaillés, 115 parcours de formation, 115 perspectives et 3 parcours Academy. Les traductions EN/ES sont explicitement des brouillons à relire.
- Sélecteur global de langue et 266 clés de messages ARB FR/EN/ES présentes.
- Tests Dart écrits pour Goal, état partagé, navigation, localisation, Academy et thème ; contrôles Python statiques disponibles.

## Non validé — ne pas annoncer comme terminé

- `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, `flutter build apk --debug` : pas encore exécutés dans une CI réelle.
- Vérification du manifeste Android généré et confirmation de l’`applicationId` dans GitHub Actions.
- Version exacte Flutter à figer après le premier log CI.
- Couverture des données EN/ES complète en brouillon selon `scripts/check_translation_coverage.py` ; aucune revue humaine n’est encore validée (2 106 éléments de revue restent en attente).
- Les 266 clés UI EN/ES, les 216 familles et les contenus Academy restent à relire par des personnes compétentes.
- Traductions EN/ES existantes et nouvelles non relues par un humain.
- Audit responsive réel à 360 dp, revue WCAG complète, onboarding et redesign visuel de tous les composants.
- Intégration et exécution Supabase/RLS non commencées ; les migrations incluses restent des documents préparatoires et aucune migration n’a été modifiée ou exécutée.
- Dépôt GitHub, PR, APK/AAB signé et site officiel non livrés dans cette étape.

## Portes de validation

1. Importer cette archive dans le dépôt GitHub canonique et obtenir une première exécution CI verte.
2. Corriger tous les problèmes Flutter/Dart révélés par `analyze`, `test` et la compilation APK.
3. Finaliser les traductions et la relecture humaine ; ne définir `TRANSLATIONS_COMPLETE=true` qu’après le passage du gate.
4. Terminer les modules, l’interface responsive et la QA intermodules.
5. Obtenir l’approbation explicite avant la phase Supabase (nouvelles migrations uniquement).
6. Préparer ensuite les builds signés, le mécanisme de mise à jour et le site officiel.

## Corrections pré-GitHub en cours — 23 novembre 2026

- Le score Match utilise désormais directement les pondérations fixes 45/30/10/15 ; les poids des dimensions absentes ne sont plus redistribués. Un avertissement précise que ce score n'est pas une probabilité.
- Le formulaire Profil synchronise explicitement les modifications avec l'état central ; la mutation de l'état depuis `build()` a été supprimée.
- Progress prend en charge l'édition, le changement de statut et la suppression des objectifs, ainsi que l'édition/suppression des preuves et notes.
- Les leçons vues dans Progress affichent leur titre Academy localisé lorsque la ressource est disponible.
- Les erreurs de restauration/sauvegarde locale sont signalées et une restauration JSON corrompue ne laisse plus des collections partiellement remplies.
- 266 clés de messages ARB FR/EN/ES sont présentes avec des ensembles identiques et des paramètres cohérents.
- Les textes visibles d'Explorer et le message de suppression locale sont raccordés aux ARB.

**Toujours bloquant avant une release localisée :** la couverture EN/ES est présente en brouillon, mais la revue humaine n'est pas effectuée ; `scripts/check_translations.py` reste bloquant. Flutter/Dart ne sont pas disponibles dans l'environnement de préparation : aucune analyse, suite de tests ou compilation Flutter n'est revendiquée.
