-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  org_id uuid REFERENCES organizations(id),
  type text NOT NULL DEFAULT 'general',
  message text NOT NULL,
  page_context text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users insert own feedback" ON feedback;
CREATE POLICY "Users insert own feedback" ON feedback FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Superadmin reads all feedback" ON feedback;
CREATE POLICY "Superadmin reads all feedback" ON feedback FOR SELECT USING (EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_app_meta_data->>'is_superadmin' = 'true'));

-- Org print settings
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS logo_dataurl text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_company_name text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_address text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_phone text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_email text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_website text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_org_nr text;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS print_footer_text text;
