-- ============================================================================
-- Migrasjon: Eier-styrt leverandortilgang per bedrift (4A)
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- Plattform-eier (superadmin) bestemmer hvilke LEVERANDORER hver installator-bedrift
-- ser. Et produkt er synlig for en installator-org KUN hvis bedriften er innvilget
-- tilgang til produktets leverandor. Leverandor-orgs ser fortsatt kun egne produkter.
-- Superadmin ser alt.
--
-- Default (bekreftet): NYE installator-orgs og brukere UTEN org-medlemskap ser INGEN
-- produkter for eier innvilger. Eksisterende installator-orgs bevares via seed (del 2).
-- ============================================================================

-- ─── 1. KOBLINGSTABELL (eier <-> bedrift <-> leverandor) ────────────────────
create table if not exists organization_supplier_access (
  org_id      uuid    not null references organizations(id) on delete cascade,
  supplier_id uuid    not null references suppliers(id)      on delete cascade,
  enabled     boolean not null default true,
  granted_by  uuid,
  created_at  timestamptz not null default now(),
  primary key (org_id, supplier_id)
);

alter table organization_supplier_access enable row level security;

-- Superadmin: full tilgang (les + skriv). Kun eier styrer innvilgelser.
drop policy if exists "osa superadmin full" on organization_supplier_access;
create policy "osa superadmin full" on organization_supplier_access
  for all using (is_superadmin()) with check (is_superadmin());

-- Org-medlemmer kan SE egne org-rader (appen leser egen tilgang). INSERT/UPDATE/DELETE
-- har INGEN medlems-policy -> kun superadmin kan skrive (eier styrer).
drop policy if exists "osa medlemmer ser egne" on organization_supplier_access;
create policy "osa medlemmer ser egne" on organization_supplier_access
  for select using (
    exists (
      select 1 from organization_members om
      where om.org_id = organization_supplier_access.org_id
        and om.user_id = auth.uid()
    )
  );

-- ─── 2. SEED (bevar dagens oppforsel for EKSISTERENDE installator-orgs) ─────
-- Alle eksisterende installator-orgs far tilgang til alle eksisterende leverandorer,
-- sa ingenting "forsvinner" for de som tester i dag. NYE orgs starter uten tilgang.
-- Re-kjoring legger ikke til duplikater.
insert into organization_supplier_access (org_id, supplier_id, enabled)
select o.id, s.id, true
from organizations o
cross join suppliers s
where o.org_type = 'installer'
on conflict (org_id, supplier_id) do nothing;

-- ─── 3. NY PRODUKT-RLS (erstatter "installator ser alt" med grant-styring) ──
-- VIKTIG: den gamle policyen ma droppes med EKSAKT navn (inneholder 'pa').
drop policy if exists "Produkttilgang basert på org-type" on heating_products;
drop policy if exists "Produkttilgang via leverandor-grant" on heating_products;

create policy "Produkttilgang via leverandor-grant" on heating_products
  for select using (
    -- a) Superadmin ser alt
    is_superadmin()
    or
    -- b) Leverandor-org som EIER produktet (uendret: supplier_name = heating_products.supplier)
    exists (
      select 1 from organization_members om
      join organizations o on o.id = om.org_id
      where om.user_id = auth.uid()
        and o.org_type = 'supplier'
        and o.supplier_name = heating_products.supplier
    )
    or
    -- c) Installator-org/bruker med ENABLED grant for produktets leverandor.
    --    Match pa supplier_id nar satt; fall tilbake til navn nar supplier_id er null.
    exists (
      select 1
      from organization_members om
      join organization_supplier_access osa on osa.org_id = om.org_id and osa.enabled = true
      join suppliers s on s.id = osa.supplier_id
      where om.user_id = auth.uid()
        and (
          (heating_products.supplier_id is not null and s.id = heating_products.supplier_id)
          or
          (heating_products.supplier_id is null and s.name = heating_products.supplier)
        )
    )
  );

-- ─── 4. VERIFISER ──────────────────────────────────────────────────────────
select
  (select count(*) from organization_supplier_access)                              as grants_seeded,
  (select count(*) from organizations where org_type = 'installer')                as installer_orgs,
  (select count(*) from suppliers)                                                  as suppliers,
  (select count(*) from heating_products where supplier_id is null)                as produkter_uten_supplier_id,
  (select count(*) from pg_policies
     where tablename = 'heating_products'
       and policyname = 'Produkttilgang via leverandor-grant')                     as ny_policy_aktiv,
  (select count(*) from pg_policies
     where tablename = 'heating_products'
       and policyname = 'Produkttilgang basert på org-type')                       as gammel_policy_skal_vaere_0;

-- ============================================================================
-- ROLLBACK (hvis nodvendig) — gjenoppretter "installator ser alt":
--   drop policy if exists "Produkttilgang via leverandor-grant" on heating_products;
--   create policy "Produkttilgang basert på org-type" on heating_products
--     for select using (
--       is_superadmin()
--       or not exists (select 1 from organization_members om
--                      join organizations o on o.id = om.org_id
--                      where om.user_id = auth.uid() and o.org_type = 'supplier')
--       or exists (select 1 from organization_members om
--                  join organizations o on o.id = om.org_id
--                  where om.user_id = auth.uid() and o.org_type = 'supplier'
--                    and o.supplier_name = heating_products.supplier)
--     );
--   drop table if exists organization_supplier_access;
-- ============================================================================
