# Journal de traduction M-TIER 4.0 — FR/EN/ES

Les IDs canoniques sont immuables. Toute traduction EN/ES produite automatiquement reste `machine_draft_needs_human_review` jusqu'à une relecture réelle par une personne compétente en langue et dans le domaine métier. Aucun statut `human_reviewed` ou `approved` n'est attribué par automatisme.

## Couverture présente dans la base canonique

| Contenu | Couverture FR/EN/ES | Statut EN/ES |
|---|---:|---|
| Titres d'occupations | 115/115 | Brouillons machine complets, à relire |
| Définitions courtes | 115/115 | Brouillons machine complets, à relire |
| Tâches d'occupations | 345/345 | Brouillons machine complets, à relire |
| Noms de domaines | 28/28 | Brouillons machine complets, à relire |
| Noms de familles | 216/216 | Brouillons machine complets, à relire |
| Profils détaillés | 115/115 | Brouillons machine complets, à relire |
| Exigences pays disponibles dans la source | 105/105 | Brouillons machine complets, à relire |
| Parcours de formation Explorer | 115/115 | Brouillons machine complets, à relire |
| Perspectives et notes de localisation | 115/115 | Brouillons machine complets, à relire |
| Parcours Academy | 3/3 | Brouillons machine complets, à relire |
| Interface ARB | 266 clés par langue | Brouillons machine complets, à relire |

Dix profils n'ont pas de champ `country_specific_requirements` dans les données sources ; aucun texte réglementaire n'a été inventé pour eux.

## État du gate

Le dernier contrôle strict rapporte **0 problème de contenu ou de structure** et **2 106 validations humaines EN/ES en attente**. Ce nombre couvre les statuts des domaines, familles, titres/définitions, tâches, profils, parcours, perspectives, Academy et UI. Le gate reste donc bloqué, à juste titre, jusqu’à la revue humaine.

## Règles de vérité éditoriale

1. Conserver exactement les 115 `occupation_id` et tous les IDs de tâches, familles, modules et leçons.
2. Ne jamais transformer un statut `machine_draft_needs_human_review` en `human_reviewed` sans une revue réelle.
3. Ne pas afficher un contenu français comme s'il était traduit ; utiliser la langue active et l'avertissement localisé de brouillon.
4. Ne pas inventer de salaires, diplômes, certifications, durées, débouchés, sources ou exigences réglementaires.
5. Ne pas définir `TRANSLATIONS_COMPLETE=true` avant la revue humaine complète et le passage du gate strict.

## Contrôles

- `scripts/audit_localization.py` : compte les contenus et les états de revue.
- `scripts/check_translation_coverage.py` : PASS si les champs et structures FR/EN/ES sont présents et cohérents ; ne certifie pas la qualité humaine.
- `scripts/check_translations.py` : porte de livraison stricte, toujours bloquée tant que la revue humaine n'est pas terminée.
