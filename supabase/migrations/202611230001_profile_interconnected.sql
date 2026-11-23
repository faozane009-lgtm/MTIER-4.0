-- M-TIER 4.0 — PROFIL interconnecté (à exécuter MANUELLEMENT)
-- Projet cible : kefixngzswwdqejlqwwz
-- Ce script complète public.user_profiles existante ; il ne remplace pas les tables Explorer.
-- Vérifier d'abord les tables déjà présentes. Toutes les données utilisateur sont privées.

begin;

-- 0) Créer la table de base uniquement si elle n'existe pas encore.
-- Si la fondation Profile v0.1 a déjà été appliquée, cette instruction ne crée aucun doublon.
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (display_name is null or char_length(display_name) <= 60),
  age_band text check (age_band is null or age_band in ('13-17','18-24','25-34','35-44','45-54','55+')),
  country_code text check (country_code is null or country_code ~ '^[A-Z]{2}$'),
  profile_visibility text not null default 'private' check (profile_visibility = 'private'),
  preferences jsonb not null default '{}'::jsonb,
  consents jsonb not null default '{"personalization":false,"portfolio_public_sharing":false,"analytics_optional":false}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 1) Compléter la table de base créée par la fondation Profile v0.1.
alter table public.user_profiles
  add column if not exists region text check (region is null or char_length(region) <= 80),
  add column if not exists education_level text check (education_level is null or education_level in ('primary','secondary','vocational','undergraduate','graduate','other')),
  add column if not exists education_detail text check (education_detail is null or char_length(education_detail) <= 100),
  add column if not exists preferred_language text not null default 'fr' check (preferred_language in ('fr','en','es')),
  add column if not exists learning_format text not null default 'practical' check (learning_format in ('practical','short_lessons','videos','reading','mixed'));

-- 2) Domaines d'intérêt : consommés par Match et les recommandations.
create table if not exists public.profile_interests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  interest_key text not null check (char_length(interest_key) between 1 and 80),
  created_at timestamptz not null default now(),
  unique (user_id, interest_key)
);

-- 3) Compétences déclarées : consommées par Match et Progress.
create table if not exists public.profile_skills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_name text not null check (char_length(skill_name) between 1 and 100),
  skill_level text not null default 'beginner' check (skill_level in ('beginner','intermediate','advanced','not_assessed')),
  source text not null default 'self_reported' check (source in ('self_reported','course','project','assessment')),
  notes text check (notes is null or char_length(notes) <= 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, skill_name)
);

-- 4) Objectifs : consommés par Academy et Progress.
create table if not exists public.profile_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  goal_type text not null default 'career' check (goal_type in ('career','learning','skill','project')),
  status text not null default 'active' check (status in ('active','paused','completed')),
  target_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 5) Métiers suivis : occupation_id reprend exactement l'ID du catalogue Explorer.
-- Pas de FK vers une table occupations tant que le catalogue n'est pas importé dans Postgres.
create table if not exists public.profile_occupation_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occupation_id text not null check (char_length(occupation_id) between 1 and 100),
  relation_type text not null default 'interested' check (relation_type in ('interested','target','favorite')),
  created_at timestamptz not null default now(),
  unique (user_id, occupation_id)
);

-- 6) Index utiles pour charger le profil d'un utilisateur.
create index if not exists profile_interests_user_idx on public.profile_interests(user_id);
create index if not exists profile_skills_user_idx on public.profile_skills(user_id);
create index if not exists profile_goals_user_idx on public.profile_goals(user_id, status);
create index if not exists profile_occupation_links_user_idx on public.profile_occupation_links(user_id);
create index if not exists profile_occupation_links_occupation_idx on public.profile_occupation_links(occupation_id);

-- 7) RLS : chaque utilisateur ne voit et ne modifie que ses propres lignes.
alter table public.user_profiles enable row level security;
alter table public.profile_interests enable row level security;
alter table public.profile_skills enable row level security;
alter table public.profile_goals enable row level security;
alter table public.profile_occupation_links enable row level security;

-- Retirer les anciennes policies du même nom pour permettre une réexécution contrôlée.
drop policy if exists "Users can read own profile" on public.user_profiles;
drop policy if exists "Users can insert own profile" on public.user_profiles;
drop policy if exists "Users can update own profile" on public.user_profiles;
create policy "Users can read own profile" on public.user_profiles for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users can insert own profile" on public.user_profiles for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users can update own profile" on public.user_profiles for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Les tables enfants utilisent une politique propriétaire pour chaque opération.
do $$
declare t text;
begin
  foreach t in array array['profile_interests','profile_skills','profile_goals','profile_occupation_links'] loop
    execute format('drop policy if exists %I on public.%I', 'owner_select_' || t, t);
    execute format('drop policy if exists %I on public.%I', 'owner_insert_' || t, t);
    execute format('drop policy if exists %I on public.%I', 'owner_update_' || t, t);
    execute format('drop policy if exists %I on public.%I', 'owner_delete_' || t, t);
    execute format('create policy %I on public.%I for select to authenticated using ((select auth.uid()) = user_id)', 'owner_select_' || t, t);
    execute format('create policy %I on public.%I for insert to authenticated with check ((select auth.uid()) = user_id)', 'owner_insert_' || t, t);
    execute format('create policy %I on public.%I for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)', 'owner_update_' || t, t);
    execute format('create policy %I on public.%I for delete to authenticated using ((select auth.uid()) = user_id)', 'owner_delete_' || t, t);
  end loop;
end $$;

-- Accès API explicite pour utilisateurs authentifiés ; aucune lecture anonyme.
grant select, insert, update on public.user_profiles to authenticated;
grant select, insert, update, delete on public.profile_interests to authenticated;
grant select, insert, update, delete on public.profile_skills to authenticated;
grant select, insert, update, delete on public.profile_goals to authenticated;
grant select, insert, update, delete on public.profile_occupation_links to authenticated;
revoke all on public.user_profiles, public.profile_interests, public.profile_skills, public.profile_goals, public.profile_occupation_links from anon;

commit;

-- Vérification manuelle après exécution :
-- select tablename, rowsecurity from pg_tables where schemaname='public' and tablename in
-- ('user_profiles','profile_interests','profile_skills','profile_goals','profile_occupation_links') order by tablename;
-- select tablename, policyname, cmd from pg_policies where schemaname='public' and tablename like 'profile_%' or tablename='user_profiles' order by tablename, policyname;
