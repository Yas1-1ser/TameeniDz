-- =============================================================
-- MIGRATION: role_separated_schema
-- Date: 2026-05-15
-- Description: Separate DB tables by role (client/operator/admin).
--              ADDITIVE ONLY — no existing tables or data are dropped.
-- Apply via: Supabase Dashboard → SQL Editor → Run
-- =============================================================

-- ─── STEP 0: BACKUPS ──────────────────────────────────────────
-- Safety backup of existing policies before any migration.
CREATE TABLE IF NOT EXISTS public.backup_policies_20260515
  AS SELECT * FROM public.policies;

-- ─── STEP 1: PROFILES VIEW ────────────────────────────────────
-- Maps existing `users` table to the new `profiles` naming convention.
-- The `users` table remains the authoritative source of truth.
--
-- If a `profiles` TABLE already exists, back it up then drop it
-- so we can create the VIEW alias instead.
DO $$
BEGIN
  -- Case 1: profiles exists as a plain TABLE → backup and drop
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name   = 'profiles'
      AND table_type   = 'BASE TABLE'
  ) THEN
    EXECUTE 'CREATE TABLE IF NOT EXISTS public.backup_profiles_20260515 AS SELECT * FROM public.profiles';
    EXECUTE 'DROP TABLE public.profiles CASCADE';
    RAISE NOTICE 'Existing profiles TABLE backed up to backup_profiles_20260515 and dropped.';

  -- Case 2: profiles already exists as a VIEW → drop so we can recreate
  ELSIF EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'public'
      AND table_name   = 'profiles'
  ) THEN
    EXECUTE 'DROP VIEW public.profiles';
    RAISE NOTICE 'Existing profiles VIEW dropped for recreation.';
  END IF;
END $$;

CREATE VIEW public.profiles AS
  SELECT
    id,
    email,
    phone_number   AS phone,
    full_name,
    NULL::text     AS avatar_url,
    role,
    'ar'::text     AS preferred_language,
    true::boolean  AS is_active,
    created_at,
    updated_at
  FROM public.users;

GRANT SELECT ON public.profiles TO authenticated;

-- ─── STEP 2: CLIENT TABLES ────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.client_profiles (
  id            UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  national_id   TEXT UNIQUE,
  date_of_birth DATE,
  address       TEXT,
  wilaya        TEXT,
  commune       TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.client_profiles TO authenticated;

CREATE TABLE IF NOT EXISTS public.client_policies (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  policy_number       TEXT UNIQUE NOT NULL,
  policy_type         TEXT NOT NULL DEFAULT 'auto'
                      CHECK (policy_type IN ('auto','health','home','travel','life')),
  company_name        TEXT NOT NULL DEFAULT 'غير محدد',
  operator_id         TEXT,
  plan_id             TEXT,
  plan_name           TEXT,
  start_date          DATE,
  end_date            DATE,
  premium_amount      NUMERIC(10,2) NOT NULL DEFAULT 0,
  status              TEXT DEFAULT 'pending'
                      CHECK (status IN (
                        'active','expired','cancelled','pending',
                        'accepted','rejected','paid','modificationRequested'
                      )),
  document_urls       JSONB,
  admin_notes         TEXT,
  applicant_full_name TEXT,
  applicant_id_number TEXT,
  receipt_url         TEXT,
  receipt_number      TEXT,
  accepted_at         TIMESTAMPTZ,
  paid_at             TIMESTAMPTZ,
  submitted_at        TIMESTAMPTZ DEFAULT NOW(),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.client_policies TO authenticated;

CREATE TABLE IF NOT EXISTS public.client_claims (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  policy_id        UUID REFERENCES public.client_policies(id),
  claim_number     TEXT UNIQUE NOT NULL
                   DEFAULT 'CLM-' || upper(substr(md5(random()::text), 1, 8)),
  claim_type       TEXT NOT NULL DEFAULT 'general',
  description      TEXT,
  amount_requested NUMERIC(10,2),
  amount_approved  NUMERIC(10,2),
  status           TEXT DEFAULT 'pending'
                   CHECK (status IN ('pending','under_review','approved','rejected','paid')),
  submitted_at     TIMESTAMPTZ DEFAULT NOW(),
  resolved_at      TIMESTAMPTZ,
  operator_id      UUID REFERENCES public.users(id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.client_claims TO authenticated;

CREATE TABLE IF NOT EXISTS public.client_documents (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL DEFAULT 'other'
                CHECK (document_type IN ('id_card','driving_license','policy','claim_proof','other')),
  file_url      TEXT NOT NULL,
  file_name     TEXT,
  uploaded_at   TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.client_documents TO authenticated;

CREATE TABLE IF NOT EXISTS public.client_road_assistance (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id            UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  policy_id            UUID REFERENCES public.client_policies(id),
  location_lat         NUMERIC,
  location_lng         NUMERIC,
  location_description TEXT,
  issue_type           TEXT,
  status               TEXT DEFAULT 'pending'
                       CHECK (status IN ('pending','dispatched','resolved','cancelled')),
  requested_at         TIMESTAMPTZ DEFAULT NOW(),
  resolved_at          TIMESTAMPTZ
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.client_road_assistance TO authenticated;

-- ─── STEP 3: OPERATOR TABLES ──────────────────────────────────

CREATE TABLE IF NOT EXISTS public.operator_profiles (
  id                UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  company_name      TEXT NOT NULL DEFAULT 'غير محدد',
  license_number    TEXT UNIQUE,
  wilaya            TEXT,
  commission_rate   NUMERIC(5,2) DEFAULT 4.00,
  total_premiums    NUMERIC(12,2) DEFAULT 0,
  total_commissions NUMERIC(12,2) DEFAULT 0,
  is_verified       BOOLEAN DEFAULT false,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.operator_profiles TO authenticated;

CREATE TABLE IF NOT EXISTS public.operator_companies (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  company_name          TEXT NOT NULL,
  commission_rate       NUMERIC(5,2) NOT NULL DEFAULT 4.00,
  total_premiums        NUMERIC(12,2) DEFAULT 0,
  total_commissions_due NUMERIC(12,2) DEFAULT 0,
  contract_start        DATE,
  contract_end          DATE,
  is_active             BOOLEAN DEFAULT true,
  created_at            TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.operator_companies TO authenticated;

CREATE TABLE IF NOT EXISTS public.operator_commissions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  company_id        UUID REFERENCES public.operator_companies(id),
  month             INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year              INTEGER NOT NULL,
  total_premiums    NUMERIC(12,2) DEFAULT 0,
  commission_rate   NUMERIC(5,2) DEFAULT 4.00,
  commission_amount NUMERIC(12,2) DEFAULT 0,
  is_paid           BOOLEAN DEFAULT false,
  paid_at           TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(operator_id, company_id, month, year)
);
GRANT SELECT, INSERT, UPDATE ON public.operator_commissions TO authenticated;

CREATE TABLE IF NOT EXISTS public.operator_clients (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  client_id   UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  is_active   BOOLEAN DEFAULT true,
  UNIQUE(operator_id, client_id)
);
GRANT SELECT, INSERT, UPDATE ON public.operator_clients TO authenticated;

CREATE TABLE IF NOT EXISTS public.operator_legal_log (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  action_type       TEXT NOT NULL,
  description       TEXT,
  related_client_id UUID REFERENCES public.users(id),
  related_claim_id  UUID REFERENCES public.client_claims(id),
  performed_at      TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT ON public.operator_legal_log TO authenticated;

-- ─── STEP 4: ADMIN TABLES ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.admin_profiles (
  id                 UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  admin_level        INTEGER DEFAULT 1 CHECK (admin_level IN (1, 2, 3)),
  department         TEXT,
  two_factor_enabled BOOLEAN DEFAULT true,
  last_login         TIMESTAMPTZ,
  created_at         TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.admin_profiles TO authenticated;

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  action       TEXT NOT NULL,
  target_table TEXT,
  target_id    UUID,
  old_value    JSONB,
  new_value    JSONB,
  ip_address   TEXT,
  performed_at TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT ON public.admin_audit_log TO authenticated;

CREATE TABLE IF NOT EXISTS public.admin_settings (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key   TEXT UNIQUE NOT NULL,
  setting_value JSONB,
  description   TEXT,
  updated_by    UUID REFERENCES public.users(id),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.admin_settings TO authenticated;

CREATE TABLE IF NOT EXISTS public.admin_user_actions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id       UUID NOT NULL REFERENCES public.users(id),
  target_user_id UUID NOT NULL REFERENCES public.users(id),
  action         TEXT NOT NULL
                 CHECK (action IN ('activate','deactivate','role_change','delete','reset_password','verify')),
  reason         TEXT,
  performed_at   TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT ON public.admin_user_actions TO authenticated;

CREATE TABLE IF NOT EXISTS public.admin_notifications (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_by     UUID NOT NULL REFERENCES public.users(id),
  title          TEXT NOT NULL,
  body           TEXT NOT NULL,
  target_role    TEXT CHECK (target_role IN ('client','operator','admin','all')),
  target_user_id UUID REFERENCES public.users(id),
  is_read        BOOLEAN DEFAULT false,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);
GRANT SELECT, INSERT, UPDATE ON public.admin_notifications TO authenticated;

-- ─── STEP 5: MIGRATE POLICIES → CLIENT_POLICIES ───────────────
INSERT INTO public.client_policies (
  id, client_id, policy_number, policy_type, company_name, operator_id,
  plan_id, plan_name, premium_amount, status, document_urls, admin_notes,
  applicant_full_name, applicant_id_number, receipt_url, receipt_number,
  accepted_at, paid_at, submitted_at, created_at
)
SELECT
  p.id,
  p.client_id,
  COALESCE(p.receipt_number, 'POL-' || upper(substr(p.id::text, 1, 8))) AS policy_number,
  'auto' AS policy_type,
  CASE
    WHEN p.operator_id = 'algeria_takaful' THEN 'الجزائر للتكافل'
    WHEN p.operator_id = 'al_ittihad'      THEN 'الاتحاد للتأمين'
    ELSE 'غير محدد'
  END AS company_name,
  p.operator_id,
  p.plan_id,
  p.plan_id AS plan_name,
  COALESCE(p.amount, 0) AS premium_amount,
  COALESCE(p.status, 'pending'),
  NULL AS document_urls,
  p.admin_notes,
  NULL AS applicant_full_name,
  NULL AS applicant_id_number,
  p.receipt_url,
  p.receipt_number,
  p.accepted_at,
  p.paid_at,
  COALESCE(p.submitted_at, NOW()),
  COALESCE(p.submitted_at, NOW())
FROM public.policies p
WHERE p.client_id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- ─── STEP 6: ENABLE RLS ───────────────────────────────────────
ALTER TABLE public.client_profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_policies        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_claims          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_documents       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_road_assistance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operator_profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operator_companies     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operator_commissions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operator_clients       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operator_legal_log     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_log        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_settings         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_user_actions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_notifications    ENABLE ROW LEVEL SECURITY;

-- ─── STEP 7: RLS POLICIES — CLIENT ────────────────────────────
-- Uses private.current_user_role() — already exists and is SECURITY DEFINER

DROP POLICY IF EXISTS "clients_own_profile"       ON public.client_profiles;
DROP POLICY IF EXISTS "admin_client_profiles"      ON public.client_profiles;
CREATE POLICY "clients_own_profile"  ON public.client_profiles
  FOR ALL TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "admin_client_profiles" ON public.client_profiles
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "clients_own_policies"              ON public.client_policies;
DROP POLICY IF EXISTS "operators_view_client_policies"    ON public.client_policies;
DROP POLICY IF EXISTS "operators_update_client_policies"  ON public.client_policies;
DROP POLICY IF EXISTS "admin_all_client_policies"         ON public.client_policies;
CREATE POLICY "clients_own_policies" ON public.client_policies
  FOR ALL TO authenticated USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());
CREATE POLICY "operators_view_client_policies" ON public.client_policies
  FOR SELECT TO authenticated
  USING (
    private.current_user_role() = 'operator' AND (
      operator_id IN (SELECT company FROM public.users WHERE id = auth.uid()) OR
      client_id   IN (SELECT client_id FROM public.operator_clients WHERE operator_id = auth.uid() AND is_active = true)
    )
  );
CREATE POLICY "operators_update_client_policies" ON public.client_policies
  FOR UPDATE TO authenticated
  USING (
    private.current_user_role() = 'operator' AND
    operator_id IN (SELECT company FROM public.users WHERE id = auth.uid())
  )
  WITH CHECK (
    private.current_user_role() = 'operator' AND
    operator_id IN (SELECT company FROM public.users WHERE id = auth.uid())
  );
CREATE POLICY "admin_all_client_policies" ON public.client_policies
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "clients_own_claims"   ON public.client_claims;
DROP POLICY IF EXISTS "operators_own_claims" ON public.client_claims;
DROP POLICY IF EXISTS "admin_all_claims"     ON public.client_claims;
CREATE POLICY "clients_own_claims" ON public.client_claims
  FOR ALL TO authenticated USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());
CREATE POLICY "operators_own_claims" ON public.client_claims
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'operator' AND operator_id = auth.uid())
  WITH CHECK (private.current_user_role() = 'operator' AND operator_id = auth.uid());
CREATE POLICY "admin_all_claims" ON public.client_claims
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "clients_own_documents" ON public.client_documents;
DROP POLICY IF EXISTS "admin_all_documents"   ON public.client_documents;
CREATE POLICY "clients_own_documents" ON public.client_documents
  FOR ALL TO authenticated USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());
CREATE POLICY "admin_all_documents" ON public.client_documents
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "clients_own_road_assistance" ON public.client_road_assistance;
CREATE POLICY "clients_own_road_assistance" ON public.client_road_assistance
  FOR ALL TO authenticated USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());

-- ─── STEP 8: RLS POLICIES — OPERATOR ─────────────────────────

DROP POLICY IF EXISTS "operators_own_profile" ON public.operator_profiles;
DROP POLICY IF EXISTS "admin_all_op_profiles" ON public.operator_profiles;
CREATE POLICY "operators_own_profile" ON public.operator_profiles
  FOR ALL TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "admin_all_op_profiles" ON public.operator_profiles
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "operators_own_companies" ON public.operator_companies;
DROP POLICY IF EXISTS "admin_all_op_companies"  ON public.operator_companies;
CREATE POLICY "operators_own_companies" ON public.operator_companies
  FOR ALL TO authenticated USING (operator_id = auth.uid()) WITH CHECK (operator_id = auth.uid());
CREATE POLICY "admin_all_op_companies" ON public.operator_companies
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "operators_own_commissions" ON public.operator_commissions;
DROP POLICY IF EXISTS "admin_all_commissions"     ON public.operator_commissions;
CREATE POLICY "operators_own_commissions" ON public.operator_commissions
  FOR ALL TO authenticated USING (operator_id = auth.uid()) WITH CHECK (operator_id = auth.uid());
CREATE POLICY "admin_all_commissions" ON public.operator_commissions
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "operators_own_clients" ON public.operator_clients;
DROP POLICY IF EXISTS "admin_all_op_clients"  ON public.operator_clients;
CREATE POLICY "operators_own_clients" ON public.operator_clients
  FOR ALL TO authenticated USING (operator_id = auth.uid()) WITH CHECK (operator_id = auth.uid());
CREATE POLICY "admin_all_op_clients" ON public.operator_clients
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "operators_own_legal_log" ON public.operator_legal_log;
DROP POLICY IF EXISTS "admin_all_legal_log"     ON public.operator_legal_log;
CREATE POLICY "operators_own_legal_log" ON public.operator_legal_log
  FOR ALL TO authenticated USING (operator_id = auth.uid()) WITH CHECK (operator_id = auth.uid());
CREATE POLICY "admin_all_legal_log" ON public.operator_legal_log
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

-- ─── STEP 9: RLS POLICIES — ADMIN ────────────────────────────

DROP POLICY IF EXISTS "admins_own_profile"  ON public.admin_profiles;
DROP POLICY IF EXISTS "admin_all_profiles"  ON public.admin_profiles;
CREATE POLICY "admins_own_profile" ON public.admin_profiles
  FOR ALL TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "admin_all_profiles" ON public.admin_profiles
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "admin_only_audit_log"     ON public.admin_audit_log;
DROP POLICY IF EXISTS "admin_only_settings"      ON public.admin_settings;
DROP POLICY IF EXISTS "admin_only_user_actions"  ON public.admin_user_actions;
CREATE POLICY "admin_only_audit_log" ON public.admin_audit_log
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');
CREATE POLICY "admin_only_settings" ON public.admin_settings
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');
CREATE POLICY "admin_only_user_actions" ON public.admin_user_actions
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

DROP POLICY IF EXISTS "notifications_read_own"  ON public.admin_notifications;
DROP POLICY IF EXISTS "notifications_create"    ON public.admin_notifications;
DROP POLICY IF EXISTS "notifications_mark_read" ON public.admin_notifications;
CREATE POLICY "notifications_read_own" ON public.admin_notifications
  FOR SELECT TO authenticated
  USING (
    target_user_id = auth.uid() OR
    target_role = private.current_user_role() OR
    target_role = 'all'
  );
CREATE POLICY "notifications_create" ON public.admin_notifications
  FOR INSERT TO authenticated
  WITH CHECK (private.current_user_role() = 'admin');
CREATE POLICY "notifications_mark_read" ON public.admin_notifications
  FOR UPDATE TO authenticated
  USING (target_user_id = auth.uid())
  WITH CHECK (target_user_id = auth.uid());

-- ─── STEP 10: UPDATED TRIGGER FUNCTION ───────────────────────
-- Extends existing handle_auth_user_created to also create role-specific profiles.
CREATE OR REPLACE FUNCTION private.handle_auth_user_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_role    TEXT;
  v_company TEXT;
BEGIN
  v_role    := COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', ''), 'client');
  v_company := NULLIF(NEW.raw_user_meta_data->>'company', '');

  INSERT INTO public.users (
    id, email, full_name, phone_number, ccp_number,
    role, company, employee_id, email_verified, created_at, updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
    NULLIF(NEW.raw_user_meta_data->>'phone_number', ''),
    NULLIF(NEW.raw_user_meta_data->>'ccp_number', ''),
    v_role,
    v_company,
    NULLIF(NEW.raw_user_meta_data->>'employee_id', ''),
    NEW.email_confirmed_at IS NOT NULL,
    timezone('utc', now()),
    timezone('utc', now())
  )
  ON CONFLICT (id) DO UPDATE SET
    email          = EXCLUDED.email,
    full_name      = COALESCE(EXCLUDED.full_name,     public.users.full_name),
    phone_number   = COALESCE(EXCLUDED.phone_number,  public.users.phone_number),
    role           = EXCLUDED.role,
    company        = COALESCE(EXCLUDED.company,       public.users.company),
    employee_id    = COALESCE(EXCLUDED.employee_id,   public.users.employee_id),
    email_verified = EXCLUDED.email_verified,
    updated_at     = timezone('utc', now());

  -- Auto-create role-specific profile record
  IF v_role = 'operator' THEN
    INSERT INTO public.operator_profiles (id, company_name)
    VALUES (NEW.id, COALESCE(v_company, 'غير محدد'))
    ON CONFLICT (id) DO NOTHING;
  ELSIF v_role = 'admin' THEN
    INSERT INTO public.admin_profiles (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
  ELSE
    INSERT INTO public.client_profiles (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

-- ─── STEP 11: COMMISSION AUTO-CALCULATE TRIGGER ───────────────
CREATE OR REPLACE FUNCTION private.calculate_commission()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.commission_amount := NEW.total_premiums * (NEW.commission_rate / 100.0);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS auto_calculate_commission ON public.operator_commissions;
CREATE TRIGGER auto_calculate_commission
  BEFORE INSERT OR UPDATE ON public.operator_commissions
  FOR EACH ROW EXECUTE FUNCTION private.calculate_commission();

-- ─── STEP 12: REALTIME FOR NEW TABLES ────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime' AND tablename = 'client_policies'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.client_policies;
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime' AND tablename = 'client_claims'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.client_claims;
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime' AND tablename = 'admin_notifications'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_notifications;
    END IF;
  END IF;
END $$;

-- =============================================================
-- VERIFICATION QUERIES (run after applying to confirm success)
-- =============================================================
-- SELECT count(*) FROM public.backup_policies_20260515;   -- should match policies count
-- SELECT count(*) FROM public.client_policies;            -- should match backup count
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1;
-- SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY 1;
