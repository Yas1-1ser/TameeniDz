-- ============================================================
-- Migration: Explicit user_role casting and 'client' mapping
-- Date: 2026-05-18
-- Description: Standardizes user role mapping to use 'client'
--              (instead of 'subscriber' which is invalid in the enum)
--              and adds explicit casting to public.user_role enum.
-- ============================================================

-- 1. Drop existing triggers on auth.users to clean up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created_tameenidz ON auth.users;

-- 2. Create the robust self-healing trigger function with explicit casting
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
    -- 3. Insert into public.users with explicit casting to public.user_role enum
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
      NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
      NULLIF(NEW.raw_user_meta_data->>'phone_number', ''),
      NULLIF(NEW.raw_user_meta_data->>'ccp_number', ''),
      NULLIF(NEW.raw_user_meta_data->>'wilaya', ''),
      v_role::public.user_role, -- EXPLICIT CAST to avoid text-to-enum type mismatch
      v_company,
      NULLIF(NEW.raw_user_meta_data->>'employee_id', ''),
      NEW.email_confirmed_at IS NOT NULL,
      now(),
      now()
    );

    -- 4. Try role-specific profile creation
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

    -- ============================================================
    -- FIRST FALLBACK: Try to save the exact error message
    -- ============================================================
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
        'client'::public.user_role, -- cast fallback too
        now(),
        now()
      )
      ON CONFLICT (id) DO UPDATE SET
        full_name = 'DB_ERROR: ' || v_err_msg || ' (STATE: ' || v_err_state || ')';
        
    EXCEPTION WHEN OTHERS THEN
      -- ABSOLUTE SAFETY: Do not allow any trigger exception to fail GoTrue insertion
      NULL;
    END;
  END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 3. Re-create the clean AFTER INSERT trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
