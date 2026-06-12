-- 
-- Migration: Dokumentasjon & garantiportal - Fase 0 + Fase 1 (MVP)
-- Varmeplan / Romtegner
-- Run via Supabase SQL Editor or Management API
--
-- Bygger oppa eksisterende: organizations, organization_members, profiles,
-- romtegner_projects, heating_products. Ingenting eksisterende fjernes.
-- 


-- --- 1. LEVERANDOR (suppliers) ------------------------------------------------------------
-- Leverandor er data, ikke merkevare. Cenika er forste (og forelopig eneste) rad,
-- seedet fra dagens katalog. OS Varme m.fl. blir senere bare en ny rad.

CREATE TABLE IF NOT EXISTS suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,                 -- matcher heating_products.supplier, f.eks. 'Cenika AS'
  display_name text,                         -- vises i UI, f.eks. 'Cenika'
  color text,                                -- merkefarge for white-label, f.eks. '#E8742C'
  garanti_id_prefix text,                    -- f.eks. 'CEN' -> CEN-2026-04471
  recipient_email text,                      -- mottaker av garantibevis-kopi
  -- Maleregler (data, ikke hardkodet):
  resistance_tolerance_pct numeric DEFAULT 10,   -- resistans innenfor +/-X % av nominell
  insulation_min_mohm numeric DEFAULT 10,        -- isolasjon > X Mohm
  insulation_min_volt numeric DEFAULT 500,       -- ved min. X V
  schema_template jsonb,                     -- valgfri skjema-mal (felt/tekst) - fremtidig
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;

-- Leverandor-katalogen er referansedata: alle innloggede kan lese.
DROP POLICY IF EXISTS "Authenticated read suppliers" ON suppliers;
CREATE POLICY "Authenticated read suppliers" ON suppliers FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Kun superadmin skriver. Leser is_superadmin fra JWT (ikke auth.users-tabellen,
-- som authenticated-rollen ikke har lesetilgang til -> 42501 permission denied).
DROP POLICY IF EXISTS "Superadmin write suppliers" ON suppliers;
CREATE POLICY "Superadmin write suppliers" ON suppliers FOR ALL USING (
  COALESCE((auth.jwt() -> 'app_metadata' ->> 'is_superadmin') = 'true', false)
);

-- Seed Cenika fra eksisterende katalog (idempotent).
INSERT INTO suppliers (name, display_name, color, garanti_id_prefix, recipient_email,
                       resistance_tolerance_pct, insulation_min_mohm, insulation_min_volt)
VALUES ('Cenika AS', 'Cenika', '#E8742C', 'CEN', 'garanti@cenika.no', 10, 10, 500)
ON CONFLICT (name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  color = EXCLUDED.color,
  garanti_id_prefix = EXCLUDED.garanti_id_prefix,
  recipient_email = EXCLUDED.recipient_email;


-- --- 2. KOBLE KATALOG TIL LEVERANDOR (FK) ------------------------------------------------------------
-- heating_products.supplier (text) finnes fra for. Legg til ekte FK supplier_id
-- og backfill ved a matche pa navn.

ALTER TABLE heating_products
  ADD COLUMN IF NOT EXISTS supplier_id uuid REFERENCES suppliers(id);

UPDATE heating_products hp
SET supplier_id = s.id
FROM suppliers s
WHERE hp.supplier = s.name AND hp.supplier_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_heating_products_supplier_id ON heating_products(supplier_id);


-- --- 3. GARANTIBEVIS (warranty_certificates) ------------------------------------------------------------
-- Ett bevis per rom, samler alle produktene i rommet. Lagres som egen tabell
-- (ikke i prosjekt-JSON) slik at portalen kan soke pa tvers av prosjekter.
-- Peker til prosjekt/rom, men beholder snapshot-felt sa beviset overlever
-- selv om prosjektet endres/slettes.

CREATE TABLE IF NOT EXISTS warranty_certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid REFERENCES organizations(id) NOT NULL,
  supplier_id uuid REFERENCES suppliers(id),
  -- Kobling til kilde (tegnet varme):
  project_id uuid REFERENCES romtegner_projects(id) ON DELETE SET NULL,
  project_name text,                         -- snapshot
  project_address text,                      -- snapshot
  room_ref integer,                          -- numerisk rom-id i S.rooms
  room_name text,                            -- snapshot
  -- Status & identitet:
  status text DEFAULT 'draft',               -- 'draft' | 'signed'
  garanti_id text,                           -- f.eks. CEN-2026-04471
  -- Installasjon & styring:
  install_type text,                         -- innendors-gulv | innendors-vegg | utendors-sno
  install_underlag text,                     -- avrettingsmasse | flislim | pastop
  overdekning_material text,
  overdekning_mm numeric,
  jording text,                              -- skjerm-jord | separat-jordleder
  styring_type text,                         -- termostat-gulvfoler | termostat-kombifoler | sentral
  styring_modell text,
  -- Sjekkliste (jsonb: {key: bool}):
  checklist jsonb DEFAULT '{}'::jsonb,
  -- Montor / signatur:
  installer_name text,
  installer_company text,
  installer_orgno text,
  signature_path text,                       -- storage-sti til signatur-bilde
  signed_at timestamptz,
  -- Deling med huseier:
  share_token text UNIQUE,
  -- Sporbarhet:
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_warranty_certificates_org ON warranty_certificates(org_id);
CREATE INDEX IF NOT EXISTS idx_warranty_certificates_project ON warranty_certificates(project_id);
CREATE INDEX IF NOT EXISTS idx_warranty_certificates_supplier ON warranty_certificates(supplier_id);

ALTER TABLE warranty_certificates ENABLE ROW LEVEL SECURITY;

-- Org-medlemmer ser/redigerer egne bevis.
DROP POLICY IF EXISTS "Org members manage own certificates" ON warranty_certificates;
CREATE POLICY "Org members manage own certificates" ON warranty_certificates FOR ALL USING (
  org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
);

-- Superadmin: full tilgang (leser is_superadmin fra JWT, ikke auth.users-tabellen).
DROP POLICY IF EXISTS "Superadmin full access certificates" ON warranty_certificates;
CREATE POLICY "Superadmin full access certificates" ON warranty_certificates FOR ALL USING (
  COALESCE((auth.jwt() -> 'app_metadata' ->> 'is_superadmin') = 'true', false)
);

-- Leverandor-rolle (Fase 2): supplier-org ser bevis der egne produkter er montert.
-- Matcher org.supplier_name -> suppliers.name -> certificate.supplier_id.
DROP POLICY IF EXISTS "Supplier orgs read their certificates" ON warranty_certificates;
CREATE POLICY "Supplier orgs read their certificates" ON warranty_certificates FOR SELECT USING (
  supplier_id IN (
    SELECT s.id FROM suppliers s
    JOIN organizations o ON o.supplier_name = s.name
    JOIN organization_members om ON om.org_id = o.id
    WHERE om.user_id = auth.uid() AND o.org_type = 'supplier'
  )
);


-- --- 4. PRODUKT PA BEVIS (certificate_products) ------------------------------------------------------------
-- 1..n produkter per bevis (rom kan ha flere kabler / folie i ulike bredder).

CREATE TABLE IF NOT EXISTS certificate_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES warranty_certificates(id) ON DELETE CASCADE NOT NULL,
  product_id integer REFERENCES heating_products(id),   -- heating_products.id er integer
  product_name text,                         -- snapshot
  kind text,                                 -- 'cable' | 'foil'
  -- Kabel:
  meters numeric,                            -- antall meter
  -- Folie:
  width_m numeric,
  length_m numeric,
  -- Felles elektrisk:
  volt numeric DEFAULT 230,
  effect_w numeric,                          -- beregnet/hentet effekt
  nominal_ohm numeric,                       -- R = U2 / P
  source_ref text,                           -- valgfri ref til strip/cable-id i tegningen
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_certificate_products_cert ON certificate_products(certificate_id);

ALTER TABLE certificate_products ENABLE ROW LEVEL SECURITY;

-- Tilgang arves fra forelder-beviset.
DROP POLICY IF EXISTS "Access certificate_products via certificate" ON certificate_products;
CREATE POLICY "Access certificate_products via certificate" ON certificate_products FOR ALL USING (
  certificate_id IN (SELECT id FROM warranty_certificates)
);


-- --- 5. MALING (measurements) ------------------------------------------------------------
-- Per produkt, tre stadier: 1=for installasjon, 2=for innstoping, 3=for tilkobling.

CREATE TABLE IF NOT EXISTS measurements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_product_id uuid REFERENCES certificate_products(id) ON DELETE CASCADE NOT NULL,
  stage smallint NOT NULL,                   -- 1 | 2 | 3
  resistance_ohm numeric,
  insulation_mohm numeric,
  ok boolean,                                -- resultat av live-validering (snapshot)
  measured_at timestamptz DEFAULT now(),
  UNIQUE (certificate_product_id, stage)
);

CREATE INDEX IF NOT EXISTS idx_measurements_product ON measurements(certificate_product_id);

ALTER TABLE measurements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Access measurements via certificate" ON measurements;
CREATE POLICY "Access measurements via certificate" ON measurements FOR ALL USING (
  certificate_product_id IN (SELECT id FROM certificate_products)
);


-- --- 6. FOTO (certificate_photos) ------------------------------------------------------------
-- Faste slots: kabel-sloyfe, foler, skjot, termostat, oversikt, annet.

CREATE TABLE IF NOT EXISTS certificate_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id uuid REFERENCES warranty_certificates(id) ON DELETE CASCADE NOT NULL,
  slot text,                                 -- 'kabel-sloyfe' | 'foler' | 'skjot' | 'termostat' | 'oversikt' | 'annet'
  storage_path text NOT NULL,
  taken_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_certificate_photos_cert ON certificate_photos(certificate_id);

ALTER TABLE certificate_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Access certificate_photos via certificate" ON certificate_photos;
CREATE POLICY "Access certificate_photos via certificate" ON certificate_photos FOR ALL USING (
  certificate_id IN (SELECT id FROM warranty_certificates)
);


-- --- 7. STORAGE-BUCKET (foto, signatur, generert PDF) ------------------------------------------------------------
-- Privat bucket; tilgang styres via policyer pa storage.objects.

INSERT INTO storage.buckets (id, name, public)
VALUES ('documentation', 'documentation', false)
ON CONFLICT (id) DO NOTHING;

-- Innloggede kan lese/skrive i documentation-bucketen (RLS pa selve bevisene
-- styrer hvem som ser hva i appen; filstier prefikses med org/cert-id).
DROP POLICY IF EXISTS "Authenticated read documentation" ON storage.objects;
CREATE POLICY "Authenticated read documentation" ON storage.objects FOR SELECT
  USING (bucket_id = 'documentation' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Authenticated write documentation" ON storage.objects;
CREATE POLICY "Authenticated write documentation" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'documentation' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Authenticated update documentation" ON storage.objects;
CREATE POLICY "Authenticated update documentation" ON storage.objects FOR UPDATE
  USING (bucket_id = 'documentation' AND auth.uid() IS NOT NULL);


-- --- VERIFISERING ------------------------------------------------------------
SELECT
  (SELECT count(*) FROM suppliers) AS suppliers_count,
  (SELECT count(*) FROM heating_products WHERE supplier_id IS NOT NULL) AS products_linked,
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'warranty_certificates') AS has_certificates_table;
