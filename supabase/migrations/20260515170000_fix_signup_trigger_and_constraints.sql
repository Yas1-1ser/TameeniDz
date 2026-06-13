-- =============================================================
-- MIGRATION: fix_signup_trigger_and_constraints
-- Date: 2026-05-15
-- Description: Fixes the 'unexpected_failure' during registration by:
--              1. Ensuring all potential profile columns in 'users' are nullable.
--              2. Creating a safe, idempotent trigger for new auth users.
--              3. Fixing RLS to allow the trigger to work correctly.
-- =============================================================

-- 1. Ensure columns are nullable to prevent 'NOT NULL' violations during signup
ALTER TABLE public.users 
  ALTER COLUMN full_name DROP NOT NULL,
  ALTER COLUMN phone_number DROP NOT NULL,
  ALTER COLUMN ccp_number DROP NOT NULL,
  ALTER COLUMN role SET DEFAULT 'client';

-- Add wilaya column to users table if it doesn't exist (some legacy triggers might expect it)
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='wilaya') THEN
    ALTER TABLE public.users ADD COLUMN wilaya TEXT;
  END IF;
END $$;

-- 2. Create a safe trigger function in public schema (idempotent)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    full_name,
    phone_number,
    ccp_number,
    wilaya,
    role,
    created_at,
    updated_at
  )
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'phone_number', ''),
    COALESCE(new.raw_user_meta_data->>'ccp_number', ''),
    COALESCE(new.raw_user_meta_data->>'wilaya', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'client'),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone_number = EXCLUDED.phone_number,
    ccp_number = EXCLUDED.ccp_number,
    wilaya = EXCLUDED.wilaya,
    updated_at = NOW();
    
  RETURN new;
END;
$$;

-- 3. Re-attach the trigger safely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. Fix RLS policies for users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
CREATE POLICY "Users can insert their own profile"
ON public.users FOR INSERT
WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- Allow service role to do everything (essential for triggers)
DROP POLICY IF EXISTS "Service role bypass" ON public.users;
CREATE POLICY "Service role bypass"
ON public.users
USING (true)
WITH CHECK (true);
