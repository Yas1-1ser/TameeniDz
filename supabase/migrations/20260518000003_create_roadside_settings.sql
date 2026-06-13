-- Create roadside settings table for dynamic UI copy
CREATE TABLE IF NOT EXISTS public.roadside_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Enable RLS and allow anyone to read
ALTER TABLE public.roadside_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read roadside settings" ON public.roadside_settings;
CREATE POLICY "Anyone can read roadside settings" ON public.roadside_settings FOR SELECT USING (true);

-- Insert premium dynamic Arabic copy
INSERT INTO public.roadside_settings (key, value) VALUES
  ('intro_title', 'لسنا مجرد تأمين، نحن سندك في الطريق'),
  ('intro_desc', 'تعطلت سيارتك؟ لا تقلق. تطبيقنا يربطك فوراً بأقرب شاحنة سحب (ديبناج) وأفضل الورشات المعتمدة في ولايتك. مع "شبكة شركائنا"، ستحصل على إصلاح مضمون، سرعة في التنفيذ، وتخفيضات حصرية لزبائننا.'),
  ('sos_title', 'النجدة في ضغطة زر'),
  ('sos_subtitle', 'اضغط لطلب المساعدة الطارئة فوراً وتحديد موقعك'),
  ('takaful_title', 'ما هو التأمين التكافلي؟'),
  ('takaful_desc', 'هو نظام تأمين إسلامي يقوم على مبدأ التضامن والتعاون المشترك بين المشتركين، حيث يتم تعويض المتضررين من صندوق مشترك يُدار بأعلى درجات الشفافية والأمان، بفصل كامل عن أرباح المساهمين.'),
  ('motto_title', 'شعار خدمات المساعدة'),
  ('motto_desc', 'شعارنا دائمًا هو "لسنا مجرد تأمين، نحن سندك في الطريق". لا نكتفي بتقديم التغطية المالية للمطالبات، بل نرافقك ميدانياً في أصعب لحظاتك على الطريق لنضمن سلامتك وراحة بالك عبر خدمة SOS على مدار الساعة.')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
