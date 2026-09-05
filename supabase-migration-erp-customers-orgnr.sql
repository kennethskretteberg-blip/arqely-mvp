-- ============================================================
-- Arqely — erp_customers.org_number (organisasjonsnummer fra Visma-uttrekket)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-visma-kundeliste-synk-ekte-fil.md (Kenneth 05.09.2026): Cenikas ekte uttrekk har org.nr pa
-- 3034 av 3130 rader, og kundekortet i Varmeplan har allerede et org.nr-felt. Organisasjonsnummer
-- er identitet -- navnematching er gjetting. Valgfri kolonne: fila kan mangle den, og 69 rader i
-- uttrekket (utenlandske firma, privatpersoner) har ingen.

alter table erp_customers add column if not exists org_number text;
create index if not exists erp_customers_org_orgnumber_idx on erp_customers (org_id, org_number);

-- VERIFY --------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'erp_customers' and column_name = 'org_number';
