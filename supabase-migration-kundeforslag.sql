-- ============================================================================
-- 043 - Kundeforslag: mode='forslag' paa kundelenker
--
-- MAALT 08.10.2026 foer denne filen ble skrevet:
--   kundelenker.mode har en CHECK-constraint `mode in ('maal','tegn')` fra 027.
--   Et forsoek paa aa sette 'forslag' ville derfor feilet med 23514, ikke stille.
--   Dette er den ENESTE skjemaendringen 043 trenger:
--     - kundelenke_answer er formagnostisk (lagrer p_answer som jsonb, kun stoerrelsescap),
--       saa svarformen { rooms:[...], approveAll, comment } trengs ingen endring for.
--     - kundelenke_get returnerer allerede mode/status/note/expires_at/org_name, som er alt
--       forslagssiden trenger. Selve prosjektet hentes som foer via get_present_project paa
--       ?present=-lenken, saa ingen ny data eksponeres anonymt.
--
-- Idempotent: kan kjoeres flere ganger.
-- ============================================================================

do $$
declare
  c_name text;
begin
  -- Finn constrainten uansett hva den heter (027 ga den systemgenerert navn).
  select con.conname into c_name
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace ns on ns.oid = rel.relnamespace
   where ns.nspname = 'public'
     and rel.relname = 'kundelenker'
     and con.contype = 'c'
     and pg_get_constraintdef(con.oid) ilike '%mode%'
   limit 1;

  if c_name is not null then
    execute format('alter table public.kundelenker drop constraint %I', c_name);
  end if;

  alter table public.kundelenker
    add constraint kundelenker_mode_check
    check (mode in ('maal','tegn','forslag'));
end $$;

-- ----------------------------------------------------------------------------
-- 044 - "Godkjenn hele prosjektet" som signal.
--
-- Hvorfor to kolonner og ikke bare lese answer->'approveAll': prosjektlistas merke hentes med
-- EN spoerring over alle aapne/besvarte lenker. `answer` er en jsonb som kan vaere opptil
-- 200 kB per rad (kundelenke_answer sin egen cap), saa aa dra den med i listespoerringen for aa
-- se etter ett felt ville vaert dyrt. Kolonnene settes server-side av kundelenke_answer, saa
-- klienten kan ikke sette dem uten aa gaa gjennom RPC-en.
-- ----------------------------------------------------------------------------

alter table public.kundelenker
  add column if not exists approve_all_at   timestamptz,
  add column if not exists approve_all_name text;

create or replace function public.kundelenke_answer(p_token uuid, p_answer jsonb, p_name text)
returns boolean
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  k public.kundelenker%rowtype;
  aa jsonb;
begin
  if p_token is null or p_answer is null then return false; end if;
  if pg_column_size(p_answer) > 200000 then return false; end if;

  select * into k from public.kundelenker where token = p_token limit 1;
  if not found then return false; end if;
  if k.status in ('applied','expired','revoked') then return false; end if;
  if k.expires_at is not null and k.expires_at < now() then return false; end if;

  -- 044: tidspunktet tas fra serveren (now()), ikke fra klientens 'at' - en kunde skal ikke
  -- kunne datere en godkjenning. Navnet er det samme som svaret ellers signeres med.
  aa := p_answer -> 'approveAll';

  update public.kundelenker
     set answer = p_answer,
         answered_at = now(),
         answered_by_name = nullif(left(coalesce(p_name,''), 120), ''),
         status = 'answered',
         approve_all_at   = case when aa is not null and aa <> 'null'::jsonb then now() else null end,
         approve_all_name = case when aa is not null and aa <> 'null'::jsonb
                                 then nullif(left(coalesce(aa->>'name', p_name, ''), 120), '')
                                 else null end
   where id = k.id;

  return true;
end;
$$;

-- ----------------------------------------------------------------------------
-- 044 - resultatet av behandlingen, saa kundesiden kan vise hva som ble godkjent/avslaatt.
-- MAALT: `kundelenker` hadde ingen applied_*-kolonner fra 027/028 - statusen ble satt til
-- 'applied', men HVA som ble gjort ble aldri lagret noe sted.
-- ----------------------------------------------------------------------------

alter table public.kundelenker
  add column if not exists applied_at     timestamptz,
  add column if not exists applied_result jsonb;
