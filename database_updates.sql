-- 0a. Fix the users table INSERT policy
DROP POLICY IF EXISTS "Users can insert their own record" ON public.users;

CREATE POLICY "Users can insert their own record"
ON public.users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- 0b. Fix the users table schema
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS ccp_number TEXT,
  ADD COLUMN IF NOT EXISTS phone_number TEXT,
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS company TEXT,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE public.users ALTER COLUMN role SET DEFAULT 'subscriber';

-- 1a. Notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_id    UUID REFERENCES auth.users(id),
  sender_role  TEXT NOT NULL DEFAULT 'system',
  recipient_role TEXT NOT NULL DEFAULT 'subscriber',
  title        TEXT NOT NULL,
  body         TEXT NOT NULL,
  type         TEXT NOT NULL DEFAULT 'general',
  reference_id UUID,
  is_read      BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Admins see all notifications"
ON public.notifications FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Anyone can insert notification"
ON public.notifications FOR INSERT
WITH CHECK (true);

CREATE POLICY "Users update own notifications"
ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

-- 1b. Plan subscriptions
CREATE TABLE IF NOT EXISTS public.plan_subscriptions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id      UUID NOT NULL REFERENCES public.plans(id),
  operator_id  TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'pending',
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.plan_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients see own subscriptions"
ON public.plan_subscriptions FOR SELECT
USING (auth.uid() = client_id);

CREATE POLICY "Operators see their subscriptions"
ON public.plan_subscriptions FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'operator'
    AND company = operator_id
  )
);

CREATE POLICY "Admins see all"
ON public.plan_subscriptions FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Clients insert own subscriptions"
ON public.plan_subscriptions FOR INSERT
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "Operators and admins can update"
ON public.plan_subscriptions FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role IN ('operator','admin')
  )
);

-- 1c. Garages table
CREATE TABLE IF NOT EXISTS public.garages (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name             TEXT NOT NULL,
  owner_name       TEXT,
  phone            TEXT NOT NULL,
  wilaya           TEXT NOT NULL,
  specialty        TEXT NOT NULL DEFAULT 'general',
  rating           NUMERIC(3,1) NOT NULL DEFAULT 4.5,
  is_towing        BOOLEAN NOT NULL DEFAULT false,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  discount_percent INTEGER NOT NULL DEFAULT 15,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.garages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active garages"
ON public.garages FOR SELECT USING (is_active = true);

CREATE POLICY "Admins manage garages"
ON public.garages FOR ALL
USING (
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
);

INSERT INTO public.garages (name, owner_name, phone, wilaya, specialty, rating, is_towing, latitude, longitude, discount_percent)
VALUES
  ('ورشة الأمانة', 'محمد بن علي', '0555123456', 'الجزائر', 'general', 4.8, false, 36.737, 3.086, 20),
  ('مركز إصلاح الإطارات الذهبي', 'حسين كريمي', '0661234567', 'الجزائر', 'tires', 4.6, false, 36.752, 3.059, 15),
  ('ورشة الكهرباء الحديثة', 'عمر سعيد', '0550987654', 'الجزائر', 'electrician', 4.5, false, 36.718, 3.113, 15),
  ('شركة السحب والإنقاذ', 'يوسف درار', '0770123456', 'الجزائر', 'general', 4.9, true, 36.740, 3.095, 10),
  ('ورشة نجمة البليدة', 'أحمد زيادي', '0660345678', 'البليدة', 'body', 4.4, false, 36.471, 2.831, 15),
  ('مركز السحب الجهوي', 'ناصر حمدي', '0555876543', 'البليدة', 'general', 4.7, true, 36.469, 2.835, 10),
  ('ورشة الأوراس', 'خالد بوشامة', '0661567890', 'باتنة', 'general', 4.5, false, 35.555, 6.174, 15),
  ('مركز إصلاح الوهراني', 'إبراهيم لعريبي', '0550234567', 'وهران', 'electrician', 4.6, false, 35.697, -0.633, 20),
  ('ورشة قسنطينة', 'رضا مرابط', '0770567890', 'قسنطينة', 'transmission', 4.3, false, 36.365, 6.614, 15),
  ('سحب الشرق', 'منير بوخبزة', '0661890123', 'قسنطينة', 'general', 4.8, true, 36.368, 6.618, 10);
