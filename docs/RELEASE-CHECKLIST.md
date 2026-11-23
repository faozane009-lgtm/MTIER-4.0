# M-TIER 4.0 — checklist de publication

Aucune publication n’est autorisée tant que les portes de validation du projet ne sont pas vertes.

## Android

- [ ] Confirmer dans CI le manifeste Android généré : permission INTERNET, label M-TIER et `applicationId` stable `com.mtier.app`.
- [ ] Figer la version Flutter/Dart à partir du premier log CI réussi et la documenter.
- [ ] Obtenir `flutter analyze` sans erreur et tous les tests Flutter verts.
- [ ] Obtenir un APK debug CI pour les tests internes.
- [ ] Préparer un APK release signé et un AAB si Google Play est retenu.
- [ ] Générer la clé de signature hors du dépôt ; sauvegarde sûre contrôlée par le propriétaire du projet.
- [ ] Conserver durablement le même `applicationId` et la même clé pour permettre les mises à jour.
- [ ] Tester installation neuve, mise à jour depuis une ancienne version, restauration locale et suppression des données.
- [ ] Vérifier permissions, réseau, taille, démarrage, navigation, langues et thèmes sur appareil Android réel.

## Site officiel M-TIER

- [ ] Page de présentation officielle du produit et des six modules.
- [ ] Page de téléchargement APK avec version, date, taille et empreinte SHA-256.
- [ ] Historique des versions et notes de publication.
- [ ] Guide d’installation Android et procédure de mise à jour.
- [ ] Documentation utilisateur et FAQ.
- [ ] Page de support avec canal de contact confirmé par le propriétaire.
- [ ] Politique de confidentialité et conditions d’utilisation adaptées aux fonctions réellement activées.
- [ ] Pages FR/EN/ES cohérentes avec la couverture linguistique réellement publiée.
- [ ] Hébergement HTTPS, domaine officiel confirmé, sauvegardes et contrôle des liens de téléchargement.

## Mise à jour applicative

- [ ] Endpoint de version contrôlé et documenté.
- [ ] Comparaison version installée / version disponible.
- [ ] Notes de version et lien officiel APK.
- [ ] Consentement explicite avant l’ouverture de l’installation Android hors Play Store.
- [ ] Contrôle SHA-256 du fichier téléchargé.
- [ ] Ne jamais remplacer ou perdre la clé de signature existante.

## Backend et sécurité

- [ ] Approbation explicite avant les nouvelles migrations Supabase.
- [ ] RLS vérifiée pour chaque table utilisateur.
- [ ] Secrets uniquement dans GitHub Secrets / configuration sécurisée, jamais dans le dépôt ou l’APK.
- [ ] Vérifier suppression de compte, suppression de données, limites de requêtes et gestion hors ligne.
