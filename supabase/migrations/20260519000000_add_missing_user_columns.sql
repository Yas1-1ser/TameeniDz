-- ============================================================
-- Migration: Add missing columns to users and policies tables
-- Date: 2026-05-19
-- Description: 
--   1. Adds 'nin', 'date_of_birth' columns to users table
--   2. Adds 'metadata' JSONB column to policies table
--   3. Updates the signup trigger to save nin/dob/wilaya
-- ============================================================

-- ── 1. Add columns to users table ──
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS nin TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS date_of_birth TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS wilaya TEXT;

-- ── 2. Add metadata column to policies table ──
ALTER TABLE public.policies ADD COLUMN IF NOT EXISTS metadata JSONB;

-- ── 3. Update the trigger function ──
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role TEXT;
  v_company TEXT;
  v_err_msg TEXT;
  v_err_state TEXT;
BEGIN
  -- 1. Extract role from metadata, default to 'client'
  v_role := COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', ''), 'client');
  
  -- 2. Map 'subscriber' to 'client' to match the database enum type (user_role)
  IF v_role = 'subscriber' THEN
    v_role := 'client';
  END IF;

  v_company := NULLIF(NEW.raw_user_meta_data->>'company', '');

  BEGIN
    INSERT INTO public.users (
      id,
      email,
      full_name,
      phone_number,
      ccp_number,
      nin,
      wilaya,
      date_of_birth,
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
      NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
      NULLIF(NEW.raw_user_meta_data->>'phone_number', ''),
      NULLIF(NEW.raw_user_meta_data->>'ccp_number', ''),
      NULLIF(NEW.raw_user_meta_data->>'nin', ''),
      NULLIF(NEW.raw_user_meta_data->>'wilaya', ''),
      NULLIF(NEW.raw_user_meta_data->>'dob', ''),
      v_role::public.user_role,
      v_company,
      NULLIF(NEW.raw_user_meta_data->>'employee_id', ''),
      NEW.email_confirmed_at IS NOT NULL,
      now(),
      now()
    );

    -- Try role-specific profile creation
    IF v_role = 'operator' THEN
      INSERT INTO public.operator_profiles (id, company_name)
      VALUES (NEW.id, COALESCE(v_company, 'غير محدد'))
      ON CONFLICT (id) DO NOTHING;
    ELSIF v_role = 'admin' THEN
      INSERT INTO public.admin_profiles (id)
      VALUES (NEW.id)
      ON CONFLICT (id) DO NOTHING;
    ELSIF v_role = 'client' THEN
      INSERT INTO public.client_profiles (id)
      VALUES (NEW.id)
      ON CONFLICT (id) DO NOTHING;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    v_err_msg := SQLERRM;
    v_err_state := SQLSTATE;

    BEGIN
      INSERT INTO public.users (
        id,
        email,
        full_name,
        role,
        created_at,
        updated_at
      )
      VALUES (
        NEW.id,
        NEW.email,
        'DB_ERROR: ' || v_err_msg || ' (STATE: ' || v_err_state || ')',
        'client'::public.user_role,
        now(),
        now()
      )
      ON CONFLICT (id) DO UPDATE SET
        full_name = 'DB_ERROR: ' || v_err_msg || ' (STATE: ' || v_err_state || ')';
        
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
