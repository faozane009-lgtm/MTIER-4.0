# QA PROFIL v0.4

## Livré
- Interface Profil organisée en 8 sections : identité minimale, études, intérêts, compétences, apprentissage, objectifs, métiers suivis et confidentialité.
- Champs facultatifs et minimisation des données : pas de date de naissance complète, adresse précise, téléphone ou établissement imposé.
- Profil privé par défaut ; aucun réseau social, recherche publique ou messagerie.
- Interconnexion préparée par `user_id` commun et `occupation_id` identique au catalogue Explorer.
- SQL manuel idempotent pour compléter `user_profiles`, créer les 4 tables enfants, indexer les recherches et activer RLS avec politiques propriétaires.
- Guide manuel Supabase avec liens directs et étapes de vérification.

## Non livré / à ne pas confondre
- Pas de sauvegarde Supabase depuis Flutter : le bouton valide un aperçu local à la session.
- Pas d'authentification réelle dans l'application.
- Pas de test Flutter `analyze`, build ou widget : le SDK Flutter/Dart n'est pas disponible dans l'environnement de préparation.
- Le SQL n'a pas été exécuté sur le projet distant ; l'utilisateur l'ajoutera manuellement comme demandé.
- Le projet Supabase n'a pas pu être inspecté via le connecteur associé ; vérifier l'existant dans le dashboard avant de lancer le script.

## Critère de clôture backend
Le module pourra être considéré connecté seulement après exécution du SQL, configuration Auth + URL/Publishable key, lecture/insertion/mise à jour du profil connecté, et vérification qu'un second compte ne peut pas lire ni modifier les données du premier.
