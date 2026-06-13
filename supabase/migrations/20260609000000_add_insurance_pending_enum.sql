-- Add 'insurance_pending' to policy_status enum to fix the database error during insurance request submission.
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'insurance_pending';
