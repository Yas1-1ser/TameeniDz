-- ============================================================
-- Migration: Fix plans with 0 premium amounts
-- Date: 2026-05-19
-- Description: Updates all plans that have premium_amount = 0
--              with realistic Algerian Takaful insurance prices.
-- ============================================================

-- Update Transport plans
UPDATE public.plans 
SET premium_amount = 18000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%transport%' OR name_ar ILIKE '%نقل%');

-- Update Agriculture plans  
UPDATE public.plans 
SET premium_amount = 25000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%agricol%' OR name_ar ILIKE '%فلاح%' OR name_ar ILIKE '%صناع%');

-- Update Auto/Car plans
UPDATE public.plans 
SET premium_amount = 10000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%auto%' OR name_en ILIKE '%car%' OR name_ar ILIKE '%سيار%' OR icon_type = 'car' OR icon_type = 'directions_car');

-- Update Home plans
UPDATE public.plans 
SET premium_amount = 15000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%home%' OR name_en ILIKE '%house%' OR name_ar ILIKE '%سكن%' OR name_ar ILIKE '%منزل%' OR icon_type = 'home');

-- Update Business/Commerce plans
UPDATE public.plans 
SET premium_amount = 35000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%business%' OR name_en ILIKE '%commerc%' OR name_ar ILIKE '%تجار%' OR icon_type = 'business' OR icon_type = 'store');

-- Update Travel plans
UPDATE public.plans 
SET premium_amount = 8000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%travel%' OR name_en ILIKE '%flight%' OR name_ar ILIKE '%سفر%' OR icon_type = 'flight' OR icon_type = 'flight_takeoff');

-- Update Legal/Rafik plans
UPDATE public.plans 
SET premium_amount = 12000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%legal%' OR name_en ILIKE '%rafik%' OR name_ar ILIKE '%قانون%' OR name_ar ILIKE '%رفيق%' OR icon_type = 'gavel');

-- Update Construction/Build plans
UPDATE public.plans 
SET premium_amount = 30000
WHERE premium_amount = 0 
  AND (name_en ILIKE '%construct%' OR name_en ILIKE '%build%' OR name_ar ILIKE '%بناء%' OR icon_type = 'build');

-- Catch-all: any remaining plans still at 0 get a default price
UPDATE public.plans 
SET premium_amount = 15000
WHERE premium_amount = 0;
