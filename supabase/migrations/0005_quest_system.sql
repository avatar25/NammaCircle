-- MVP quest system: fixed quest types, submission statuses, approval-only
-- rewards, and daily duplicate protection.

update public.quests
set quest_type = case quest_type
  when 'lesson' then 'learn_kannada'
  when 'rent_check' then 'rent_signal'
  when 'city_exploration' then 'photo_walk'
  when 'locality_research' then 'area_tip'
  when 'daily' then 'area_tip'
  else quest_type
end;

alter table public.quests
  add column if not exists frequency text not null default 'daily';

do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'quests_quest_type_check'
      and conrelid = 'public.quests'::regclass
  ) then
    alter table public.quests drop constraint quests_quest_type_check;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'quests_frequency_check'
      and conrelid = 'public.quests'::regclass
  ) then
    alter table public.quests
      add constraint quests_frequency_check
      check (frequency in ('daily', 'once'));
  end if;
end;
$$;

alter table public.quests
  add constraint quests_quest_type_check
  check (quest_type in ('learn_kannada', 'forum_help', 'photo_walk', 'rent_signal', 'area_tip'));

alter table public.quest_submissions
  add column if not exists submission_date date not null default current_date;

create unique index if not exists quest_submissions_one_approved_per_day_idx
on public.quest_submissions(quest_id, user_id, submission_date)
where verification_status = 'approved';

drop policy if exists "users can create own quest submissions" on public.quest_submissions;
create policy "users can create own quest submissions"
on public.quest_submissions for insert
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.quests
    where quests.id = quest_submissions.quest_id
      and quests.is_active = true
  )
  and (
    verification_status = 'pending'
    or (
      verification_status = 'approved'
      and exists (
        select 1
        from public.quests
        where quests.id = quest_submissions.quest_id
          and quests.quest_type = 'learn_kannada'
      )
    )
  )
);

create or replace function public.award_points_for_approved_quest_submission()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  quest_record record;
  today date := current_date;
  existing_current integer;
  existing_longest integer;
  existing_last_activity date;
  next_current integer;
  next_longest integer;
begin
  if new.verification_status <> 'approved' then
    return new;
  end if;

  if tg_op = 'UPDATE' and old.verification_status = 'approved' then
    return new;
  end if;

  select points, frequency
  into quest_record
  from public.quests
  where id = new.quest_id;

  if not found then
    raise exception 'Quest % not found for approved submission.', new.quest_id;
  end if;

  insert into public.points_ledger (
    user_id,
    event_type,
    points_delta,
    source_type,
    source_id
  )
  values (
    new.user_id,
    'daily_quest_completed',
    quest_record.points,
    'quest_submission',
    new.id
  )
  on conflict (user_id, source_type, source_id)
  where reversed_at is null
  do nothing;

  if quest_record.frequency = 'daily' then
    select current_streak, longest_streak, last_activity_date
    into existing_current, existing_longest, existing_last_activity
    from public.user_streaks
    where user_id = new.user_id;

    if existing_last_activity = today then
      return new;
    end if;

    next_current := case
      when existing_last_activity = today - 1
        then coalesce(existing_current, 0) + 1
      else 1
    end;
    next_longest := greatest(coalesce(existing_longest, 0), next_current);

    insert into public.user_streaks (
      user_id,
      current_streak,
      longest_streak,
      last_activity_date
    )
    values (
      new.user_id,
      next_current,
      next_longest,
      today
    )
    on conflict (user_id)
    do update set
      current_streak = excluded.current_streak,
      longest_streak = greatest(public.user_streaks.longest_streak, excluded.longest_streak),
      last_activity_date = excluded.last_activity_date;
  end if;

  return new;
end;
$$;

drop trigger if exists award_points_for_approved_quest_submission on public.quest_submissions;
create trigger award_points_for_approved_quest_submission
after insert or update of verification_status
on public.quest_submissions
for each row
execute function public.award_points_for_approved_quest_submission();
