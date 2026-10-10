-- ============================================================================
-- Migration 055: kundedialog-logg. Hendelser uten egen kolonne.
-- Kjores manuelt i Supabase SQL Editor. Idempotent. Ren ASCII.
-- Krever supabase-migration-kundelenke.sql (027) kjort forst.
--
-- Hvorfor en kolonne og ikke en tabell: MAALT 10.10.2026 (STEG 0.1) at nesten
-- hele dialogen alt ligger i `kundelenker` - created_at, invite_sent_at,
-- answered_at, answer, approve_all_at, applied_result (053), svar_sendt_at (053).
-- Loggen kan altsaa AVLEDES. Det eneste som mangler er hendelser uten egen
-- kolonne: at lenka ble kopiert til e-post, og at den ble trukket tilbake.
--
-- `hendelser || $1` i en RPC i stedet for les-endre-skriv i klienten: to vinduer
-- som logger samtidig skal ikke overskrive hverandre.
-- ============================================================================

alter table public.kundelenker
  add column if not exists hendelser jsonb not null default '[]'::jsonb;

comment on column public.kundelenker.hendelser is
  '055: hendelser uten egen kolonne - kopiert, trukket, paaminnelse. '
  'Kundens egne handlinger logges IKKE her; de staar i answer/answered_at.';

-- security INVOKER med vilje: RLS paa `kundelenker` avgjor hvem som kan skrive,
-- akkurat som for en vanlig update. Anonyme veier (kundelenke_get/_answer) rorer
-- aldri denne funksjonen.
create or replace function public.kundelenke_logg(p_id uuid, p_hendelse jsonb)
returns void
language sql
security invoker
set search_path = public
as $$
  update public.kundelenker
     set hendelser = coalesce(hendelser, '[]'::jsonb) || jsonb_build_array(p_hendelse)
   where id = p_id;
$$;

revoke all on function public.kundelenke_logg(uuid, jsonb) from public;
grant execute on function public.kundelenke_logg(uuid, jsonb) to authenticated;
