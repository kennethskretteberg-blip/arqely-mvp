-- ============================================================================
-- Migrasjon: Værdata pr postnummer (datakontrakt for snøsmelting-auto-fyll)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- Tabellen fylles fra 40-arsarket (alle vaerstasjoner, koblet til postnummer).
-- Til arket er klart brukes manuell innfylling i kalkulatoren; denne tabellen
-- er KONTRAKTEN appen slar opp mot (postnr -> dimensjonerende vaerforhold).
-- ============================================================================

create table if not exists weather_by_postcode (
  postcode        text primary key,         -- 4-sifret norsk postnr
  place           text,                      -- poststed
  municipality    text,                      -- kommune
  design_temp_c   numeric,                   -- dimensjonerende vintertemp (°C)
  design_wind_ms  numeric,                   -- dimensjonerende/typisk vind (m/s)
  snowfall_cm_h   numeric,                   -- snofallsintensitet (cm/h)
  altitude_m      integer,                   -- hoyde over havet (m)
  source          text,                      -- kilde/arstall for raden
  updated_at      timestamptz not null default now()
);

alter table weather_by_postcode enable row level security;

-- Referansedata: lesbar for alle innloggede. Skriv kun superadmin (eier vedlikeholder arket).
drop policy if exists "weather_by_postcode read" on weather_by_postcode;
create policy "weather_by_postcode read" on weather_by_postcode
  for select to authenticated using (true);

drop policy if exists "weather_by_postcode superadmin write" on weather_by_postcode;
create policy "weather_by_postcode superadmin write" on weather_by_postcode
  for all using (is_superadmin()) with check (is_superadmin());

-- --- VERIFISER --------------------------------------------------------------
select
  (select count(*) from information_schema.tables where table_name='weather_by_postcode') as tabell_finnes,   -- 1
  (select count(*) from weather_by_postcode)                                              as antall_rader,    -- 0 til arket importeres
  (select count(*) from pg_policies where tablename='weather_by_postcode')                as policyer;        -- 2

-- ============================================================================
-- IMPORT (nar 40-arsarket er klart): map kolonnene og kjor en upsert, f.eks.
--   insert into weather_by_postcode (postcode, place, design_temp_c, design_wind_ms, snowfall_cm_h, altitude_m, source)
--   values ('0001','Oslo', -20, 4, 1.5, 20, '40-ars 1985-2024')
--   on conflict (postcode) do update set
--     design_temp_c=excluded.design_temp_c, design_wind_ms=excluded.design_wind_ms,
--     snowfall_cm_h=excluded.snowfall_cm_h, altitude_m=excluded.altitude_m,
--     place=excluded.place, source=excluded.source, updated_at=now();
--
-- ROLLBACK:  drop table if exists weather_by_postcode;
-- ============================================================================
