-- Migration: Varmecomfort — Aluboard platesystem + FLXHEAT-katalog (Del 1)
-- ---------------------------------------------------------------------------
-- EGET leverandoer-datasett (IKKE Cenika). Produktene gates i appen via
-- p.supplier = 'Varmecomfort' (_productVisibleToOrg): leverandoer-org ser kun egne,
-- elektrobedrift + superadmin ser alle.
--
-- Idempotent. Kjoeres manuelt i Supabase SQL Editor. TILPASS kolonnenavn til ditt
-- faktiske skjema foer du kjoerer (spesielt heating_products-kolonnene).
-- ---------------------------------------------------------------------------

-- ===========================================================================
-- STEG 0 (KJOR DENNE LINJEN ALENE FORST, saa resten) — module_type er en enum,
-- og en NY enum-verdi kan IKKE brukes i samme transaksjon som den opprettes.
-- Marker kun linjen under og kjor den; kjor deretter resten av fila.
-- ===========================================================================
alter type module_type add value if not exists 'aluboard';

-- ---------------------------------------------------------------------------
-- STEG 1+ (kjor etter at STEG 0 er committet):

-- 1) Asymmetrisk resistanstoleranse paa suppliers (Varmecomfort: -5 % / +10 %, lengde +/-2 %).
--    (Dagens felt resistance_tolerance_pct er symmetrisk; disse utvider uten aa endre det.)
alter table suppliers add column if not exists resistance_tol_minus_pct numeric;
alter table suppliers add column if not exists resistance_tol_plus_pct  numeric;
alter table suppliers add column if not exists length_tol_pct           numeric;
alter table suppliers add column if not exists max_temp_c               numeric;

-- 2) Varmecomfort supplier-rad (maalregler = leverandoer-data, ikke hardkodet).
insert into suppliers (name, display_name, garanti_id_prefix, recipient_email,
                       resistance_tolerance_pct, resistance_tol_minus_pct, resistance_tol_plus_pct,
                       length_tol_pct, insulation_min_mohm, insulation_min_volt, max_temp_c, color)
select 'Varmecomfort', 'Varmecomfort', 'VC', 'garanti@varmecomfort.no',
       10, 5, 10, 2, 10, 500, 90, '#e8511d'
where not exists (select 1 from suppliers where name = 'Varmecomfort');

-- 3) Produktkategori for Aluboard (egen module_type 'aluboard', kun indoor).
insert into product_categories (name, module_type, available_contexts, sort_order, active)
select 'Aluboard platesystem', 'aluboard', array['indoor'], 400, true
where not exists (select 1 from product_categories where name = 'Aluboard platesystem');

-- 4) Nye produkt-kolonner (plate-rolle/dims + aluboard-regler). Tilpass om de finnes.
alter table heating_products add column if not exists plate_role        text;     -- 'straight' | 'turn'
alter table heating_products add column if not exists plate_width_mm    numeric;
alter table heating_products add column if not exists plate_length_mm   numeric;
alter table heating_products add column if not exists plate_area_m2     numeric;
alter table heating_products add column if not exists nominal_ohm       numeric;
alter table heating_products add column if not exists aluboard_cc_mm    numeric;
alter table heating_products add column if not exists min_bend_radius_mm numeric;
alter table heating_products add column if not exists max_temp_c        numeric;

-- 5) Produkter. Legg inn plater + FLXHEAT-kabler under Aluboard-kategorien.
--    (Kabeldata: meter, watt, EL, nominell ohm — se _ensureVarmecomfortProducts i romtegner.html.)
--    Enkeltvis eller via Produktimport. Eksempel for de to platene:
with cat as (select id from product_categories where name = 'Aluboard platesystem' limit 1)
insert into heating_products (category_id, name, product_family, supplier, el_no, article_no, active,
                              plate_role, plate_width_mm, plate_length_mm, plate_area_m2, available_contexts)
select cat.id, v.name, 'Aluboard', 'Varmecomfort', v.el, v.el, true,
       v.role, v.w, v.l, v.area, array['indoor']
from cat, (values
  ('Aluboard rett plate 60×120', '5402067', 'straight', 600, 1200, 0.72),
  ('Aluboard vendeplate 28×60',  '5402066', 'turn',     600,  280, 0.168)
) as v(name, el, role, w, l, area)
where not exists (select 1 from heating_products hp where hp.el_no = v.el);

-- 6) FLXHEAT 3 mm 8 W/m-kablene (17 lengder). watt_per_m=8, voltage=230, aluboard_cc_mm=100,
--    min_bend_radius_mm=36, max_temp_c=90. Navn = "FLXHEAT 3mm 8W/m {W}W {m}m".
with cat as (select id from product_categories where name = 'Aluboard platesystem' limit 1)
insert into heating_products (category_id, name, product_family, supplier, el_no, article_no, active,
                              cable_length_m, total_effect_w, watt_per_m, voltage, nominal_ohm,
                              aluboard_cc_mm, min_bend_radius_mm, max_temp_c, available_contexts)
select cat.id, 'FLXHEAT 3mm 8W/m ' || v.w || 'W ' || v.m || 'm', 'FLXHEAT 8W/m', 'Varmecomfort',
       v.el, v.el, true, v.m, v.w, 8, 230, v.ohm, 100, 36, 90, array['indoor']
from cat, (values
  (10.0,   80, '1006049', 660.0),
  (15.9,  130, '1006050', 413.0),
  (19.1,  150, '1006051', 346.0),
  (25.0,  200, '1006052', 255.0),
  (32.0,  250, '1006053', 211.0),
  (37.0,  300, '1006054', 178.0),
  (52.0,  420, '1006055', 127.0),
  (66.0,  520, '1006056', 102.0),
  (77.0,  620, '1006057',  85.0),
  (86.0,  720, '1006058',  73.0),
  (106.0, 820, '1006059',  65.0),
  (117.0, 920, '1006060',  57.0),
  (120.0,1000, '1006061',  52.8),
  (137.0,1100, '1006062',  48.0),
  (163.0,1300, '1006063',  40.8),
  (196.0,1500, '1006064',  35.3),
  (216.0,1750, '1006065',  30.2)
) as v(m, w, el, ohm)
where not exists (select 1 from heating_products hp where hp.el_no = v.el);

-- 7) VEIL.PRIS (B6) — appen har feltet price_list per produkt, men Varmecomfort-prisene er IKKE
--    med her (leveres av Varmecomfort). Fyll inn fra prislista, f.eks.:
-- update heating_products set price_list = <kr>, cost_price = <kr> where el_no = '5402067'; -- rett plate
-- update heating_products set price_list = <kr>, cost_price = <kr> where el_no = '5402066'; -- vendeplate
-- update heating_products set price_list = <kr> where el_no = '1006058';                    -- FLXHEAT 86 m
--    (… tilsvarende for de øvrige EL-numrene.) Uten priser blir tilbudspris-arket tomt for Aluboard.

-- Kontroll:
-- select name, supplier, el_no, plate_role, cable_length_m, total_effect_w, nominal_ohm, price_list
--   from heating_products where supplier = 'Varmecomfort' order by plate_role nulls last, cable_length_m;
