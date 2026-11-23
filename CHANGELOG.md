# Changelog

## 0.9.0+9 — chantier de consolidation (non publié)

- Choix d’une base canonique unique conservant le projet Flutter et la CI Android.
- Accueil réel et navigation principale en cinq destinations ; Match et Progress réunis dans Parcours ; assistant ouvert depuis le FAB.
- État local partagé, modèle Goal canonique, persistance des objectifs, preuves, journal, leçons consultées, langue et thème.
- Normalisation multilingue et Match alimenté par le Profil et le catalogue Explorer uniques.
- Assistant local relié aux données partagées, réponses principales FR/EN/ES et garde-fou cybersécurité défensif.
- Academy reliée à Match/Profil/Progress ; traductions EN/ES des trois parcours de démonstration en brouillon.
- Thèmes Material 3 sombre par défaut, clair et système.
- 266 clés ARB, 28 domaines et 216 familles, 115 titres/définitions, 345 tâches, 115 profils détaillés, 115 parcours et 115 perspectives traduits en brouillon EN/ES ; aucune validation humaine revendiquée.
- Match utilise les compétences, familles, parcours et perspectives dans la langue active ; avertissement de traduction Explorer mis à jour.
- Les statuts techniques de classification et de revue Explorer sont rendus dans la langue active.
- `AppState.setProfile()` notifie les consommateurs et persiste via le contrat partagé ; test de notification ajouté.
- Contrôle de couverture `scripts/check_translation_coverage.py` ajouté ; gate strict de revue humaine conservé.
- Tests Flutter supplémentaires écrits ; exécution CI, analyse Dart et builds Android encore en attente.

Cette version n’est pas une release. Voir `docs/PROJECT-STATUS.md` et `docs/RELEASE-CHECKLIST.md`.
