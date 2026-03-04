-- ═══════════════════════════════════════════════════════════════
-- Romtegner — Supabase produktoppsett
-- Kjør dette i Supabase Dashboard → SQL Editor → New query
-- ═══════════════════════════════════════════════════════════════

-- 1. Produktkategorier
CREATE TABLE IF NOT EXISTS product_categories (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,          -- "Varmefolie", "Varmekabel"
  description TEXT,
  sort_order  INT DEFAULT 0,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Produkter (artikler per kategori)
CREATE TABLE IF NOT EXISTS heating_products (
  id               SERIAL PRIMARY KEY,
  category_id      INT REFERENCES product_categories(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,       -- "Varmefolie 50 cm"
  article_no       TEXT,               -- Leverandørens artikkelnummer
  width_mm         INT NOT NULL,        -- Bredde i mm (500 = 50 cm)
  cut_interval_mm  INT NOT NULL DEFAULT 200,  -- Kuttes hver X mm
  watt_per_m2      INT,                -- Effekt W/m²
  voltage          INT DEFAULT 230,    -- Volt
  max_length_m     NUMERIC(6,2),       -- Maks lengde per stripe (meter)
  description      TEXT,
  sort_order       INT DEFAULT 0,
  active           BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Indekser
CREATE INDEX IF NOT EXISTS idx_heating_products_category ON heating_products(category_id);
CREATE INDEX IF NOT EXISTS idx_heating_products_active   ON heating_products(active);

-- 4. Row Level Security — kun les (anon), ingen skriv
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE heating_products   ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read categories"
  ON product_categories FOR SELECT
  USING (active = TRUE);

CREATE POLICY "Public read products"
  ON heating_products FOR SELECT
  USING (active = TRUE);

-- 5. Innledende data — Varmefolie
INSERT INTO product_categories (name, description, sort_order) VALUES
  ('Varmefolie', 'Elektrisk varmefolie for gulvoppvarming', 1),
  ('Varmekabel',  'Elektrisk varmekabel for gulvoppvarming', 2);

-- Varmefolie-artikler (category_id = 1)
INSERT INTO heating_products
  (category_id, name, article_no, width_mm, cut_interval_mm, watt_per_m2, max_length_m, sort_order)
VALUES
  (1, 'Varmefolie 50 cm',  'VF-050-60',  500,  200, 60,  12.0, 1),
  (1, 'Varmefolie 100 cm', 'VF-100-60', 1000,  200, 60,  12.0, 2),
  (1, 'Varmefolie 50 cm 120W',  'VF-050-120',  500,  200, 120, 10.0, 3),
  (1, 'Varmefolie 100 cm 120W', 'VF-100-120', 1000,  200, 120, 10.0, 4);

-- Varmekabel-artikler (category_id = 2) — klar for fremtidig bruk
-- INSERT INTO heating_products ... (legg til når klar)
