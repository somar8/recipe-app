-- Extra checks when the project is shared with Word Buddy.
\set ON_ERROR_STOP on
\set QUIET on
create or replace function pg_temp.check(ok boolean, what text) returns void language plpgsql as $$
begin
  if ok is not true then raise exception 'FAILED: %', what; end if;
  raise notice 'ok - %', what;
end $$;

select pg_temp.check(pg_get_functiondef('public.sync_profile'::regproc) not like '%display_name%',
  'Word Buddy''s sync_profile function is left untouched');
select pg_temp.check(exists (select 1 from pg_trigger where tgname = 'on_auth_user_changed')
  and exists (select 1 from pg_trigger where tgname = 'sync_recipe_profile')
  and not exists (select 1 from pg_trigger where tgname = 'sync_profile'),
  'both apps keep their own sign-up trigger, and no stray one is left');

insert into auth.users (id, email, raw_user_meta_data, last_sign_in_at) values
  ('99999999-0000-0000-0000-000000000009', 'shared@example.com', '{"username":"Sam","language":"de"}', now());
select pg_temp.check((select language = 'de' and sign_in_count = 1 from public.profiles
  where id = '99999999-0000-0000-0000-000000000009'), 'a sign-up still fills Word Buddy''s profile');
select pg_temp.check((select display_name = 'Sam' from public.recipe_profiles
  where id = '99999999-0000-0000-0000-000000000009'), 'and the Recipe App''s own profile');
update auth.users set last_sign_in_at = now() + interval '1 hour' where id = '99999999-0000-0000-0000-000000000009';
select pg_temp.check((select count(*) = 2 from public.sign_ins where user_id = '99999999-0000-0000-0000-000000000009'),
  'Word Buddy logs each sign-in exactly once');
