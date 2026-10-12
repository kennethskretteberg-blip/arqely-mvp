-- 064: Fryserom/kjolerom -- CC 30-50 cm og 15-30 W/m2, uavhengig kabeltype.
-- Kenneth 12.10.2026: "cc skal ligge mellom 30 og 50 cm uavhengig kabel type.
-- w/m skal ligge mellom 15 - 30 w/m2 uavhengig type."
--
-- Kjores manuelt i Supabase SQL Editor. Idempotent.
--
-- Bakgrunn: den globale raden holder i dag cc_min_mm = 200 og wm2_min = 10. Begge ligger
-- utenfor omradet Kenneth oppgir, og 10 W/m2 er dessuten fysisk uoppnaelig: en 10 W/m kabel
-- gir 10 * 100 / 50 = 20 W/m2 ved maks CC. Appen regner det fysiske gulvet selv
-- (_cableWm2Floor) og lofter 15 til 20 nar kabelen er 10 W/m -- men politikk-gulvet skal
-- likevel vaere 15, slik at en framtidig svakere kabel (f.eks. 8 W/m -> 16 W/m2) slipper til.

-- 1. Nytt tak per romtype. Additiv kolonne, som wm2_min/cc_min_mm/cc_max_mm i 025.
alter table room_type_defaults add column if not exists wm2_max integer;

comment on column room_type_defaults.wm2_max is
  '064: ovre grense for onsket flateeffekt for denne romtypen. NULL = modulens tak (inne 300, ute 450).';

-- 2. Den globale fryserom-raden far Kenneths omrade.
update room_type_defaults
   set cc_min_mm = 300,     -- var 200
       cc_max_mm = 500,     -- uendret, satt eksplisitt
       wm2_min   = 15,      -- var 10
       wm2_max   = 30,      -- nytt
       updated_at = now()
 where room_type_id = 'fryserom'
   and scope = 'global';

-- 3. Kontroll -- forventet: cc 300/500, wm2 15/30, default_mod_type 'cable', reserve_cable true.
select scope, org_id, default_mod_type, reserve_cable, target_wm2, wm2_min, wm2_max,
       cc_min_mm, cc_max_mm
  from room_type_defaults
 where room_type_id = 'fryserom'
 order by scope;

-- ---------------------------------------------------------------------------
-- IKKE KJORT AUTOMATISK -- krever Kenneths avgjorelse:
--
-- Org-raden (scope='org') har reserve_cable = false. 025 ble bygget nettopp fordi "en kabel
-- stopt under et fryselager kan ikke byttes", sa en org som slar AV reservekabelen for
-- fryserom ser ut som en uhellig backfill, ikke et valg. Null i de andre feltene betyr na
-- "arv" (rettet i koden, 064) -- men en EKSPLISITT false ma respekteres som false.
--
-- Skal reservekabelen tilbake for organisasjonen, kjor:
--
--   update room_type_defaults set reserve_cable = null, updated_at = now()
--    where room_type_id = 'fryserom' and scope = 'org';
--
-- (null = arv fra global = true. Sett den til false bare hvis org FAKTISK skal ha den av.)
--
-- Org-raden har ogsa target_wm2 = 25 mot globalt 20. 25 er innenfor 15-30, altsa lovlig --
-- men _reserveCableRegressionTest forventer 20. Avklar hvilket tall som er riktig for org.
