-- What an older Recipe App setup could leave behind in a shared project: Word Buddy's
-- sync_profile replaced by the Recipe App's old version (tests only).
create or replace function public.sync_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name, email) values (new.id, '', '');
  return new;
end;
$$;
