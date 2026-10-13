-- 064f: en overstyringsrad skal baere KUN det den overstyrer.
-- Kenneth 13.10.2026 ("ta den") -- oppfolging av 064c/064e.
--
-- Kjores manuelt i Supabase SQL Editor. Idempotent.
--
-- MONSTERET, tredje gang: room_type_defaults er et lagdelt oppslag (global > org > user), men
-- flere kolonner ble opprettet med NOT NULL og/eller DEFAULT. Da kan et overstyringslag ikke si
-- "arv" -- det MA ha en verdi, og den verdien overstyrer laget under for alltid.
--   reserve_cable  boolean not null default false  -> rettet i 064c
--   target_wm2     integer not null default 100    -> rettet i 064e
--   icon           text default '...'              -> her
--   sort_order     integer default 0               -> her
--
-- Malt 13.10.2026: org-raden for fryserom bar icon og sort_order = 9, mens global har 10.
-- Raden flyttet altsa romtypen en plass i lista uten at noen hadde bedt om det.
--
-- Koden (index.html, 064f) slutter samtidig a kopiere icon/sort_order/target_wm2 inn i nye
-- bruker-rader. Uten denne migrasjonen ville defaultene fylt dem inn likevel.

-- 1. La kolonnene vaere tomme = arv.
alter table public.room_type_defaults
  alter column icon drop default,
  alter column sort_order drop default;

comment on column public.room_type_defaults.icon is
  '064f: null = arv fra laget under (global). Sett kun pa raden som faktisk skal endre ikonet.';
comment on column public.room_type_defaults.sort_order is
  '064f: null = arv fra laget under (global). Sett kun pa raden som faktisk skal endre rekkefolgen.';

-- 2. Rydd frosne verdier i eksisterende overstyringsrader.
-- Rorer ALDRI scope='global' -- det er baselaget og skal ha verdier.
update room_type_defaults
   set icon = null, sort_order = null, updated_at = now()
 where scope <> 'global';

-- 3. Kontroll -- forventet: ingen ikke-globale rader med icon eller sort_order satt.
select scope, room_type_id, label, icon, sort_order, target_wm2, default_mod_type, reserve_cable
  from room_type_defaults
 where scope <> 'global'
 order by room_type_id, scope;

-- ---------------------------------------------------------------------------
-- SIDEFUNN (ikke rort -- krever Kenneths avgjorelse):
--
-- Det finnes en GLOBAL romtype med room_type_id = '9', label 'Varmefolie', 60 W/m2,
-- opprettet 2026-06-03. "Varmefolie" er et produkt, ikke en romtype, og den dukker opp som et
-- valgbart alternativ i romtypelista. Ser ut som et uhell fra admin-panelet.
--
-- Skal den bort:
--   delete from room_type_defaults where room_type_id = '9' and scope = 'global';
--
-- Sjekk forst om noen lagrede prosjekter bruker den (rom med roomType '9') -- de ville da
-- miste romtypen sin.
