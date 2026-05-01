-- Public landing-page leads for the free deterministic area match.

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  office_location_text text not null,
  budget_text text not null,
  budget_min integer,
  budget_max integer,
  commute_tolerance_minutes integer,
  lifestyle_tags text[] not null default '{}',
  contact text,
  top_matches jsonb not null default '[]'::jsonb,
  source text not null default 'landing_page',
  created_at timestamptz not null default now()
);

create index if not exists leads_created_at_idx
on public.leads(created_at);

create index if not exists leads_contact_idx
on public.leads(contact)
where contact is not null;

alter table public.leads enable row level security;

-- Leads are inserted by server-side actions with the service role key.
-- Public direct insert/read policies are intentionally omitted for MVP safety.
