-- ============================================================
-- Arqely — erp_customers: org-scopet oppslagsregister fra Visma sin kundeliste
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-visma-eksporter-gbao10-del-b-revidert.md (Kenneth 04.09.2026): Cenikas kundeliste i Visma
-- er 3130 kundenumre (mange avdelinger per kjede -- Bravida/Elektroimportøren har titalls hver).
-- Varmeplan skal ALDRI fa 3130 kunderader -- dette er et OPPSLAGSREGISTER, separat fra
-- `customers` (Varmeplans egne kunder), som B1 sitt sokefelt og B3 sine forslag leser fra.
-- Additiv migrasjon -- ingen eksisterende kolonne/tabell endres.

create table if not exists erp_customers (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references organizations(id) on delete cascade,
  erp_no        text not null,
  name          text not null,
  name_norm     text not null,          -- normalisert (B2), brukt til sok/matching, ALDRI til visning
  active        boolean not null default true,   -- B2: "borte" -> false, ALDRI slettet (historikk)
  first_seen_at timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  unique (org_id, erp_no)
);

create index if not exists erp_customers_org_norm_idx on erp_customers (org_id, name_norm);
create index if not exists erp_customers_org_no_idx on erp_customers (org_id, erp_no);

alter table erp_customers enable row level security;

-- Samme monster som customers (verifisert mot pg_policies for customers 04.09.2026):
-- org-medlemmer full CRUD pa egen org, superadmin full tilgang.
create policy "Org-medlemmer CRUD erp_customers" on erp_customers
  for all
  using (org_id in (select organization_members.org_id from organization_members where organization_members.user_id = auth.uid()));

create policy "Superadmin full tilgang erp_customers" on erp_customers
  for all
  using (is_superadmin());

-- VERIFY --------------------------------------------------------
select table_name from information_schema.tables where table_name = 'erp_customers';
select policyname, cmd from pg_policies where tablename = 'erp_customers';
