-- Database tests for the Recipe App. Run with: bash supabase/tests/run.sh
-- Every check raises an error with a clear message when it fails.
\set ON_ERROR_STOP on
\set QUIET on

create or replace function pg_temp.check(ok boolean, what text) returns void language plpgsql as $$
begin
  if ok is not true then raise exception 'FAILED: %', what; end if;
  raise notice 'ok - %', what;
end $$;

-- Two users. Acting as one: set_config('request.jwt.claim.sub', id) + set role authenticated.
insert into auth.users (id, email, raw_user_meta_data) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'anna@example.com', '{"username":"anna"}'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'ben@example.com', '{"username":"ben"}');

-- ---------- Anna saves a recipe ----------
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-0000-0000-000000000001', false);
set role authenticated;

select public.save_recipe('{"title":"Pancakes","description":"Sunday breakfast","servings":4,"prep_time_minutes":10,
  "ingredients":[{"name":"flour","quantity":"250","unit":"g"},{"name":"  "},{"name":"milk","quantity":"500","unit":"ml"},{"name":"eggs","quantity":"2"}]}') as pancakes \gset

select pg_temp.check((select user_id = auth.uid() and title = 'Pancakes' and servings = 4 and cook_time_minutes is null
  from public.recipes where id = :pancakes), 'a new recipe is saved and belongs to the signed-in user');
select pg_temp.check((select array_agg(name order by position) = array['flour','milk','eggs']
  from public.recipe_ingredients where recipe_id = :pancakes), 'ingredients keep their order; empty ones are skipped');
select pg_temp.check((select quantity = '2' and unit is null from public.recipe_ingredients
  where recipe_id = :pancakes and name = 'eggs'), 'a missing unit is stored as nothing');

select public.save_recipe(jsonb_build_object('id', :pancakes, 'title', 'Fluffy pancakes', 'servings', 2,
  'ingredients', '[{"name":"flour","quantity":"200","unit":"g"},{"name":"buttermilk"}]'::jsonb)) as same_id \gset
select pg_temp.check(:same_id = :pancakes, 'saving an existing recipe keeps its id');
select pg_temp.check((select title = 'Fluffy pancakes' and servings = 2 and description is null and updated_at >= created_at
  from public.recipes where id = :pancakes), 'editing a recipe replaces its fields');
select pg_temp.check((select array_agg(name order by position) = array['flour','buttermilk']
  from public.recipe_ingredients where recipe_id = :pancakes), 'editing a recipe replaces its ingredients');

do $$ begin
  perform public.save_recipe('{"title":"  "}');
  perform pg_temp.check(false, 'a recipe without a title is refused');
exception when check_violation then perform pg_temp.check(true, 'a recipe without a title is refused'); end $$;
do $$ begin
  perform public.save_recipe('{"title":"Soup","servings":0}');
  perform pg_temp.check(false, 'zero servings is refused');
exception when check_violation then perform pg_temp.check(true, 'zero servings is refused'); end $$;
do $$ begin
  perform public.save_recipe('{"id":999999,"title":"Ghost"}');
  perform pg_temp.check(false, 'saving a recipe that does not exist is refused');
exception when no_data_found then perform pg_temp.check(true, 'saving a recipe that does not exist is refused'); end $$;
select pg_temp.check((select count(*) = 1 from public.recipes), 'refused saves leave nothing behind');

select public.save_recipe('{"title":"Tomato soup","ingredients":[{"name":"tomatoes"}]}') as soup \gset
select set_config('my.pancakes', :'pancakes', false), set_config('my.soup', :'soup', false) \g /dev/null

-- ---------- Anna's groups ----------
insert into public.recipe_groups (name, description) values ('Breakfast', 'Morning food') returning id as breakfast \gset
select set_config('my.breakfast', :'breakfast', false);
insert into public.recipe_group_items (group_id, recipe_id) values (:breakfast, :pancakes);
select pg_temp.check((select user_id = auth.uid() from public.recipe_groups where id = :breakfast),
  'a new group belongs to the signed-in user');
select pg_temp.check((select count(*) = 1 from public.recipe_group_items where group_id = :breakfast),
  'a recipe can be added to a group');
select pg_temp.check((select count(*) = 1 from public.recipes r join public.recipe_group_items i on i.recipe_id = r.id
  where i.group_id = :breakfast and r.title ilike '%PANCAKE%'), 'search on the title ignores capitals');

-- ---------- Ben cannot see or touch Anna's data ----------
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-0000-0000-000000000002', false);

select pg_temp.check((select count(*) = 0 from public.recipes), 'another user sees none of the recipes');
select pg_temp.check((select count(*) = 0 from public.recipe_ingredients), 'another user sees none of the ingredients');
select pg_temp.check((select count(*) = 0 from public.recipe_groups), 'another user sees none of the groups');
select pg_temp.check((select count(*) = 0 from public.recipe_group_items), 'another user sees none of the group contents');

update public.recipes set title = 'Hacked' where id = :pancakes;
delete from public.recipes where id = :soup;
delete from public.recipe_groups where id = :breakfast;
delete from public.recipe_ingredients where recipe_id = :pancakes;

do $$ begin
  perform public.save_recipe(jsonb_build_object('id', current_setting('my.pancakes')::bigint, 'title', 'Hacked'));
  perform pg_temp.check(false, 'another user cannot save over a recipe');
exception when no_data_found then perform pg_temp.check(true, 'another user cannot save over a recipe'); end $$;

do $$ begin
  insert into public.recipes (user_id, title) values ('aaaaaaaa-0000-0000-0000-000000000001', 'Planted');
  perform pg_temp.check(false, 'a recipe cannot be created in someone else''s name');
exception when insufficient_privilege then perform pg_temp.check(true, 'a recipe cannot be created in someone else''s name'); end $$;

do $$ begin
  insert into public.recipe_ingredients (recipe_id, name) values (current_setting('my.pancakes')::bigint, 'salt');
  perform pg_temp.check(false, 'ingredients cannot be added to someone else''s recipe');
exception when insufficient_privilege then perform pg_temp.check(true, 'ingredients cannot be added to someone else''s recipe'); end $$;

insert into public.recipe_groups (name) values ('Ben''s group') returning id as bens_group \gset
select set_config('my.bens_group', :'bens_group', false);
do $$ begin
  insert into public.recipe_group_items (group_id, recipe_id)
  values (current_setting('my.bens_group')::bigint, current_setting('my.pancakes')::bigint);
  perform pg_temp.check(false, 'someone else''s recipe cannot be put in your group');
exception when insufficient_privilege then perform pg_temp.check(true, 'someone else''s recipe cannot be put in your group'); end $$;

select public.save_recipe('{"title":"Ben''s stew"}') as stew \gset
select set_config('my.stew', :'stew', false);
do $$ begin
  insert into public.recipe_group_items (group_id, recipe_id)
  values (current_setting('my.breakfast')::bigint, current_setting('my.stew')::bigint);
  perform pg_temp.check(false, 'your recipe cannot be put in someone else''s group');
exception when insufficient_privilege then perform pg_temp.check(true, 'your recipe cannot be put in someone else''s group'); end $$;

-- ---------- Signed-out visitors ----------
reset role;
set role anon;
select set_config('request.jwt.claim.sub', '', false);
do $$ begin
  perform count(*) from public.recipes;
  perform pg_temp.check(false, 'a signed-out visitor cannot read recipes');
exception when insufficient_privilege then perform pg_temp.check(true, 'a signed-out visitor cannot read recipes'); end $$;
do $$ begin
  perform public.save_recipe('{"title":"Spam"}');
  perform pg_temp.check(false, 'a signed-out visitor cannot save recipes');
exception when insufficient_privilege then perform pg_temp.check(true, 'a signed-out visitor cannot save recipes'); end $$;
select pg_temp.check(public.ping() = 'ok', 'the keep-alive ping works without signing in');

-- ---------- Back as Anna: nothing was changed, and deletes clean up ----------
reset role;
select pg_temp.check((select title = 'Fluffy pancakes' from public.recipes where id = :pancakes),
  'the other user''s update changed nothing');
select pg_temp.check((select count(*) = 3 from public.recipes), 'the other user''s deletes removed nothing');
select pg_temp.check((select count(*) = 2 from public.recipe_ingredients where recipe_id = :pancakes),
  'the other user could not delete ingredients');

select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-0000-0000-000000000001', false);
set role authenticated;
delete from public.recipes where id = :pancakes;
reset role;
select pg_temp.check((select count(*) = 0 from public.recipe_ingredients where recipe_id = :pancakes),
  'deleting a recipe deletes its ingredients');
select pg_temp.check((select count(*) = 0 from public.recipe_group_items where recipe_id = :pancakes)
  and (select count(*) = 1 from public.recipe_groups where id = :breakfast),
  'deleting a recipe takes it out of groups but keeps the group');

delete from auth.users where email = 'anna@example.com';
select pg_temp.check((select count(*) = 0 from public.recipes where user_id = 'aaaaaaaa-0000-0000-0000-000000000001')
  and (select count(*) = 0 from public.recipe_groups where user_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  'deleting an account deletes its recipes and groups');
select pg_temp.check((select count(*) = 1 from public.recipes), 'the other account keeps its recipes');
