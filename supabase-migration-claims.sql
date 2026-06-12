-- ============================================================================
-- Migration: Reklamasjon - Fase 3
-- Varmeplan / Romtegner
-- Run via Supabase SQL Editor or Management API
--
-- Bygger paa Fase 1/2 (warranty_certificates, suppliers). En reklamasjonssak er
-- knyttet til et garantibevis; maaleverdier + foto fra beviset folger automatisk
-- med via certificate_id. Egne tabeller (ikke i prosjekt-JSON).
-- ============================================================================


-- --- 1. REKLAMASJONSSAK (claims) --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_no text UNIQUE,                       -- f.eks. CEN-2026-0312
  -- Kobling til garantibevis (kilde: maaleverdier + foto):
  certificate_id uuid REFERENCES warranty_certificates(id) ON DELETE SET NULL,
  org_id uuid REFERENCES organizations(id),   -- elektrofirma som meldte (app), eller leverandor (telefon)
  supplier_id uuid REFERENCES suppliers(id),  -- leverandor som eier saken (for portal-tilgang)
  channel text DEFAULT 'app',                 -- 'app' (montor melder) | 'phone' (leverandor registrerer)
  -- Status-flyt:
  status text DEFAULT 'venter_godkjenning',   -- venter_godkjenning | godkjent | avvist | under_arbeid | lukket
  -- Feilbeskrivelse:
  fault_type text,                            -- f.eks. 'kabelbrudd', 'kald-sone', 'jordfeil', 'styring'
  fault_description text,                     -- kundens/montorens beskrivelse
  discovered_at date,
  customer_email text,                        -- mottaker av rutine-e-post
  -- Feilsok paa stedet:
  troubleshoot_resistance_ohm numeric,
  troubleshoot_insulation_mohm numeric,
  recommended_action text,
  troubleshoot_firm text,                     -- feilsokefirma (f.eks. M-Tek)
  est_hours text,
  est_material text,
  -- Kostnad og utfall:
  cost numeric,
  outcome text,                               -- godkjent | delvis | avslatt
  outcome_reason_code text,
  covered_by_warranty boolean,
  -- Sporbarhet:
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  approved_at timestamptz,
  approved_by uuid REFERENCES auth.users(id),
  closed_at timestamptz,
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_claims_cert ON claims(certificate_id);
CREATE INDEX IF NOT EXISTS idx_claims_org ON claims(org_id);
CREATE INDEX IF NOT EXISTS idx_claims_supplier ON claims(supplier_id);
CREATE INDEX IF NOT EXISTS idx_claims_status ON claims(status);

ALTER TABLE claims ENABLE ROW LEVEL SECURITY;

-- Org-medlemmer (elektrofirma som meldte) ser/redigerer egne saker.
DROP POLICY IF EXISTS "Org members manage own claims" ON claims;
CREATE POLICY "Org members manage own claims" ON claims FOR ALL USING (
  org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
);

-- Superadmin: full tilgang (leser is_superadmin fra JWT, ikke auth.users -> 42501).
DROP POLICY IF EXISTS "Superadmin full access claims" ON claims;
CREATE POLICY "Superadmin full access claims" ON claims FOR ALL USING (
  COALESCE((auth.jwt() -> 'app_metadata' ->> 'is_superadmin') = 'true', false)
);

-- Leverandor-org: full tilgang til saker for egne produkter (godkjenning + oppfolging).
DROP POLICY IF EXISTS "Supplier orgs manage their claims" ON claims;
CREATE POLICY "Supplier orgs manage their claims" ON claims FOR ALL USING (
  supplier_id IN (
    SELECT s.id FROM suppliers s
    JOIN organizations o ON o.supplier_name = s.name
    JOIN organization_members om ON om.org_id = o.id
    WHERE om.user_id = auth.uid() AND o.org_type = 'supplier'
  )
);


-- --- 2. HENDELSESLOGG / TIDSLINJE (claim_events) --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS claim_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id uuid REFERENCES claims(id) ON DELETE CASCADE NOT NULL,
  kind text,                                  -- 'meldt' | 'opprettet' | 'godkjent' | 'avvist' | 'arbeid' | 'kostnad' | 'lukket' | 'notat'
  message text,
  actor text,                                 -- hvem/hva (montor, leverandor-saksbehandler, system, feilsokefirma)
  at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_claim_events_claim ON claim_events(claim_id);

ALTER TABLE claim_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Access claim_events via claim" ON claim_events;
CREATE POLICY "Access claim_events via claim" ON claim_events FOR ALL USING (
  claim_id IN (SELECT id FROM claims)
);


-- --- 3. FOTO PAA SAK (claim_photos) --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS claim_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id uuid REFERENCES claims(id) ON DELETE CASCADE NOT NULL,
  slot text,                                  -- 'maaling' | 'feil' | 'reparasjon' | 'annet'
  storage_path text NOT NULL,
  taken_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_claim_photos_claim ON claim_photos(claim_id);

ALTER TABLE claim_photos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Access claim_photos via claim" ON claim_photos;
CREATE POLICY "Access claim_photos via claim" ON claim_photos FOR ALL USING (
  claim_id IN (SELECT id FROM claims)
);


-- --- VERIFISERING --------------------------------------------------------------
SELECT
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'claims') AS has_claims,
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'claim_events') AS has_events,
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'claim_photos') AS has_photos;
