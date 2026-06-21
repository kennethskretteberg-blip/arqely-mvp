-- ============================================================================
-- Migration: Read-only project presentation via share link (?present=<token>)
-- Run manually in the Supabase SQL Editor. Idempotent (safe to re-run).
-- Plain ASCII only.
--
-- What this adds:
--   1. A nullable, unique `present_token` column on romtegner_projects.
--   2. A SECURITY DEFINER function get_present_project(p_token) that returns a
--      single project's { id, name, data } ONLY when the exact token matches.
--      The function is the ONLY anon entry point, so anonymous viewers can
--      open a project they have a link for, but CANNOT enumerate or list other
--      shared projects (the table's RLS is never opened to anon).
--   3. Anonymous SELECT on the read-only product/catalog tables so product
--      names, categories and supplier colors render in the presentation.
-- ============================================================================

-- 1) Share-token column -------------------------------------------------------
alter table public.romtegner_projects
  add column if not exists present_token text;

create unique index if not exists romtegner_projects_present_token_key
  on public.romtegner_projects (present_token)
  where present_token is not null;

-- 2) Secure public lookup (single row by exact token) -------------------------
create or replace function public.get_present_project(p_token text)
returns table (id uuid, name text, data jsonb)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.name, p.data
  from public.romtegner_projects p
  where p_token is not null
    and p.present_token = p_token
  limit 1;
$$;

-- Only this function is exposed to anonymous (and authenticated) callers.
revoke all on function public.get_present_project(text) from public;
grant execute on function public.get_present_project(text) to anon, authenticated;

-- 3) Read-only catalog access for anonymous presentation viewers --------------
-- Catalog tables are non-sensitive reference data. Enable RLS (if not already)
-- and add an anon SELECT policy. Re-running drops+recreates the policy.
do $$
declare
  t text;
begin
  foreach t in array array['heating_products', 'product_categories', 'suppliers']
  loop
    if to_regclass('public.' || t) is not null then
      execute format('alter table public.%I enable row level security', t);
      execute format('drop policy if exists %I on public.%I', t || '_anon_read', t);
      execute format(
        'create policy %I on public.%I for select to anon using (true)',
        t || '_anon_read', t
      );
    end if;
  end loop;
end $$;

-- ============================================================================
-- Rollback (if ever needed):
--   drop function if exists public.get_present_project(text);
--   drop index if exists public.romtegner_projects_present_token_key;
--   alter table public.romtegner_projects drop column if exists present_token;
--   drop policy if exists heating_products_anon_read   on public.heating_products;
--   drop policy if exists product_categories_anon_read on public.product_categories;
--   drop policy if exists suppliers_anon_read          on public.suppliers;
-- ============================================================================
