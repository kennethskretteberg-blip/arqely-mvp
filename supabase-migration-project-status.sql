-- MIGRATION: To-akse prosjektstatus (salg + leveranse)
-- Run in Supabase Dashboard -> SQL Editor. Idempotent (kan kjores flere ganger).
--
-- Bakgrunn:
--   Dagens `status`-kolonne (draft/planned/in_progress/ready_quote/completed/archived)
--   blander salg og utforelse. Vi legger til TO nye, uavhengige akser ved siden av den:
--
--   Akse A - sales_status    : hvor i salgstrakten prosjektet er (alle bedrifter).
--   Akse B - delivery_status : hvor i utforelsen jobben er (aktiveres kun ved 'vunnet').
--
--   Den gamle `status`-kolonnen rores IKKE - den blir liggende for bakoverkompatibilitet.
--
-- RLS: INGEN endring. Scope er fortsatt org_id + personlige prosjekter.

-- ==============================================================
-- STEP 1: Legg til de nye kolonnene
-- ==============================================================
ALTER TABLE romtegner_projects
  ADD COLUMN IF NOT EXISTS sales_status text NOT NULL DEFAULT 'under_arbeid'
    CHECK (sales_status IN ('under_arbeid','tilbud_sendt','vunnet','tapt')),
  ADD COLUMN IF NOT EXISTS delivery_status text
    CHECK (delivery_status IN
      ('klar_for_montering','under_montering','montert_venter_dok',
       'klar_for_levering','levert','ferdig')),
  ADD COLUMN IF NOT EXISTS lost_reason text,
  ADD COLUMN IF NOT EXISTS status_changed_at timestamptz DEFAULT now();

-- ==============================================================
-- STEP 2: Delvis indeks for de aktive listene (hopper over 'tapt')
-- ==============================================================
CREATE INDEX IF NOT EXISTS romtegner_projects_active_idx
  ON romtegner_projects (org_id, sales_status)
  WHERE sales_status <> 'tapt';

-- ==============================================================
-- STEP 3: Backfill - alle eksisterende rader til trygt startpunkt
-- ==============================================================
-- Kolonnen har allerede default 'under_arbeid', men eldre rader kan ha NULL
-- dersom kolonnen ble lagt til uten default i en tidligere delkjoring.
UPDATE romtegner_projects
   SET sales_status = 'under_arbeid'
 WHERE sales_status IS NULL;

-- Rader med signert garantibevis -> vunnet + ferdig (utledet der det lar seg gjore).
-- Kjores kun hvis warranty_certificates finnes (dokumentasjonsmodulen er tatt i bruk).
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'warranty_certificates'
  ) THEN
    UPDATE romtegner_projects p
       SET sales_status    = 'vunnet',
           delivery_status = 'ferdig'
     WHERE EXISTS (
       SELECT 1 FROM warranty_certificates wc
       WHERE wc.project_id = p.id
         AND wc.status = 'signed'
     );
  END IF;
END $$;

-- ==============================================================
-- STEP 4: Verifiser
-- ==============================================================
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'romtegner_projects'
  AND column_name IN ('sales_status','delivery_status','lost_reason','status_changed_at')
ORDER BY column_name;

SELECT sales_status, delivery_status, count(*)
FROM romtegner_projects
GROUP BY sales_status, delivery_status
ORDER BY sales_status, delivery_status;
