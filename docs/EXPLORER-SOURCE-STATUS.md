# M-TIER 4.0 — Explorer v4.3

## État de cette version

Le contenu central d'Explorer est prêt pour l'intégration dans l'application et les essais fonctionnels : 115 métiers, 115 profils détaillés, 115 parcours généraux et 115 perspectives mondiales qualitatives. La suite de contrôles automatisés vérifie les liens et le minimum de contenu de chaque fiche.

Cette clôture est une clôture de **développement produit**, pas une certification factuelle ou une autorisation de publication mondiale. Les 115 fiches restent des candidates éditoriales. Les sources métier directement rattachées, les qualifications nationales, les licences et les validations professionnelles doivent être renforcées progressivement.

## Salaires — chantier reporté

La matrice conserve 25 070 couples métier-économie. Six observations métier-pays US vérifiées contiennent des montants; les 25 064 autres couples restent sans valeur numérique publiable. La rubrique doit afficher « données salariales non disponibles / à compléter » et ne jamais inventer de montant. Le chantier salarial ne bloque plus l'intégration fonctionnelle d'Explorer.

## Limites de localisation

- Les parcours sont des orientations générales, non des équivalences nationales garanties.
- Les perspectives sont qualitatives et mondiales pour 2025-2030, non des prévisions nationales.
- Aucun fait national de qualification/licence n'est actuellement validé dans le catalogue maître.
- Les correspondances de classification non confirmées restent candidates.
- Les fiches ne sont pas approuvées pour publication mondiale sans revue documentaire et métier.

## Validation

À la racine du projet : `python -m pytest -q`

Audit de clôture reproductible : `python scripts/audit_explorer_release_v43.py`

Rapport détaillé : `reports/EXPLORER-RELEASE-GATE-v4.3.md`
