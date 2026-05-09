-- Migration to enhance policies table with receipt support and RLS
-- Date: 2026-05-09

-- 1. Add receipt_url column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policies' AND COLUMN_NAME = 'receipt_url') THEN
        ALTER TABLE public.policies ADD COLUMN receipt_url TEXT;
    END IF;
END $$;

-- 2. Enable Row Level Security
ALTER TABLE public.policies ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies to avoid conflicts during migration
DROP POLICY IF EXISTS "Clients can view their own policies" ON public.policies;
DROP POLICY IF EXISTS "Clients can insert their own policies" ON public.policies;
DROP POLICY IF EXISTS "Clients can update their own policies" ON public.policies;
DROP POLICY IF EXISTS "Operators can view assigned policies" ON public.policies;
DROP POLICY IF EXISTS "Operators can update assigned policies" ON public.policies;
DROP POLICY IF EXISTS "Admins can view all policies" ON public.policies;

-- 4. Create Policies for Clients
CREATE POLICY "Clients can view their own policies" 
ON public.policies FOR SELECT 
USING (auth.uid() = client_id);

CREATE POLICY "Clients can insert their own policies" 
ON public.policies FOR INSERT 
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "Clients can update their own policies" 
ON public.policies FOR UPDATE 
USING (auth.uid() = client_id);

-- 5. Create Policies for Operators (Filtering by company)
CREATE POLICY "Operators can view assigned policies" 
ON public.policies FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() 
    AND company = policies.operator_id
    AND role = 'operator'
  )
);

CREATE POLICY "Operators can update assigned policies" 
ON public.policies FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() 
    AND company = policies.operator_id
    AND role = 'operator'
  )
);

-- 6. Create Policy for Admins (View all)
CREATE POLICY "Admins can view all policies" 
ON public.policies FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() 
    AND role = 'admin'
  )
);

-- 7. Enable Realtime Replication for policies
-- First, check if the publication exists, then add the table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        -- Check if table is already in publication
        IF NOT EXISTS (
            SELECT 1 FROM pg_publication_tables 
            WHERE pubname = 'supabase_realtime' 
            AND schemaname = 'public' 
            AND tablename = 'policies'
        ) THEN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.policies;
        END IF;
    END IF;
END $$;
