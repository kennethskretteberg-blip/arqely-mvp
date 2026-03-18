-- Migration: Org-centric access model
-- Run via Supabase Management API or SQL Editor

-- Org reference on profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS org_id uuid REFERENCES organizations(id);

-- Org reference on projects
ALTER TABLE romtegner_projects ADD COLUMN IF NOT EXISTS org_id uuid REFERENCES organizations(id);

-- Updated trigger: auto-create org when user registers with company_name
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  new_org_id uuid;
  company text;
BEGIN
  company := NEW.raw_user_meta_data->>'company_name';

  -- Create profile
  INSERT INTO public.profiles (id, email, full_name, company_name, message)
  VALUES (
    NEW.id, NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    company,
    NEW.raw_user_meta_data->>'message'
  );

  -- If company_name provided AND no matching invitation, auto-create org
  IF company IS NOT NULL AND company != '' THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.org_invitations
      WHERE lower(email) = lower(NEW.email) AND status = 'pending' AND expires_at > now()
    ) THEN
      INSERT INTO public.organizations (name, slug, org_type)
      VALUES (company, lower(regexp_replace(company, '[^a-zA-Z0-9]+', '-', 'g')), 'installer')
      RETURNING id INTO new_org_id;

      -- Make user owner of new org
      INSERT INTO public.organization_members (org_id, user_id, role)
      VALUES (new_org_id, NEW.id, 'owner');

      -- Link profile to org
      UPDATE public.profiles SET org_id = new_org_id WHERE id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- RLS: Users see org projects
DROP POLICY IF EXISTS "Users see org projects" ON romtegner_projects;
CREATE POLICY "Users see org projects" ON romtegner_projects
  FOR SELECT USING (
    org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
    OR user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_app_meta_data->>'is_superadmin' = 'true')
  );
