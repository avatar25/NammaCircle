-- Progress, streak, and points rules for NammaCircle.

create unique index if not exists points_ledger_unique_active_source_idx
on public.points_ledger(user_id, source_type, source_id)
where source_id is not null and reversed_at is null;

create index if not exists points_ledger_active_total_idx
on public.points_ledger(user_id, points_delta)
where reversed_at is null;

drop view if exists public.user_points_totals;
create view public.user_points_totals as
select
  user_id,
  coalesce(sum(points_delta) filter (where reversed_at is null), 0)::integer as total_points
from public.points_ledger
group by user_id;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'points_ledger_event_type_check'
      and conrelid = 'public.points_ledger'::regclass
  ) then
    alter table public.points_ledger
      add constraint points_ledger_event_type_check
      check (
        event_type in (
          'kannada_lesson_completed',
          'daily_quest_completed',
          'forum_answer_created',
          'forum_answer_accepted'
        )
      ) not valid;
  end if;
end;
$$;

alter table public.points_ledger
  validate constraint points_ledger_event_type_check;

-- TODO: if this view is queried directly from clients, add security definer RPCs
-- or policies once production auth is finalized. Edge functions use service role
-- and still derive totals from points_ledger rather than mutating profile totals.
