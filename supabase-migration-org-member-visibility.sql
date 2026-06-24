-- ============================================================================
-- Migrasjon: Medlemmer ser ALLE medlemmer i sine egne orgs (uansett rolle)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- PROBLEM: En ikke-superadmin (f.eks. ksk@cenika.no i Cenika AS) ser kun seg
-- selv i medlemslista, ikke andre i samme org.
--
-- ROTARSAK:
--   - organization_members SELECT-policy = using (user_id = auth.uid())  -> kun egen rad
--   - profiles SELECT-policy            = using (auth.uid() = id)        -> kun egen profil
--   Appen leser organization_members filtrert pa org_id, og henter e-post via en
--   innleiret profiles-join. Begge policyene ma utvides.
--
-- LOSNING: SECURITY DEFINER-hjelpefunksjon user_org_ids() (bypasser RLS -> ingen
--   rekursjon nar policyen ligger PA organization_members). Utvid SELECT pa begge
--   tabeller til "medlemmer i mine orgs". Skrive-policyer rores IKKE.
-- ============================================================================

-- --- 1. HJELPEFUNKSJON: org-id-ene til innlogget bruker (RLS-safe) -----------
-- SECURITY DEFINER => kjorer som funksjons-eier => bypasser RLS pa
-- organization_members => unngar uendelig rekursjon (42P17) nar funksjonen
-- brukes inne i en policy PA samme tabell.
create or replace function public.user_org_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select org_id from public.organization_members where user_id = auth.uid()
$$;

revoke all on function public.user_org_ids() from public;
grant execute on function public.user_org_ids() to authenticated;

-- --- 2. organization_members: se ALLE rader i mine orgs ----------------------
-- Erstatter "kun egen rad". Superadmin-policyen ("Superadmin full tilgang
-- members", for all) beholdes uendret. Skrive-tilgang er uendret (kun
-- superadmin har en eksplisitt skrive-policy; owner/admin-skriving gar via
-- app-logikk slik som i dag).
drop policy if exists "Medlemmer ser egne medlemskap" on organization_members;
drop policy if exists "Medlemmer ser medlemmer i egne orgs" on organization_members;
create policy "Medlemmer ser medlemmer i egne orgs" on organization_members
  for select using (org_id in (select user_org_ids()));

-- --- 3. profiles: se profiler til medlemmer i samme org ----------------------
-- Additiv SELECT-policy (permissive policyer OR-es). "Bruker ser egen profil"
-- og "Superadmin full tilgang profiler" beholdes. Ingen tverr-org-lekkasje:
-- kun profiler hvis user_id er medlem i en av MINE orgs.
drop policy if exists "Medlem ser profiler i egne orgs" on profiles;
create policy "Medlem ser profiler i egne orgs" on profiles
  for select using (
    id in (
      select om.user_id
      from organization_members om
      where om.org_id in (select user_org_ids())
    )
  );

-- --- 4. VERIFISER ------------------------------------------------------------
-- Forventet: begge nye policyer aktive (=1), gammel "kun egen rad" borte (=0).
select
  (select count(*) from pg_policies
     where tablename = 'organization_members'
       and policyname = 'Medlemmer ser medlemmer i egne orgs')      as om_ny_policy_aktiv,
  (select count(*) from pg_policies
     where tablename = 'organization_members'
       and policyname = 'Medlemmer ser egne medlemskap')            as om_gammel_skal_vaere_0,
  (select count(*) from pg_policies
     where tablename = 'profiles'
       and policyname = 'Medlem ser profiler i egne orgs')          as profiles_ny_policy_aktiv,
  (select count(*) from pg_proc
     where proname = 'user_org_ids'
       and pronamespace = 'public'::regnamespace)                   as hjelpefunksjon_finnes;

-- ============================================================================
-- ROLLBACK (gjenoppretter "kun egen rad / kun egen profil"):
--   drop policy if exists "Medlemmer ser medlemmer i egne orgs" on organization_members;
--   create policy "Medlemmer ser egne medlemskap" on organization_members
--     for select using (user_id = auth.uid());
--   drop policy if exists "Medlem ser profiler i egne orgs" on profiles;
--   drop function if exists public.user_org_ids();
-- ============================================================================
