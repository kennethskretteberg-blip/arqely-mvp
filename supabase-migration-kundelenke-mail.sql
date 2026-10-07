-- ============================================================================
-- Migration 029: e-post for kundelenker (invitasjon ut, varsel inn).
-- Kjores manuelt i Supabase SQL Editor. Idempotent. Ren ASCII.
-- Krever supabase-migration-kundelenke.sql (027) og -028.sql.
--
-- Tre additive kolonner. Ingen RLS-endring: tabellen er fortsatt stengt for anon, og
-- Edge-funksjonen kjorer med service role.
--   last_notified_at - naar det sist gikk et svarvarsel for denne lenken. Rate-grensa
--                      (maks ett varsel per 10 min) leses OG skrives kun av funksjonen,
--                      slik at en anonym kaller ikke kan bruke den som e-postkanon.
--   invite_sent_to   - hvem invitasjonen sist ble sendt til. Eneste stedet kundens
--                      e-postadresse lagres (spec: ingen lagring utover dette).
--   invite_sent_at   - naar.
-- ============================================================================

alter table public.kundelenker add column if not exists last_notified_at timestamptz;
alter table public.kundelenker add column if not exists invite_sent_to   text;
alter table public.kundelenker add column if not exists invite_sent_at   timestamptz;
