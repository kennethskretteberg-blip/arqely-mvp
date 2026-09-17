-- ============================================================================
-- Migrasjon: Egne initialer pa profilen (profiles.initials)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- Sak 6b (Kenneth 17.09.2026): prosjektlista viser "Prosjektert av" som initialer
-- (automatisk utledet fra fritekst-navnet, f.eks. "Kenneth Skretteberg" -> "KS").
-- Dette feltet lar brukeren sette EGNE initialer (maks 4 tegn) som vinner over de
-- automatiske NAR prosjektets "Prosjektert av"-fritekst er lik brukerens eget navn.
-- STEG 0 (17.09.2026) bekreftet: andre brukeres profiler lastes IKKE i vanlig bruk
-- (kun i _openOrgAdminPanel, gatet til owner/admin/superadmin) - derfor skrives
-- initialene ogsa til auth sin user_metadata (samme muster som full_name allerede
-- bruker), og profiles.initials er kun en sekundaer, egen-lesbar kopi - ingen
-- kryss-bruker-oppslag er bygget pa denne kolonnen.
--
-- RLS er uendret (kun ny kolonne, samme policy som full_name/company_name/phone
-- allerede dekker). Eksisterende rader far initials = NULL.
-- ============================================================================

alter table profiles add column if not exists initials text;

-- --- VERIFISER --------------------------------------------------------------
select
  (select count(*) from information_schema.columns
     where table_name = 'profiles' and column_name = 'initials')   as initials_kolonne_finnes;  -- forventet 1

-- ============================================================================
-- ROLLBACK (hvis nodvendig):
--   alter table profiles drop column if exists initials;
-- ============================================================================
