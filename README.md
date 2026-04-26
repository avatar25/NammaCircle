# NammaCircle

iOS app for surviving BLR.

## Supabase Setup

The MVP database lives in `supabase/`.

```sh
supabase start
supabase db reset
```

The initial migration creates the NammaCircle MVP schema with Postgres, PostGIS geography columns, indexes, and simple RLS policies. Seed data includes 10 Bangalore localities, sample scores, Kannada lessons, quests, and starter forum posts.
