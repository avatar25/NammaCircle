-- NammaCircle MVP schema.
-- Uses Supabase auth.users for identity and PostGIS geography columns when available.

do $$
begin
  create extension if not exists postgis;
exception
  when undefined_file then
    raise notice 'PostGIS extension is not available in this Postgres instance.';
end;
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.localities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  city text not null default 'Bengaluru',
  description text,
  center geography(point, 4326) not null,
  polygon geography(polygon, 4326),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  home_locality_id uuid references public.localities(id) on delete set null,
  work_location_text text,
  budget_min integer,
  budget_max integer,
  commute_tolerance_minutes integer,
  lifestyle_tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.locality_scores (
  locality_id uuid primary key references public.localities(id) on delete cascade,
  rent_score integer,
  commute_score integer,
  food_score integer,
  social_life_score integer,
  quiet_score integer,
  safety_confidence_score integer,
  newcomer_friendliness_score integer,
  kannada_dependency_score integer,
  broker_risk_score integer,
  water_reliability_score integer,
  last_verified_at timestamptz,
  confidence_level text not null default 'low' check (confidence_level in ('low', 'medium', 'high'))
);

create table if not exists public.locality_signals (
  id uuid primary key default gen_random_uuid(),
  locality_id uuid not null references public.localities(id) on delete cascade,
  signal_type text not null,
  source_type text not null check (source_type in ('user_report', 'scout', 'mentor', 'official', 'admin')),
  summary text not null,
  confidence_level text not null default 'low' check (confidence_level in ('low', 'medium', 'high')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  verified_at timestamptz
);

create table if not exists public.rent_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  locality_id uuid not null references public.localities(id) on delete cascade,
  bhk text not null,
  furnishing text,
  monthly_rent integer not null,
  deposit integer,
  maintenance integer,
  broker_fee integer,
  source_type text,
  notes text,
  created_at timestamptz not null default now(),
  moderation_status text not null default 'pending' check (moderation_status in ('pending', 'approved', 'rejected', 'flagged', 'hidden'))
);

create table if not exists public.rent_checks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  locality_id uuid not null references public.localities(id) on delete cascade,
  bhk text not null,
  monthly_rent integer not null,
  deposit integer,
  result_label text not null,
  result_score numeric,
  explanation text,
  created_at timestamptz not null default now()
);

create table if not exists public.kannada_lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  situation text not null,
  difficulty text not null default 'beginner',
  sort_order integer not null default 0,
  is_published boolean not null default false
);

create table if not exists public.kannada_phrases (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.kannada_lessons(id) on delete cascade,
  kannada_text text not null,
  transliteration text not null,
  english_meaning text not null,
  usage_note text,
  sort_order integer not null default 0
);

create table if not exists public.lesson_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.kannada_lessons(id) on delete cascade,
  completed_at timestamptz not null default now()
);

create table if not exists public.user_streaks (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_activity_date date
);

create table if not exists public.forum_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  locality_id uuid references public.localities(id) on delete set null,
  title text not null,
  body text not null,
  category text not null,
  urgency text not null default 'normal',
  moderation_status text not null default 'visible' check (moderation_status in ('visible', 'flagged', 'hidden', 'removed')),
  accepted_comment_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.forum_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.forum_posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  body text not null,
  moderation_status text not null default 'visible' check (moderation_status in ('visible', 'flagged', 'hidden', 'removed')),
  created_at timestamptz not null default now()
);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'forum_posts_accepted_comment_fk'
      and conrelid = 'public.forum_posts'::regclass
  ) then
    alter table public.forum_posts
      add constraint forum_posts_accepted_comment_fk
      foreign key (accepted_comment_id) references public.forum_comments(id) on delete set null;
  end if;
end;
$$;

create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null,
  target_id uuid not null,
  value integer not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  unique (user_id, target_type, target_id)
);

create table if not exists public.quests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  quest_type text not null,
  locality_id uuid references public.localities(id) on delete set null,
  points integer not null default 0,
  is_active boolean not null default true,
  sponsor_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.quest_submissions (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null references public.quests(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  text_response text,
  photo_url text,
  location geography(point, 4326),
  verification_status text not null default 'pending' check (verification_status in ('pending', 'approved', 'rejected', 'flagged')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table if not exists public.points_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null,
  points_delta integer not null,
  source_type text not null,
  source_id uuid,
  created_at timestamptz not null default now(),
  reversed_at timestamptz
);

create table if not exists public.mentors (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  display_name text not null,
  bio text,
  specialties text[] not null default '{}',
  hourly_rate_inr integer,
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.mentor_bookings (
  id uuid primary key default gen_random_uuid(),
  mentor_id uuid not null references public.mentors(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  topic text not null,
  status text not null default 'requested' check (status in ('requested', 'accepted', 'declined', 'completed', 'cancelled')),
  scheduled_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.moderation_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  target_type text not null,
  target_id uuid not null,
  reason text not null,
  status text not null default 'open' check (status in ('open', 'reviewing', 'resolved', 'dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid references auth.users(id) on delete set null,
  target_type text not null,
  target_id uuid not null,
  action text not null,
  notes text,
  created_at timestamptz not null default now()
);

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_localities_updated_at on public.localities;
create trigger set_localities_updated_at
before update on public.localities
for each row execute function public.set_updated_at();

drop trigger if exists set_forum_posts_updated_at on public.forum_posts;
create trigger set_forum_posts_updated_at
before update on public.forum_posts
for each row execute function public.set_updated_at();

create index if not exists profiles_home_locality_id_idx on public.profiles(home_locality_id);
create index if not exists profiles_created_at_idx on public.profiles(created_at);
create index if not exists localities_created_at_idx on public.localities(created_at);
create unique index if not exists kannada_lessons_title_idx on public.kannada_lessons(title);
create unique index if not exists kannada_phrases_lesson_text_idx on public.kannada_phrases(lesson_id, kannada_text);
create unique index if not exists quests_title_idx on public.quests(title);
create unique index if not exists forum_posts_seed_title_idx on public.forum_posts(title) where user_id is null;
create unique index if not exists locality_signals_seed_idx on public.locality_signals(locality_id, signal_type, summary);
create index if not exists localities_center_gix on public.localities using gist(center);
create index if not exists localities_polygon_gix on public.localities using gist(polygon);
create index if not exists locality_signals_locality_id_idx on public.locality_signals(locality_id);
create index if not exists locality_signals_created_by_idx on public.locality_signals(created_by);
create index if not exists locality_signals_created_at_idx on public.locality_signals(created_at);
create index if not exists rent_reports_user_id_idx on public.rent_reports(user_id);
create index if not exists rent_reports_locality_id_idx on public.rent_reports(locality_id);
create index if not exists rent_reports_created_at_idx on public.rent_reports(created_at);
create index if not exists rent_reports_moderation_status_idx on public.rent_reports(moderation_status);
create index if not exists rent_checks_user_id_idx on public.rent_checks(user_id);
create index if not exists rent_checks_locality_id_idx on public.rent_checks(locality_id);
create index if not exists rent_checks_created_at_idx on public.rent_checks(created_at);
create index if not exists kannada_phrases_lesson_id_idx on public.kannada_phrases(lesson_id);
create index if not exists lesson_attempts_user_id_idx on public.lesson_attempts(user_id);
create index if not exists lesson_attempts_created_at_idx on public.lesson_attempts(completed_at);
create index if not exists forum_posts_user_id_idx on public.forum_posts(user_id);
create index if not exists forum_posts_locality_id_idx on public.forum_posts(locality_id);
create index if not exists forum_posts_created_at_idx on public.forum_posts(created_at);
create index if not exists forum_posts_moderation_status_idx on public.forum_posts(moderation_status);
create index if not exists forum_comments_post_id_idx on public.forum_comments(post_id);
create index if not exists forum_comments_user_id_idx on public.forum_comments(user_id);
create index if not exists forum_comments_created_at_idx on public.forum_comments(created_at);
create index if not exists forum_comments_moderation_status_idx on public.forum_comments(moderation_status);
create index if not exists votes_user_id_idx on public.votes(user_id);
create index if not exists quests_locality_id_idx on public.quests(locality_id);
create index if not exists quests_created_at_idx on public.quests(created_at);
create index if not exists quest_submissions_quest_id_idx on public.quest_submissions(quest_id);
create index if not exists quest_submissions_user_id_idx on public.quest_submissions(user_id);
create index if not exists quest_submissions_created_at_idx on public.quest_submissions(created_at);
create index if not exists quest_submissions_verification_status_idx on public.quest_submissions(verification_status);
create index if not exists quest_submissions_location_gix on public.quest_submissions using gist(location);
create index if not exists points_ledger_user_id_idx on public.points_ledger(user_id);
create index if not exists points_ledger_created_at_idx on public.points_ledger(created_at);
create index if not exists mentors_user_id_idx on public.mentors(user_id);
create index if not exists mentors_created_at_idx on public.mentors(created_at);
create index if not exists mentor_bookings_mentor_id_idx on public.mentor_bookings(mentor_id);
create index if not exists mentor_bookings_user_id_idx on public.mentor_bookings(user_id);
create index if not exists mentor_bookings_created_at_idx on public.mentor_bookings(created_at);
create index if not exists moderation_reports_reporter_id_idx on public.moderation_reports(reporter_id);
create index if not exists moderation_reports_created_at_idx on public.moderation_reports(created_at);
create index if not exists moderation_reports_status_idx on public.moderation_reports(status);
create index if not exists moderation_actions_admin_user_id_idx on public.moderation_actions(admin_user_id);
create index if not exists moderation_actions_created_at_idx on public.moderation_actions(created_at);

alter table public.profiles enable row level security;
alter table public.localities enable row level security;
alter table public.locality_scores enable row level security;
alter table public.locality_signals enable row level security;
alter table public.rent_reports enable row level security;
alter table public.rent_checks enable row level security;
alter table public.kannada_lessons enable row level security;
alter table public.kannada_phrases enable row level security;
alter table public.lesson_attempts enable row level security;
alter table public.user_streaks enable row level security;
alter table public.forum_posts enable row level security;
alter table public.forum_comments enable row level security;
alter table public.votes enable row level security;
alter table public.quests enable row level security;
alter table public.quest_submissions enable row level security;
alter table public.points_ledger enable row level security;
alter table public.mentors enable row level security;
alter table public.mentor_bookings enable row level security;
alter table public.moderation_reports enable row level security;
alter table public.moderation_actions enable row level security;

drop policy if exists "public can read localities" on public.localities;
create policy "public can read localities"
on public.localities for select
using (true);

drop policy if exists "public can read locality scores" on public.locality_scores;
create policy "public can read locality scores"
on public.locality_scores for select
using (true);

drop policy if exists "public can read verified locality signals" on public.locality_signals;
create policy "public can read verified locality signals"
on public.locality_signals for select
using (verified_at is not null);

drop policy if exists "public can read published lessons" on public.kannada_lessons;
create policy "public can read published lessons"
on public.kannada_lessons for select
using (is_published = true);

drop policy if exists "public can read lesson phrases" on public.kannada_phrases;
create policy "public can read lesson phrases"
on public.kannada_phrases for select
using (
  exists (
    select 1 from public.kannada_lessons
    where kannada_lessons.id = kannada_phrases.lesson_id
      and kannada_lessons.is_published = true
  )
);

drop policy if exists "public can read visible forum posts" on public.forum_posts;
create policy "public can read visible forum posts"
on public.forum_posts for select
using (moderation_status = 'visible');

drop policy if exists "public can read visible forum comments" on public.forum_comments;
create policy "public can read visible forum comments"
on public.forum_comments for select
using (moderation_status = 'visible');

drop policy if exists "public can read active quests" on public.quests;
create policy "public can read active quests"
on public.quests for select
using (is_active = true);

drop policy if exists "public can read verified mentors" on public.mentors;
create policy "public can read verified mentors"
on public.mentors for select
using (is_verified = true);

drop policy if exists "users can read own profile" on public.profiles;
create policy "users can read own profile"
on public.profiles for select
using (auth.uid() = id);

drop policy if exists "users can insert own profile" on public.profiles;
create policy "users can insert own profile"
on public.profiles for insert
with check (auth.uid() = id);

drop policy if exists "users can update own profile" on public.profiles;
create policy "users can update own profile"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "users can create own locality signals" on public.locality_signals;
create policy "users can create own locality signals"
on public.locality_signals for insert
with check (auth.uid() = created_by);

drop policy if exists "users can create own rent reports" on public.rent_reports;
create policy "users can create own rent reports"
on public.rent_reports for insert
with check (auth.uid() = user_id);

drop policy if exists "users can read own rent reports" on public.rent_reports;
create policy "users can read own rent reports"
on public.rent_reports for select
using (auth.uid() = user_id);

drop policy if exists "users can create own rent checks" on public.rent_checks;
create policy "users can create own rent checks"
on public.rent_checks for insert
with check (auth.uid() = user_id);

drop policy if exists "users can read own rent checks" on public.rent_checks;
create policy "users can read own rent checks"
on public.rent_checks for select
using (auth.uid() = user_id);

drop policy if exists "users can create own lesson attempts" on public.lesson_attempts;
create policy "users can create own lesson attempts"
on public.lesson_attempts for insert
with check (auth.uid() = user_id);

drop policy if exists "users can read own lesson attempts" on public.lesson_attempts;
create policy "users can read own lesson attempts"
on public.lesson_attempts for select
using (auth.uid() = user_id);

drop policy if exists "users can read own streak" on public.user_streaks;
create policy "users can read own streak"
on public.user_streaks for select
using (auth.uid() = user_id);

drop policy if exists "users can upsert own streak" on public.user_streaks;
create policy "users can upsert own streak"
on public.user_streaks for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "users can create own forum posts" on public.forum_posts;
create policy "users can create own forum posts"
on public.forum_posts for insert
with check (auth.uid() = user_id);

drop policy if exists "users can create own forum comments" on public.forum_comments;
create policy "users can create own forum comments"
on public.forum_comments for insert
with check (auth.uid() = user_id);

drop policy if exists "users can create own votes" on public.votes;
create policy "users can create own votes"
on public.votes for insert
with check (auth.uid() = user_id);

drop policy if exists "users can update own votes" on public.votes;
create policy "users can update own votes"
on public.votes for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "users can create own quest submissions" on public.quest_submissions;
create policy "users can create own quest submissions"
on public.quest_submissions for insert
with check (auth.uid() = user_id);

drop policy if exists "users can read own quest submissions" on public.quest_submissions;
create policy "users can read own quest submissions"
on public.quest_submissions for select
using (auth.uid() = user_id);

drop policy if exists "users can read own points ledger" on public.points_ledger;
create policy "users can read own points ledger"
on public.points_ledger for select
using (auth.uid() = user_id);

drop policy if exists "users can create own mentor booking requests" on public.mentor_bookings;
create policy "users can create own mentor booking requests"
on public.mentor_bookings for insert
with check (auth.uid() = user_id);

drop policy if exists "users can read own mentor bookings" on public.mentor_bookings;
create policy "users can read own mentor bookings"
on public.mentor_bookings for select
using (auth.uid() = user_id);

drop policy if exists "users can create own moderation reports" on public.moderation_reports;
create policy "users can create own moderation reports"
on public.moderation_reports for insert
with check (auth.uid() = reporter_id);

drop policy if exists "users can read own moderation reports" on public.moderation_reports;
create policy "users can read own moderation reports"
on public.moderation_reports for select
using (auth.uid() = reporter_id);

-- TODO: replace this placeholder with production admin policies using either
-- custom JWT role claims or an admin_users table.
