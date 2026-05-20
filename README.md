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

## Brand Assets

- `app icon.png` is the source artwork for the iOS app icon, the SwiftUI brand mark, and the admin dashboard favicon/sidebar mark.
- `icons.png` is the source feature-art sheet. Cropped feature images live in `ios/NammaCircleApp/NammaCircleApp/Assets.xcassets` and are used by the SwiftUI home, locality, Kannada, rent, quest, and mentor surfaces.

## MVP Scope

- Locality map, recommendations, and scores
- Rent fairness check
- Kannada daily lessons and local streaks
- Forum posts and comments
- Quests and points
- Mentor profiles and booking requests
- Admin moderation dashboard with pending forum review, user reports, and moderation action logs
- Public landing page with deterministic area matching and lead capture

Not in scope yet:

- Payments
- Production auth
- Real AI ranking or moderation
- Push notifications
- Full booking/calendar automation

Use deterministic logic first. AI may later help explain decisions, but it must not invent locality, rent, commute, or safety facts.

## Local Setup

Prerequisites:

- Xcode with an iOS simulator runtime
- Node.js and npm
- Deno
- Supabase CLI and Docker

### iOS

```sh
cd /Users/shiben/Desktop/NammaCircle
open ios/NammaCircleApp/NammaCircleApp.xcodeproj
```

The checked-in Xcode scheme defaults to mock mode, so the app can run without secrets.
To verify compilation from the command line, use an installed simulator name from `xcrun simctl list devices available`:

```sh
cd /Users/shiben/Desktop/NammaCircle
xcodebuild -project ios/NammaCircleApp/NammaCircleApp.xcodeproj \
  -scheme NammaCircleApp \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /private/tmp/NammaCircleDerivedData \
  build
```

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
cd /Users/shiben/Desktop/NammaCircle/admin
cp .env.example .env.local
npm install
npm run dev
```

Then open `http://localhost:3000` for the landing page or `http://localhost:3000/dashboard` for admin.

Build check:

```sh
cd /Users/shiben/Desktop/NammaCircle
npm --prefix admin run build
```

Required admin env vars:

```sh
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

The service role key is only for server-side admin actions.

### Supabase

```sh
cd /Users/shiben/Desktop/NammaCircle
supabase start
supabase db reset
```

The Supabase folder includes schema migrations, seeded Bangalore locality data, rent baselines, Kannada lessons, quests, forum sample data, and deterministic edge functions.
It also creates the private `quest-proof` Storage bucket and MVP admin RLS policies based on trusted Supabase Auth app metadata.

Run edge-function logic tests with Deno:

```sh
cd /Users/shiben/Desktop/NammaCircle
deno test supabase/edge-functions/rent-check/rentFairness.test.ts
deno test supabase/edge-functions/area-recommendations/areaRecommendations.test.ts
deno test supabase/edge-functions/rewards/rewardLogic.test.ts
deno test supabase/edge-functions/moderation/moderationRules.test.ts
deno test supabase/edge-functions/quests/questRules.test.ts
deno test supabase/edge-functions/ai-report/localityReport.test.ts
```

## Key Docs

- [Product spec](docs/product-spec.md)
- [Architecture](docs/architecture.md)
- [Data model](docs/data-model.md)
- [API contracts](docs/api-contracts.md)
- [AI report service](docs/ai-report-service.md)
- [MVP demo script](docs/mvp-demo-script.md)
- [Trust and safety](docs/trust-and-safety.md)
- [Agent guidelines](AGENTS.md)

## Data And Trust

Locality scores, rent data, and moderation actions are trust-sensitive. Keep data changes auditable where practical, show confidence levels when data is incomplete, and avoid presenting MVP guidance as legal, financial, or brokerage advice.
