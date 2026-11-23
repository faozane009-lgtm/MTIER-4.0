# Spécification fonctionnelle — M-TIER Academy v0.1

## 1. Mission
Academy transforme une intention professionnelle en apprentissage progressif, mesurable et utile.
Le module doit fonctionner avec des connexions limitées, être utilisable sur téléphone et éviter
de confondre progression pédagogique et certification officielle.

## 2. Objets pédagogiques
- **Parcours** : objectif global, public visé, prérequis, niveau, durée indicative, compétences ciblées.
- **Module** : étape cohérente d'un parcours, avec objectifs observables.
- **Leçon** : explication structurée, exemple, résumé et ressources référencées.
- **Activité** : exercice, étude de cas ou mini-projet avec consignes et critères.
- **Évaluation** : questions ou grille de critères, seuil configurable et feedback explicatif.
- **Compétence** : résultat d'apprentissage relié à Explorer et Match.
- **Preuve** : livrable de l'apprenant, conservé dans Progress avec son accord.

## 3. Parcours de démonstration
1. Culture numérique et citoyenneté numérique.
2. Programmation : logique et bases.
3. Cybersécurité défensive : principes et bonnes pratiques.

Les parcours sont des prototypes pédagogiques, non des diplômes et non des certifications.

## 4. Boucle d'apprentissage
1. Diagnostic de niveau facultatif.
2. Présentation des objectifs et prérequis.
3. Leçon courte et accessible.
4. Exemple contextualisé.
5. Activité pratique sûre.
6. Feedback explicatif.
7. Évaluation formative.
8. Récapitulatif et recommandation de prochaine étape.

## 5. Progression
- Une leçon est terminée lorsque l'apprenant confirme l'avoir étudiée et réussit l'activité requise.
- Un module est terminé lorsque toutes ses leçons obligatoires sont terminées et que l'évaluation atteint le seuil.
- Un parcours est terminé lorsque tous les modules obligatoires sont terminés.
- Les résultats peuvent être réessayés; conserver le meilleur score et l'historique des tentatives.
- Ne jamais présenter un score comme une mesure de valeur personnelle ou de potentiel définitif.
- L'utilisateur peut mettre en pause, reprendre ou réviser un module.

## 6. Évaluation et feedback
- Priorité à l'évaluation formative et aux explications.
- Questions reliées explicitement à un objectif d'apprentissage.
- Critères de projets publiés avant le dépôt.
- Feedback précis : acquis, point à revoir, ressource conseillée, prochaine action.
- Prévoir des alternatives aux activités chronométrées.
- Pas de classement public par défaut.

## 7. Sécurité et protection des apprenants
- Parcours cybersécurité centrés sur la prévention, la protection, la conception sûre et les environnements autorisés.
- Aucun exercice sur des comptes, appareils, réseaux ou sites tiers.
- Les projets de sécurité utilisent des scénarios fictifs, des données synthétiques ou des environnements pédagogiques isolés et explicitement autorisés.
- Pas de collecte inutile de données personnelles.
- Modération et signalement pour les espaces communautaires futurs.
- Les fonctions sociales ne sont pas nécessaires au MVP.

## 8. Accessibilité et fonctionnement mobile
- Leçon lisible sur petit écran, navigation clavier et lecteur d'écran.
- Texte clair, contrastes suffisants, médias avec transcription ou description.
- Télécharger les leçons textuelles pour lecture hors ligne.
- Synchroniser les progrès lorsque la connexion revient, avec résolution de conflits documentée.
- Économiser données et batterie : médias facultatifs, images optimisées, pas d'autoplay.

## 9. Intégration aux autres modules
- Explorer fournit les métiers et compétences ciblés.
- Match recommande un parcours en fonction des écarts de compétences, sans imposer un choix.
- Profile conserve les préférences et le niveau déclaré.
- Progress conserve les objectifs, preuves et résultats.
- Assistant explique les leçons et aide à réviser, sans donner les réponses à la place de l'apprenant.

## 10. Statuts de publication
`draft` → `in_review` → `approved` → `published` → `archived`.
Un contenu sans auteur, objectifs, sources et relecture ne peut pas être publié.
Les références externes doivent être datées et leur licence/conditions de réutilisation vérifiées.

## 11. Hors périmètre de cette version
- Application Flutter réelle.
- Authentification, paiement, backend, synchronisation cloud.
- Certification accréditée.
- Génération IA automatique des cours en production.
- Communauté, classes virtuelles et marketplace.
