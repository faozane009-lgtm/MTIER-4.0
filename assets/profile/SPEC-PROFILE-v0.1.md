# Spécification fonctionnelle — M-TIER Profile v0.1

## Rôle
Profile fournit à l'utilisateur un espace personnel permettant de gérer les informations nécessaires
à l'orientation et à l'apprentissage, avec minimisation des données et contrôles compréhensibles.

## Fonctions
- Profil de base : pseudonyme ou nom d'affichage facultatif, tranche d'âge, pays/région facultatifs.
- Préférences : domaines d'intérêt, langues d'interface (ajout ultérieur), format d'apprentissage, accessibilité.
- Objectifs : objectifs d'orientation et d'apprentissage.
- Compétences : compétences déclarées, niveau estimé, date et contexte.
- Confidentialité : visibilité du profil, consentements, export et suppression.
- Sécurité : gestion de session et authentification seront définies dans la phase backend.

## Principes de données
- Collecter uniquement ce qui est utile à une fonction activée.
- Ne pas demander adresse exacte, date de naissance complète, établissement scolaire ou téléphone pour le MVP.
- Ne jamais rendre un profil public par défaut.
- Séparer données de profil, données pédagogiques et preuves du portfolio.
- Autoriser consultation, correction et suppression selon les règles applicables.
- Expliquer les conséquences d'un partage avant confirmation.

## Règles spécifiques aux jeunes utilisateurs
- Paramètres de confidentialité prudents par défaut.
- Pas de recherche publique de profils ni de messagerie directe dans le MVP.
- Aucun partage de localisation précise.
- Pas de publicité comportementale ni de profilage sensible.
- Les réglages importants doivent être expliqués simplement.

## Intégrations
Profile fournit à Match les préférences explicitement renseignées, à Academy les préférences d'apprentissage,
et à Progress les paramètres de portfolio. Chaque module ne reçoit que les champs nécessaires.

## Hors périmètre
Authentification réelle, connexion sociale, stockage serveur, vérification d'identité, messagerie et réseau social.
