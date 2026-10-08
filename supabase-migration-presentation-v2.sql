-- ============================================================================
-- 041 - get_present_project: returns table -> returns jsonb
--
-- MAALT 08.10.2026 mot den deployede RPC-en:
--   get_present_project med ukjent token  ->  []      (en LISTE)
--   kundelenke_get       med ukjent token  ->  null    (en skalar)
--
-- En `returns table` kommer tilbake fra supabase-js som `[{id, name, data}]`. Klienten leste
-- `data.data` rett paa lista, som er `undefined`, saa et HELT GYLDIG token ga "fant ikke
-- prosjekt" - Kenneth havnet paa dashbordet og kunden ville fatt innloggingsskjermen.
--
-- Klienten er rettet til aa taale begge former (`Array.isArray(data) ? data[0] : data`), saa
-- denne migrasjonen er IKKE paakrevd. Den gjoer funksjonen lik `kundelenke_get` fra 027, saa
-- neste leser ikke gaar i samme felle.
--
-- Sikkerhetsmodellen er UENDRET: security definer, samme search_path, samme grants, og
-- fortsatt kun oppslag paa eksakt token (anon kan ikke liste delte prosjekter).
--
-- Idempotent: kan kjoeres flere ganger.
-- ============================================================================

-- Den gamle signaturen maa slippes foerst: PostgreSQL tillater ikke at en funksjon bytter
-- returtype med `create or replace`.
drop function if exists public.get_present_project(text);

create or replace function public.get_present_project(p_token text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object('id', p.id, 'name', p.name, 'data', p.data)
  from public.romtegner_projects p
  where p_token is not null
    and p.present_token = p_token
  limit 1;
$$;

revoke all on function public.get_present_project(text) from public;
grant execute on function public.get_present_project(text) to anon, authenticated;
