-- NammaCircle MVP initial schema placeholder.
-- TODO: split into smaller migrations as the data model stabilizes.

create table if not exists public.localities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null default 'Bengaluru',
  commute_score integer,
  safety_score integer,
  affordability_score integer,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.rent_checks (
  id uuid primary key default gen_random_uuid(),
  locality_id uuid references public.localities(id),
  bhk_type text not null,
  quoted_rent integer not null,
  fairness_label text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.kannada_lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  phrase text not null,
  transliteration text,
  meaning text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.forum_posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  status text not null default 'visible',
  created_at timestamptz not null default now()
);

create table if not exists public.forum_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.forum_posts(id),
  body text not null,
  status text not null default 'visible',
  created_at timestamptz not null default now()
);

create table if not exists public.quests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  points integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.mentors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  locality text,
  bio text,
  status text not null default 'pending_review',
  created_at timestamptz not null default now()
);

create table if not exists public.mentor_bookings (
  id uuid primary key default gen_random_uuid(),
  mentor_id uuid not null references public.mentors(id),
  requester_note text,
  status text not null default 'requested',
  created_at timestamptz not null default now()
);
