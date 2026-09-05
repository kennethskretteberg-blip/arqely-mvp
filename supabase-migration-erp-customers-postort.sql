-- ============================================================
-- Arqely — erp_customers.postal_code + city (Postnr/Poststed fra Visma-uttrekket)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-visma-opprett-kunde-fra-register.md (Kenneth 05.09.2026): "Opprett kunde direkte fra
-- Visma-registeret" trenger postnr/poststed for a kunne fylle en ny customers-rad fullt ut ved
-- ett klikk, ikke bare navn+nummer+org.nr (57697fc). Additivt -- ingen eksisterende kolonne endres.
-- Valgfritt ved import: en fil uten disse kolonnene skal fortsatt kunne synkes (kolonnene star tomme).

alter table erp_customers add column if not exists postal_code text;
alter table erp_customers add column if not exists city text;

-- VERIFY --------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'erp_customers' and column_name in ('postal_code', 'city');
