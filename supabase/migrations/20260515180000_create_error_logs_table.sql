-- =============================================================
-- MIGRATION: create_error_logs_table
-- Date: 2026-05-15
-- Description: Creates a table to track application errors and auth failures.
-- =============================================================

CREATE TABLE IF NOT EXISTS public.error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    error_message TEXT NOT NULL,
    error_code TEXT,
    stack_trace TEXT,
    context_data JSONB, -- For extra info like screen name, form data, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.error_logs ENABLE ROW LEVEL SECURITY;

-- Allow anyone (even unauthenticated guests) to INSERT error logs
-- This is useful for tracking signup errors where the user isn't logged in yet.
CREATE POLICY "Anyone can insert error logs"
ON public.error_logs FOR INSERT
WITH CHECK (true);

-- Only admins can view error logs
CREATE POLICY "Admins can view error logs"
ON public.error_logs FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND role = 'admin'
    )
);
