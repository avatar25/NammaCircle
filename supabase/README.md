# NammaCircle Supabase

Supabase/Postgres is the source of truth for the NammaCircle MVP.

## Contents

- `migrations/0001_nammacircle_mvp_schema.sql`: initial MVP schema, indexes, PostGIS columns, and simple RLS policies.
- `seed.sql`: Bangalore locality, score, lesson, quest, and sample forum data.

## Local Setup

```sh
supabase start
supabase db reset
```

## Notes

- PostGIS is enabled with `create extension if not exists postgis`.
- RLS is intentionally simple for MVP development.
- Admin authorization is a TODO and should later use either custom JWT role claims or an `admin_users` table.
- Do not hardcode secrets in SQL, seed files, edge functions, or app code.
