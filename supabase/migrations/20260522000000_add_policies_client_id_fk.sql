-- Add missing foreign key constraint from policies.client_id → public.users(id).
-- The original CREATE TABLE IF NOT EXISTS in 20260517000001 was a no-op because
-- the policies table already existed from earlier migrations, so the FK was never created.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.policies'::regclass
      AND conname  = 'policies_client_id_fkey'
  ) THEN
    ALTER TABLE public.policies
      ADD CONSTRAINT policies_client_id_fkey
      FOREIGN KEY (client_id)
      REFERENCES public.users(id)
      ON DELETE CASCADE;
    RAISE NOTICE 'Added FK policies.client_id → users.id';
  ELSE
    RAISE NOTICE 'FK policies_client_id_fkey already exists – skipped.';
  END IF;
END $$;
