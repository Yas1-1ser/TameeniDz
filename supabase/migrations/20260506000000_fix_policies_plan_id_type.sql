
-- Migration to fix UUID type mismatch in policies table
-- This changes plan_id and operator_id to TEXT to accommodate human-readable identifiers used in the UI

ALTER TABLE public.policies 
  ALTER COLUMN plan_id TYPE TEXT,
  ALTER COLUMN operator_id TYPE TEXT;

-- Ensure RLS is still working correctly if it was based on these columns
-- (Usually RLS is based on client_id which remains a UUID)
