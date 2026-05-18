-- Steg 1: Finn user_id
-- SELECT id, email FROM auth.users;

-- Steg 2: Lim inn user_id under og kjør
DO $$
DECLARE
  v_user_id uuid := 'DIN-UUID-HER';  -- ← bytt ut
  v_org_id uuid;
BEGIN
  IF EXISTS (SELECT 1 FROM organization_members WHERE user_id = v_user_id) THEN
    RAISE NOTICE 'Bruker er allerede medlem av en organisasjon — ingen endring';
    RETURN;
  END IF;

  INSERT INTO organizations (name, org_type)
  VALUES ('Demo', 'installer')
  RETURNING id INTO v_org_id;

  INSERT INTO organization_members (user_id, org_id, role)
  VALUES (v_user_id, v_org_id, 'owner');

  RAISE NOTICE 'Opprettet org % og la til bruker %', v_org_id, v_user_id;
END $$;
