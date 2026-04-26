# NammaCircle Supabase

Supabase/Postgres is the source of truth for the NammaCircle MVP.

## Contents

- `migrations/0001_nammacircle_mvp_schema.sql`: initial MVP schema, indexes, PostGIS columns, and simple RLS policies.
- `migrations/0002_rent_baselines.sql`: fallback baseline table for deterministic rent checks.
- `seed.sql`: Bangalore locality, score, lesson, quest, and sample forum data.
- `edge-functions/rent-check`: deterministic rent fairness check function and pure logic tests.

## Local Setup

```sh
supabase start
supabase db reset
```

Run the pure rent engine tests with Deno:

```sh
deno test supabase/edge-functions/rent-check/rentFairness.test.ts
```

## Notes

- PostGIS is enabled with `create extension if not exists postgis`.
- RLS is intentionally simple for MVP development.
- Admin authorization is a TODO and should later use either custom JWT role claims or an `admin_users` table.
- Do not hardcode secrets in SQL, seed files, edge functions, or app code.
