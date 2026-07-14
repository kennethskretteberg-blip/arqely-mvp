-- ENGANGS-BACKFILL: utled sales_status fra den gamle `status`-kolonnen.
-- Run i Supabase SQL Editor. Trygg a kjore flere ganger (idempotent).
--
-- Mapping:
--   ready_quote (Tilbudsklar) -> tilbud_sendt
--   completed   (Ferdig)      -> vunnet     (delivery_status rores IKKE -> blir liggende
--                                             synlig som "Vunnet", forsvinner ikke fra lista)
--   archived    (Arkivert)    -> tapt
--   alt annet   (draft/planned/in_progress/active/NULL) -> under_arbeid (uendret)
--
-- Sikkerhet: oppdaterer KUN rader som fortsatt star pa 'under_arbeid'. Dermed
-- klobbes ikke rader som Steg 1-migrasjonen alt satte til vunnet/ferdig
-- (signert garantibevis), og ingen manuelt satt status overskrives.

UPDATE romtegner_projects
   SET sales_status = CASE status
                        WHEN 'ready_quote' THEN 'tilbud_sendt'
                        WHEN 'completed'   THEN 'vunnet'
                        WHEN 'archived'    THEN 'tapt'
                      END,
       status_changed_at = now()
 WHERE sales_status = 'under_arbeid'
   AND status IN ('ready_quote','completed','archived');

-- Verifiser fordelingen etterpa
SELECT sales_status, count(*)
FROM romtegner_projects
GROUP BY sales_status
ORDER BY sales_status;
