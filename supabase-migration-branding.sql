-- Migration: Leverandor-/org-logo + plasseringsvalg (branding) — Del 1
-- ---------------------------------------------------------------------------
-- Logo som DATA per organisasjon (baade leverandor- og installatoer-org kan ha logo).
-- «Varmeplan» vises alltid sammen med org-logoen (co-branding); ingen logo => noytral Varmeplan.
-- Idempotent. Kjoeres manuelt i Supabase SQL Editor. TILPASS til ditt skjema om noedvendig.
-- ---------------------------------------------------------------------------

-- 1) Logo + 3 plasserings-flagg paa organizations.
alter table organizations add column if not exists logo_path          text;
alter table organizations add column if not exists logo_show_cover     boolean default false;  -- forside PDF
alter table organizations add column if not exists logo_show_allpages  boolean default false;  -- alle sider PDF
alter table organizations add column if not exists logo_show_inapp     boolean default true;   -- i appen (header/paneler)
alter table organizations add column if not exists logo_updated_at     timestamptz;

-- 2) Storage-bucket for logoer. Public read (logoer er ikke hemmelige => direkte URL i app + PDF).
insert into storage.buckets (id, name, public)
values ('branding', 'branding', true)
on conflict (id) do nothing;

-- 3) RLS paa storage.objects for 'branding': sti-prefiks = '<org_id>/...'.
--    Skriv (insert/update/delete): superadmin, ELLER owner/admin i org-en som eier stien.
--    Les: public (bucket er public) — ingen select-policy noedvendig.
--    org_id sammenlignes som TEKST (split_part gir text; cast organizations.id til text).

drop policy if exists "branding write own org" on storage.objects;
create policy "branding write own org" on storage.objects
  for all to authenticated
  using (
    bucket_id = 'branding' and (
      coalesce((auth.jwt() -> 'app_metadata' ->> 'is_superadmin')::boolean, false)
      or split_part(name, '/', 1) in (
        select org_id::text from organization_members
        where user_id = auth.uid() and role in ('owner','admin')
      )
    )
  )
  with check (
    bucket_id = 'branding' and (
      coalesce((auth.jwt() -> 'app_metadata' ->> 'is_superadmin')::boolean, false)
      or split_part(name, '/', 1) in (
        select org_id::text from organization_members
        where user_id = auth.uid() and role in ('owner','admin')
      )
    )
  );

-- Kontroll:
-- select id, name, org_type, logo_path, logo_show_cover, logo_show_allpages, logo_show_inapp
--   from organizations order by name;
-- select id, public from storage.buckets where id = 'branding';
