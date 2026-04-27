-- Basic forum moderation lifecycle for MVP.
-- Keeps legacy visible/removed values readable while moving new content to
-- pending -> approved/rejected.

alter table public.forum_posts
  alter column moderation_status set default 'pending';

alter table public.forum_comments
  alter column moderation_status set default 'pending';

do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'forum_posts_moderation_status_check'
      and conrelid = 'public.forum_posts'::regclass
  ) then
    alter table public.forum_posts drop constraint forum_posts_moderation_status_check;
  end if;

  if exists (
    select 1 from pg_constraint
    where conname = 'forum_comments_moderation_status_check'
      and conrelid = 'public.forum_comments'::regclass
  ) then
    alter table public.forum_comments drop constraint forum_comments_moderation_status_check;
  end if;
end;
$$;

alter table public.forum_posts
  add constraint forum_posts_moderation_status_check
  check (moderation_status in ('pending', 'approved', 'rejected', 'flagged', 'hidden', 'visible', 'removed'));

alter table public.forum_comments
  add constraint forum_comments_moderation_status_check
  check (moderation_status in ('pending', 'approved', 'rejected', 'flagged', 'hidden', 'visible', 'removed'));

create index if not exists moderation_reports_target_idx
on public.moderation_reports(target_type, target_id);

create index if not exists moderation_actions_target_idx
on public.moderation_actions(target_type, target_id);

drop policy if exists "public can read visible forum posts" on public.forum_posts;
drop policy if exists "public can read approved forum posts" on public.forum_posts;
create policy "public can read approved forum posts"
on public.forum_posts for select
using (moderation_status in ('approved', 'visible'));

drop policy if exists "public can read visible forum comments" on public.forum_comments;
drop policy if exists "public can read approved forum comments" on public.forum_comments;
create policy "public can read approved forum comments"
on public.forum_comments for select
using (moderation_status in ('approved', 'visible'));

drop policy if exists "users can create own forum posts" on public.forum_posts;
create policy "users can create own forum posts"
on public.forum_posts for insert
with check (auth.uid() = user_id and moderation_status = 'pending');

drop policy if exists "users can create own forum comments" on public.forum_comments;
create policy "users can create own forum comments"
on public.forum_comments for insert
with check (auth.uid() = user_id and moderation_status = 'pending');
