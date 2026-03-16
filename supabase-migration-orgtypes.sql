-- ============================================================
-- Arqely — Org types, supplier linking, invitations
-- Run in Supabase SQL Editor
-- ============================================================

-- ─── 1. ORG TYPE + SUPPLIER LINK ─────────────────────────────

-- Add org_type to organizations
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
    WHERE table_name='organizations' AND column_name='org_type') THEN
    ALTER TABLE organizations ADD COLUMN org_type text NOT NULL DEFAULT 'installer';
    -- 'supplier' | 'installer'
  END IF;
END $$;

-- Add supplier_id to organizations (links supplier org to their products)
-- This is the supplier name string that matches heating_products.supplier
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
    WHERE table_name='organizations' AND column_name='supplier_name') THEN
    ALTER TABLE organizations ADD COLUMN supplier_name text;
    -- e.g. 'Cenika AS' — matches heating_products.supplier
  END IF;
END $$;

-- Add supplier column to heating_products if not exists
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
    WHERE table_name='heating_products' AND column_name='supplier') THEN
    ALTER TABLE heating_products ADD COLUMN supplier text;
  END IF;
END $$;


-- ─── 2. INVITATIONS ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS org_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'member',  -- 'admin' | 'member'
  invited_by uuid REFERENCES auth.users(id),
  token text UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),
  status text NOT NULL DEFAULT 'pending',  -- 'pending' | 'accepted' | 'expired'
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT now() + interval '7 days'
);

-- RLS for invitations
ALTER TABLE org_invitations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Superadmin full tilgang invitations" ON org_invitations;
CREATE POLICY "Superadmin full tilgang invitations" ON org_invitations
  FOR ALL USING (is_superadmin());

DROP POLICY IF EXISTS "Org admin ser sine invitasjoner" ON org_invitations;
CREATE POLICY "Org admin ser sine invitasjoner" ON org_invitations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE org_id = org_invitations.org_id
        AND user_id = auth.uid()
        AND role IN ('owner', 'admin')
    )
  );

-- Allow org admins to insert invitations for their org
DROP POLICY IF EXISTS "Org admin kan invitere" ON org_invitations;
CREATE POLICY "Org admin kan invitere" ON org_invitations
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE org_id = org_invitations.org_id
        AND user_id = auth.uid()
        AND role IN ('owner', 'admin')
    )
  );

-- Anyone can read their own invitation (by email match with auth user)
DROP POLICY IF EXISTS "Bruker ser egne invitasjoner" ON org_invitations;
CREATE POLICY "Bruker ser egne invitasjoner" ON org_invitations
  FOR SELECT USING (
    lower(email) = lower((SELECT email FROM auth.users WHERE id = auth.uid()))
  );


-- ─── 3. AUTO-ACCEPT INVITATION ON SIGNUP ─────────────────────

-- Function: when a new user signs up, check if there's a pending invitation
-- and auto-join them to the org
CREATE OR REPLACE FUNCTION handle_invitation_on_signup()
RETURNS trigger AS $$
DECLARE
  inv RECORD;
BEGIN
  -- Find pending invitations for this email
  FOR inv IN
    SELECT * FROM org_invitations
    WHERE lower(email) = lower(NEW.email)
      AND status = 'pending'
      AND expires_at > now()
  LOOP
    -- Add user to org
    INSERT INTO organization_members (org_id, user_id, role)
    VALUES (inv.org_id, NEW.id, inv.role)
    ON CONFLICT (org_id, user_id) DO NOTHING;

    -- Mark invitation as accepted
    UPDATE org_invitations SET status = 'accepted' WHERE id = inv.id;

    -- Auto-activate the user profile
    UPDATE profiles SET status = 'active', approved_at = now() WHERE id = NEW.id;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_user_check_invitations ON auth.users;
CREATE TRIGGER on_user_check_invitations
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_invitation_on_signup();


-- ─── 4. UPDATE PRODUCT RLS — SUPPLIER FILTERING ─────────────

-- Drop old simple policy
DROP POLICY IF EXISTS "Alle autentiserte ser produkter" ON heating_products;

-- New policy: supplier orgs see only their own products, everyone else sees all
CREATE POLICY "Produkttilgang basert på org-type" ON heating_products
  FOR SELECT USING (
    -- Superadmin sees everything
    is_superadmin()
    OR
    -- Users in installer orgs (or no org) see all products
    NOT EXISTS (
      SELECT 1 FROM organization_members om
      JOIN organizations o ON o.id = om.org_id
      WHERE om.user_id = auth.uid() AND o.org_type = 'supplier'
    )
    OR
    -- Users in supplier orgs see only their supplier's products
    EXISTS (
      SELECT 1 FROM organization_members om
      JOIN organizations o ON o.id = om.org_id
      WHERE om.user_id = auth.uid()
        AND o.org_type = 'supplier'
        AND o.supplier_name = heating_products.supplier
    )
  );


-- ─── 5. VERIFY ──────────────────────────────────────────────

SELECT 'organizations' AS tbl,
  (SELECT count(*) FROM information_schema.columns WHERE table_name='organizations' AND column_name='org_type') AS has_org_type,
  (SELECT count(*) FROM information_schema.columns WHERE table_name='organizations' AND column_name='supplier_name') AS has_supplier_name;

SELECT 'org_invitations' AS tbl, count(*) FROM org_invitations;
