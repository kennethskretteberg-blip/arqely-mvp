-- ============================================================================
-- Migration 053: kundeforslag - beslutningene lagres per rom, og svaret til
-- kunden blir valgfritt.
-- Kjores manuelt i Supabase SQL Editor. Idempotent. Ren ASCII.
-- Krever supabase-migration-kundeforslag.sql (044) kjort forst.
--
-- Hvorfor: MAALT 10.10.2026 (STEG 0.1). Godkjenn/Avslaa skrev bare til en Map i
-- minnet (`_forslagRevState.behandlet`). Etter en ny innlasting var beslutningen
-- borte, status fortsatt 'answered', og panelet apnet igjen med alle rom som
-- ubehandlet - selv om utlegget i rommet ALT var byttet. Eneste vei til
-- 'applied' var knappen "Send svar til kunden", som Kenneth ikke vil trykke.
--
-- 044 la alt til `applied_at` og `applied_result`. Det som manglet var et skille
-- mellom "ferdig behandlet" og "svar sendt til kunden" - de er na to ting:
--   status='applied' + applied_at  = Kenneth er ferdig (ingen e-post)
--   svar_sendt_at                  = e-post faktisk sendt til kunden
-- ============================================================================

alter table public.kundelenker
  add column if not exists svar_sendt_at timestamptz;

comment on column public.kundelenker.svar_sendt_at is
  '053: naar "Send svar til kunden" faktisk ble trykket. NULL = forslaget kan '
  'vaere ferdig behandlet (status=applied) uten at kunden har faatt beskjed. '
  'Skilt fra applied_at med vilje - se spec-kundeforslag regel 7 og 13.';
