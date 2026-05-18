-- Migration: room_type_defaults
-- Hierarchical W/m² preferences: global (superadmin) > org (company admin) > user

CREATE TABLE IF NOT EXISTS room_type_defaults (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_type_id TEXT NOT NULL,
  label TEXT NOT NULL,
  icon TEXT DEFAULT '📐',
  target_wm2 INTEGER NOT NULL DEFAULT 100,
  sort_order INTEGER DEFAULT 0,
  scope TEXT NOT NULL DEFAULT 'global',
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  CONSTRAINT valid_scope CHECK (
    (scope = 'global' AND org_id IS NULL AND user_id IS NULL) OR
    (scope = 'org' AND org_id IS NOT NULL AND user_id IS NULL) OR
    (scope = 'user' AND user_id IS NOT NULL)
  )
);

-- Unique constraint: one entry per room_type_id per scope/org/user
CREATE UNIQUE INDEX idx_rtd_unique ON room_type_defaults (
  room_type_id,
  scope,
  COALESCE(org_id, '00000000-0000-0000-0000-000000000000'),
  COALESCE(user_id, '00000000-0000-0000-0000-000000000000')
);

-- RLS
ALTER TABLE room_type_defaults ENABLE ROW LEVEL SECURITY;

-- Everyone can read global defaults + their own org + their own user overrides
CREATE POLICY "rtd_select" ON room_type_defaults FOR SELECT USING (
  scope = 'global'
  OR (scope = 'org' AND org_id IN (SELECT om.org_id FROM organization_members om WHERE om.user_id = auth.uid()))
  OR (scope = 'user' AND user_id = auth.uid())
);

-- Superadmin can manage global defaults
CREATE POLICY "rtd_superadmin" ON room_type_defaults FOR ALL USING (
  is_superadmin() AND scope = 'global'
);

-- Org admins can manage org-level overrides for their org
CREATE POLICY "rtd_org_admin" ON room_type_defaults FOR ALL USING (
  scope = 'org'
  AND org_id IN (
    SELECT om.org_id FROM organization_members om
    WHERE om.user_id = auth.uid() AND om.role IN ('owner', 'admin')
  )
);

-- Users can manage their own personal overrides
CREATE POLICY "rtd_user" ON room_type_defaults FOR ALL USING (
  scope = 'user' AND user_id = auth.uid()
);

-- Seed global defaults
INSERT INTO room_type_defaults (room_type_id, label, icon, target_wm2, sort_order, scope) VALUES
  ('bathroom',  'Bad',       '🚿', 130, 1, 'global'),
  ('kitchen',   'Kjøkken',   '🍳', 100, 2, 'global'),
  ('living',    'Stue',      '🛋️', 80,  3, 'global'),
  ('bedroom',   'Soverom',   '🛏️', 80,  4, 'global'),
  ('laundry',   'Vaskerom',  '🧺', 130, 5, 'global'),
  ('hallway',   'Gang',      '🚪', 100, 6, 'global'),
  ('office',    'Kontor',    '💼', 80,  7, 'global'),
  ('other',     'Annet',     '📐', 100, 8, 'global')
ON CONFLICT DO NOTHING;
