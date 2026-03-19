-- CRM Extended: Add category, follow_up_date, contact_notes to customers
-- Run in Supabase Dashboard → SQL Editor

ALTER TABLE customers
  ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'business',
  ADD COLUMN IF NOT EXISTS follow_up_date DATE,
  ADD COLUMN IF NOT EXISTS contact_notes TEXT;

-- Index for filtering by category
CREATE INDEX IF NOT EXISTS idx_cust_category ON customers(org_id, category);
