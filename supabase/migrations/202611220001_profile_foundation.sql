-- M-TIER 4.0 / Profile foundation
-- Safe to review first. Do not apply until existing tables and policies are checked.
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) <= 60),
  age_band text check (age_band in ('13-17','18-24','25-34','35-44','45-54','55+')),
  country_code text check (country_code is null or country_code ~ '^[A-Z]{2}$'),
  profile_visibility text not null default 'private' check (profile_visibility = 'private'),
  preferences jsonb not null default '{}'::jsonb,
  consents jsonb not null default '{"personalization":false,"portfolio_public_sharing":false,"analytics_optional":false}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.user_profiles enable row level security;
drop policy if exists "Users can read own profile" on public.user_profiles;
create policy "Users can read own profile" on public.user_profiles
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can insert own profile" on public.user_profiles;
create policy "Users can insert own profile" on public.user_profiles
  for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can update own profile" on public.user_profiles;
create policy "Users can update own profile" on public.user_profiles
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
