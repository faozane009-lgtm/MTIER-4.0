# M-TIER 4.0 — installation manuelle de PROFIL

## Projet existant
- Dashboard du projet : https://supabase.com/dashboard/project/kefixngzswwdqejlqwwz
- SQL Editor direct : https://supabase.com/dashboard/project/kefixngzswwdqejlqwwz/sql/new
- URL API : https://kefixngzswwdqejlqwwz.supabase.co

## Procédure
1. Ouvrir le dashboard et confirmer qu'il s'agit bien du projet M-TIER.
2. Dans Table Editor, vérifier si `user_profiles` existe déjà. Le script est conçu pour compléter cette table issue de Profile Foundation v0.1 ; ne pas créer une deuxième table de profil.
3. Vérifier si `profile_interests`, `profile_skills`, `profile_goals` ou `profile_occupation_links` existent déjà. Si leur structure diffère, arrêter et comparer avant exécution.
4. Ouvrir le SQL Editor direct, copier tout le contenu de `supabase/migrations/202611230001_profile_interconnected.sql`, puis Run.
5. Contrôler que les cinq tables existent et que RLS est activé. Les politiques limitent chaque ligne à `auth.uid() = user_id`.
6. Vérifier dans Integrations > Data API que les tables voulues sont exposées à l'API si l'application les utilise via PostgREST. Les GRANT du script ne remplacent pas ce réglage de publication.
7. Dans Project Settings > API Keys, récupérer uniquement la clé **Publishable** (`sb_publishable_...`) pour Flutter. Ne jamais mettre une clé `sb_secret_...` ou `service_role` dans l'application.
8. Configurer Auth avant toute sauvegarde réelle : un utilisateur doit être connecté pour que `auth.uid()` soit défini. Définir aussi les URL de redirection si un flux de connexion par lien magique est retenu.

## Tables et liens inter-modules
| Table | Rôle | Modules consommateurs |
|---|---|---|
| `user_profiles` | profil de base, pays, niveau d'études, langue et format d'apprentissage | tous les modules selon besoin |
| `profile_interests` | domaines d'intérêt | Match, recommandations |
| `profile_skills` | compétences déclarées et niveau | Match, Progress |
| `profile_goals` | objectifs de carrière, apprentissage et projet | Academy, Progress |
| `profile_occupation_links` | métiers suivis via l'identifiant exact `occupation_id` | Explorer, Match, parcours |

Toutes les tables partagent le même `user_id` issu de Supabase Auth. Les autres modules ne doivent lire que les champs nécessaires. Le catalogue Explorer reste actuellement dans les assets Flutter ; aucune FK vers une table de métiers Postgres n'est créée tant que le catalogue n'a pas été importé en base.

## Vérification après exécution
```sql
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in ('user_profiles','profile_interests','profile_skills','profile_goals','profile_occupation_links')
order by tablename;

select tablename, policyname, cmd
from pg_policies
where schemaname = 'public'
  and tablename in ('user_profiles','profile_interests','profile_skills','profile_goals','profile_occupation_links')
order by tablename, policyname;
```

## Limites actuelles
- Le module Flutter livré conserve le profil et les objectifs dans un stockage local JSON versionné. Il ne réalise aucune écriture Supabase ; la synchronisation serveur reste différée.
- L'authentification réelle, le chargement/upsert des profils et les tests multi-utilisateurs restent à brancher après création manuelle du schéma et configuration des clés.
- Partage public, recherche de profils et messagerie ne font pas partie de ce MVP. La visibilité reste privée.
