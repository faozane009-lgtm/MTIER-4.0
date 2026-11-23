# QA IA — M-TIER 4.0 — v0.1

## Périmètre livré
- Onglet IA ajouté à la navigation Flutter après Academy.
- Assistant local de démonstration avec conversation, saisie libre et suggestions.
- Lecture directe des sources partagées : `ProfileBridge.current`, `ExplorerData.shared`, `OrientationEngine.rank`, `AcademyData.shared`, `AcademyBridge.viewedLessons` et `ProgressBridge`.
- Réponses d'orientation, profil, apprentissage, progression et confidentialité fondées sur les données locales partagées entre modules.
- Détection des intentions sensibles par expressions à frontières de mots ; une question défensive sur la protection contre des attaques n’est pas assimilée automatiquement à une demande d’attaque.
- Réponse de sécurité orientée vers la cybersécurité défensive et les environnements autorisés.

## Limites explicites
- Ce n'est pas encore un modèle génératif connecté : les réponses sont locales, déterministes et fondées sur des règles.
- Aucun appel réseau, aucune écriture Supabase ni synchronisation serveur. Les données des modules sont conservées localement.
- Les messages de conversation sont conservés uniquement dans l'état mémoire de l'écran.
- Les réponses ne remplacent pas un conseiller d'orientation ni une validation humaine des contenus pédagogiques.
- Les tests statiques ne remplacent pas `flutter analyze`, les tests Flutter, la compilation Android/iOS ou un contrôle sur appareil réel.

## Contrat d'interconnexion
L'assistante ne possède ni profil utilisateur autonome ni catalogue de métiers. Elle lit les ponts de données des modules existants et utilise les `occupation_id`/identifiants de leçons déjà partagés.

## Sécurité et confidentialité
- Ne pas saisir de mots de passe ou d'informations sensibles.
- Aucun partage public ni transfert de données par ce prototype.
- Les sujets cybersécurité sont redirigés vers l'apprentissage défensif et les laboratoires autorisés.

## Priorité d'intention — correctif pré-GitHub

Les marqueurs d'intention offensive explicite (demande d'instruction, première personne ou impératif) sont maintenant évalués avant les mots génériques de défense. Une formulation mixte comme « protéger mon compte, mais expliquer comment pirater celui d'une autre personne » ne doit plus être classée comme défensive uniquement parce qu'elle contient le mot « protéger ». Les demandes défensives simples qui mentionnent une attaque restent non bloquées. Tests de régression ajoutés ; exécution Flutter en attente de CI.
