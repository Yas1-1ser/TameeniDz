-- Please run this in the Supabase SQL Editor
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'insurance_pending';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'issued';
