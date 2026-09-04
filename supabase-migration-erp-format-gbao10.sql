-- ============================================================
-- Arqely — erp_format blir en kommaseparert liste (Cenika far GBAO10 i tillegg)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-visma-eksporter-gbao10-del-a-f.md DEL A (Kenneth 04.09.2026): erp_format var en likhets-
-- sjekk mot EN verdi ('visma_paste'). Cenika skal ha BADE paste og den nye GBAO10-fileksporten.
-- Kolonnen BEHOLDES som text (minst migrering, ingen ALTER COLUMN TYPE) -- verdien blir en
-- kommaseparert liste, lest av _orgHasErpFormat(name) i romtegner.html.

UPDATE organizations
SET erp_format = 'visma_paste,gbao10'
WHERE erp_format = 'visma_paste'
  AND erp_format NOT LIKE '%gbao10%';

-- VERIFY --------------------------------------------------------
SELECT id, name, erp_format
FROM organizations
WHERE erp_format IS NOT NULL;
