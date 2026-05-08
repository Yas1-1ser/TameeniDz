create schema if not exists private;

grant usage on schema private to authenticated;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone_number text,
  ccp_number text,
  role text not null default 'client',
  company text,
  employee_id text,
  operator_id text,
  documents_submitted boolean not null default false,
  documents_submitted_at timestamptz,
  phone_verified boolean not null default false,
  email_verified boolean not null default false,
  fcm_token text,
  last_login timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.users add column if not exists full_name text;
alter table public.users add column if not exists email text;
alter table public.users add column if not exists phone_number text;
alter table public.users add column if not exists ccp_number text;
alter table public.users add column if not exists role text not null default 'client';
alter table public.users add column if not exists company text;
alter table public.users add column if not exists employee_id text;
alter table public.users add column if not exists operator_id text;
alter table public.users add column if not exists documents_submitted boolean not null default false;
alter table public.users add column if not exists documents_submitted_at timestamptz;
alter table public.users add column if not exists phone_verified boolean not null default false;
alter table public.users add column if not exists email_verified boolean not null default false;
alter table public.users add column if not exists fcm_token text;
alter table public.users add column if not exists last_login timestamptz;
alter table public.users add column if not exists created_at timestamptz not null default timezone('utc', now());
alter table public.users add column if not exists updated_at timestamptz not null default timezone('utc', now());

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_role_check'
      and conrelid = 'public.users'::regclass
  ) then
    alter table public.users
      add constraint users_role_check
      check (role in ('client', 'operator', 'admin'));
  end if;
end $$;

create unique index if not exists users_email_unique_idx
  on public.users (lower(email))
  where email is not null;

create unique index if not exists users_phone_number_unique_idx
  on public.users (phone_number)
  where phone_number is not null;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
  before update on public.users
  for each row execute function private.set_updated_at();

create or replace function private.current_user_role()
returns text
language sql
security definer
stable
set search_path = ''
as $$
  select role
  from public.users
  where id = auth.uid()
  limit 1
$$;

grant execute on function private.current_user_role() to authenticated;

create or replace function private.handle_auth_user_created()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.users (
    id,
    email,
    full_name,
    phone_number,
    ccp_number,
    role,
    company,
    employee_id,
    email_verified,
    created_at,
    updated_at
  )
  values (
    new.id,
    new.email,
    nullif(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.raw_user_meta_data ->> 'phone_number', ''),
    nullif(new.raw_user_meta_data ->> 'ccp_number', ''),
    coalesce(nullif(new.raw_user_meta_data ->> 'role', ''), 'client'),
    nullif(new.raw_user_meta_data ->> 'company', ''),
    nullif(new.raw_user_meta_data ->> 'employee_id', ''),
    new.email_confirmed_at is not null,
    timezone('utc', now()),
    timezone('utc', now())
  )
  on conflict (id) do update set
    email = excluded.email,
    full_name = coalesce(excluded.full_name, public.users.full_name),
    phone_number = coalesce(excluded.phone_number, public.users.phone_number),
    ccp_number = coalesce(excluded.ccp_number, public.users.ccp_number),
    role = excluded.role,
    company = coalesce(excluded.company, public.users.company),
    employee_id = coalesce(excluded.employee_id, public.users.employee_id),
    email_verified = excluded.email_verified,
    updated_at = timezone('utc', now());

  return new;
end;
$$;

create or replace function private.handle_auth_user_updated()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.users
  set
    email = new.email,
    email_verified = new.email_confirmed_at is not null,
    updated_at = timezone('utc', now())
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_tameenidz on auth.users;
create trigger on_auth_user_created_tameenidz
  after insert on auth.users
  for each row execute function private.handle_auth_user_created();

drop trigger if exists on_auth_user_updated_tameenidz on auth.users;
create trigger on_auth_user_updated_tameenidz
  after update of email, email_confirmed_at on auth.users
  for each row execute function private.handle_auth_user_updated();

alter table public.users enable row level security;

grant select, insert, update, delete on public.users to authenticated;

drop policy if exists "Users can read own profile" on public.users;
create policy "Users can read own profile"
  on public.users
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on public.users;
create policy "Users can insert own profile"
  on public.users
  for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.users;
create policy "Users can update own profile"
  on public.users
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "Staff can read user profiles" on public.users;
create policy "Staff can read user profiles"
  on public.users
  for select
  to authenticated
  using (private.current_user_role() in ('admin', 'operator'));

drop policy if exists "Admins can manage user profiles" on public.users;
create policy "Admins can manage user profiles"
  on public.users
  for all
  to authenticated
  using (private.current_user_role() = 'admin')
  with check (private.current_user_role() = 'admin');

insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do update set public = false;

drop policy if exists "Users can read own documents" on storage.objects;
create policy "Users can read own documents"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'users'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

drop policy if exists "Users can upload own documents" on storage.objects;
create policy "Users can upload own documents"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'users'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

drop policy if exists "Users can replace own documents" on storage.objects;
create policy "Users can replace own documents"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'users'
    and (storage.foldername(name))[2] = auth.uid()::text
  )
  with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'users'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

drop policy if exists "Users can delete own documents" on storage.objects;
create policy "Users can delete own documents"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = 'users'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

drop policy if exists "Admins can manage documents" on storage.objects;
create policy "Admins can manage documents"
  on storage.objects
  for all
  to authenticated
  using (bucket_id = 'documents' and private.current_user_role() = 'admin')
  with check (bucket_id = 'documents' and private.current_user_role() = 'admin');
