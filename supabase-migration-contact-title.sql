-- ============================================================================
-- Migrasjon: Tittel-felt pa kontaktpersoner (contacts.title)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- Legger til en valgfri tittel/rolle (f.eks. "Daglig leder") pa kontaktpersoner.
-- RLS er uendret (kun ny kolonne). Eksisterende rader far title = NULL.
-- ============================================================================

alter table contacts add column if not exists title text;

-- --- VERIFISER --------------------------------------------------------------
select
  (select count(*) from information_schema.columns
     where table_name = 'contacts' and column_name = 'title')   as title_kolonne_finnes;  -- forventet 1

-- ============================================================================
-- ROLLBACK (hvis nodvendig):
--   alter table contacts drop column if exists title;
-- ============================================================================
