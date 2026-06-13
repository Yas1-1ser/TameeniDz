-- =============================================================
-- MIGRATION: Add missing columns to client_claims
-- Date: 2026-06-12
-- Description: Adds client_name, metadata, created_at, and
--              changes operator_id to TEXT so it can store
--              operator codes like 'algeria_takaful', 'al_ittihad'.
--              Also adds 'received'/'accepted' to the status check.
-- =============================================================

-- ── 1. Add client_name column ──
ALTER TABLE public.client_claims
  ADD COLUMN IF NOT EXISTS client_name TEXT;

-- ── 2. Add metadata JSONB column ──
ALTER TABLE public.client_claims
  ADD COLUMN IF NOT EXISTS metadata JSONB;

-- ── 3. Add created_at column (for ordering) ──
ALTER TABLE public.client_claims
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- ── 3b. Add admin_notes column (operator notes on claim) ──
ALTER TABLE public.client_claims
  ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- ── 4. Change operator_id from UUID to TEXT ──
-- Must drop RLS policies and FK constraint first, then recreate.

-- 4a. Drop all RLS policies that depend on operator_id
DROP POLICY IF EXISTS "operators_own_claims" ON public.client_claims;
DROP POLICY IF EXISTS "clients_own_claims"   ON public.client_claims;
DROP POLICY IF EXISTS "admin_all_claims"     ON public.client_claims;

-- 4b. Drop FK constraint on operator_id (if it exists)
DO $$
DECLARE
  _constraint_name TEXT;
BEGIN
  SELECT tc.constraint_name INTO _constraint_name
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  WHERE tc.table_name = 'client_claims'
    AND tc.table_schema = 'public'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND kcu.column_name = 'operator_id'
  LIMIT 1;

  IF _constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.client_claims DROP CONSTRAINT %I', _constraint_name);
    RAISE NOTICE 'Dropped FK constraint: %', _constraint_name;
  END IF;
END $$;

-- 4c. Change column type to TEXT
ALTER TABLE public.client_claims ALTER COLUMN operator_id TYPE TEXT USING operator_id::TEXT;

-- 4d. Recreate RLS policies (operator_id is now TEXT, matching company codes)
CREATE POLICY "clients_own_claims" ON public.client_claims
  FOR ALL TO authenticated
  USING (client_id = auth.uid())
  WITH CHECK (client_id = auth.uid());

CREATE POLICY "operators_own_claims" ON public.client_claims
  FOR ALL TO authenticated
  USING (
    private.current_user_role() = 'operator' AND (
      operator_id = auth.uid()::TEXT OR
      operator_id IN (SELECT company FROM public.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    private.current_user_role() = 'operator' AND (
      operator_id = auth.uid()::TEXT OR
      operator_id IN (SELECT company FROM public.users WHERE id = auth.uid())
    )
  );

CREATE POLICY "admin_all_claims" ON public.client_claims
  FOR ALL TO authenticated
  USING (private.current_user_role() = 'admin')
  WITH CHECK (private.current_user_role() = 'admin');

-- ── 5. Update status CHECK constraint ──
ALTER TABLE public.client_claims DROP CONSTRAINT IF EXISTS client_claims_status_check;
ALTER TABLE public.client_claims
  ADD CONSTRAINT client_claims_status_check
  CHECK (status IN ('pending','under_review','approved','rejected','paid','received','accepted'));

-- ── 6. Backfill created_at from submitted_at where missing ──
UPDATE public.client_claims
SET created_at = submitted_at
WHERE created_at IS NULL AND submitted_at IS NOT NULL;
