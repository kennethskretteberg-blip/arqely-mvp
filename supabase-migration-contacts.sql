-- ============================================================================
-- Migrasjon: Flere kontaktpersoner per kunde (contacts)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- I dag har customers ETT enkelt contact_person-felt. Denne migrasjonen legger
-- en egen contacts-tabell (1..n per customer), org-scopet GJENNOM customer.
-- customers.contact_person beholdes for bakoverkomp; eksisterende verdier
-- migreres inn som EN kontakt per kunde.
-- ============================================================================

-- --- 1. TABELL ---------------------------------------------------------------
create table if not exists contacts (
  id          uuid primary key default gen_random_uuid(),
  customer_id uuid not null references customers(id) on delete cascade,
  name        text not null,
  email       text,
  phone       text,
  created_at  timestamptz not null default now()
);
create index if not exists contacts_customer_id_idx on contacts (customer_id);

alter table contacts enable row level security;

-- --- 2. RLS: org-scopet GJENNOM customer -------------------------------------
-- En kontakt er synlig/redigerbar for org-medlemmer hvis kundens org er en av
-- mine orgs. Bruker user_org_ids() (SECURITY DEFINER) -> ingen RLS-rekursjon.
-- Samme org-monster som customers.
drop policy if exists "Org members see own contacts" on contacts;
create policy "Org members see own contacts" on contacts
  for all
  using (
    customer_id in (select c.id from customers c where c.org_id in (select user_org_ids()))
  )
  with check (
    customer_id in (select c.id from customers c where c.org_id in (select user_org_ids()))
  );

drop policy if exists "Superadmin full access contacts" on contacts;
create policy "Superadmin full access contacts" on contacts
  for all using (is_superadmin()) with check (is_superadmin());

-- --- 3. contact_id pa prosjekt (for framtidig server-rapportering) -----------
-- Appen lagrer ogsa contact_id + navn-snapshot i prosjekt-JSON; denne kolonnen
-- er for fremtidige SQL-sporringer og er ikke pakrevd av appen.
alter table romtegner_projects add column if not exists contact_id uuid references contacts(id);

-- --- 4. BACKFILL: eksisterende contact_person -> en kontakt -------------------
-- Kun for kunder som har et utfylt contact_person OG enna ingen kontakter
-- (idempotent: re-kjoring legger ikke til duplikater).
insert into contacts (customer_id, name, email, phone)
select c.id, btrim(c.contact_person), c.email, c.phone
from customers c
where c.contact_person is not null
  and btrim(c.contact_person) <> ''
  and not exists (select 1 from contacts ct where ct.customer_id = c.id);

-- --- 5. VERIFISER ------------------------------------------------------------
select
  (select count(*) from contacts)                                                 as total_contacts,
  (select count(*) from customers
     where contact_person is not null and btrim(contact_person) <> '')            as kunder_med_contact_person,
  (select count(*) from pg_policies where tablename = 'contacts')                 as contacts_policies,
  (select count(*) from information_schema.columns
     where table_name = 'romtegner_projects' and column_name = 'contact_id')      as prosjekt_contact_id_kolonne;

-- ============================================================================
-- ROLLBACK (hvis nodvendig):
--   alter table romtegner_projects drop column if exists contact_id;
--   drop table if exists contacts;
-- ============================================================================
