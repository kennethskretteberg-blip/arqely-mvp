-- ============================================================
-- Arqely / Romtegner — Auth, Profiles, Organizations
-- Run this in Supabase SQL Editor as superadmin
-- ============================================================

-- ─── 1. PROFILES ─────────────────────────────────────────────

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  company_name text,
  message text,
  status text not null default 'pending',  -- 'pending' | 'active' | 'rejected'
  created_at timestamptz default now(),
  approved_at timestamptz,
  approved_by uuid references auth.users(id)
);

-- Trigger: auto-create profile when a new user signs up
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, email, full_name, company_name, message)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'company_name',
    new.raw_user_meta_data->>'message'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Drop existing trigger if it exists, then recreate
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();


-- ─── 2. ORGANIZATIONS ───────────────────────────────────────

create table if not exists organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  created_at timestamptz default now()
);

create table if not exists organization_members (
  org_id uuid references organizations(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'member',  -- 'owner' | 'admin' | 'member'
  primary key (org_id, user_id)
);

create table if not exists organization_product_access (
  org_id uuid references organizations(id) on delete cascade,
  category_slug text not null,
  primary key (org_id, category_slug)
);

-- Add slug column to product_categories if it doesn't exist
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'product_categories' and column_name = 'slug'
  ) then
    alter table product_categories add column slug text;
    -- Populate slugs from existing names
    update product_categories set slug = lower(replace(replace(name, ' ', '-'), 'æ', 'ae'));
  end if;
end $$;

-- Add user_id to romtegner_projects if it doesn't exist
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'romtegner_projects' and column_name = 'user_id'
  ) then
    alter table romtegner_projects add column user_id uuid references auth.users(id);
  end if;
end $$;


-- ─── 3. ROW LEVEL SECURITY ──────────────────────────────────

-- Helper: check if current user is superadmin
create or replace function is_superadmin()
returns boolean as $$
begin
  return coalesce(
    (current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'is_superadmin')::boolean,
    false
  );
end;
$$ language plpgsql stable security definer;

-- Helper: check if current user has active profile
create or replace function is_active_user()
returns boolean as $$
begin
  return exists (
    select 1 from profiles where id = auth.uid() and status = 'active'
  );
end;
$$ language plpgsql stable security definer;


-- ── Profiles RLS ──
alter table profiles enable row level security;

-- Drop existing policies if they exist (idempotent)
drop policy if exists "Bruker ser egen profil" on profiles;
drop policy if exists "Superadmin full tilgang profiler" on profiles;

create policy "Bruker ser egen profil" on profiles
  for select using (auth.uid() = id);

create policy "Superadmin full tilgang profiler" on profiles
  for all using (is_superadmin());


-- ── Organizations RLS ──
alter table organizations enable row level security;

drop policy if exists "Superadmin full tilgang org" on organizations;
drop policy if exists "Medlemmer ser sine org" on organizations;

create policy "Superadmin full tilgang org" on organizations
  for all using (is_superadmin());

create policy "Medlemmer ser sine org" on organizations
  for select using (
    exists (
      select 1 from organization_members
      where org_id = organizations.id and user_id = auth.uid()
    )
  );


-- ── Organization Members RLS ──
alter table organization_members enable row level security;

drop policy if exists "Superadmin full tilgang members" on organization_members;
drop policy if exists "Medlemmer ser egne medlemskap" on organization_members;

create policy "Superadmin full tilgang members" on organization_members
  for all using (is_superadmin());

create policy "Medlemmer ser egne medlemskap" on organization_members
  for select using (user_id = auth.uid());


-- ── Organization Product Access RLS ──
alter table organization_product_access enable row level security;

drop policy if exists "Superadmin full tilgang product access" on organization_product_access;
drop policy if exists "Medlemmer ser sin org produkttilgang" on organization_product_access;

create policy "Superadmin full tilgang product access" on organization_product_access
  for all using (is_superadmin());

create policy "Medlemmer ser sin org produkttilgang" on organization_product_access
  for select using (
    exists (
      select 1 from organization_members
      where org_id = organization_product_access.org_id and user_id = auth.uid()
    )
  );


-- ── Projects RLS ──
-- Enable RLS on romtegner_projects (may already be enabled)
alter table romtegner_projects enable row level security;

drop policy if exists "Bruker ser egne prosjekter" on romtegner_projects;
drop policy if exists "Superadmin ser alle prosjekter" on romtegner_projects;
drop policy if exists "Aktive brukere CRUD egne prosjekter" on romtegner_projects;

create policy "Superadmin ser alle prosjekter" on romtegner_projects
  for all using (is_superadmin());

create policy "Aktive brukere CRUD egne prosjekter" on romtegner_projects
  for all using (
    auth.uid() = user_id
    and (is_superadmin() or is_active_user())
  );

-- Allow insert for any authenticated user (so new users can save before approval)
drop policy if exists "Autentiserte brukere kan opprette prosjekter" on romtegner_projects;
create policy "Autentiserte brukere kan opprette prosjekter" on romtegner_projects
  for insert with check (auth.uid() = user_id);


-- ── Heating Products RLS ──
-- Note: products may not have RLS yet. Enable it.
alter table heating_products enable row level security;

drop policy if exists "Alle ser produkter" on heating_products;
drop policy if exists "Superadmin full tilgang produkter" on heating_products;

-- For now: all authenticated users can see all products
-- (org-filtered access can be added later when orgs are actively used)
create policy "Alle autentiserte ser produkter" on heating_products
  for select using (auth.uid() is not null);

create policy "Superadmin full tilgang produkter" on heating_products
  for all using (is_superadmin());


-- ── Product Categories RLS ──
alter table product_categories enable row level security;

drop policy if exists "Alle ser kategorier" on product_categories;
drop policy if exists "Superadmin full tilgang kategorier" on product_categories;

create policy "Alle autentiserte ser kategorier" on product_categories
  for select using (auth.uid() is not null);

create policy "Superadmin full tilgang kategorier" on product_categories
  for all using (is_superadmin());


-- ─── 4. BACKFILL: Create profile for existing user ──────────
-- (Your existing user won't have a profile row yet)
insert into profiles (id, email, full_name, status, approved_at)
select id, email, raw_user_meta_data->>'full_name', 'active', now()
from auth.users
where id not in (select id from profiles)
on conflict (id) do nothing;

-- Backfill user_id on existing projects (assign all to your user)
update romtegner_projects
set user_id = (select id from auth.users limit 1)
where user_id is null;


-- ─── DONE ────────────────────────────────────────────────────
-- Verify:
select 'profiles' as tbl, count(*) from profiles
union all select 'organizations', count(*) from organizations
union all select 'org_members', count(*) from organization_members;
