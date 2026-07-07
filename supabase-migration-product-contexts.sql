-- Migration: produkt-tilgjengelighet per modul-kontekst (indoor / outdoor)
-- ---------------------------------------------------------------------------
-- Erstatter den gamle navne-hacken (kategorinavn som inneholder "utendørs") med
-- en eksplisitt, data-drevet parameter paa hver produktkategori (gruppe):
--
--   available_contexts text[]  -- delmengde av {'indoor','outdoor'}
--
-- En gruppe kan vaere i BEGGE (f.eks. InFloor-kabel = {indoor,outdoor}).
-- Design-modulene mapper til kontekst i appen: snow + stair = outdoor, resten = indoor.
--
-- Idempotent: trygg aa kjoere flere ganger. Kjoeres manuelt i Supabase SQL Editor.
-- ---------------------------------------------------------------------------

-- 1) Ny kolonne
alter table product_categories
  add column if not exists available_contexts text[] default '{}';

-- 2) Backfill fra dagens navne-konvensjon:
--    kategorinavn med "utend..." -> outdoor, alt annet -> indoor.
--    (Kjoerer bare paa rader som ikke allerede har verdi.)
update product_categories
  set available_contexts = case
    when lower(name) like '%utend%' then array['outdoor']
    else array['indoor']
  end
  where coalesce(array_length(available_contexts, 1), 0) = 0;

-- 3) Grupper som skal vaere i BEGGE kontekstene.
--    InFloor-kabel brukes baade til innendoers gulvvarme og utendoers (snoe/trapp).
--    JUSTER navnene til dine faktiske kategorinavn foer du kjoerer.
update product_categories
  set available_contexts = array['indoor','outdoor']
  where name in ('Varmekabel');   -- <-- legg til/endre kategorinavn her

-- 4) (Valgfritt) Naar InFloor er merket {indoor,outdoor}, kan den dupliserte
--    "… utendoers"-kabelkategorien fjernes/deaktiveres. Gjoer dette MANUELT etter
--    at produktene er flyttet over til den samlede kategorien:
-- update product_categories set active = false where name = 'Varmekabel utendørs';

-- Kontroll:
-- select id, name, module_type, available_contexts from product_categories order by sort_order;
