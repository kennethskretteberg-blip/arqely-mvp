-- Migration: Varmecomfort — Aluboard platesystem + FLXHEAT-katalog (Del 1)
-- ---------------------------------------------------------------------------
-- EGET leverandoer-datasett (IKKE Cenika). Produktene gates i appen via
-- p.supplier = 'Varmecomfort' (_productVisibleToOrg): leverandoer-org ser kun egne,
-- elektrobedrift + superadmin ser alle.
--
-- Idempotent. Kjoeres manuelt i Supabase SQL Editor. TILPASS kolonnenavn til ditt
-- faktiske skjema foer du kjoerer (spesielt heating_products-kolonnene).
-- ---------------------------------------------------------------------------

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

-- FLXHEAT-kablene (17 lengder) legges inn tilsvarende — se katalogtabellen i prompten/
-- _ensureVarmecomfortProducts (m/watt/EL/ohm), med watt_per_m=8, voltage=230, aluboard_cc_mm=100.

-- Kontroll:
-- select name, supplier, el_no, plate_role, nominal_ohm from heating_products where supplier='Varmecomfort' order by sort_order;
