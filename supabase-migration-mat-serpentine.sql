-- Migration: Add serpentine cable pattern fields for EcoMat heating mats
-- Based on technical drawing TPL-ECOMT-CA-2183 from Thermopads Pvt. Ltd.

-- Add new columns for cable center-to-center spacing and cut interval
ALTER TABLE heating_products
  ADD COLUMN IF NOT EXISTS mat_cc_mm INTEGER,
  ADD COLUMN IF NOT EXISTS mat_cut_interval_mm INTEGER;

-- EcoMat 150T: CC=80mm, cut interval=160mm (every 2 loops)
-- From drawing page 1: loop spacing 80±5mm, can only cut every other U-turn
UPDATE heating_products
SET mat_cc_mm = 80, mat_cut_interval_mm = 160
WHERE product_family = 'EcoMat 150T';

-- EcoMat 60T: CC=120mm, cut interval=240mm (every 2 loops)
-- From drawing page 2: loop spacing 120±5mm
UPDATE heating_products
SET mat_cc_mm = 120, mat_cut_interval_mm = 240
WHERE product_family = 'EcoMat 60T';

-- EcoMat 100T: CC=120mm, cut interval=240mm (every 2 loops)
-- Same physical construction as 60T, just higher wattage
UPDATE heating_products
SET mat_cc_mm = 120, mat_cut_interval_mm = 240
WHERE product_family = 'EcoMat 100T';
