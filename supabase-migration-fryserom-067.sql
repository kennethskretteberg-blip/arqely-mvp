-- 067: Fryserom etter BL-001 (Thermopads 22.03.2026) -- standard 25 W/m2.
-- Kenneth 13.10.2026.
--
-- Kjores manuelt i Supabase SQL Editor. Idempotent.
--
-- BL-001 godkjenner InFloor 10T (10 W/m) lagt med c/c 40 cm for fryseromsgulv.
-- 10 * 100 / 40 = 25 W/m2. Standarden var 20, som gav c/c 49,9 cm i auto-utlegget
-- (malt 13.10.2026) -- altsa pa grensen av DEVI sine maks 50 cm, ikke pa den godkjente 40.
--
-- CC-en LAGRES ikke noe sted: den utledes av malet og kabellengden i _autoFillCableImpl.
-- Derfor er det nok a rette malet; c/c 40 folger av seg selv.

-- 1. Globalt mal 25 W/m2.
update room_type_defaults
   set target_wm2 = 25, updated_at = now()
 where room_type_id = 'fryserom'
   and scope = 'global';

-- 2. Org-raden skal ikke sta som en egen overstyring av malet (den var 25, satt for 064e).
--    null = arv fra global. Kolonnen ble gjort nullable i 064e.
update room_type_defaults
   set target_wm2 = null, updated_at = now()
 where room_type_id = 'fryserom'
   and scope = 'org';

-- 3. Kontroll -- forventet: global 25 / 15 / 30 / 300 / 500 / cable / true,
--    org kun label (alt annet null = arv).
select scope, org_id, default_mod_type, reserve_cable, target_wm2, wm2_min, wm2_max,
       cc_min_mm, cc_max_mm
  from room_type_defaults
 where room_type_id = 'fryserom'
 order by scope;
