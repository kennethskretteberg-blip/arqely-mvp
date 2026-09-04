-- ============================================================
-- Arqely — customers.erp_customer_no (kundenr. i Visma/annet ERP)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-visma-eksporter-gbao10-del-a-f.md DEL B (Kenneth 04.09.2026): fila oppretter tilbudet
-- (paste-veien slapp unna dette -- brukeren star allerede i riktig tilbud der), sa felt 3 i
-- GBAO10-linja ma vaere kundens nummer i Visma. customers er org-scopet -- en kunderad tilhorer
-- EN organisasjon, sa ett nummer pa raden er entydig. Ingen koblingstabell.
--
-- erp_customer_no, IKKE visma_customer_no -- kolonnen er den samme uansett ERP; organizations
-- sitt eget erp_format (DEL A) sier hvilket. Samme ERP-noytrale monster som a405a75.

alter table customers add column if not exists erp_customer_no text;

-- VERIFY --------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'customers' and column_name = 'erp_customer_no';
