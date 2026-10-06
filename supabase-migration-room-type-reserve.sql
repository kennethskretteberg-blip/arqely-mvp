-- 025 (Kenneth 06.10.2026): romtype «Fryserom/kjolerom» med lav flateeffekt og reservekabel.
-- ADDITIV og idempotent — kan kjores flere ganger.
--
-- Bakgrunn: varmekablene legges UNDER isolasjonen, under stopt dekke, for a hindre at frosten
-- gar ned i bakken. Derfor 10 W/m med CC 20-50 cm — begge er ADVARSELS-grenser, ikke sperrer, og derfor en reservekabel:
-- en kabel stopt under et fryselager kan ikke byttes.
--
-- Virker ogsa UTEN denne migrasjonen: klienten har de samme verdiene hardkodet som fallback
-- (_ROOMTYPE_HARDCODED i index.html). Migrasjonen gjor romtypen tilgjengelig for alle brukere.

alter table public.room_type_defaults
  add column if not exists reserve_cable boolean not null default false,
  add column if not exists wm2_min  integer null,
  add column if not exists cc_min_mm integer null,
  add column if not exists cc_max_mm integer null;

comment on column public.room_type_defaults.reserve_cable is
  '025: romtypen prosjekteres med reservekabel (kopi av hovedkabelen forskjovet 1/2 CC).';
comment on column public.room_type_defaults.wm2_min is
  '025: nedre grense for onsket flateeffekt for DENNE romtypen. null = modulens standard (50 innendors).';

-- Selve romtypen. ON CONFLICT: oppdaterer en rad som alt finnes, sa fila kan kjores pa nytt.
insert into public.room_type_defaults
  (room_type_id, label, icon, target_wm2, default_mod_type, sort_order, scope,
   reserve_cable, wm2_min, cc_min_mm, cc_max_mm)
select 'fryserom', 'Fryserom/kjolerom', '🧊', 20, 'cable',
       coalesce((select max(sort_order) from public.room_type_defaults), 0) + 1, 'global',
       true, 10, 200, 500
where not exists (
  select 1 from public.room_type_defaults
  where room_type_id = 'fryserom' and scope = 'global'
);

update public.room_type_defaults
   set reserve_cable = true, wm2_min = 10, cc_min_mm = 200, cc_max_mm = 500,
       target_wm2 = 20, default_mod_type = 'cable'
 where room_type_id = 'fryserom' and scope = 'global';
