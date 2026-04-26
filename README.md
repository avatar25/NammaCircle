# NammaCircle

iOS app for surviving BLR.

## Supabase Setup

The MVP database lives in `supabase/`.

```sh
supabase start
supabase db reset
```

The migrations create the NammaCircle MVP schema with Postgres, PostGIS geography columns, indexes, simple RLS policies, and deterministic rent baselines. Seed data includes 10 Bangalore localities, sample scores, Kannada lessons, quests, and starter forum posts.

Run the pure rent fairness tests with:

```sh
deno test supabase/edge-functions/rent-check/rentFairness.test.ts
```
