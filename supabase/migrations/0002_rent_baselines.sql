-- Deterministic fallback data for rent fairness checks.

create table if not exists public.rent_baselines (
  locality_id uuid not null references public.localities(id) on delete cascade,
  bhk text not null,
  median_rent integer not null,
  deposit_months numeric not null default 6,
  sample_size integer not null default 0,
  confidence_level text not null default 'low' check (confidence_level in ('low', 'medium', 'high')),
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (locality_id, bhk)
);

drop trigger if exists set_rent_baselines_updated_at on public.rent_baselines;
create trigger set_rent_baselines_updated_at
before update on public.rent_baselines
for each row execute function public.set_updated_at();

create index if not exists rent_baselines_locality_id_idx on public.rent_baselines(locality_id);
create index if not exists rent_baselines_created_at_idx on public.rent_baselines(created_at);

alter table public.rent_baselines enable row level security;

drop policy if exists "public can read rent baselines" on public.rent_baselines;
create policy "public can read rent baselines"
on public.rent_baselines for select
using (true);

alter table public.rent_checks
  add column if not exists furnishing text,
  add column if not exists maintenance integer,
  add column if not exists median_rent integer,
  add column if not exists report_count integer,
  add column if not exists reference_source text,
  add column if not exists confidence_level text,
  add column if not exists deposit_warning text,
  add column if not exists recommended_negotiation_points jsonb not null default '[]'::jsonb;

create index if not exists rent_checks_reference_source_idx on public.rent_checks(reference_source);

-- TODO: add admin-only insert/update policies when admin role handling is finalized.
