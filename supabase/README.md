# NammaCircle Supabase

Supabase/Postgres is the source of truth for the NammaCircle MVP.

## Contents

- `migrations/0001_nammacircle_mvp_schema.sql`: initial MVP schema, indexes, PostGIS columns, and simple RLS policies.
- `migrations/0001_initial_schema.sql`: superseded no-op placeholder kept so old local reset histories stay stable.
- `migrations/0002_rent_baselines.sql`: fallback baseline table for deterministic rent checks.
- `migrations/0003_progress_rewards.sql`: duplicate-safe reward ledger and derived point totals.
- `migrations/0004_forum_moderation.sql`: pending/approved/rejected forum flow, reporting indexes, and public visibility policies.
- `migrations/0005_quest_system.sql`: MVP quest types, submission status flow, approval-triggered points, and daily duplicate protection.
- `migrations/0006_mentor_marketplace.sql`: mentor booking status flow and preferred time text for marketplace MVP.
- `migrations/0007_leads.sql`: landing-page lead capture for deterministic area matches.
- `seed.sql`: Bangalore locality, score, lesson, quest, mentor, rent baseline, rent report, forum, and moderation sample data.
- `edge-functions/rent-check`: deterministic rent fairness check function and pure logic tests.
- `edge-functions/rewards`: deterministic points, rank, and streak rules.
- `edge-functions/moderation`: pure moderation visibility rules and tests.
- `edge-functions/quests`: pure quest status and approval rules.
- `edge-functions/ai-report`: deterministic locality report placeholder with a swappable explanation generator.

## Local Setup

```sh
cd /Users/shiben/Desktop/NammaCircle
supabase start
supabase db reset
```

`supabase db reset` applies all files in `migrations/` and then loads `seed.sql`.
For hosted Supabase, apply the migrations in order and run `seed.sql` only against a disposable development database.

Run the pure rent engine tests with Deno:

```sh
cd /Users/shiben/Desktop/NammaCircle
deno test supabase/edge-functions/rent-check/rentFairness.test.ts
deno test supabase/edge-functions/area-recommendations/areaRecommendations.test.ts
deno test supabase/edge-functions/rewards/rewardLogic.test.ts
deno test supabase/edge-functions/moderation/moderationRules.test.ts
deno test supabase/edge-functions/quests/questRules.test.ts
deno test supabase/edge-functions/ai-report/localityReport.test.ts
```

## Notes

- PostGIS is enabled with `create extension if not exists postgis`.
- RLS is intentionally simple for MVP development.
- Admin authorization is a TODO and should later use either custom JWT role claims or an `admin_users` table.
- Do not hardcode secrets in SQL, seed files, edge functions, or app code.
