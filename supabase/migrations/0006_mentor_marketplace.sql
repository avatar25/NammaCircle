-- Mentor marketplace MVP: standalone mentor profiles, specialties/rates,
-- booking requests with preferred time text, and admin-controlled statuses.

alter table public.mentor_bookings
  add column if not exists preferred_time_text text;

update public.mentor_bookings
set status = 'pending'
where status = 'requested';

update public.mentor_bookings
set status = 'cancelled'
where status = 'declined';

do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'mentor_bookings_status_check'
      and conrelid = 'public.mentor_bookings'::regclass
  ) then
    alter table public.mentor_bookings drop constraint mentor_bookings_status_check;
  end if;
end;
$$;

alter table public.mentor_bookings
  alter column status set default 'pending';

alter table public.mentor_bookings
  add constraint mentor_bookings_status_check
  check (status in ('pending', 'accepted', 'completed', 'cancelled'));

create index if not exists mentors_is_verified_idx
on public.mentors(is_verified);

create index if not exists mentor_bookings_status_idx
on public.mentor_bookings(status);

drop policy if exists "users can create own mentor booking requests" on public.mentor_bookings;
create policy "users can create own mentor booking requests"
on public.mentor_bookings for insert
with check (
  auth.uid() = user_id
  and status = 'pending'
  and exists (
    select 1
    from public.mentors
    where mentors.id = mentor_bookings.mentor_id
      and mentors.is_verified = true
  )
);
