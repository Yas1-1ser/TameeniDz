-- ============================================================
-- Migration: Create Plans Table for Dynamic Offers
-- Date: 2026-05-18
-- ============================================================

DROP TABLE IF EXISTS public.plans CASCADE;

CREATE TABLE public.plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  operator_id TEXT NOT NULL, -- 'algeria_takaful' or 'al_ittihad'
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  premium_amount NUMERIC NOT NULL,
  coverage_details TEXT NOT NULL,
  tabarru_rate NUMERIC NOT NULL, -- e.g. 0.8 for 80%
  surplus_rate NUMERIC NOT NULL, -- e.g. 0.5 for 50%
  claims_duration TEXT NOT NULL,
  is_best_value BOOLEAN DEFAULT false,
  icon_type TEXT DEFAULT 'shield',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;

-- Allow public read access to plans
CREATE POLICY "Allow public read access to plans" ON public.plans
  FOR SELECT USING (true);

-- Allow authenticated admins/operators to insert/update plans
CREATE POLICY "Allow admins to manage plans" ON public.plans
  FOR ALL USING (auth.role() = 'authenticated');

-- Insert default dummy data to match the UI comparison
INSERT INTO public.plans (
  operator_id, name_ar, name_en, premium_amount, coverage_details, 
  tabarru_rate, surplus_rate, claims_duration, is_best_value, icon_type
) VALUES 
(
  'algeria_takaful', 'الجزائر للتكافل', 'Algerie Takaful', 50000, '10,000,000',
  0.8, 0.5, '48 Hours', true, 'workspace_premium'
),
(
  'al_ittihad', 'الاتحاد', 'Al Ittihad', 45000, '8,000,000',
  0.85, 0.3, '72 Hours', false, 'shield_outlined'
);
