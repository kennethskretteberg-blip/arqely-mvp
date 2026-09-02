-- ============================================================
-- Arqely — Prosjektnr: unik indeks PER FIRMA (org_id)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-pdf-forside-prosjektnr-og-romoversikt-rekkefolge.md DEL B (Kenneth 02.09.2026):
-- «husk her å lag en indeks slik at alle prosjektene får sin unike id (prosjektnr), meningen
-- skal være at man enkelt kan søke på prosjektnr i varmeplan som er unik».
--
-- Kenneth valgte PER FIRMA (org_id) fremfor én global sekvens — hvert firma får sin egen
-- 1, 2, 3-serie. En vanlig identity-kolonne holder ikke til det (den er global per natur); dette
-- krever en database-trigger som er garantert kollisjonsfri når to brukere i SAMME firma lagrer
-- et NYTT prosjekt samtidig — den atomiske "hent og øk"-oppdateringen (steg 3) gjør nettopp det,
-- via Postgres sin radnivå-låsing på INSERT ... ON CONFLICT ... RETURNING (ett SQL-statement).
--
-- Prosjekter UTEN org_id (ingen firma-tilknytning) samles i en egen "ingen firma"-bøtte via en
-- fast sentinel-UUID (alle nuller), slik at de også får en fortløpende, kollisjonsfri serie seg
-- imellom — vanlig UNIQUE(org_id, project_no) ville IKKE fanget duplikater der (Postgres
-- behandler NULL <> NULL i en unik indeks).

-- ─── 1. KOLONNE ───────────────────────────────────────────────
ALTER TABLE romtegner_projects ADD COLUMN IF NOT EXISTS project_no bigint;

-- ─── 2. TELLER PER FIRMA ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS romtegner_project_counters (
  org_key uuid PRIMARY KEY,
  next_no bigint NOT NULL DEFAULT 1
);
ALTER TABLE romtegner_project_counters ENABLE ROW LEVEL SECURITY;
-- Ingen policies -> ingen rolle har direkte tilgang via PostgREST. Kun SECURITY DEFINER-
-- triggeren under (kjører som tabellens eier, som ikke er underlagt RLS på egne tabeller uten
-- FORCE ROW LEVEL SECURITY) skal noensinne røre denne tabellen.

-- ─── 3. TRIGGER: TILDEL PROSJEKTNR VED INSERT ─────────────────
CREATE OR REPLACE FUNCTION romtegner_assign_project_no()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_org_key uuid := COALESCE(NEW.org_id, '00000000-0000-0000-0000-000000000000'::uuid);
  v_no bigint;
BEGIN
  IF NEW.project_no IS NOT NULL THEN
    RETURN NEW;  -- allerede satt (f.eks. av backfillen under) — ikke overskriv
  END IF;
  INSERT INTO romtegner_project_counters (org_key, next_no)
  VALUES (v_org_key, 2)
  ON CONFLICT (org_key) DO UPDATE SET next_no = romtegner_project_counters.next_no + 1
  RETURNING next_no - 1 INTO v_no;
  NEW.project_no := v_no;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS romtegner_projects_assign_no ON romtegner_projects;
CREATE TRIGGER romtegner_projects_assign_no
  BEFORE INSERT ON romtegner_projects
  FOR EACH ROW EXECUTE FUNCTION romtegner_assign_project_no();

-- ─── 4. UNIK PER FIRMA (ikke globalt) ─────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS romtegner_projects_org_projectno_key
  ON romtegner_projects (COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid), project_no)
  WHERE project_no IS NOT NULL;

-- ─── 5. BACKFILL: eksisterende prosjekter, eldste = nr. 1, PER FIRMA ──
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid)
             ORDER BY created_at ASC
           ) AS rn
    FROM romtegner_projects
    WHERE project_no IS NULL
  ) LOOP
    UPDATE romtegner_projects SET project_no = r.rn WHERE id = r.id;
  END LOOP;
END $$;

-- Sett hvert firmas teller til å fortsette rett etter det backfillede høyeste nummeret, slik at
-- neste ekte INSERT ikke kolliderer med et prosjekt som nettopp fikk et backfillet nummer.
INSERT INTO romtegner_project_counters (org_key, next_no)
SELECT COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid), MAX(project_no) + 1
FROM romtegner_projects
WHERE project_no IS NOT NULL
GROUP BY COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid)
ON CONFLICT (org_key) DO UPDATE
  SET next_no = GREATEST(romtegner_project_counters.next_no, EXCLUDED.next_no);

-- ─── VERIFY ────────────────────────────────────────────────────
SELECT org_id, project_no, name, created_at
FROM romtegner_projects
ORDER BY COALESCE(org_id, '00000000-0000-0000-0000-000000000000'::uuid), project_no;

SELECT * FROM romtegner_project_counters ORDER BY org_key;
