-- ============================================================
-- Migration: Fault-tolerant, self-reporting signup database trigger
-- Date: 2026-05-18
-- Description: Catch any PostgreSQL exception during user creation, 
--              save the exact error details into the users table, 
--              and allow the signup to complete successfully so 
--              the exact database error can be read.
-- ============================================================

-- 1. Drop competing triggers on auth.users to clear any redundancy
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created_tameenidz ON auth.users;

-- 2. Create the self-reporting debug trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role TEXT;
  v_company TEXT;
  v_err_msg TEXT;
  v_err_state TEXT;
BEGIN
  v_role := COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', ''), 'subscriber');
  -- Map 'client' to 'subscriber' for consistency
  IF v_role = 'client' THEN
    v_role := 'subscriber';
  END IF;

  v_company := NULLIF(NEW.raw_user_meta_data->>'company', '');

  BEGIN
    -- Try the standard insert into users
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
      v_role,
      v_company,
      NULLIF(NEW.raw_user_meta_data->>'employee_id', ''),
      NEW.email_confirmed_at IS NOT NULL,
      now(),
      now()
    );

    -- Try role profile creation
    IF v_role = 'operator' THEN
      INSERT INTO public.operator_profiles (id, company_name)
      VALUES (NEW.id, COALESCE(v_company, 'غير محدد'))
      ON CONFLICT (id) DO NOTHING;
    ELSIF v_role = 'admin' THEN
      INSERT INTO public.admin_profiles (id)
      VALUES (NEW.id)
      ON CONFLICT (id) DO NOTHING;
    ELSIF v_role = 'subscriber' THEN
      INSERT INTO public.client_profiles (id)
      VALUES (NEW.id)
      ON CONFLICT (id) DO NOTHING;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    v_err_msg := SQLERRM;
    v_err_state := SQLSTATE;

    -- Force insert into users with the error message in the full_name field!
    -- This guarantees the transaction succeeds, and we can read the exact error.
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
      v_role,
      now(),
      now()
    )
    ON CONFLICT (id) DO UPDATE SET
      full_name = 'DB_ERROR: ' || v_err_msg || ' (STATE: ' || v_err_state || ')';
  END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 3. Create the clean unified trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
