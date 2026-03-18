CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid REFERENCES organizations(id) NOT NULL,
  name text NOT NULL,
  contact_person text,
  email text,
  phone text,
  address text,
  postal_code text,
  city text,
  org_number text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Org members see own customers" ON customers;
CREATE POLICY "Org members see own customers" ON customers FOR ALL USING (
  org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
);
DROP POLICY IF EXISTS "Superadmin full access customers" ON customers;
CREATE POLICY "Superadmin full access customers" ON customers FOR ALL USING (
  EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_app_meta_data->>'is_superadmin' = 'true')
);
ALTER TABLE romtegner_projects ADD COLUMN IF NOT EXISTS customer_id uuid REFERENCES customers(id);
