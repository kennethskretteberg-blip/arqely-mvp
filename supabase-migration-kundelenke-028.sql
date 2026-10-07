-- ============================================================================
-- Migration 028: kundelenken blir ugyldig naar maalene er innarbeidet.
-- Kjores manuelt i Supabase SQL Editor. Idempotent. Ren ASCII.
-- Krever at supabase-migration-kundelenke.sql (027) er kjort forst.
--
-- Hvorfor: 027s kundelenke_get avviste 'revoked' og 'expired', men IKKE 'applied'.
-- Spec regel 10 har forlopet open -> answered -> applied, og 028 setter 'applied' naar
-- Kenneth har trykket Bruk. Uten denne endringen kunne kunden apne lenken igjen etterpa
-- og se tegningen - og tro at han fortsatt kunne rette maal som alt var innarbeidet.
-- kundelenke_answer avviste 'applied' allerede fra 027; na er de to enige.
-- ============================================================================

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
  -- 028: 'applied' lagt til. Samme liste som kundelenke_answer avviser.
  if k.status in ('revoked','expired','applied') then return null; end if;
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
    'floors', coalesce((
      select jsonb_agg(jsonb_build_object('id', f->'id', 'name', f->>'name'))
      from jsonb_array_elements(coalesce(d->'floors','[]'::jsonb)) f
    ), '[]'::jsonb),
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
