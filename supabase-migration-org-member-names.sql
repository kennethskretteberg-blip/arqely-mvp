-- ============================================================================
-- Migrasjon 062: org_member_names() - kolonne-last oppslag av KOLLEGERS navn
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- BAKGRUNN (062, Kenneth 12.10.2026): Â"Prosjektert avÂ" kan settes til en kollega i
-- Kunde & prosjektinfo. Da skal initialene i PDF-filnavnet vaere KOLLEGAENS egne
-- profil-initialer (profiles.initials), ikke initialer regnet av fritekst-navnet
-- (Â"Fredrik HansenÂ" -> FH, selv om profilen hans sier FHA).
--
-- STEG 0.1 (malt 12.10.2026): basis-RLS pa profiles er
--     "Bruker ser egen profil"          for select using (auth.uid() = id)
--     "Superadmin full tilgang profiler" for all   using (is_superadmin())
-- dvs. en vanlig org-bruker ser KUN sin egen profil. (Migrasjonen
-- supabase-migration-org-member-visibility.sql legger til en bredere policy
-- "Medlem ser profiler i egne orgs" som gir ALLE kolonner for medlemmer i egne
-- orgs - men den gir mer enn 062 trenger, og vi kan ikke anta at den er kjort.)
--
-- LOSNING: en security definer-funksjon som returnerer NOYAKTIG tre kolonner -
-- user_id, full_name, initials - for medlemmer i samme org som auth.uid().
-- Ingen e-post, ingen roller, ingen prefs. Fungerer uavhengig av om
-- org-member-visibility-migrasjonen er kjort.
--
-- MERK (STEG 0, malt): organization_members har kolonnene (org_id, user_id, role)
-- - det finnes INGEN status-kolonne. 062-prompten ba om Â"bare status = 'active'Â";
-- i dette skjemaet ER en medlemsrad aktivt medlemskap (fjerning er en DELETE, se
-- _removeOrgMember i index.html). Filteret er derfor utelatt med vilje.
-- ============================================================================

create or replace function public.org_member_names()
returns table (user_id uuid, full_name text, initials text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.full_name, p.initials
  from public.profiles p
  where p.id in (
    select mine.user_id
    from public.organization_members mine
    where mine.org_id in (
      select om.org_id
      from public.organization_members om
      where om.user_id = auth.uid()
    )
  )
$$;

revoke all on function public.org_member_names() from public;
revoke all on function public.org_member_names() from anon;
grant execute on function public.org_member_names() to authenticated;

-- --- VERIFISER --------------------------------------------------------------
-- Forventet: funksjonen finnes (=1) og er security definer (=true).
select
  (select count(*) from pg_proc
     where proname = 'org_member_names'
       and pronamespace = 'public'::regnamespace)                 as funksjon_finnes,
  (select prosecdef from pg_proc
     where proname = 'org_member_names'
       and pronamespace = 'public'::regnamespace)                 as er_security_definer;

-- Kjor som innlogget bruker (f.eks. via appen) for a se egne org-medlemmer:
--   select * from org_member_names();

-- ============================================================================
-- ROLLBACK:
--   drop function if exists public.org_member_names();
-- ============================================================================
