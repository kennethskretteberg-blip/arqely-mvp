-- ============================================================================
-- Migrasjon 060: PROSJEKTLAAS - en redigerende bruker per prosjekt
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- MAALT FOER (STEG 0.1, to vinduer, samme prosjekt, ekte database):
--   Vindu A dopte om rom 1, lagret  -> databasen hadde "A-ENDRET-AV-VINDU-A".
--   Vindu B dopte om rom 2, lagret  -> databasen hadde "Omraade 1" igjen.
--   Vindus B sin `data`-blob var bygget FOER A lagret, og `update(row).eq('id',..)`
--   bytter HELE blobben. As endring forsvant uten en eneste feilmelding i noen av
--   vinduene, og begge lagre-indikatorene sto pa gront "Lagret".
--
-- Denne migrasjonen legger laasen i databasen. UI-gaten i index.html er forstelinje;
-- triggeren nederst her er sikringen (regel 5 i docs/spec-prosjektlaas.md).
--
-- VIKTIG: `data`-blobben er beskyttet, INGENTING annet. En INSERT roeres ikke
-- (feltappen oppretter prosjekter, se varmeplan-app/src/db/writeRepo.ts), og
-- oppdatering av status / customer_id / kundelenke-kolonner slipper gjennom.
-- ============================================================================

-- --- 1. KOLONNER -----------------------------------------------------------
alter table romtegner_projects
  add column if not exists locked_by      uuid,          -- auth.uid() til den som har laasen
  add column if not exists locked_by_name text,           -- visningsnavn, snapshot (profiles.full_name)
  add column if not exists locked_at      timestamptz,    -- "apnet 14:02"
  add column if not exists lock_seen_at   timestamptz,    -- siste hjerteslag -> sovende etter 3 min
  add column if not exists lock_session   text;           -- vindu-okt: samme bruker, to vinduer = to laaser

comment on column romtegner_projects.lock_session is
  '060: en tilfeldig uuid per sidelasting. Regel 6: samme bruker i to vinduer er to laaser.';

-- --- 2. SOVENDE LAAS -------------------------------------------------------
-- Regel 2: ingen hjerteslag paa 3 minutter = sovende, og kan tas av en annen.
-- NB: `stable`, IKKE `immutable` - funksjonen leser now(). En immutable funksjon
-- kan foldes ved planlegging, og da ville svaret vaert fra et annet tidspunkt enn
-- spoerringen faktisk kjorte paa.
create or replace function project_lock_is_stale(seen timestamptz)
  returns boolean
  language sql
  stable
as $$ select seen is null or seen < now() - interval '3 minutes' $$;

-- --- 3. TA / FORNY LAASEN --------------------------------------------------
-- Returnerer {ok, by_user, by_name, since, seen, same_user}.
-- `security invoker`: RLS gjelder, saa bare org-medlemmer kan laase et prosjekt
-- (UPDATE-policyen "Eier kan oppdatere prosjekter" er fasiten).
-- Navnet hentes fra profiles.full_name, med JWT-ens e-post foer @ som fallback.
-- auth.users leses ALDRI - den authenticated-rollen har ikke tilgang (42501),
-- se RLS-moensteret i CLAUDE.md.
create or replace function project_lock_acquire(p_id uuid, p_session text, p_force boolean default false)
  returns jsonb
  language plpgsql
  security invoker
as $$
declare
  r           romtegner_projects;
  v_name      text;
  v_stale     boolean;
  v_mine      boolean;
  v_same_user boolean;
  v_since     timestamptz;
  v_rows      int;
begin
  if p_session is null or length(trim(p_session)) = 0 then
    raise exception 'project_lock_acquire: p_session mangler';
  end if;

  -- `for update` serialiserer to samtidige forsok paa samme rad. Uten den kunne
  -- begge lest "fri" og begge skrevet seg inn som eier.
  -- Finner vi ikke raden, har vi ikke tilgang til prosjektet (RLS).
  select * into r from romtegner_projects where id = p_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'not_found', true);
  end if;

  v_stale     := project_lock_is_stale(r.lock_seen_at);
  v_mine      := (r.lock_session is not null and r.lock_session = p_session);
  v_same_user := (r.locked_by is not null and r.locked_by = auth.uid());

  -- Fri, min egen okt, eller sovende -> jeg kan ta den uten p_force.
  -- p_force er BARE lov naar laasen sover (regel 3) eller det er meg selv i et
  -- annet vindu (regel 6). Haandhevet HER, ikke bare i klienten.
  if not (r.locked_by is null
          or v_mine
          or v_stale
          or (p_force and (v_stale or v_same_user))) then
    return jsonb_build_object(
      'ok',        false,
      'by_user',   r.locked_by,
      'by_name',   coalesce(nullif(trim(r.locked_by_name), ''), 'En kollega'),
      'since',     r.locked_at,
      'seen',      r.lock_seen_at,
      'same_user', v_same_user
    );
  end if;

  v_name := coalesce(
    nullif(trim((select full_name from profiles where id = auth.uid())), ''),
    nullif(split_part(coalesce(auth.jwt() ->> 'email', ''), '@', 1), ''),
    'En kollega'
  );

  -- "apnet 14:02" skal ikke hoppe framover hvert minutt for den som alt sitter der.
  v_since := case when v_mine and r.locked_at is not null then r.locked_at else now() end;

  update romtegner_projects
     set locked_by      = auth.uid(),
         locked_by_name = v_name,
         locked_at      = v_since,
         lock_seen_at   = now(),
         lock_session   = p_session
   where id = p_id;
  get diagnostics v_rows = row_count;

  -- RLS slipper SELECT og UPDATE gjennom ulike policyer: en bruker kan ha lov til
  -- aa LESE et prosjekt uten aa ha lov til aa SKRIVE det (f.eks. org_id is null og
  -- user_id = en kollega). Da treffer UPDATE-en over NULL rader - uten denne sjekken
  -- ville funksjonen svart ok=true pa en laas den aldri fikk, og klienten trodd den
  -- kunne redigere helt til forste lagring feilet. `no_write` -> skrivebeskyttet.
  if v_rows = 0 then
    return jsonb_build_object('ok', false, 'no_write', true,
                              'by_name', coalesce(nullif(trim(r.locked_by_name), ''), ''),
                              'since', r.locked_at, 'seen', r.lock_seen_at,
                              'same_user', v_same_user);
  end if;

  return jsonb_build_object(
    'ok', true, 'by_user', auth.uid(), 'by_name', v_name,
    'since', v_since, 'seen', now(), 'same_user', true
  );
end $$;

-- --- 4. HJERTESLAG ---------------------------------------------------------
-- Oppdaterer lock_seen_at KUN naar okten fortsatt er min. Returnerer om jeg
-- fortsatt eier laasen - `false` betyr at noen har tatt over.
create or replace function project_lock_heartbeat(p_id uuid, p_session text)
  returns boolean
  language plpgsql
  security invoker
as $$
declare v_rows int;
begin
  update romtegner_projects
     set lock_seen_at = now()
   where id = p_id and lock_session = p_session and locked_by = auth.uid();
  get diagnostics v_rows = row_count;
  return v_rows > 0;
end $$;

-- --- 5. FRIGI --------------------------------------------------------------
-- Nuller alle fem feltene KUN naar okten er min. Har noen alt tatt over, er
-- dette en no-op - og det er riktig: da er laasen ikke min aa gi bort.
create or replace function project_lock_release(p_id uuid, p_session text)
  returns void
  language plpgsql
  security invoker
as $$
begin
  update romtegner_projects
     set locked_by = null, locked_by_name = null, locked_at = null,
         lock_seen_at = null, lock_session = null
   where id = p_id and lock_session = p_session and locked_by = auth.uid();
end $$;

grant execute on function project_lock_is_stale(timestamptz) to authenticated;
grant execute on function project_lock_acquire(uuid, text, boolean) to authenticated;
grant execute on function project_lock_heartbeat(uuid, text) to authenticated;
grant execute on function project_lock_release(uuid, text) to authenticated;

-- --- 6. SIKRINGEN (regel 5) -----------------------------------------------
-- `before update of data`: fyrer BARE naar `data`-blobben er med i UPDATE-ens
-- kolonneliste. En statusendring eller en kundelenke-oppdatering slipper derfor
-- gjennom uten aa se denne triggeren i det hele tatt, og INSERT roeres ikke.
--
-- OLD, ikke NEW, avgjor: det er laasen SOM DEN STAR som bestemmer om skrivingen
-- er lov. Satte en tyv locked_by = seg selv i samme UPDATE som `data`, ville NEW
-- sett lovlig ut mens OLD fortsatt viser offeret.
--
-- Hjerteslag paa gratis-tur: eieren som lagrer ER aktiv. Derfor settes
-- lock_seen_at her i stedet for i et eget RPC-kall etter hver autosave (valget
-- er dokumentert i docs/spec-prosjektlaas.md paragraf 4). Ingen rekursjon - dette endrer
-- bare NEW-raden, det kjorer ingen ny UPDATE.
create or replace function romtegner_projects_lock_guard()
  returns trigger
  language plpgsql
as $$
begin
  if old.locked_by is not null
     and old.locked_by <> auth.uid()
     and not project_lock_is_stale(old.lock_seen_at) then
    raise exception 'PROJECT_LOCKED'
      using detail = coalesce(nullif(trim(old.locked_by_name), ''), 'En kollega'),
            hint   = 'Prosjektet er apent hos en annen bruker. Laasen slipper av seg selv 3 minutter etter siste aktivitet.';
  end if;

  if old.locked_by is not null and old.locked_by = auth.uid() then
    new.lock_seen_at := now();
  end if;

  return new;
end $$;

drop trigger if exists romtegner_projects_lock_guard_trg on romtegner_projects;
create trigger romtegner_projects_lock_guard_trg
  before update of data on romtegner_projects
  for each row execute function romtegner_projects_lock_guard();

-- --- VERIFISER -------------------------------------------------------------
select
  (select count(*) from information_schema.columns
     where table_name = 'romtegner_projects'
       and column_name in ('locked_by','locked_by_name','locked_at','lock_seen_at','lock_session')) as kolonner,      -- 5
  (select count(*) from pg_proc
     where proname in ('project_lock_is_stale','project_lock_acquire',
                       'project_lock_heartbeat','project_lock_release',
                       'romtegner_projects_lock_guard'))                                            as funksjoner,    -- 5
  (select count(*) from pg_trigger
     where tgname = 'romtegner_projects_lock_guard_trg' and not tgisinternal)                        as trigger_finnes, -- 1
  (select count(*) from romtegner_projects where locked_by is not null)                              as laaste_naa;     -- 0
