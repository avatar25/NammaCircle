# NammaCircle

NammaCircle is a Bangalore survival app for newcomers who need practical help choosing where to live, checking rent fairness, learning useful Kannada, asking trusted local questions, completing city quests, and finding mentor help.

This repo is a monorepo for the MVP: SwiftUI iOS app, Next.js admin dashboard, Supabase backend assets, and product documentation.

## Monorepo Structure

```txt
/ios
  SwiftUI iOS app skeleton with MVVM, services, mock mode, and Supabase placeholders

/admin
  Next.js + TypeScript + Tailwind admin dashboard

/supabase
  Postgres/PostGIS migrations, seed data, edge functions, and policy notes

/docs
  Product spec, architecture notes, data model, and API contracts
```

## MVP Scope

- Locality map, recommendations, and scores
- Rent fairness check
- Kannada daily lessons and local streaks
- Forum posts and comments
- Quests and points
- Mentor profiles and booking requests
- Admin moderation dashboard

Not in scope yet:

- Payments
- Production auth
- Real AI ranking or moderation
- Push notifications
- Full booking/calendar automation

Use deterministic logic first. AI may later help explain decisions, but it must not invent locality, rent, commute, or safety facts.

## Local Setup

### iOS

```sh
cd ios
open README.md
```

Create an Xcode iOS app project named `NammaCircle`, add the files under `ios/NammaCircle` to the app target, and add the Supabase Swift package when Supabase mode is needed.

Mock mode is the default:

```sh
NAMMA_DATA_MODE=mock
```

Supabase mode expects:

```sh
NAMMA_DATA_MODE=supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Never put a Supabase service role key in the iOS app.

### Admin

```sh
cd admin
cp .env.example .env.local
npm install
npm run dev
```

Then open `http://localhost:3000/dashboard`.

Required admin env vars:

```sh
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

The service role key is only for server-side admin actions.

### Supabase

```sh
cd supabase
supabase start
supabase db reset
```

The Supabase folder includes schema migrations, seeded Bangalore locality data, rent baselines, Kannada lessons, quests, forum sample data, and deterministic edge functions.

Run edge-function logic tests with Deno:

```sh
deno test supabase/edge-functions/rent-check/rentFairness.test.ts
deno test supabase/edge-functions/area-recommendations/areaRecommendations.test.ts
```

## Key Docs

- [Product spec](docs/product-spec.md)
- [Architecture](docs/architecture.md)
- [Data model](docs/data-model.md)
- [API contracts](docs/api-contracts.md)
- [Agent guidelines](AGENTS.md)

## Data And Trust

Locality scores, rent data, and moderation actions are trust-sensitive. Keep data changes auditable where practical, show confidence levels when data is incomplete, and avoid presenting MVP guidance as legal, financial, or brokerage advice.
