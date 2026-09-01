-- ============================================================
-- Arqely — ERP-format per organisasjon («Kopier til Visma»)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- Kopier-til-Visma-knappen (romtegner.html, _copyToVisma) vises kun for organisasjoner med
-- erp_format satt — «ikke hardkod «Cenika»» (spec-visma-paste.md, DEL C). Feltet er en fri
-- streng, ikke en boolsk, slik at en annen grossist kan få sin egen verdi ('visma_paste' er
-- Cenikas — foreløpig eneste kjente format) uten at koden må røres.

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
    WHERE table_name='organizations' AND column_name='erp_format') THEN
    ALTER TABLE organizations ADD COLUMN erp_format text;
    -- NULL = ingen ERP-integrasjon (standard). 'visma_paste' = Cenikas
    -- utklippstavle-format (felt-ID 2269/2270/2281/2274).
  END IF;
END $$;

-- ─── SETT CENIKAS ORG TIL 'visma_paste' ──────────────────────
-- KJØRT 01.09.2026 mot Cenika AS (id 3565ca88-b0c4-4033-97bf-0bc3aec2f763, org_type=supplier —
-- eneste org i databasen på det tidspunktet). Linjen står igjen som dokumentasjon; idempotent å
-- kjøre på nytt.
UPDATE organizations SET erp_format = 'visma_paste' WHERE id = '3565ca88-b0c4-4033-97bf-0bc3aec2f763';

-- ─── VERIFY ───────────────────────────────────────────────────
SELECT id, name, org_type, erp_format FROM organizations ORDER BY name;
