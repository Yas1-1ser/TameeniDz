-- Fix storage RLS policies for the private 'documents' bucket
-- Ensures quotes/, policies/, users/, and receipts/ paths work correctly
-- Must be applied to the live database for document upload to work

-- READ
DROP POLICY IF EXISTS "Users can read own documents" ON storage.objects;
CREATE POLICY "Users can read own documents" ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

DROP POLICY IF EXISTS "Authenticated can read legal dossier" ON storage.objects;
CREATE POLICY "Authenticated can read legal dossier" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'documents' AND name = 'dossier.pdf');

-- INSERT
DROP POLICY IF EXISTS "Users can upload own documents" ON storage.objects;
CREATE POLICY "Users can upload own documents" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- UPDATE (for upsert)
DROP POLICY IF EXISTS "Users can replace own documents" ON storage.objects;
CREATE POLICY "Users can replace own documents" ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  )
  WITH CHECK (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- DELETE
DROP POLICY IF EXISTS "Users can delete own documents" ON storage.objects;
CREATE POLICY "Users can delete own documents" ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'documents' AND (
      ((storage.foldername(name))[1] = 'users' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      ((storage.foldername(name))[1] = 'quotes' AND (storage.foldername(name))[2] = auth.uid()::text)
      OR
      (name LIKE 'receipts/' || auth.uid()::text || '_%')
      OR
      (name LIKE 'policies/documents/' || auth.uid()::text || '_%')
      OR
      ((storage.foldername(name))[1] = 'policies' AND EXISTS (
        SELECT 1 FROM public.policies 
        WHERE id::text = (storage.foldername(name))[2] AND client_id = auth.uid()
      ))
    )
  );

-- ADMIN (full access)
DROP POLICY IF EXISTS "Admins can manage documents" ON storage.objects;
CREATE POLICY "Admins can manage documents" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'documents' AND private.current_user_role()::text = 'admin')
  WITH CHECK (bucket_id = 'documents' AND private.current_user_role()::text = 'admin');

-- OPERATOR read access (operators need to read policy documents to review them)
DROP POLICY IF EXISTS "Operators can read policy documents" ON storage.objects;
CREATE POLICY "Operators can read policy documents" ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'documents' AND
    private.current_user_role()::text IN ('operator', 'admin') AND
    (
      (storage.foldername(name))[1] IN ('quotes', 'policies', 'receipts', 'users')
    )
  );
