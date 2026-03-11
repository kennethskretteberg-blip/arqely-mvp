-- =============================================================================
-- Supabase Migration: Cenika EcoMat Varmematter Import
-- Kjor dette i Supabase SQL Editor (https://supabase.com/dashboard)
-- Dato: 2026-03-11
-- Kilde: CVA_EcoMat60T/100T/150T_produktblad.pdf (05/2025)
--        CVA_EcoMat_installasjonsveiledning.pdf
-- =============================================================================

-- ─── STEG 0: Nye mat-spesifikke kolonner ────────────────────────────────────

ALTER TABLE heating_products
  ADD COLUMN IF NOT EXISTS mat_width_mm INTEGER,
  ADD COLUMN IF NOT EXISTS mat_length_mm INTEGER,
  ADD COLUMN IF NOT EXISTS mat_area_m2 DECIMAL;

-- ─── STEG 1: Sikre at Varmematte-kategori finnes ───────────────────────────

INSERT INTO product_categories (id, name, module_type, sort_order, active)
VALUES (3, 'Varmematte', 'mat', 30, true)
ON CONFLICT (id) DO UPDATE SET module_type = 'mat', name = 'Varmematte', active = true;

-- ─── STEG 2: Import Cenika EcoMat 60T (19 varianter) ───────────────────────
-- 60 W/m² — for stue, soverom, kjokken
-- Bredde: 50cm | Kaldkabel: 4m | Kabeldiameter: 3.2mm | IP: IPX7
-- Kan legges direkte pa brennbart underlag
-- Installasjonsregler:
--   Min veggavstand: 50mm | Min gap mellom matter: 50mm
--   Min hindring-avstand: 50mm | Min sluk-avstand: 100mm

INSERT INTO heating_products (
  category_id, name, article_no, el_no, active, sort_order,
  supplier, product_family, usage_area,
  mat_width_mm, mat_length_mm, mat_area_m2,
  watt_per_m2, total_effect_w, resistance_ohm,
  min_gap_mm, min_wall_margin_mm, min_obstacle_distance_mm, min_drain_distance_mm
) VALUES
  (3, 'EcoMat 60T 0.5×2m',  'CVA10100', '1013743', true, 301, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  2000,  1,   60,   60, 881.67, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×3m',  'CVA10101', '1013744', true, 302, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  3000,  1.5, 60,   90, 587.78, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×4m',  'CVA10102', '1013745', true, 303, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  4000,  2,   60,  120, 440.83, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×5m',  'CVA10103', '1013746', true, 304, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  5000,  2.5, 60,  150, 352.67, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×6m',  'CVA10104', '1013747', true, 305, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  6000,  3,   60,  180, 293.89, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×7m',  'CVA10105', '1013748', true, 306, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  7000,  3.5, 60,  210, 251.90, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×8m',  'CVA10106', '1013749', true, 307, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  8000,  4,   60,  240, 220.42, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×9m',  'CVA10107', '1013750', true, 308, 'Cenika AS', 'EcoMat 60T', 'indoor', 500,  9000,  4.5, 60,  270, 195.93, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×10m', 'CVA10108', '1013751', true, 309, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 10000,  5,   60,  300, 176.33, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×12m', 'CVA10109', '1013752', true, 310, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 12000,  6,   60,  360, 146.94, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×14m', 'CVA10110', '1013753', true, 311, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 14000,  7,   60,  420, 125.95, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×16m', 'CVA10111', '1013754', true, 312, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 16000,  8,   60,  480, 110.21, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×18m', 'CVA10112', '1013755', true, 313, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 18000,  9,   60,  540,  97.96, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×20m', 'CVA10113', '1013756', true, 314, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 20000, 10,   60,  600,  88.17, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×22m', 'CVA10114', '1013757', true, 315, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 22000, 11,   60,  660,  80.15, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×24m', 'CVA10115', '1013758', true, 316, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 24000, 12,   60,  720,  73.47, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×26m', 'CVA10116', '1013759', true, 317, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 26000, 13,   60,  780,  67.82, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×28m', 'CVA10117', '1013760', true, 318, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 28000, 14,   60,  840,  62.97, 50, 50, 50, 100),
  (3, 'EcoMat 60T 0.5×30m', 'CVA10118', '1013761', true, 319, 'Cenika AS', 'EcoMat 60T', 'indoor', 500, 30000, 15,   60,  900,  58.78, 50, 50, 50, 100)
ON CONFLICT (article_no) DO UPDATE SET
  name = EXCLUDED.name, el_no = EXCLUDED.el_no,
  supplier = EXCLUDED.supplier, product_family = EXCLUDED.product_family,
  usage_area = EXCLUDED.usage_area,
  mat_width_mm = EXCLUDED.mat_width_mm, mat_length_mm = EXCLUDED.mat_length_mm,
  mat_area_m2 = EXCLUDED.mat_area_m2,
  watt_per_m2 = EXCLUDED.watt_per_m2, total_effect_w = EXCLUDED.total_effect_w,
  resistance_ohm = EXCLUDED.resistance_ohm,
  min_gap_mm = EXCLUDED.min_gap_mm, min_wall_margin_mm = EXCLUDED.min_wall_margin_mm,
  min_obstacle_distance_mm = EXCLUDED.min_obstacle_distance_mm,
  min_drain_distance_mm = EXCLUDED.min_drain_distance_mm,
  active = EXCLUDED.active;

-- ─── STEG 3: Import Cenika EcoMat 100T (19 varianter) ──────────────────────
-- 100 W/m² — for entre, generell bruk
-- Kan legges direkte pa brennbart underlag

INSERT INTO heating_products (
  category_id, name, article_no, el_no, active, sort_order,
  supplier, product_family, usage_area,
  mat_width_mm, mat_length_mm, mat_area_m2,
  watt_per_m2, total_effect_w, resistance_ohm,
  min_gap_mm, min_wall_margin_mm, min_obstacle_distance_mm, min_drain_distance_mm
) VALUES
  (3, 'EcoMat 100T 0.5×2m',  'CVA10120', '1013762', true, 401, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  2000,  1,   100,  100, 529,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×3m',  'CVA10121', '1013763', true, 402, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  3000,  1.5, 100,  150, 353,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×4m',  'CVA10122', '1013764', true, 403, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  4000,  2,   100,  200, 265,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×5m',  'CVA10123', '1013765', true, 404, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  5000,  2.5, 100,  250, 212,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×6m',  'CVA10124', '1013766', true, 405, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  6000,  3,   100,  300, 176,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×7m',  'CVA10125', '1013767', true, 406, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  7000,  3.5, 100,  350, 151,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×8m',  'CVA10126', '1013768', true, 407, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  8000,  4,   100,  400, 132,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×9m',  'CVA10127', '1013769', true, 408, 'Cenika AS', 'EcoMat 100T', 'indoor', 500,  9000,  4.5, 100,  450, 118,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×10m', 'CVA10128', '1013770', true, 409, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 10000,  5,   100,  500, 106,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×12m', 'CVA10129', '1013771', true, 410, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 12000,  6,   100,  600,  88,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×14m', 'CVA10130', '1013772', true, 411, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 14000,  7,   100,  700,  76,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×16m', 'CVA10131', '1013773', true, 412, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 16000,  8,   100,  800,  66,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×18m', 'CVA10132', '1013774', true, 413, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 18000,  9,   100,  900,  59,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×20m', 'CVA10133', '1013775', true, 414, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 20000, 10,   100, 1000,  53,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×22m', 'CVA10134', '1013776', true, 415, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 22000, 11,   100, 1100,  48,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×24m', 'CVA10135', '1013777', true, 416, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 24000, 12,   100, 1200,  44,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×26m', 'CVA10136', '1013778', true, 417, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 26000, 13,   100, 1300,  41,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×28m', 'CVA10137', '1013779', true, 418, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 28000, 14,   100, 1400,  38,   50, 50, 50, 100),
  (3, 'EcoMat 100T 0.5×30m', 'CVA10138', '1013780', true, 419, 'Cenika AS', 'EcoMat 100T', 'indoor', 500, 30000, 15,   100, 1500,  35,   50, 50, 50, 100)
ON CONFLICT (article_no) DO UPDATE SET
  name = EXCLUDED.name, el_no = EXCLUDED.el_no,
  supplier = EXCLUDED.supplier, product_family = EXCLUDED.product_family,
  usage_area = EXCLUDED.usage_area,
  mat_width_mm = EXCLUDED.mat_width_mm, mat_length_mm = EXCLUDED.mat_length_mm,
  mat_area_m2 = EXCLUDED.mat_area_m2,
  watt_per_m2 = EXCLUDED.watt_per_m2, total_effect_w = EXCLUDED.total_effect_w,
  resistance_ohm = EXCLUDED.resistance_ohm,
  min_gap_mm = EXCLUDED.min_gap_mm, min_wall_margin_mm = EXCLUDED.min_wall_margin_mm,
  min_obstacle_distance_mm = EXCLUDED.min_obstacle_distance_mm,
  min_drain_distance_mm = EXCLUDED.min_drain_distance_mm,
  active = EXCLUDED.active;

-- ─── STEG 4: Import Cenika EcoMat 150T (19 varianter) ──────────────────────
-- 150 W/m² — for bad, WC, vaskerom
-- IKKE godkjent for brennbart underlag (sponplate o.l.)

INSERT INTO heating_products (
  category_id, name, article_no, el_no, active, sort_order,
  supplier, product_family, usage_area,
  mat_width_mm, mat_length_mm, mat_area_m2,
  watt_per_m2, total_effect_w, resistance_ohm,
  min_gap_mm, min_wall_margin_mm, min_obstacle_distance_mm, min_drain_distance_mm
) VALUES
  (3, 'EcoMat 150T 0.5×2m',  'CVA10140', '1013781', true, 501, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  2000,  1,   150,  150, 353,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×3m',  'CVA10141', '1013782', true, 502, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  3000,  1.5, 150,  225, 235,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×4m',  'CVA10142', '1013783', true, 503, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  4000,  2,   150,  300, 176,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×5m',  'CVA10143', '1013784', true, 504, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  5000,  2.5, 150,  375, 141,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×6m',  'CVA10144', '1013785', true, 505, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  6000,  3,   150,  450, 118,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×7m',  'CVA10145', '1013786', true, 506, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  7000,  3.5, 150,  525, 101,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×8m',  'CVA10146', '1013787', true, 507, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  8000,  4,   150,  600,  88,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×9m',  'CVA10147', '1013788', true, 508, 'Cenika AS', 'EcoMat 150T', 'indoor', 500,  9000,  4.5, 150,  675,  78,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×10m', 'CVA10148', '1013789', true, 509, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 10000,  5,   150,  750,  71,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×12m', 'CVA10149', '1013790', true, 510, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 12000,  6,   150,  900,  59,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×14m', 'CVA10150', '1013791', true, 511, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 14000,  7,   150, 1050,  50,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×16m', 'CVA10151', '1013792', true, 512, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 16000,  8,   150, 1200,  44,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×18m', 'CVA10152', '1013793', true, 513, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 18000,  9,   150, 1350,  39,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×20m', 'CVA10153', '1013794', true, 514, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 20000, 10,   150, 1500,  35,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×22m', 'CVA10154', '1013795', true, 515, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 22000, 11,   150, 1650,  32,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×24m', 'CVA10155', '1013796', true, 516, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 24000, 12,   150, 1800,  29,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×26m', 'CVA10156', '1013797', true, 517, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 26000, 13,   150, 1950,  27,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×28m', 'CVA10157', '1013798', true, 518, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 28000, 14,   150, 2100,  25,   50, 50, 50, 100),
  (3, 'EcoMat 150T 0.5×30m', 'CVA10158', '1013799', true, 519, 'Cenika AS', 'EcoMat 150T', 'indoor', 500, 30000, 15,   150, 2250,  23.5, 50, 50, 50, 100)
ON CONFLICT (article_no) DO UPDATE SET
  name = EXCLUDED.name, el_no = EXCLUDED.el_no,
  supplier = EXCLUDED.supplier, product_family = EXCLUDED.product_family,
  usage_area = EXCLUDED.usage_area,
  mat_width_mm = EXCLUDED.mat_width_mm, mat_length_mm = EXCLUDED.mat_length_mm,
  mat_area_m2 = EXCLUDED.mat_area_m2,
  watt_per_m2 = EXCLUDED.watt_per_m2, total_effect_w = EXCLUDED.total_effect_w,
  resistance_ohm = EXCLUDED.resistance_ohm,
  min_gap_mm = EXCLUDED.min_gap_mm, min_wall_margin_mm = EXCLUDED.min_wall_margin_mm,
  min_obstacle_distance_mm = EXCLUDED.min_obstacle_distance_mm,
  min_drain_distance_mm = EXCLUDED.min_drain_distance_mm,
  active = EXCLUDED.active;

-- ─── Verifiser ──────────────────────────────────────────────────────────────

SELECT product_family, COUNT(*) as antall,
       MIN(total_effect_w) || 'W - ' || MAX(total_effect_w) || 'W' as effekt_range,
       MIN(mat_length_mm/1000.0) || 'm - ' || MAX(mat_length_mm/1000.0) || 'm' as lengde_range,
       MIN(watt_per_m2) || ' W/m²' as effekttetthet
FROM heating_products
WHERE supplier = 'Cenika AS' AND category_id = 3
GROUP BY product_family
ORDER BY product_family;
