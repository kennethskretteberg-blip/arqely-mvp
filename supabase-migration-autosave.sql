-- Arqely: Autosave, Versioning & Draft Project Schema Migration
-- Run this in Supabase SQL Editor before deploying code changes

-- 1. Add new columns to romtegner_projects
ALTER TABLE romtegner_projects
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS last_autosave_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS autosave_count INTEGER DEFAULT 0;

-- 2. Create project_versions table for version history
CREATE TABLE IF NOT EXISTS project_versions (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id    UUID NOT NULL REFERENCES romtegner_projects(id) ON DELETE CASCADE,
  data          JSONB NOT NULL,
  version_type  TEXT NOT NULL DEFAULT 'autosave',  -- 'autosave' | 'manual' | 'restore'
  label         TEXT,                               -- optional user label
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- 3. Indexes for version history queries
CREATE INDEX IF NOT EXISTS idx_pv_project_id ON project_versions(project_id);
CREATE INDEX IF NOT EXISTS idx_pv_created_at ON project_versions(project_id, created_at DESC);

-- 4. Index on romtegner_projects.status for filtered queries
CREATE INDEX IF NOT EXISTS idx_rp_status ON romtegner_projects(status);
