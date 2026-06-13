-- ============================================================
-- Migration: Create all tables referenced in code but missing
-- from the DB. Fully idempotent — safe to run multiple times.
-- Project: tameenidz / Taminy Elite
-- ============================================================

-- ── 1. OPERATORS ─────────────────────────────────────────────
-- Table may already exist with a different schema — patch with ALTER.
CREATE TABLE IF NOT EXISTS public.operators (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar    TEXT NOT NULL DEFAULT '',
  name_en    TEXT NOT NULL DEFAULT '',
  is_active  BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure a default is configured on the id column for pre-existing tables
ALTER TABLE public.operators ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Add missing columns to pre-existing operators table (safe to run repeatedly)
ALTER TABLE public.operators ADD COLUMN IF NOT EXISTS code TEXT;

-- Backfill code for existing rows based on name_ar
UPDATE public.operators SET code = 'TAKAFUL'
  WHERE code IS NULL AND name_ar ILIKE '%تكافل%';
UPDATE public.operators SET code = 'ITTIHAD'
  WHERE code IS NULL AND name_ar ILIKE '%اتحاد%';

-- Add UNIQUE constraint on code if not already present
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'operators_code_key'
      AND conrelid = 'public.operators'::regclass
  ) THEN
    BEGIN
      ALTER TABLE public.operators ALTER COLUMN code SET NOT NULL;
      ALTER TABLE public.operators ADD CONSTRAINT operators_code_key UNIQUE (code);
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not add UNIQUE constraint on operators.code (rows may still have NULL): %', SQLERRM;
    END;
  END IF;
END;
$$;

-- Seed the two operators (only if they don't already exist)
INSERT INTO public.operators (code, name_ar, name_en)
SELECT 'TAKAFUL', 'الجزائر للتكافل', 'Algerie Takaful'
WHERE NOT EXISTS (SELECT 1 FROM public.operators WHERE code = 'TAKAFUL');

INSERT INTO public.operators (code, name_ar, name_en)
SELECT 'ITTIHAD', 'الاتحاد للتأمين', 'Al-Ittihad Insurance'
WHERE NOT EXISTS (SELECT 1 FROM public.operators WHERE code = 'ITTIHAD');

ALTER TABLE public.operators ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='operators' AND policyname='operators_public_read') THEN
    CREATE POLICY "operators_public_read" ON public.operators FOR SELECT USING (true);
  END IF;
END;
$$;


-- ── 2. PLANS ─────────────────────────────────────────────────
-- Referenced by: plan_repository.dart, supabase_service.dart, payment_screen.dart
CREATE TABLE IF NOT EXISTS public.plans (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_code    TEXT,                          -- FK added below, conditionally
  name_ar          TEXT NOT NULL DEFAULT '',
  name_en          TEXT NOT NULL DEFAULT '',
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

-- Add columns to pre-existing plans table if it already exists (defensive migration)
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS operator_code    TEXT;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS name_ar          TEXT NOT NULL DEFAULT '';
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS name_en          TEXT NOT NULL DEFAULT '';
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS premium_amount   NUMERIC(12, 2) NOT NULL DEFAULT 0;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS coverage_details TEXT;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS tabarru_rate     NUMERIC(5, 4) NOT NULL DEFAULT 0.15;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS surplus_rate     NUMERIC(5, 4) NOT NULL DEFAULT 0.10;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS claims_duration  TEXT NOT NULL DEFAULT '48 Hours';
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS is_best_value    BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS icon_type        TEXT NOT NULL DEFAULT 'shield';
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS is_active        BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS created_at       TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE public.plans ADD COLUMN IF NOT EXISTS updated_at       TIMESTAMPTZ NOT NULL DEFAULT now();

-- Add FK to operators(code) only once operators.code has its unique constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'plans_operator_code_fkey'
      AND conrelid = 'public.plans'::regclass
  ) AND EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'operators_code_key'
      AND conrelid = 'public.operators'::regclass
  ) THEN
    ALTER TABLE public.plans
      ADD CONSTRAINT plans_operator_code_fkey
      FOREIGN KEY (operator_code) REFERENCES public.operators(code);
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS plans_operator_code_idx  ON public.plans (operator_code);
CREATE INDEX IF NOT EXISTS plans_premium_amount_idx ON public.plans (premium_amount);

ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='plans' AND policyname='plans_public_read') THEN
    CREATE POLICY "plans_public_read" ON public.plans FOR SELECT USING (is_active = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='plans' AND policyname='plans_operator_insert') THEN
    CREATE POLICY "plans_operator_insert" ON public.plans
      FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','admin','employee'))
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='plans' AND policyname='plans_operator_update') THEN
    CREATE POLICY "plans_operator_update" ON public.plans
      FOR UPDATE USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','admin','employee'))
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='plans' AND policyname='plans_admin_delete') THEN
    CREATE POLICY "plans_admin_delete" ON public.plans
      FOR DELETE USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin')
      );
  END IF;
END;
$$;


-- ── 3. AUDIT_LOGS ────────────────────────────────────────────
-- Referenced by: audit_repository.dart, supabase_service.dart
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

-- Add columns to pre-existing audit_logs table if it already exists
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS user_id      UUID;
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS user_name    TEXT NOT NULL DEFAULT 'System';
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS action       TEXT;
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS entity_type  TEXT;
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS entity_id    UUID;
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS status_color TEXT DEFAULT 'green';
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS metadata     JSONB;
ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS created_at   TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx ON public.audit_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_user_id_idx    ON public.audit_logs (user_id);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='audit_logs' AND policyname='audit_logs_admin_read') THEN
    CREATE POLICY "audit_logs_admin_read" ON public.audit_logs
      FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin')
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='audit_logs' AND policyname='audit_logs_no_user_insert') THEN
    -- Service role key bypasses RLS; regular users cannot insert directly
    CREATE POLICY "audit_logs_no_user_insert" ON public.audit_logs
      FOR INSERT WITH CHECK (false);
  END IF;
END;
$$;


-- ── 4. LEGAL_SECTIONS ────────────────────────────────────────
-- Referenced by: legal_repository.dart
CREATE TABLE IF NOT EXISTS public.legal_sections (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL DEFAULT '',
  content       TEXT NOT NULL DEFAULT '',
  icon_name     TEXT NOT NULL DEFAULT 'gavel',
  display_order INT NOT NULL DEFAULT 0,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add columns to pre-existing legal_sections table if it already exists
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS title         TEXT NOT NULL DEFAULT '';
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS content       TEXT NOT NULL DEFAULT '';
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS icon_name     TEXT NOT NULL DEFAULT 'gavel';
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS display_order INT NOT NULL DEFAULT 0;
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS is_active     BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS created_at    TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE public.legal_sections ADD COLUMN IF NOT EXISTS updated_at    TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS legal_sections_order_idx ON public.legal_sections (display_order);

ALTER TABLE public.legal_sections ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='legal_sections' AND policyname='legal_sections_public_read') THEN
    CREATE POLICY "legal_sections_public_read" ON public.legal_sections
      FOR SELECT USING (is_active = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='legal_sections' AND policyname='legal_sections_admin_write') THEN
    CREATE POLICY "legal_sections_admin_write" ON public.legal_sections
      FOR ALL USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin')
      );
  END IF;
END;
$$;


-- ── 5. SURPLUS_DISTRIBUTIONS ─────────────────────────────────
-- Referenced by: surplus_repository.dart
CREATE TABLE IF NOT EXISTS public.surplus_distributions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id     TEXT NOT NULL,
  subscriber_name TEXT NOT NULL DEFAULT '',
  ccp_number      TEXT NOT NULL DEFAULT '',
  amount          NUMERIC(12, 2) NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'paid', 'cancelled')),
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add columns to pre-existing surplus_distributions table if it already exists
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS operator_id     TEXT;
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS subscriber_name TEXT NOT NULL DEFAULT '';
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS ccp_number      TEXT NOT NULL DEFAULT '';
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS amount          NUMERIC(12, 2) NOT NULL DEFAULT 0;
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS status          TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS notes           TEXT;
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS created_at      TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE public.surplus_distributions ADD COLUMN IF NOT EXISTS updated_at      TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS surplus_dist_operator_idx   ON public.surplus_distributions (operator_id);
CREATE INDEX IF NOT EXISTS surplus_dist_created_at_idx ON public.surplus_distributions (created_at DESC);

ALTER TABLE public.surplus_distributions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='surplus_distributions' AND policyname='surplus_dist_subscriber_read') THEN
    CREATE POLICY "surplus_dist_subscriber_read" ON public.surplus_distributions
      FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.ccp_number = surplus_distributions.ccp_number)
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='surplus_distributions' AND policyname='surplus_dist_operator_read') THEN
    CREATE POLICY "surplus_dist_operator_read" ON public.surplus_distributions
      FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin'))
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='surplus_distributions' AND policyname='surplus_dist_operator_write') THEN
    CREATE POLICY "surplus_dist_operator_write" ON public.surplus_distributions
      FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin'))
      );
  END IF;
END;
$$;


-- ── 6. SURPLUS_QUARTERS ──────────────────────────────────────
-- Referenced by: surplus_repository.dart
CREATE TABLE IF NOT EXISTS public.surplus_quarters (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id        TEXT NOT NULL,
  title_ar           TEXT NOT NULL DEFAULT '',
  title_en           TEXT NOT NULL DEFAULT '',
  status             TEXT NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'approved', 'distributed')),
  policyholders_fund NUMERIC(14, 2) NOT NULL DEFAULT 0,
  shareholders_fund  NUMERIC(14, 2) NOT NULL DEFAULT 0,
  individual_share   NUMERIC(12, 2) NOT NULL DEFAULT 0,
  distribution_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add columns to pre-existing surplus_quarters table if it already exists
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS operator_id        TEXT;
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS title_ar           TEXT NOT NULL DEFAULT '';
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS title_en           TEXT NOT NULL DEFAULT '';
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS status             TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS policyholders_fund NUMERIC(14, 2) NOT NULL DEFAULT 0;
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS shareholders_fund  NUMERIC(14, 2) NOT NULL DEFAULT 0;
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS individual_share   NUMERIC(12, 2) NOT NULL DEFAULT 0;
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS distribution_date  DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS created_at         TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE public.surplus_quarters ADD COLUMN IF NOT EXISTS updated_at         TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS surplus_quarters_operator_idx ON public.surplus_quarters (operator_id);
CREATE INDEX IF NOT EXISTS surplus_quarters_date_idx     ON public.surplus_quarters (distribution_date DESC);

ALTER TABLE public.surplus_quarters ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='surplus_quarters' AND policyname='surplus_quarters_authenticated_read') THEN
    CREATE POLICY "surplus_quarters_authenticated_read" ON public.surplus_quarters
      FOR SELECT USING (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='surplus_quarters' AND policyname='surplus_quarters_operator_write') THEN
    CREATE POLICY "surplus_quarters_operator_write" ON public.surplus_quarters
      FOR ALL USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text IN ('operator','employee','admin'))
      );
  END IF;
END;
$$;


-- ── 7. GARAGES ───────────────────────────────────────────────
-- Referenced by: sos_service.dart (fetchGarages, fetchTowingTrucks)
CREATE TABLE IF NOT EXISTS public.garages (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name             TEXT NOT NULL DEFAULT '',
  owner_name       TEXT,
  phone            TEXT NOT NULL DEFAULT '',
  wilaya           TEXT NOT NULL DEFAULT '',
  specialty        TEXT NOT NULL DEFAULT 'mechanic'
                   CHECK (specialty IN ('mechanic', 'electric', 'tires', 'towing')),
  rating           NUMERIC(3, 1) NOT NULL DEFAULT 4.5
                   CHECK (rating >= 0 AND rating <= 5),
  is_towing        BOOLEAN NOT NULL DEFAULT false,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  discount_percent INT NOT NULL DEFAULT 15,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add columns to pre-existing garages table if it already exists
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS name             TEXT NOT NULL DEFAULT '';
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS owner_name       TEXT;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS phone            TEXT NOT NULL DEFAULT '';
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS wilaya           TEXT NOT NULL DEFAULT '';
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS specialty        TEXT NOT NULL DEFAULT 'mechanic';
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS rating           NUMERIC(3, 1) NOT NULL DEFAULT 4.5;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS is_towing        BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS latitude         DOUBLE PRECISION;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS longitude        DOUBLE PRECISION;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS discount_percent INT NOT NULL DEFAULT 15;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS is_active        BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.garages ADD COLUMN IF NOT EXISTS created_at       TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS garages_wilaya_idx    ON public.garages (wilaya);
CREATE INDEX IF NOT EXISTS garages_specialty_idx ON public.garages (specialty);
CREATE INDEX IF NOT EXISTS garages_is_towing_idx ON public.garages (is_towing);
CREATE INDEX IF NOT EXISTS garages_rating_idx    ON public.garages (rating DESC);

ALTER TABLE public.garages ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='garages' AND policyname='garages_public_read') THEN
    CREATE POLICY "garages_public_read" ON public.garages FOR SELECT USING (is_active = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='garages' AND policyname='garages_admin_write') THEN
    CREATE POLICY "garages_admin_write" ON public.garages
      FOR ALL USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin')
      );
  END IF;
END;
$$;


-- ── 8. TOW_TRUCKS ────────────────────────────────────────────
-- Referenced by: roadside_assistance_screen.dart (.from('tow_trucks'))
CREATE TABLE IF NOT EXISTS public.tow_trucks (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL DEFAULT '',
  phone        TEXT NOT NULL DEFAULT '',
  wilaya       TEXT NOT NULL DEFAULT '',
  rating       NUMERIC(3, 1) NOT NULL DEFAULT 4.5,
  is_available BOOLEAN NOT NULL DEFAULT true,
  latitude     DOUBLE PRECISION,
  longitude    DOUBLE PRECISION,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add columns to pre-existing tow_trucks table if it already exists
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS name         TEXT NOT NULL DEFAULT '';
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS phone        TEXT NOT NULL DEFAULT '';
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS wilaya       TEXT NOT NULL DEFAULT '';
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS rating       NUMERIC(3, 1) NOT NULL DEFAULT 4.5;
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS is_available BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS latitude     DOUBLE PRECISION;
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS longitude    DOUBLE PRECISION;
ALTER TABLE public.tow_trucks ADD COLUMN IF NOT EXISTS created_at   TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS tow_trucks_wilaya_idx ON public.tow_trucks (wilaya);

ALTER TABLE public.tow_trucks ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='tow_trucks' AND policyname='tow_trucks_public_read') THEN
    CREATE POLICY "tow_trucks_public_read" ON public.tow_trucks FOR SELECT USING (is_available = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='tow_trucks' AND policyname='tow_trucks_admin_write') THEN
    CREATE POLICY "tow_trucks_admin_write" ON public.tow_trucks
      FOR ALL USING (
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role::text = 'admin')
      );
  END IF;
END;
$$;


-- ── 9. FCM_TOKEN column on public.users ──────────────────────
-- notification_service.dart: .from('users').update({'fcm_token': token})
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS fcm_token TEXT;


-- ── 10. updated_at trigger function ──────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Attach trigger to all tables that have an updated_at column
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'plans', 'legal_sections', 'surplus_distributions', 'surplus_quarters'
  ] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS set_%1$s_updated_at ON public.%1$s;
       CREATE TRIGGER set_%1$s_updated_at
         BEFORE UPDATE ON public.%1$s
         FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();',
      t
    );
  END LOOP;
END;
$$;


-- ── 11. Enable Realtime for new tables ───────────────────────
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.plans;            EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.audit_logs;       EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.surplus_distributions; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.surplus_quarters;  EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.garages;           EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
