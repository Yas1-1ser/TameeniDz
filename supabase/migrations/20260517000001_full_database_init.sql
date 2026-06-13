-- ============================================================
-- Unified Database Initialization & Setup Script
-- Project: Tameeni Elite (tameenidz)
-- Description: Sets up the entire database from scratch. 
--              Creates all enums, tables, indexes, RLS policies,
--              auth triggers, storage buckets, and realtime configurations.
-- Safe to run on a brand new Supabase project or PostgreSQL instance.
-- ============================================================

-- ── 1. SCHEMAS & PERMISSIONS ──────────────────────────────────
CREATE SCHEMA IF NOT EXISTS private;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT USAGE ON SCHEMA private TO anon;

-- ── 2. USERS & PROFILES ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.users (
  id                     UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name              TEXT,
  email                  TEXT,
  phone_number           TEXT,
  ccp_number             TEXT,
  wilaya                 TEXT,
  role                   TEXT NOT NULL DEFAULT 'subscriber',
  company                TEXT,
  employee_id            TEXT,
  operator_id            TEXT,
  documents_submitted    BOOLEAN NOT NULL DEFAULT false,
  documents_submitted_at TIMESTAMPTZ,
  phone_verified         BOOLEAN NOT NULL DEFAULT false,
  email_verified         BOOLEAN NOT NULL DEFAULT false,
  fcm_token              TEXT,
  last_login             TIMESTAMPTZ,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure a safe constraint that covers all roles (both subscriber and legacy client)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'users_role_check' AND conrelid = 'public.users'::regclass
  ) THEN
    ALTER TABLE public.users ADD CONSTRAINT users_role_check 
      CHECK (role IN ('subscriber', 'client', 'operator', 'admin', 'employee'));
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique_idx
  ON public.users (lower(email)) WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS users_phone_number_unique_idx
  ON public.users (phone_number) WHERE phone_number IS NOT NULL;


-- ── 3. CORE TRIGGER FUNCTIONS ────────────────────────────────
-- Set updated_at timestamp helper
CREATE OR REPLACE FUNCTION private.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS users_set_updated_at ON public.users;
CREATE TRIGGER users_set_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- Get current authenticated user role
CREATE OR REPLACE FUNCTION private.current_user_role()
RETURNS TEXT AS $$
  SELECT role FROM public.users WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = '';

GRANT EXECUTE ON FUNCTION private.current_user_role() TO authenticated;


-- ── 4. AUTH SIGNUP & UPDATE TRIGGERS ─────────────────────────
-- Trigger when a new user signs up via auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role TEXT;
BEGIN
  v_role := COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', ''), 'subscriber');
  -- Map 'client' to 'subscriber' for consistency, but allow either
  IF v_role = 'client' THEN
    v_role := 'subscriber';
  END IF;

  INSERT INTO public.users (
    id,
    email,
    full_name,
    phone_number,
    ccp_number,
    wilaya,
    role,
    company,
    employee_id,
    email_verified,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'ccp_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'wilaya', ''),
    v_role,
    NULLIF(NEW.raw_user_meta_data->>'company', ''),
    NULLIF(NEW.raw_user_meta_data->>'employee_id', ''),
    NEW.email_confirmed_at IS NOT NULL,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
    phone_number = COALESCE(EXCLUDED.phone_number, public.users.phone_number),
    ccp_number = COALESCE(EXCLUDED.ccp_number, public.users.ccp_number),
    wilaya = COALESCE(EXCLUDED.wilaya, public.users.wilaya),
    role = EXCLUDED.role,
    company = COALESCE(EXCLUDED.company, public.users.company),
    employee_id = COALESCE(EXCLUDED.employee_id, public.users.employee_id),
    email_verified = EXCLUDED.email_verified,
    updated_at = now();
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger when user changes auth credentials
CREATE OR REPLACE FUNCTION public.handle_auth_user_updated()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.users
  SET
    email = NEW.email,
    email_verified = NEW.email_confirmed_at IS NOT NULL,
    updated_at = now()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE OF email, email_confirmed_at ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_auth_user_updated();


-- ── 5. OPERATORS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.operators (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code       TEXT UNIQUE NOT NULL,                -- 'TAKAFUL' | 'ITTIHAD'
  name_ar    TEXT NOT NULL,
  name_en    TEXT NOT NULL,
  is_active  BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure a default is configured on the id column for pre-existing tables
ALTER TABLE public.operators ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Seed the two core operators
INSERT INTO public.operators (code, name_ar, name_en) VALUES
  ('TAKAFUL', 'الجزائر للتكافل',  'Algerie Takaful'),
  ('ITTIHAD',  'الاتحاد للتأمين', 'Al-Ittihad Insurance')
ON CONFLICT (code) DO NOTHING;


-- ── 6. PLANS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.plans (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_code    TEXT REFERENCES public.operators(code) ON DELETE CASCADE,
  name_ar          TEXT NOT NULL,
  name_en          TEXT NOT NULL,
  premium_amount   NUMERIC(12, 2) NOT NULL DEFAULT 0,
  coverage_details TEXT,
  tabarru_rate     NUMERIC(5, 4) NOT NULL DEFAULT 0.15,
  surplus_rate     NUMERIC(5, 4) NOT NULL DEFAULT 0.10,
  claims_duration  TEXT NOT NULL DEFAULT '48 Hours',
  is_best_value    BOOLEAN NOT NULL DEFAULT false,
  icon_type        TEXT NOT NULL DEFAULT 'shield',
  is_active        BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS plans_operator_code_idx  ON public.plans (operator_code);
CREATE INDEX IF NOT EXISTS plans_premium_amount_idx ON public.plans (premium_amount);


-- ── 7. POLICIES ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.policies (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id           UUID REFERENCES public.users(id) ON DELETE CASCADE,
  plan_id             TEXT,
  operator_id         TEXT,
  status              TEXT DEFAULT 'pending',
  amount              NUMERIC(12, 2) NOT NULL DEFAULT 0,
  company_name        TEXT,
  submitted_at        TIMESTAMPTZ DEFAULT now(),
  accepted_at         TIMESTAMPTZ,
  paid_at             TIMESTAMPTZ,
  receipt_number      TEXT,
  document_urls       JSONB,
  admin_notes         TEXT,
  applicant_id_number TEXT,
  plan_name           TEXT,
  applicant_full_name TEXT,
  receipt_url         TEXT,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS policies_client_id_idx ON public.policies (client_id);
CREATE INDEX IF NOT EXISTS policies_status_idx ON public.policies (status);


-- ── 8. AUDIT LOGS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_name    TEXT NOT NULL DEFAULT 'System',
  action       TEXT NOT NULL,
  entity_type  TEXT,
  entity_id    UUID,
  status_color TEXT DEFAULT 'green',
  metadata     JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx ON public.audit_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_user_id_idx    ON public.audit_logs (user_id);


-- ── 9. LEGAL SECTIONS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.legal_sections (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  content       TEXT NOT NULL,
  icon_name     TEXT NOT NULL DEFAULT 'gavel',
  display_order INT NOT NULL DEFAULT 0,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS legal_sections_order_idx ON public.legal_sections (display_order);


-- ── 10. SURPLUS DISTRIBUTIONS ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.surplus_distributions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id     TEXT NOT NULL,
  subscriber_name TEXT NOT NULL,
  ccp_number      TEXT NOT NULL,
  amount          NUMERIC(12, 2) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled')),
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS surplus_dist_operator_idx   ON public.surplus_distributions (operator_id);
CREATE INDEX IF NOT EXISTS surplus_dist_created_at_idx ON public.surplus_distributions (created_at DESC);


-- ── 11. SURPLUS QUARTERS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.surplus_quarters (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id        TEXT NOT NULL,
  title_ar           TEXT NOT NULL,
  title_en           TEXT NOT NULL,
  status             TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'distributed')),
  policyholders_fund NUMERIC(14, 2) NOT NULL DEFAULT 0,
  shareholders_fund  NUMERIC(14, 2) NOT NULL DEFAULT 0,
  individual_share   NUMERIC(12, 2) NOT NULL DEFAULT 0,
  distribution_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS surplus_quarters_operator_idx ON public.surplus_quarters (operator_id);
CREATE INDEX IF NOT EXISTS surplus_quarters_date_idx     ON public.surplus_quarters (distribution_date DESC);


-- ── 12. GARAGES ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.garages (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name             TEXT NOT NULL,
  owner_name       TEXT,
  phone            TEXT NOT NULL,
  wilaya           TEXT NOT NULL,
  specialty        TEXT NOT NULL DEFAULT 'mechanic' CHECK (specialty IN ('mechanic', 'electric', 'tires', 'towing')),
  rating           NUMERIC(3, 1) NOT NULL DEFAULT 4.5 CHECK (rating >= 0 AND rating <= 5),
  is_towing        BOOLEAN NOT NULL DEFAULT false,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  discount_percent INT NOT NULL DEFAULT 15,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS garages_wilaya_idx    ON public.garages (wilaya);
CREATE INDEX IF NOT EXISTS garages_specialty_idx ON public.garages (specialty);


-- ── 13. TOW TRUCKS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tow_trucks (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  phone        TEXT NOT NULL,
  wilaya       TEXT NOT NULL,
  rating       NUMERIC(3, 1) NOT NULL DEFAULT 4.5,
  is_available BOOLEAN NOT NULL DEFAULT true,
  latitude     DOUBLE PRECISION,
  longitude    DOUBLE PRECISION,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tow_trucks_wilaya_idx ON public.tow_trucks (wilaya);


-- ── 14. ERROR LOGS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.error_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  error_message TEXT NOT NULL,
  error_code    TEXT,
  stack_trace   TEXT,
  context_data  JSONB,
  created_at    TIMESTAMPTZ DEFAULT now()
);


-- ── 15. UPDATED_AT TRIGGER COUPLING ──────────────────────────
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'plans', 'policies', 'legal_sections', 'surplus_distributions', 'surplus_quarters'
  ] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS set_%1$s_updated_at ON public.%1$s;
       CREATE TRIGGER set_%1$s_updated_at
         BEFORE UPDATE ON public.%1$s
         FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();',
      t
    );
  END LOOP;
END;
$$;


-- ── 16. ROW LEVEL SECURITY (RLS) ──────────────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surplus_distributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surplus_quarters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.garages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tow_trucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.error_logs ENABLE ROW LEVEL SECURITY;


-- ── 17. RLS POLICIES ──────────────────────────────────────────

-- Users Policies
DROP POLICY IF EXISTS "Users can read own profile" ON public.users;
CREATE POLICY "Users can read own profile" ON public.users FOR SELECT TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Staff can read user profiles" ON public.users;
CREATE POLICY "Staff can read user profiles" ON public.users FOR SELECT TO authenticated USING (private.current_user_role()::text IN ('admin', 'operator'));

DROP POLICY IF EXISTS "Admins can manage user profiles" ON public.users;
CREATE POLICY "Admins can manage user profiles" ON public.users FOR ALL TO authenticated USING (private.current_user_role()::text = 'admin');

-- Operators Policies
DROP POLICY IF EXISTS "operators_public_read" ON public.operators;
CREATE POLICY "operators_public_read" ON public.operators FOR SELECT USING (true);

-- Plans Policies
DROP POLICY IF EXISTS "plans_public_read" ON public.plans;
CREATE POLICY "plans_public_read" ON public.plans FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "plans_operator_insert" ON public.plans;
CREATE POLICY "plans_operator_insert" ON public.plans FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','admin','employee')));

DROP POLICY IF EXISTS "plans_operator_update" ON public.plans;
CREATE POLICY "plans_operator_update" ON public.plans FOR UPDATE USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','admin','employee')));

DROP POLICY IF EXISTS "plans_admin_delete" ON public.plans;
CREATE POLICY "plans_admin_delete" ON public.plans FOR DELETE USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

-- Policies (Insurance) Policies
DROP POLICY IF EXISTS "Clients can view their own policies" ON public.policies;
CREATE POLICY "Clients can view their own policies" ON public.policies FOR SELECT USING (auth.uid() = client_id);

DROP POLICY IF EXISTS "Clients can insert their own policies" ON public.policies;
CREATE POLICY "Clients can insert their own policies" ON public.policies FOR INSERT WITH CHECK (auth.uid() = client_id);

DROP POLICY IF EXISTS "Clients can update their own policies" ON public.policies;
CREATE POLICY "Clients can update their own policies" ON public.policies FOR UPDATE USING (auth.uid() = client_id);

DROP POLICY IF EXISTS "Operators can view assigned policies" ON public.policies;
CREATE POLICY "Operators can view assigned policies" ON public.policies FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND company = policies.operator_id AND role::text = 'operator'));

DROP POLICY IF EXISTS "Operators can update assigned policies" ON public.policies;
CREATE POLICY "Operators can update assigned policies" ON public.policies FOR UPDATE USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND company = policies.operator_id AND role::text = 'operator'));

DROP POLICY IF EXISTS "Admins can manage all policies" ON public.policies;
CREATE POLICY "Admins can manage all policies" ON public.policies FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

-- Audit Logs Policies
DROP POLICY IF EXISTS "audit_logs_admin_read" ON public.audit_logs;
CREATE POLICY "audit_logs_admin_read" ON public.audit_logs FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

DROP POLICY IF EXISTS "audit_logs_no_user_insert" ON public.audit_logs;
CREATE POLICY "audit_logs_no_user_insert" ON public.audit_logs FOR INSERT WITH CHECK (false);

-- Legal Sections Policies
DROP POLICY IF EXISTS "legal_sections_public_read" ON public.legal_sections;
CREATE POLICY "legal_sections_public_read" ON public.legal_sections FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "legal_sections_admin_write" ON public.legal_sections;
CREATE POLICY "legal_sections_admin_write" ON public.legal_sections FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

-- Surplus Distributions Policies
DROP POLICY IF EXISTS "surplus_dist_subscriber_read" ON public.surplus_distributions;
CREATE POLICY "surplus_dist_subscriber_read" ON public.surplus_distributions FOR SELECT USING (EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.ccp_number = surplus_distributions.ccp_number));

DROP POLICY IF EXISTS "surplus_dist_operator_read" ON public.surplus_distributions;
CREATE POLICY "surplus_dist_operator_read" ON public.surplus_distributions FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin')));

DROP POLICY IF EXISTS "surplus_dist_operator_write" ON public.surplus_distributions;
CREATE POLICY "surplus_dist_operator_write" ON public.surplus_distributions FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin')));

-- Surplus Quarters Policies
DROP POLICY IF EXISTS "surplus_quarters_authenticated_read" ON public.surplus_quarters;
CREATE POLICY "surplus_quarters_authenticated_read" ON public.surplus_quarters FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "surplus_quarters_operator_write" ON public.surplus_quarters;
CREATE POLICY "surplus_quarters_operator_write" ON public.surplus_quarters FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin')));

-- Garages Policies
DROP POLICY IF EXISTS "garages_public_read" ON public.garages;
CREATE POLICY "garages_public_read" ON public.garages FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "garages_admin_write" ON public.garages;
CREATE POLICY "garages_admin_write" ON public.garages FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

-- Tow Trucks Policies
DROP POLICY IF EXISTS "tow_trucks_public_read" ON public.tow_trucks;
CREATE POLICY "tow_trucks_public_read" ON public.tow_trucks FOR SELECT USING (is_available = true);

DROP POLICY IF EXISTS "tow_trucks_admin_write" ON public.tow_trucks;
CREATE POLICY "tow_trucks_admin_write" ON public.tow_trucks FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));

-- Error Logs Policies
DROP POLICY IF EXISTS "Anyone can insert error logs" ON public.error_logs;
CREATE POLICY "Anyone can insert error logs" ON public.error_logs FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Admins can view error logs" ON public.error_logs;
CREATE POLICY "Admins can view error logs" ON public.error_logs FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin'));


-- ── 18. STORAGE SETUP ─────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- Storage Read Policies
DROP POLICY IF EXISTS "Users can read own documents" ON storage.objects;
CREATE POLICY "Users can read own documents" ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

DROP POLICY IF EXISTS "Authenticated can read legal dossier" ON storage.objects;
CREATE POLICY "Authenticated can read legal dossier" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'documents' AND name = 'dossier.pdf');

-- Storage Insert Policies
DROP POLICY IF EXISTS "Users can upload own documents" ON storage.objects;
CREATE POLICY "Users can upload own documents" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- Storage Update Policies
DROP POLICY IF EXISTS "Users can replace own documents" ON storage.objects;
CREATE POLICY "Users can replace own documents" ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  )
  WITH CHECK (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- Storage Delete Policies
DROP POLICY IF EXISTS "Users can delete own documents" ON storage.objects;
CREATE POLICY "Users can delete own documents" ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- Storage Admin Policy
DROP POLICY IF EXISTS "Admins can manage documents" ON storage.objects;
CREATE POLICY "Admins can manage documents" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'documents' AND private.current_user_role()::text = 'admin')
  WITH CHECK (bucket_id = 'documents' AND private.current_user_role()::text = 'admin');


-- ── 19. REALTIME CONFIGURATION ────────────────────────────────
-- Enable Realtime for all active app tables
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'policies') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.policies;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'plans') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.plans;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'audit_logs') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.audit_logs;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'surplus_distributions') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.surplus_distributions;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'surplus_quarters') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.surplus_quarters;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'garages') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.garages;
    END IF;
  END IF;
END $$;
