-- ═══════════════════════════════════════════════════════════════
-- Romtegner — Oppdater heating_products med nye felter
-- Kjør i Supabase Dashboard → SQL Editor → New query
-- ═══════════════════════════════════════════════════════════════

-- Legg til nye kolonner (trygt å kjøre flere ganger)
ALTER TABLE heating_products
  ADD COLUMN IF NOT EXISTS el_no           TEXT,           -- Elnummer
  ADD COLUMN IF NOT EXISTS netto_width_mm  INT,            -- Nettobredde i mm (varmeaktivt areal)
  ADD COLUMN IF NOT EXISTS brutto_width_mm INT,            -- Bruttobredde i mm (inkl. kanter)
  ADD COLUMN IF NOT EXISTS watt_per_lm     NUMERIC(6,2);  -- Watt per løpemeter

-- Migrer eksisterende width_mm → netto_width_mm
UPDATE heating_products
  SET netto_width_mm = width_mm
  WHERE netto_width_mm IS NULL;

-- Oppdater eksisterende testartikler med realistiske verdier
-- (du kan overskrive dette med ekte data via Excel-import)
UPDATE heating_products SET
  netto_width_mm  = 490,
  brutto_width_mm = 500,
  watt_per_lm     = 30
WHERE id = 1;  -- Varmefolie 50 cm 60W

UPDATE heating_products SET
  netto_width_mm  = 990,
  brutto_width_mm = 1000,
  watt_per_lm     = 60
WHERE id = 2;  -- Varmefolie 100 cm 60W

UPDATE heating_products SET
  netto_width_mm  = 490,
  brutto_width_mm = 500,
  watt_per_lm     = 60
WHERE id = 3;  -- Varmefolie 50 cm 120W

UPDATE heating_products SET
  netto_width_mm  = 990,
  brutto_width_mm = 1000,
  watt_per_lm     = 120
WHERE id = 4;  -- Varmefolie 100 cm 120W

-- Legg til RLS-policy for INSERT (kreves for Excel-import fra appen)
-- OBS: Dette tillater alle å skrive — bytt til auth.uid() når du legger til login
CREATE POLICY IF NOT EXISTS "Service insert products"
  ON heating_products FOR INSERT
  WITH CHECK (TRUE);

CREATE POLICY IF NOT EXISTS "Service update products"
  ON heating_products FOR UPDATE
  USING (TRUE);

CREATE POLICY IF NOT EXISTS "Service delete products"
  ON heating_products FOR DELETE
  USING (TRUE);
