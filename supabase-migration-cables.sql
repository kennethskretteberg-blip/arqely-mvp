-- =============================================================================
-- Supabase Migration: Cenika Varmekabler Import
-- Kjor dette i Supabase SQL Editor (https://supabase.com/dashboard)
-- Dato: 2026-03-10
-- =============================================================================

-- ─── STEG 0: Gjor folie-spesifikke kolonner nullable (kabler har ikke bredde) ─

ALTER TABLE heating_products ALTER COLUMN width_mm DROP NOT NULL;
ALTER TABLE heating_products ALTER COLUMN netto_width_mm DROP NOT NULL;
ALTER TABLE heating_products ALTER COLUMN brutto_width_mm DROP NOT NULL;
ALTER TABLE heating_products ALTER COLUMN watt_per_lm DROP NOT NULL;

-- ─── STEG 1: Nye kolonner pa heating_products ─────────────────────────────────

ALTER TABLE heating_products
  ADD COLUMN IF NOT EXISTS supplier TEXT,
  ADD COLUMN IF NOT EXISTS product_family TEXT,
  ADD COLUMN IF NOT EXISTS usage_area TEXT DEFAULT 'both',
  ADD COLUMN IF NOT EXISTS watt_per_m DECIMAL,
  ADD COLUMN IF NOT EXISTS cable_length_m DECIMAL,
  ADD COLUMN IF NOT EXISTS total_effect_w INTEGER,
  ADD COLUMN IF NOT EXISTS resistance_ohm DECIMAL,
  ADD COLUMN IF NOT EXISTS cable_diameter_mm DECIMAL,
  ADD COLUMN IF NOT EXISTS cold_cable_length_m DECIMAL,
  ADD COLUMN IF NOT EXISTS min_spacing_mm INTEGER,
  ADD COLUMN IF NOT EXISTS max_spacing_mm INTEGER,
  ADD COLUMN IF NOT EXISTS recommended_spacing_mm INTEGER,
  ADD COLUMN IF NOT EXISTS min_bend_radius_mm INTEGER,
  ADD COLUMN IF NOT EXISTS max_length_m INTEGER,
  ADD COLUMN IF NOT EXISTS min_obstacle_distance_mm INTEGER DEFAULT 50,
  ADD COLUMN IF NOT EXISTS min_drain_distance_mm INTEGER DEFAULT 100;

-- ─── STEG 2: Oppdater eksisterende folie-produkter med leverandor-info ────────

UPDATE heating_products
SET supplier = 'Cenika AS',
    product_family = 'FlexFoil 60W',
    usage_area = 'indoor'
WHERE category_id = 1 AND supplier IS NULL;

-- ─── STEG 3: Sikre at Varmekabel-kategori finnes ──────────────────────────────

INSERT INTO product_categories (id, name, module_type, sort_order, active)
VALUES (2, 'Varmekabel', 'cable', 20, true)
ON CONFLICT (id) DO UPDATE SET module_type = 'cable', active = true;

-- ─── STEG 4: Import Cenika InFloor 17T (25 varianter) ─────────────────────────
-- Kilde: CVA_InFloor17T_produktblad.pdf (02/2023)
-- Felles regler (fra installasjonsveiledning):
--   Min CC-avstand: 50mm | Min veggavstand: 50mm | Min boyeradius: 32mm
--   Min hindring-avstand: 50mm | Min sluk-avstand: 100mm
--   Kabeldiameter: 5.3mm | Kaldkabel: 4m | IP: IPX7

INSERT INTO heating_products (
  category_id, name, article_no, active, sort_order,
  supplier, product_family, usage_area,
  watt_per_m, total_effect_w, cable_length_m, resistance_ohm,
  cable_diameter_mm, cold_cable_length_m,
  min_spacing_mm, max_spacing_mm, recommended_spacing_mm,
  min_bend_radius_mm, max_length_m,
  min_gap_mm, min_wall_margin_mm, min_obstacle_distance_mm, min_drain_distance_mm
) VALUES
  (2, 'InFloor 17T 120W 7m',    'CVA10090', true, 101, 'Cenika AS', 'InFloor 17T', 'both', 17, 120,   7,   441, 5.3, 4, 50, 200, 100, 32,   7, 10, 50, 50, 100),
  (2, 'InFloor 17T 170W 10m',   'CVA10050', true, 102, 'Cenika AS', 'InFloor 17T', 'both', 17, 170,  10,   311, 5.3, 4, 50, 200, 100, 32,  10, 10, 50, 50, 100),
  (2, 'InFloor 17T 250W 15m',   'CVA10051', true, 103, 'Cenika AS', 'InFloor 17T', 'both', 17, 250,  15,   211, 5.3, 4, 50, 200, 100, 32,  15, 10, 50, 50, 100),
  (2, 'InFloor 17T 300W 18m',   'CVA10091', true, 104, 'Cenika AS', 'InFloor 17T', 'both', 17, 300,  18,   176, 5.3, 4, 50, 200, 100, 32,  18, 10, 50, 50, 100),
  (2, 'InFloor 17T 350W 21m',   'CVA10052', true, 105, 'Cenika AS', 'InFloor 17T', 'both', 17, 350,  21,   151, 5.3, 4, 50, 200, 100, 32,  21, 10, 50, 50, 100),
  (2, 'InFloor 17T 400W 23.5m', 'CVA10092', true, 106, 'Cenika AS', 'InFloor 17T', 'both', 17, 400,  23.5, 132, 5.3, 4, 50, 200, 100, 32,  23, 10, 50, 50, 100),
  (2, 'InFloor 17T 450W 27m',   'CVA10053', true, 107, 'Cenika AS', 'InFloor 17T', 'both', 17, 450,  27,   118, 5.3, 4, 50, 200, 100, 32,  27, 10, 50, 50, 100),
  (2, 'InFloor 17T 500W 29m',   'CVA10054', true, 108, 'Cenika AS', 'InFloor 17T', 'both', 17, 500,  29,   106, 5.3, 4, 50, 200, 100, 32,  29, 10, 50, 50, 100),
  (2, 'InFloor 17T 600W 35m',   'CVA10055', true, 109, 'Cenika AS', 'InFloor 17T', 'both', 17, 600,  35,    88, 5.3, 4, 50, 200, 100, 32,  35, 10, 50, 50, 100),
  (2, 'InFloor 17T 700W 41m',   'CVA10056', true, 110, 'Cenika AS', 'InFloor 17T', 'both', 17, 700,  41,    76, 5.3, 4, 50, 200, 100, 32,  41, 10, 50, 50, 100),
  (2, 'InFloor 17T 800W 47m',   'CVA10057', true, 111, 'Cenika AS', 'InFloor 17T', 'both', 17, 800,  47,    66, 5.3, 4, 50, 200, 100, 32,  47, 10, 50, 50, 100),
  (2, 'InFloor 17T 900W 54m',   'CVA10058', true, 112, 'Cenika AS', 'InFloor 17T', 'both', 17, 900,  54,    59, 5.3, 4, 50, 200, 100, 32,  54, 10, 50, 50, 100),
  (2, 'InFloor 17T 1000W 59m',  'CVA10059', true, 113, 'Cenika AS', 'InFloor 17T', 'both', 17, 1000, 59,    53, 5.3, 4, 50, 200, 100, 32,  59, 10, 50, 50, 100),
  (2, 'InFloor 17T 1100W 65m',  'CVA10060', true, 114, 'Cenika AS', 'InFloor 17T', 'both', 17, 1100, 65,    48, 5.3, 4, 50, 200, 100, 32,  65, 10, 50, 50, 100),
  (2, 'InFloor 17T 1200W 70.5m','CVA10093', true, 115, 'Cenika AS', 'InFloor 17T', 'both', 17, 1200, 70.5,  44, 5.3, 4, 50, 200, 100, 32,  70, 10, 50, 50, 100),
  (2, 'InFloor 17T 1350W 79m',  'CVA10061', true, 116, 'Cenika AS', 'InFloor 17T', 'both', 17, 1350, 79,    39, 5.3, 4, 50, 200, 100, 32,  79, 10, 50, 50, 100),
  (2, 'InFloor 17T 1450W 84m',  'CVA10062', true, 117, 'Cenika AS', 'InFloor 17T', 'both', 17, 1450, 84,    36, 5.3, 4, 50, 200, 100, 32,  84, 10, 50, 50, 100),
  (2, 'InFloor 17T 1650W 96m',  'CVA10063', true, 118, 'Cenika AS', 'InFloor 17T', 'both', 17, 1650, 96,    32, 5.3, 4, 50, 200, 100, 32,  96, 10, 50, 50, 100),
  (2, 'InFloor 17T 1900W 112m', 'CVA10064', true, 119, 'Cenika AS', 'InFloor 17T', 'both', 17, 1900, 112,   28, 5.3, 4, 50, 200, 100, 32, 112, 10, 50, 50, 100),
  (2, 'InFloor 17T 2150W 126m', 'CVA10094', true, 120, 'Cenika AS', 'InFloor 17T', 'both', 17, 2150, 126,   25, 5.3, 4, 50, 200, 100, 32, 126, 10, 50, 50, 100),
  (2, 'InFloor 17T 2400W 141m', 'CVA10065', true, 121, 'Cenika AS', 'InFloor 17T', 'both', 17, 2400, 141,   22, 5.3, 4, 50, 200, 100, 32, 141, 10, 50, 50, 100),
  (2, 'InFloor 17T 2650W 155m', 'CVA10066', true, 122, 'Cenika AS', 'InFloor 17T', 'both', 17, 2650, 155,   20, 5.3, 4, 50, 200, 100, 32, 155, 10, 50, 50, 100),
  (2, 'InFloor 17T 2900W 170m', 'CVA10067', true, 123, 'Cenika AS', 'InFloor 17T', 'both', 17, 2900, 170,   18, 5.3, 4, 50, 200, 100, 32, 170, 10, 50, 50, 100),
  (2, 'InFloor 17T 3100W 183m', 'CVA10068', true, 124, 'Cenika AS', 'InFloor 17T', 'both', 17, 3100, 183,   17, 5.3, 4, 50, 200, 100, 32, 183, 10, 50, 50, 100),
  (2, 'InFloor 17T 3400W 200m', 'CVA10069', true, 125, 'Cenika AS', 'InFloor 17T', 'both', 17, 3400, 200,   16, 5.3, 4, 50, 200, 100, 32, 200, 10, 50, 50, 100)
ON CONFLICT (article_no) DO UPDATE SET
  name = EXCLUDED.name,
  supplier = EXCLUDED.supplier,
  product_family = EXCLUDED.product_family,
  usage_area = EXCLUDED.usage_area,
  watt_per_m = EXCLUDED.watt_per_m,
  total_effect_w = EXCLUDED.total_effect_w,
  cable_length_m = EXCLUDED.cable_length_m,
  resistance_ohm = EXCLUDED.resistance_ohm,
  cable_diameter_mm = EXCLUDED.cable_diameter_mm,
  cold_cable_length_m = EXCLUDED.cold_cable_length_m,
  min_spacing_mm = EXCLUDED.min_spacing_mm,
  max_spacing_mm = EXCLUDED.max_spacing_mm,
  recommended_spacing_mm = EXCLUDED.recommended_spacing_mm,
  min_bend_radius_mm = EXCLUDED.min_bend_radius_mm,
  max_length_m = EXCLUDED.max_length_m,
  min_gap_mm = EXCLUDED.min_gap_mm,
  min_wall_margin_mm = EXCLUDED.min_wall_margin_mm,
  min_obstacle_distance_mm = EXCLUDED.min_obstacle_distance_mm,
  min_drain_distance_mm = EXCLUDED.min_drain_distance_mm,
  active = EXCLUDED.active;

-- ─── STEG 5: Import Cenika InFloor 10T (19 varianter) ─────────────────────────
-- Kilde: CVA_InFloor10T_produktblad.pdf (12/2023)
-- Samme regler som 17T. InFloor 10T har El.nummer.

INSERT INTO heating_products (
  category_id, name, article_no, el_no, active, sort_order,
  supplier, product_family, usage_area,
  watt_per_m, total_effect_w, cable_length_m, resistance_ohm,
  cable_diameter_mm, cold_cable_length_m,
  min_spacing_mm, max_spacing_mm, recommended_spacing_mm,
  min_bend_radius_mm, max_length_m,
  min_gap_mm, min_wall_margin_mm, min_obstacle_distance_mm, min_drain_distance_mm
) VALUES
  (2, 'InFloor 10T 100W 10m',   'CVA10070', '1008355', true, 201, 'Cenika AS', 'InFloor 10T', 'both', 10, 100,  10,  529,   5.3, 4, 50, 200, 100, 32,  10, 10, 50, 50, 100),
  (2, 'InFloor 10T 200W 20m',   'CVA10071', '1008356', true, 202, 'Cenika AS', 'InFloor 10T', 'both', 10, 200,  20,  265,   5.3, 4, 50, 200, 100, 32,  20, 10, 50, 50, 100),
  (2, 'InFloor 10T 300W 30m',   'CVA10072', '1008357', true, 203, 'Cenika AS', 'InFloor 10T', 'both', 10, 300,  30,  176,   5.3, 4, 50, 200, 100, 32,  30, 10, 50, 50, 100),
  (2, 'InFloor 10T 400W 40m',   'CVA10073', '1008358', true, 204, 'Cenika AS', 'InFloor 10T', 'both', 10, 400,  40,  132,   5.3, 4, 50, 200, 100, 32,  40, 10, 50, 50, 100),
  (2, 'InFloor 10T 500W 50m',   'CVA10074', '1008359', true, 205, 'Cenika AS', 'InFloor 10T', 'both', 10, 500,  50,  106,   5.3, 4, 50, 200, 100, 32,  50, 10, 50, 50, 100),
  (2, 'InFloor 10T 600W 60m',   'CVA10075', '1008360', true, 206, 'Cenika AS', 'InFloor 10T', 'both', 10, 600,  60,   88,   5.3, 4, 50, 200, 100, 32,  60, 10, 50, 50, 100),
  (2, 'InFloor 10T 700W 70m',   'CVA10076', '1008361', true, 207, 'Cenika AS', 'InFloor 10T', 'both', 10, 700,  70,   76,   5.3, 4, 50, 200, 100, 32,  70, 10, 50, 50, 100),
  (2, 'InFloor 10T 800W 80m',   'CVA10077', '1008362', true, 208, 'Cenika AS', 'InFloor 10T', 'both', 10, 800,  80,   66,   5.3, 4, 50, 200, 100, 32,  80, 10, 50, 50, 100),
  (2, 'InFloor 10T 900W 90m',   'CVA10078', '1008363', true, 209, 'Cenika AS', 'InFloor 10T', 'both', 10, 900,  90,   59,   5.3, 4, 50, 200, 100, 32,  90, 10, 50, 50, 100),
  (2, 'InFloor 10T 1000W 100m', 'CVA10079', '1008364', true, 210, 'Cenika AS', 'InFloor 10T', 'both', 10, 1000, 100,  53,   5.3, 4, 50, 200, 100, 32, 100, 10, 50, 50, 100),
  (2, 'InFloor 10T 1100W 110m', 'CVA10080', '1008365', true, 211, 'Cenika AS', 'InFloor 10T', 'both', 10, 1100, 110,  48,   5.3, 4, 50, 200, 100, 32, 110, 10, 50, 50, 100),
  (2, 'InFloor 10T 1200W 120m', 'CVA10081', '1008366', true, 212, 'Cenika AS', 'InFloor 10T', 'both', 10, 1200, 120,  44,   5.3, 4, 50, 200, 100, 32, 120, 10, 50, 50, 100),
  (2, 'InFloor 10T 1300W 130m', 'CVA10082', '1008367', true, 213, 'Cenika AS', 'InFloor 10T', 'both', 10, 1300, 130,  41,   5.3, 4, 50, 200, 100, 32, 130, 10, 50, 50, 100),
  (2, 'InFloor 10T 1400W 140m', 'CVA10083', '1008368', true, 214, 'Cenika AS', 'InFloor 10T', 'both', 10, 1400, 140,  38,   5.3, 4, 50, 200, 100, 32, 140, 10, 50, 50, 100),
  (2, 'InFloor 10T 1500W 150m', 'CVA10084', '1008369', true, 215, 'Cenika AS', 'InFloor 10T', 'both', 10, 1500, 150,  35,   5.3, 4, 50, 200, 100, 32, 150, 10, 50, 50, 100),
  (2, 'InFloor 10T 1600W 160m', 'CVA10085', '1008370', true, 216, 'Cenika AS', 'InFloor 10T', 'both', 10, 1600, 160,  33,   5.3, 4, 50, 200, 100, 32, 160, 10, 50, 50, 100),
  (2, 'InFloor 10T 1700W 170m', 'CVA10086', '1008371', true, 217, 'Cenika AS', 'InFloor 10T', 'both', 10, 1700, 170,  31,   5.3, 4, 50, 200, 100, 32, 170, 10, 50, 50, 100),
  (2, 'InFloor 10T 1800W 180m', 'CVA10087', '1008372', true, 218, 'Cenika AS', 'InFloor 10T', 'both', 10, 1800, 180,  29,   5.3, 4, 50, 200, 100, 32, 180, 10, 50, 50, 100),
  (2, 'InFloor 10T 2000W 200m', 'CVA10088', '1008373', true, 219, 'Cenika AS', 'InFloor 10T', 'both', 10, 2000, 200,  26.5, 5.3, 4, 50, 200, 100, 32, 200, 10, 50, 50, 100)
ON CONFLICT (article_no) DO UPDATE SET
  name = EXCLUDED.name,
  el_no = EXCLUDED.el_no,
  supplier = EXCLUDED.supplier,
  product_family = EXCLUDED.product_family,
  usage_area = EXCLUDED.usage_area,
  watt_per_m = EXCLUDED.watt_per_m,
  total_effect_w = EXCLUDED.total_effect_w,
  cable_length_m = EXCLUDED.cable_length_m,
  resistance_ohm = EXCLUDED.resistance_ohm,
  cable_diameter_mm = EXCLUDED.cable_diameter_mm,
  cold_cable_length_m = EXCLUDED.cold_cable_length_m,
  min_spacing_mm = EXCLUDED.min_spacing_mm,
  max_spacing_mm = EXCLUDED.max_spacing_mm,
  recommended_spacing_mm = EXCLUDED.recommended_spacing_mm,
  min_bend_radius_mm = EXCLUDED.min_bend_radius_mm,
  max_length_m = EXCLUDED.max_length_m,
  min_gap_mm = EXCLUDED.min_gap_mm,
  min_wall_margin_mm = EXCLUDED.min_wall_margin_mm,
  min_obstacle_distance_mm = EXCLUDED.min_obstacle_distance_mm,
  min_drain_distance_mm = EXCLUDED.min_drain_distance_mm,
  active = EXCLUDED.active;

-- ─── Verifiser ─────────────────────────────────────────────────────────────────

SELECT product_family, COUNT(*) as antall,
       MIN(total_effect_w) || 'W - ' || MAX(total_effect_w) || 'W' as effekt_range,
       MIN(cable_length_m) || 'm - ' || MAX(cable_length_m) || 'm' as lengde_range
FROM heating_products
WHERE supplier = 'Cenika AS' AND category_id = 2
GROUP BY product_family
ORDER BY product_family;
