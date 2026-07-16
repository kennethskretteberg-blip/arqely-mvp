-- Migration: default varmetype per romtype (kalkyle-forhandsfyll, STEG 3)
-- Legger default_mod_type pa room_type_defaults slik at kalkyle-matrisen kan
-- forhandsfylle varmetype per rom basert pa detektert romtype.
-- Scope-hierarki (global > org > user) hondteres i frontend (_loadRoomTypeDefaults).
-- Idempotent: trygt a kjore flere ganger. Kjores manuelt i Supabase SQL Editor.

-- 1) Ny kolonne (foil | cable | mat). NULL = ingen override (frontend faller
--    tilbake pa hardkodet standard: vatrom -> mat, ellers foil).
ALTER TABLE public.room_type_defaults
  ADD COLUMN IF NOT EXISTS default_mod_type text;

-- 2) Valider verdiene nar de er satt (NULL tillatt).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'room_type_defaults_default_mod_type_chk'
  ) THEN
    ALTER TABLE public.room_type_defaults
      ADD CONSTRAINT room_type_defaults_default_mod_type_chk
      CHECK (default_mod_type IS NULL OR default_mod_type IN ('foil','cable','mat'));
  END IF;
END $$;

-- 3) Seed globale standarder for de kjente romtypene (kun der global-raden finnes
--    og verdien ikke alt er satt). Vatrom -> matte, ellers folie.
UPDATE public.room_type_defaults
   SET default_mod_type = 'mat'
 WHERE scope = 'global' AND default_mod_type IS NULL
   AND room_type_id IN ('bathroom','laundry');

UPDATE public.room_type_defaults
   SET default_mod_type = 'foil'
 WHERE scope = 'global' AND default_mod_type IS NULL
   AND room_type_id IN ('kitchen','living','bedroom','hallway','office','other');
