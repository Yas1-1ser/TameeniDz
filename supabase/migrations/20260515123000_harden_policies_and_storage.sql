-- Harden policies table RLS and storage read access for shared legal dossier.

alter table public.policies enable row level security;

drop policy if exists "Clients can update their own policies" on public.policies;
create policy "Clients can update their own policies"
  on public.policies
  for update
  to authenticated
  using (auth.uid() = client_id)
  with check (auth.uid() = client_id);

drop policy if exists "Operators can view assigned policies" on public.policies;
create policy "Operators can view assigned policies"
  on public.policies
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'operator'
        and u.company = policies.operator_id
    )
  );

drop policy if exists "Operators can update assigned policies" on public.policies;
create policy "Operators can update assigned policies"
  on public.policies
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'operator'
        and u.company = policies.operator_id
    )
  )
  with check (
    exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'operator'
        and u.company = policies.operator_id
    )
  );

drop policy if exists "Admins can view all policies" on public.policies;
drop policy if exists "Admins can manage all policies" on public.policies;
create policy "Admins can manage all policies"
  on public.policies
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'admin'
    )
  )
  with check (
    exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'admin'
    )
  );

drop policy if exists "Authenticated can read legal dossier" on storage.objects;
create policy "Authenticated can read legal dossier"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'documents'
    and name = 'dossier.pdf'
  );
