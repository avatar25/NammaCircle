-- Quest proof image storage and MVP admin-role RLS.
-- Admin access is based on trusted Supabase Auth app_metadata, not user_metadata.

create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') = 'admin'
    or coalesce(auth.jwt() -> 'app_metadata' -> 'roles' ? 'admin', false)
    or coalesce(auth.jwt() ->> 'user_role', '') = 'admin';
$$;

grant execute on function public.is_admin() to authenticated;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'quest-proof',
  'quest-proof',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/heic', 'image/heif', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "users can upload own quest proof" on storage.objects;
create policy "users can upload own quest proof"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'quest-proof'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "users can read own quest proof" on storage.objects;
create policy "users can read own quest proof"
on storage.objects for select
to authenticated
using (
  bucket_id = 'quest-proof'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "admins can read quest proof" on storage.objects;
create policy "admins can read quest proof"
on storage.objects for select
to authenticated
using (
  bucket_id = 'quest-proof'
  and public.is_admin()
);

drop policy if exists "admins can remove quest proof" on storage.objects;
create policy "admins can remove quest proof"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'quest-proof'
  and public.is_admin()
);

drop policy if exists "admins can manage localities" on public.localities;
create policy "admins can manage localities"
on public.localities for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage locality scores" on public.locality_scores;
create policy "admins can manage locality scores"
on public.locality_scores for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage locality signals" on public.locality_signals;
create policy "admins can manage locality signals"
on public.locality_signals for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage rent reports" on public.rent_reports;
create policy "admins can manage rent reports"
on public.rent_reports for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage rent baselines" on public.rent_baselines;
create policy "admins can manage rent baselines"
on public.rent_baselines for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage kannada lessons" on public.kannada_lessons;
create policy "admins can manage kannada lessons"
on public.kannada_lessons for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage kannada phrases" on public.kannada_phrases;
create policy "admins can manage kannada phrases"
on public.kannada_phrases for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage forum posts" on public.forum_posts;
create policy "admins can manage forum posts"
on public.forum_posts for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage forum comments" on public.forum_comments;
create policy "admins can manage forum comments"
on public.forum_comments for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage moderation reports" on public.moderation_reports;
create policy "admins can manage moderation reports"
on public.moderation_reports for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can read moderation actions" on public.moderation_actions;
create policy "admins can read moderation actions"
on public.moderation_actions for select
to authenticated
using (public.is_admin());

drop policy if exists "admins can create moderation actions" on public.moderation_actions;
create policy "admins can create moderation actions"
on public.moderation_actions for insert
to authenticated
with check (
  public.is_admin()
  and admin_user_id = auth.uid()
);

drop policy if exists "admins can manage quests" on public.quests;
create policy "admins can manage quests"
on public.quests for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage quest submissions" on public.quest_submissions;
create policy "admins can manage quest submissions"
on public.quest_submissions for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage mentors" on public.mentors;
create policy "admins can manage mentors"
on public.mentors for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can manage mentor bookings" on public.mentor_bookings;
create policy "admins can manage mentor bookings"
on public.mentor_bookings for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can read leads" on public.leads;
create policy "admins can read leads"
on public.leads for select
to authenticated
using (public.is_admin());
