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
