-- Migration to add payment tracking columns to policies table
-- Date: 2026-05-09

-- 1. Add paid_at column
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policies' AND COLUMN_NAME = 'paid_at') THEN
        ALTER TABLE public.policies ADD COLUMN paid_at TIMESTAMPTZ;
    END IF;
END $$;

-- 2. Add receipt_number column
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policies' AND COLUMN_NAME = 'receipt_number') THEN
        ALTER TABLE public.policies ADD COLUMN receipt_number TEXT;
    END IF;
END $$;

-- 3. Add admin_notes column if missing (used in detail screens)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policies' AND COLUMN_NAME = 'admin_notes') THEN
        ALTER TABLE public.policies ADD COLUMN admin_notes TEXT;
    END IF;
END $$;

-- 4. Add 'paid' to policy_status enum
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'paid';
