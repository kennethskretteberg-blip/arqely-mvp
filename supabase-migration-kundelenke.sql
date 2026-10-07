-- ============================================================================
-- Migration 027: Kundelenke - kunden fyller inn maal eller tegner rommene selv.
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg aa kjore flere ganger).
-- Ren ASCII.
--
-- Sikkerhetsmodellen er den SAMME som ?present= (supabase-migration-presentation.sql):
--   * Tabellens RLS apnes ALDRI for anon.
--   * To SECURITY DEFINER-funksjoner er de ENESTE inngangene for anonyme kall.
--   * kundelenke_get velger felt EKSPLISITT fra prosjektets data - aldri `data` raatt,
--     slik at kunden bare ser geometri og navn (spec regel 1). Ingen produkter, ingen
--     priser, intet kundenavn, ingen andre prosjekter.
-- ============================================================================

-- 1) Tabell -------------------------------------------------------------------
create table if not exists public.kundelenker (
  id                uuid primary key default gen_random_uuid(),
  token             uuid not null unique default gen_random_uuid(),
  project_id        uuid not null references public.romtegner_projects(id) on delete cascade,
  org_id            uuid,
  mode              text not null default 'maal' check (mode in ('maal','tegn')),
  asked_walls       jsonb not null default '[]'::jsonb,   -- [{roomId, wallIdx}]
  note              text,
  status            text not null default 'open'
                      check (status in ('open','answered','applied','expired','revoked')),
  expires_at        timestamptz,
  created_by        uuid,
  notify_email      text,
  answer            jsonb,
  answered_at       timestamptz,
  answered_by_name  text,
  created_at        timestamptz not null default now()
);

create index if not exists kundelenker_project_idx on public.kundelenker (project_id);
create index if not exists kundelenker_org_idx     on public.kundelenker (org_id);

-- 2) RLS: kun org-medlemmer, aldri anon ---------------------------------------
alter table public.kundelenker enable row level security;

drop policy if exists kundelenker_member_select on public.kundelenker;
create policy kundelenker_member_select on public.kundelenker
  for select to authenticated
  using (org_id in (select om.org_id from public.organization_members om where om.user_id = auth.uid()));

drop policy if exists kundelenker_member_insert on public.kundelenker;
create policy kundelenker_member_insert on public.kundelenker
  for insert to authenticated
  with check (org_id in (select om.org_id from public.organization_members om where om.user_id = auth.uid()));

drop policy if exists kundelenker_member_update on public.kundelenker;
create policy kundelenker_member_update on public.kundelenker
  for update to authenticated
  using (org_id in (select om.org_id from public.organization_members om where om.user_id = auth.uid()))
  with check (org_id in (select om.org_id from public.organization_members om where om.user_id = auth.uid()));

-- 3) Anonym henting - EKSPLISITT feltutvalg ------------------------------------
-- Returnerer null naar token ikke finnes, er revoked/applied/expired, eller utlopt.
create or replace function public.kundelenke_get(p_token uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  k public.kundelenker%rowtype;
  d jsonb;
begin
  if p_token is null then return null; end if;

  select * into k from public.kundelenker where token = p_token limit 1;
  if not found then return null; end if;
  if k.status in ('revoked','expired') then return null; end if;
  if k.expires_at is not null and k.expires_at < now() then return null; end if;

  select p.data into d from public.romtegner_projects p where p.id = k.project_id limit 1;
  if d is null then return null; end if;

  return jsonb_build_object(
    'mode',        k.mode,
    'status',      k.status,
    'note',        k.note,
    'expires_at',  k.expires_at,
    'asked_walls', k.asked_walls,
    'org_name',    (select o.name from public.organizations o where o.id = k.org_id),
    'project_name', coalesce(d->>'projectName', d#>>'{project,name}', 'Prosjekt'),
    -- Kun id + navn pr. etasje.
    'floors', coalesce((
      select jsonb_agg(jsonb_build_object('id', f->'id', 'name', f->>'name'))
      from jsonb_array_elements(coalesce(d->'floors','[]'::jsonb)) f
    ), '[]'::jsonb),
    -- Kun geometri + navn pr. rom. Ingen produkter, ingen utlegg, ingen effekt.
    'rooms', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',             r->'id',
        'name',           r->>'name',
        'floorId',        r->'floorId',
        'points',         coalesce(r->'points','[]'::jsonb),
        'dimSnap',        coalesce(r->'dimSnap','false'::jsonb),
        'uncertainWalls', coalesce(r->'uncertainWalls','[]'::jsonb),
        'walls', coalesce((
          select jsonb_agg(jsonb_build_object(
            'label',  w->>'label',
            'length', w->'length',
            'x1', w->'x1', 'y1', w->'y1', 'x2', w->'x2', 'y2', w->'y2'
          ))
          from jsonb_array_elements(coalesce(r->'walls','[]'::jsonb)) w
        ), '[]'::jsonb)
      ))
      from jsonb_array_elements(coalesce(d->'rooms','[]'::jsonb)) r
      where coalesce(jsonb_array_length(r->'points'), 0) >= 3
    ), '[]'::jsonb)
  );
end;
$$;

revoke all on function public.kundelenke_get(uuid) from public;
grant execute on function public.kundelenke_get(uuid) to anon, authenticated;

-- 4) Anonymt svar --------------------------------------------------------------
-- Avviser applied/expired/revoked og utlopte lenker. Tak paa 200 kB payload.
create or replace function public.kundelenke_answer(p_token uuid, p_answer jsonb, p_name text)
returns boolean
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  k public.kundelenker%rowtype;
begin
  if p_token is null or p_answer is null then return false; end if;
  if pg_column_size(p_answer) > 200000 then return false; end if;

  select * into k from public.kundelenker where token = p_token limit 1;
  if not found then return false; end if;
  if k.status in ('applied','expired','revoked') then return false; end if;
  if k.expires_at is not null and k.expires_at < now() then return false; end if;

  update public.kundelenker
     set answer = p_answer,
         answered_at = now(),
         answered_by_name = nullif(left(coalesce(p_name,''), 120), ''),
         status = 'answered'
   where id = k.id;

  return true;
end;
$$;

revoke all on function public.kundelenke_answer(uuid, jsonb, text) from public;
grant execute on function public.kundelenke_answer(uuid, jsonb, text) to anon, authenticated;
