-- MIGRATION: Soft-delete / papirkurv (trash bin) for romtegner_projects
-- Run in Supabase Dashboard → SQL Editor.
--
-- Modell:
--   • Soft delete  = UPDATE deleted_at = now()  → alle org-medlemmer kan gjøre dette
--   • Gjenopprett  = UPDATE deleted_at = NULL   → alle org-medlemmer kan gjøre dette
--   • Permanent    = DELETE                     → kun owner/admin (eller superadmin)
--
-- RLS: INGEN endring nødvendig.
--   - Eksisterende UPDATE-policy ("Eier kan oppdatere prosjekter") lar alle
--     org-medlemmer oppdatere → soft delete + restore fungerer.
--   - Eksisterende DELETE-policy ("Eier kan slette prosjekter") begrenser allerede
--     permanent sletting til owner/admin → permanent delete er korrekt beskyttet.

-- ══════════════════════════════════════════════
-- STEP 1: Legg til deleted_at-kolonnen
-- ══════════════════════════════════════════════
ALTER TABLE romtegner_projects
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- ══════════════════════════════════════════════
-- STEP 2: Indeks for raske papirkurv-filtreringer
-- ══════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_romtegner_projects_deleted_at
  ON romtegner_projects (deleted_at);

-- ══════════════════════════════════════════════
-- STEP 3: Verifiser
-- ══════════════════════════════════════════════
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'romtegner_projects' AND column_name = 'deleted_at';
