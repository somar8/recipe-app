-- A small stand-in for the parts of Supabase that schema.sql relies on (local tests only).
create role anon nologin;
create role authenticated nologin;
create schema auth;
create table auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_user_meta_data jsonb,
  created_at timestamptz default now(),
  email_confirmed_at timestamptz default now(), -- confirmed unless a test says otherwise
  last_sign_in_at timestamptz
);
-- Like Supabase: the signed-in user's id comes from the request's JWT.
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
-- Like Supabase: all claims of the request's JWT (the email lives here).
create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
$$;
grant usage on schema auth to anon, authenticated;
grant execute on function auth.jwt() to anon, authenticated;
grant execute on function auth.uid() to anon, authenticated;
-- Like Supabase: new tables, sequences and functions in public are open to anon and
-- authenticated by default; schema.sql narrows this down and RLS decides which rows.
grant usage on schema public to anon, authenticated;
alter default privileges in schema public grant all on tables to anon, authenticated;
alter default privileges in schema public grant all on sequences to anon, authenticated;
alter default privileges in schema public grant execute on functions to anon, authenticated;
