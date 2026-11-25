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

-- =====================================================================
-- Friends and sharing
-- =====================================================================
reset role;
-- Acting as someone now also sets their email, which friend requests are matched on.
create or replace function pg_temp.act_as(uid uuid, email text) returns void language sql as $$
  select set_config('request.jwt.claim.sub', uid::text, false),
         set_config('request.jwt.claims', json_build_object('sub', uid, 'email', email)::text, false);
$$;

insert into auth.users (id, email, raw_user_meta_data) values
  ('cccccccc-0000-0000-0000-000000000003', 'Carol@Example.com', '{"username":"Carol"}'),
  ('dddddddd-0000-0000-0000-000000000004', 'dave@example.com', '{"username":"Dave"}'),
  ('eeeeeeee-0000-0000-0000-000000000005', 'erin@example.com', null);

select pg_temp.check((select display_name = 'Carol' and email = 'carol@example.com' from public.recipe_profiles
  where id = 'cccccccc-0000-0000-0000-000000000003'), 'a profile is made at sign-up, with the name and a lower-case email');
select pg_temp.check((select display_name = 'erin' from public.recipe_profiles where id = 'eeeeeeee-0000-0000-0000-000000000005'),
  'without a name, the profile uses the first part of the email');

-- ---------- Carol sends requests ----------
select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
set role authenticated;
select public.send_friend_request('  DAVE@example.com ');
select public.send_friend_request('frank@example.com'); -- no account (yet)
select public.send_friend_request('dave@example.com');  -- again: no duplicate
select pg_temp.check((select array_agg(email_label order by email_label) = array['dave@example.com','frank@example.com']
  from public.list_sent_requests()), 'requests are stored once, in lower case, for accounts and non-accounts alike');
select pg_temp.check((select count(*) = 1 from public.recipe_profiles), 'the sender cannot see the profile of someone they asked (no hint they have an account)');
do $$ begin
  perform public.send_friend_request('carol@example.com');
  perform pg_temp.check(false, 'you cannot send a request to yourself');
exception when invalid_parameter_value then perform pg_temp.check(true, 'you cannot send a request to yourself'); end $$;
do $$ begin
  perform public.send_friend_request('not an email');
  perform pg_temp.check(false, 'a request needs a real email address');
exception when invalid_parameter_value then perform pg_temp.check(true, 'a request needs a real email address'); end $$;
do $$ begin
  insert into public.friend_requests (to_email) values ('someone@example.com');
  perform pg_temp.check(false, 'requests can only be sent through send_friend_request');
exception when insufficient_privilege then perform pg_temp.check(true, 'requests can only be sent through send_friend_request'); end $$;

-- ---------- Erin, a stranger, sees nothing ----------
select pg_temp.act_as('eeeeeeee-0000-0000-0000-000000000005', 'erin@example.com');
select pg_temp.check((select count(*) = 0 from public.friend_requests), 'a stranger sees no one else''s requests');
select pg_temp.check((select count(*) = 1 from public.recipe_profiles), 'a stranger sees only their own profile');
reset role;
select id as dave_request from public.friend_requests where to_email = 'dave@example.com' \gset
select set_config('my.dave_request', :'dave_request', false) \g /dev/null
select pg_temp.act_as('eeeeeeee-0000-0000-0000-000000000005', 'erin@example.com');
set role authenticated;
do $$ begin
  perform public.accept_friend_request(current_setting('my.dave_request')::bigint);
  perform pg_temp.check(false, 'nobody can accept a request meant for someone else');
exception when no_data_found then perform pg_temp.check(true, 'nobody can accept a request meant for someone else'); end $$;
delete from public.friend_requests;
select pg_temp.check(true, 'a stranger''s delete is ignored (checked below)');

-- ---------- Dave sees and accepts ----------
select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
select pg_temp.check((select count(*) = 1 from public.friend_requests), 'the addressee sees the waiting request');
select pg_temp.check((select display_name = 'Carol' from public.recipe_profiles where id = 'cccccccc-0000-0000-0000-000000000003'),
  'the addressee can see who sent it');
select pg_temp.check(public.accept_friend_request(:dave_request) = 'cccccccc-0000-0000-0000-000000000003', 'accepting makes you friends');
select pg_temp.check((select count(*) = 0 from public.friend_requests), 'the request is gone after accepting');
select pg_temp.check((select array_agg(display_name) = array['Carol'] from public.list_friends()), 'list_friends shows the new friend by name');
select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
select pg_temp.check((select array_agg(display_name) = array['Dave'] from public.list_friends()), 'the friendship shows for both');
select public.send_friend_request('dave@example.com');
select pg_temp.check((select count(*) = 0 from public.list_sent_requests() where email_label = 'dave@example.com'),
  'asking an existing friend again does nothing');

-- ---------- Carol's recipes and sharing ----------
select public.save_recipe('{"title":"Lasagne","ingredients":[{"name":"pasta sheets"},{"name":"ragu"}]}') as lasagne \gset
select public.save_recipe('{"title":"Tiramisu","ingredients":[{"name":"mascarpone"}]}') as tiramisu \gset
insert into public.recipe_groups (name) values ('Italian') returning id as italian \gset
insert into public.recipe_group_items (group_id, recipe_id) values (:italian, :tiramisu);
select set_config('my.lasagne', :'lasagne', false), set_config('my.tiramisu', :'tiramisu', false),
       set_config('my.italian', :'italian', false) \g /dev/null

select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
select pg_temp.check((select count(*) = 0 from public.recipes where user_id = 'cccccccc-0000-0000-0000-000000000003'),
  'a friend sees nothing that was not shared');

select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
insert into public.recipe_shares (recipe_id, friend_id) values (:lasagne, 'dddddddd-0000-0000-0000-000000000004');
do $$ begin
  insert into public.recipe_shares (recipe_id, friend_id) values (current_setting('my.lasagne')::bigint, 'eeeeeeee-0000-0000-0000-000000000005');
  perform pg_temp.check(false, 'you can only share with friends');
exception when insufficient_privilege then perform pg_temp.check(true, 'you can only share with friends'); end $$;

select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
select pg_temp.check((select title = 'Lasagne' from public.recipes where id = :lasagne), 'a shared recipe is visible to the friend');
select pg_temp.check((select count(*) = 2 from public.recipe_ingredients where recipe_id = :lasagne), 'with its ingredients');
select pg_temp.check((select count(*) = 0 from public.recipes where id = :tiramisu), 'but not the owner''s other recipes');
update public.recipes set title = 'Hacked' where id = :lasagne;
delete from public.recipe_ingredients where recipe_id = :lasagne;
delete from public.recipes where id = :lasagne;
do $$ begin
  perform public.save_recipe(jsonb_build_object('id', current_setting('my.lasagne')::bigint, 'title', 'Hacked'));
  perform pg_temp.check(false, 'a friend cannot save over a shared recipe');
exception when no_data_found then perform pg_temp.check(true, 'a friend cannot save over a shared recipe'); end $$;
do $$ begin
  insert into public.recipe_shares (recipe_id, friend_id) values (current_setting('my.lasagne')::bigint, 'eeeeeeee-0000-0000-0000-000000000005');
  perform pg_temp.check(false, 'a friend cannot pass a shared recipe on');
exception when insufficient_privilege then perform pg_temp.check(true, 'a friend cannot pass a shared recipe on'); end $$;
insert into public.recipe_groups (name) values ('Dave''s favourites') returning id as daves_group \gset
select set_config('my.daves_group', :'daves_group', false) \g /dev/null
do $$ begin
  insert into public.recipe_group_items (group_id, recipe_id) values (current_setting('my.daves_group')::bigint, current_setting('my.lasagne')::bigint);
  perform pg_temp.check(false, 'a shared recipe cannot go into your own collection (save a copy first)');
exception when insufficient_privilege then perform pg_temp.check(true, 'a shared recipe cannot go into your own collection (save a copy first)'); end $$;

select public.copy_recipe(:lasagne) as dave_copy \gset
select pg_temp.check((select user_id = auth.uid() and title = 'Lasagne' from public.recipes where id = :dave_copy),
  'saving a copy gives the friend their own recipe');
select pg_temp.check((select count(*) = 2 from public.recipe_ingredients where recipe_id = :dave_copy), 'the copy has the ingredients');
select public.save_recipe(jsonb_build_object('id', :dave_copy, 'title', 'Dave''s lasagne'));

-- ---------- Shared collections ----------
select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
select pg_temp.check((select title = 'Lasagne' from public.recipes where id = :lasagne), 'the friend''s changes and deletes did nothing; the copy is separate');
insert into public.collection_shares (group_id, friend_id) values (:italian, 'dddddddd-0000-0000-0000-000000000004');
select public.save_recipe('{"title":"Panna cotta"}') as panna \gset
insert into public.recipe_group_items (group_id, recipe_id) values (:italian, :panna);

select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
select pg_temp.check((select name = 'Italian' from public.recipe_groups where id = :italian), 'a shared collection is visible');
select pg_temp.check((select count(*) = 2 from public.recipes r join public.recipe_group_items i on i.recipe_id = r.id where i.group_id = :italian),
  'with its recipes, including ones added after sharing');
select pg_temp.check((select count(*) = 1 from public.recipe_ingredients where recipe_id = :tiramisu), 'and their ingredients');
delete from public.recipe_group_items where group_id = :italian;
update public.recipe_groups set name = 'Hacked' where id = :italian;
select pg_temp.check((select count(*) = 2 from public.recipe_group_items where group_id = :italian)
  and (select name = 'Italian' from public.recipe_groups where id = :italian), 'a friend cannot change a shared collection');

-- The friend can remove a shared recipe from their own list.
delete from public.recipe_shares where recipe_id = :lasagne;
select pg_temp.check((select count(*) = 0 from public.recipes where id = :lasagne), 'a friend can remove a share from their list');

-- ---------- Erin stays outside ----------
select pg_temp.act_as('eeeeeeee-0000-0000-0000-000000000005', 'erin@example.com');
select pg_temp.check((select count(*) = 0 from public.recipes) and (select count(*) = 0 from public.recipe_groups)
  and (select count(*) = 0 from public.recipe_shares) and (select count(*) = 0 from public.collection_shares)
  and (select count(*) = 0 from public.friendships), 'a stranger sees no recipes, collections, shares or friendships');
delete from public.collection_shares;
select pg_temp.check((select count(*) = 0 from public.list_friends()), 'a stranger has no friends listed');

-- ---------- Requests both ways become a friendship ----------
select public.send_friend_request('carol@example.com');
select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
select public.send_friend_request('Erin@example.com');
select pg_temp.check((select count(*) = 2 from public.list_friends()), 'asking someone who already asked you makes you friends at once');

-- ---------- Someone who signs up later finds the request ----------
reset role;
insert into auth.users (id, email, raw_user_meta_data) values
  ('ffffffff-0000-0000-0000-000000000006', 'frank@example.com', '{"username":"Frank"}');
select pg_temp.act_as('ffffffff-0000-0000-0000-000000000006', 'frank@example.com');
set role authenticated;
select pg_temp.check((select count(*) = 1 from public.friend_requests), 'a request waits for someone who signs up later');
delete from public.friend_requests;
select pg_temp.check((select count(*) = 0 from public.friend_requests), 'the addressee can decline (delete) a request');

-- ---------- Ending a friendship ends the sharing ----------
reset role;
select pg_temp.check((select count(*) = 1 from public.collection_shares), 'the stranger''s delete of shares did nothing');
select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
set role authenticated;
delete from public.friendships;
select pg_temp.check((select count(*) = 0 from public.recipe_groups where id = :italian), 'after unfriending, shared collections disappear');
reset role;
select pg_temp.check((select count(*) = 0 from public.collection_shares) and (select count(*) = 0 from public.recipe_shares),
  'unfriending removes everything the two shared');
select pg_temp.check((select count(*) = 1 from public.friendships), 'the other friendship (Carol and Erin) stays');

-- ---------- Signed-out visitors ----------
set role anon;
do $$ begin
  perform count(*) from public.recipe_profiles;
  perform pg_temp.check(false, 'a signed-out visitor cannot read profiles');
exception when insufficient_privilege then perform pg_temp.check(true, 'a signed-out visitor cannot read profiles'); end $$;
do $$ begin
  perform public.send_friend_request('x@example.com');
  perform pg_temp.check(false, 'a signed-out visitor cannot send requests');
exception when insufficient_privilege then perform pg_temp.check(true, 'a signed-out visitor cannot send requests'); end $$;
reset role;

-- =====================================================================
-- Finding people while typing
-- =====================================================================
reset role;
update auth.users set raw_user_meta_data = '{"username":"Dave van Dam"}' where id = 'dddddddd-0000-0000-0000-000000000004';
insert into auth.users (id, email, raw_user_meta_data)
select ('a0000000-0000-0000-0000-00000000000' || n)::uuid, 'zed' || n || '@mail.example', json_build_object('username', 'Zed ' || n)::jsonb
from generate_series(1, 6) n;
insert into auth.users (id, email, raw_user_meta_data) values ('b0000000-0000-0000-0000-000000000001', 'jo@example.com', '{"username":"Jo Bloggs"}'),
  ('b0000000-0000-0000-0000-000000000002', 'kim.de.wit@example.com', '{"username":"Kim"}');

select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
set role authenticated;
select pg_temp.check((select count(*) = 0 from public.search_people('da')), 'search starts at 3 letters');
select pg_temp.check((select display_name = 'Dave van Dam' and email_hint = 'da***@example.com' and status = 'none'
  from public.search_people('dav')), 'a name start finds the person, with only a hint of the email');
select pg_temp.check((select count(*) = 1 from public.search_people('van')), 'a later word of the name matches too');
select pg_temp.check((select display_name = 'Kim' from public.search_people('KIM.de')), 'the start of an email (before the @) matches, ignoring capitals');
select pg_temp.check((select count(*) = 0 from public.search_people('kim.de.wit@example.com')),
  'a whole email address finds nobody, so it never confirms an account');
select pg_temp.check((select count(*) = 0 from public.search_people('example.com')),
  'typing a domain does not list everyone with that email provider');
select pg_temp.check((select count(*) = 0 from public.search_people('%%%')) and (select count(*) = 0 from public.search_people('___')),
  'typed % and _ are plain letters, not wildcards');
select pg_temp.check((select count(*) = 0 from public.search_people('car')), 'you never find yourself');
select pg_temp.check((select status = 'friend' from public.search_people('eri')), 'friends are marked as friends');
select pg_temp.check((select count(*) = 5 from public.search_people('zed')), 'at most 5 people are returned');
select pg_temp.check((select bool_and(email_hint not like 'zed_@%' and email_hint like '%***@mail.example') from public.search_people('zed')),
  'no full email address is ever returned');
select pg_temp.check((select email_hint = 'er***@example.com' from public.search_people('erin')), 'only the first two letters of an email show');
select pg_temp.check((select email_hint = 'j***@example.com' from public.search_people('jo b')), 'a very short email shows only its first letter');

select public.send_friend_request_to('dddddddd-0000-0000-0000-000000000004');
select pg_temp.check((select status = 'sent' from public.search_people('dave')), 'tapping a person sends them a request');

select pg_temp.act_as('dddddddd-0000-0000-0000-000000000004', 'dave@example.com');
select pg_temp.check((select status = 'received' from public.search_people('carol')), 'the other person sees that you asked them');
select public.send_friend_request_to('cccccccc-0000-0000-0000-000000000003');
select pg_temp.check((select status = 'friend' from public.search_people('carol')), 'adding someone who asked you makes you friends');
do $$ begin
  perform public.send_friend_request_to('00000000-0000-0000-0000-000000000000');
  perform pg_temp.check(false, 'sending to an unknown person is refused');
exception when no_data_found then perform pg_temp.check(true, 'sending to an unknown person is refused'); end $$;

reset role;
set role anon;
do $$ begin
  perform * from public.search_people('dave');
  perform pg_temp.check(false, 'a signed-out visitor cannot search for people');
exception when insufficient_privilege then perform pg_temp.check(true, 'a signed-out visitor cannot search for people'); end $$;
reset role;

-- =====================================================================
-- Hardening: hidden addresses, rate limits, ids, sizes, confirmed email
-- =====================================================================
reset role;
select pg_temp.act_as('cccccccc-0000-0000-0000-000000000003', 'carol@example.com');
set role authenticated;
select public.send_friend_request_to('b0000000-0000-0000-0000-000000000002'); -- Kim, picked from the search
select pg_temp.check((select display_name = 'Kim' and email_label = 'ki***@example.com' from public.list_sent_requests()
  where display_name = 'Kim'), 'a person picked from the search shows in your sent list by name, email hidden');
do $$ begin
  perform to_email from public.friend_requests;
  perform pg_temp.check(false, 'nobody can read the address a request was sent to');
exception when insufficient_privilege then perform pg_temp.check(true, 'nobody can read the address a request was sent to'); end $$;

-- Searching too fast is refused (60 a minute).
do $$ begin
  for i in 1..61 loop perform * from public.search_people('zed'); end loop;
  perform pg_temp.check(false, 'searching too fast is refused');
exception when program_limit_exceeded then perform pg_temp.check(true, 'searching too fast is refused'); end $$;

-- Sending and cancelling over and over is refused too (30 a day).
do $$ begin
  for i in 1..31 loop
    perform public.send_friend_request('spam' || i || '@example.com');
    delete from public.friend_requests where from_user = auth.uid();
  end loop;
  perform pg_temp.check(false, 'sending and cancelling requests over and over is refused');
exception when program_limit_exceeded then perform pg_temp.check(true, 'sending and cancelling requests over and over is refused'); end $$;

do $$ begin
  insert into public.recipes (id, title) values (987654, 'Future id');
  perform pg_temp.check(false, 'nobody can choose a recipe id (which would block everyone else''s saves)');
exception when others then perform pg_temp.check(sqlstate = '428C9', 'nobody can choose a recipe id (which would block everyone else''s saves)'); end $$;
do $$ begin
  perform public.save_recipe(jsonb_build_object('title', repeat('x', 201)));
  perform pg_temp.check(false, 'a 201-character title is refused');
exception when check_violation then perform pg_temp.check(true, 'a 201-character title is refused'); end $$;
do $$ begin
  perform public.save_recipe(jsonb_build_object('title', 'Big', 'servings', 5000));
  perform pg_temp.check(false, 'servings above 1000 are refused');
exception when check_violation then perform pg_temp.check(true, 'servings above 1000 are refused'); end $$;
do $$ begin
  perform public.save_recipe(jsonb_build_object('title', 'Long list',
    'ingredients', (select jsonb_agg(jsonb_build_object('name', 'item ' || n)) from generate_series(1, 201) n)));
  perform pg_temp.check(false, 'a recipe with more than 200 ingredients is refused');
exception when program_limit_exceeded then perform pg_temp.check(true, 'a recipe with more than 200 ingredients is refused'); end $$;

-- Only a confirmed email can accept requests.
reset role;
update auth.users set email_confirmed_at = null where id = 'b0000000-0000-0000-0000-000000000002';
select id as kim_request from public.friend_requests where to_user = 'b0000000-0000-0000-0000-000000000002' \gset
select set_config('my.kim_request', :'kim_request', false) \g /dev/null
select pg_temp.act_as('b0000000-0000-0000-0000-000000000002', 'kim.de.wit@example.com');
set role authenticated;
do $$ begin
  perform public.accept_friend_request(current_setting('my.kim_request')::bigint);
  perform pg_temp.check(false, 'an unconfirmed email cannot accept requests');
exception when insufficient_privilege then perform pg_temp.check(true, 'an unconfirmed email cannot accept requests'); end $$;
reset role;
select pg_temp.check((select count(*) = 0 from pg_class c
  where c.relname in ('rate_events') and has_table_privilege('authenticated', c.oid, 'select')),
  'nobody can read the rate log directly');
