-- FIX: "permission denied for table user"
-- This script diagnoses and fixes the issue.
-- Run in Supabase Dashboard → SQL Editor

-- ══════════════════════════════════════════════
-- STEP 1: DIAGNOSE — find what references 'user' table
-- ══════════════════════════════════════════════

-- Check if a table called 'user' (singular) exists
SELECT table_schema, table_name FROM information_schema.tables WHERE table_name = 'user';

-- Find ALL policies on romtegner_projects
SELECT policyname, cmd, qual::text, with_check::text
FROM pg_policies WHERE tablename = 'romtegner_projects';

-- Find ALL policies on project_versions
SELECT policyname, cmd, qual::text, with_check::text
FROM pg_policies WHERE tablename = 'project_versions';

-- Find triggers on romtegner_projects
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers WHERE event_object_table = 'romtegner_projects';

-- ══════════════════════════════════════════════
-- STEP 2: FIX — Drop all policies and recreate cleanly
-- ══════════════════════════════════════════════

-- ── romtegner_projects policies ──
DROP POLICY IF EXISTS "Bruker ser egne prosjekter" ON romtegner_projects;
DROP POLICY IF EXISTS "Superadmin ser alle prosjekter" ON romtegner_projects;
DROP POLICY IF EXISTS "Aktive brukere CRUD egne prosjekter" ON romtegner_projects;
DROP POLICY IF EXISTS "Autentiserte brukere kan opprette prosjekter" ON romtegner_projects;
DROP POLICY IF EXISTS "Users see org projects" ON romtegner_projects;

-- Recreate: Superadmin full access
CREATE POLICY "Superadmin full tilgang prosjekter" ON romtegner_projects
  FOR ALL USING (is_superadmin());

-- Recreate: Org members can SELECT their org's projects
CREATE POLICY "Org-medlemmer ser prosjekter" ON romtegner_projects
  FOR SELECT USING (
    org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
    OR user_id = auth.uid()
  );

-- Recreate: Authenticated users can INSERT (new projects)
CREATE POLICY "Autentiserte kan opprette prosjekter" ON romtegner_projects
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Recreate: Owner can UPDATE own projects
CREATE POLICY "Eier kan oppdatere prosjekter" ON romtegner_projects
  FOR UPDATE USING (
    user_id = auth.uid()
    OR org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
  );

-- Recreate: Owner can DELETE own projects
CREATE POLICY "Eier kan slette prosjekter" ON romtegner_projects
  FOR DELETE USING (
    user_id = auth.uid()
    OR org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid() AND role IN ('owner','admin'))
  );

-- ── project_versions policies (may be missing) ──
ALTER TABLE project_versions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own versions" ON project_versions;
CREATE POLICY "Users manage own versions" ON project_versions
  FOR ALL USING (
    project_id IN (
      SELECT id FROM romtegner_projects
      WHERE user_id = auth.uid()
        OR org_id IN (SELECT org_id FROM organization_members WHERE user_id = auth.uid())
    )
  );

-- ══════════════════════════════════════════════
-- STEP 3: VERIFY
-- ══════════════════════════════════════════════
SELECT policyname, cmd FROM pg_policies WHERE tablename IN ('romtegner_projects','project_versions') ORDER BY tablename, policyname;
