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

-- 4. Reservekabelen tilbake for organisasjonen.
--
-- Kenneth 12.10.2026: "jeg onsker at reservekabelen tegnes opp slik den gjorde sist jeg provde,
-- den skal hensyntas pa materiallister, men ikke pavirke effekten da reservekabelen aldri star pa."
--
-- Org-raden hadde reserve_cable = false, som slo den AV. null betyr na "arv" (arvefeilen i
-- koden er rettet i 064), altsa arv fra global = true. Ingen kodeendring trengs: alle tre
-- egenskapene er allerede bygget i 025 og MALT 12.10.2026 pa et 48 m2 fryselager med
-- InFloor 10T 1000W 100m:
--   tegnes opp     -- reserven far egen geometri (12 lop, 97,4 m lagt), som hovedkabelen
--   materialliste  -- 1 stk -> 2 stk, og "2 stk (1 + 1 reserve)" i Bestilles
--   effekt         -- 1000 W bade med og uten; Romoversikten gir reserven egen rad med 0 W
-- ROTARSAK (funnet 13.10.2026): reserve_cable er den ENESTE av de fire 025-kolonnene som ble
-- lagt til som "boolean not null default false" -- wm2_min, cc_min_mm og cc_max_mm er alle
-- nullable. Konsekvensen: HVER org-rad som opprettes far automatisk reserve_cable = false, som
-- deretter overstyrer global true. Org-raden var altsa aldri et valg; kolonnedefaultet skrev den.
-- Uten denne endringen kan et overstyringslag ikke si "arv" for nettopp dette feltet, og enhver
-- ny org mister reservekabelen for fryserom pa samme mate.
--
-- Gjor den lik sine tre sosken. Eksisterende false-verdier blir staende som false (ingen data
-- endres av selve alter-setningen); raden under settes eksplisitt til null = arv.
alter table public.room_type_defaults
  alter column reserve_cable drop not null,
  alter column reserve_cable drop default;

comment on column public.room_type_defaults.reserve_cable is
  '025/064b: romtypen prosjekteres med reservekabel (kopi av hovedkabelen forskjovet 1/2 CC). '
  'null = arv fra laget under (global), som for wm2_min/cc_min_mm/cc_max_mm.';

update room_type_defaults
   set reserve_cable = null, updated_at = now()
 where room_type_id = 'fryserom'
   and scope = 'org';

-- ---------------------------------------------------------------------------
-- FORTSATT APENT -- krever Kenneths avgjorelse:
--
-- Org-raden har target_wm2 = 25 mot globalt 20. 25 er innenfor 15-30, altsa fullt lovlig.
-- Hvilket tall er riktig for organisasjonen? Skal den arve globalt, kjor:
--
--   update room_type_defaults set target_wm2 = null, updated_at = now()
--    where room_type_id = 'fryserom' and scope = 'org';
