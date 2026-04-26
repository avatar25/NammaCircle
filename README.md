# NammaCircle

NammaCircle is a Bangalore survival iOS app for people moving to, settling in, or navigating life in Bengaluru. The MVP focuses on practical locality intelligence, rent sanity checks, Kannada learning, community help, city quests, mentor access, and a small admin moderation surface.

This repository is organized as a clean monorepo with separate workspaces for the iOS app, admin dashboard, Supabase backend assets, and product documentation.

## Monorepo Structure

```txt
/ios
  SwiftUI iOS app placeholder and iOS-specific README

/admin
  Next.js, TypeScript, and Tailwind admin dashboard placeholder

/supabase
  database migrations, seed data, edge function placeholders, and RLS policy notes

/docs
  product spec, architecture, data model, and API contracts
```

## MVP Scope

The MVP includes:

1. Locality map and scores
2. Rent fairness check
3. Kannada daily lessons and streaks
4. Forum posts and comments
5. Quests and points
6. Mentor profiles and bookings
7. Admin moderation dashboard

Out of scope for the MVP:

- Payments
- Real AI or LLM-based advice
- Production authentication
- Native map optimization
- Push notifications
- Full booking calendar automation

Use placeholders and TODOs for these areas until the MVP behavior is validated.

## Local Setup

### Requirements

- Xcode for the SwiftUI iOS app
- Node.js 20+ for the admin dashboard
- Supabase CLI for local backend development

### iOS App

```sh
cd ios
open README.md
```

The iOS folder currently contains SwiftUI source placeholders. Create the Xcode project here when the mobile implementation begins.

### Admin Dashboard

```sh
cd admin
npm install
npm run dev
```

The admin app is scaffolded as a Next.js + TypeScript + Tailwind workspace with clean placeholder screens for moderation, locality management, mentor review, and quest oversight.

### Supabase

```sh
cd supabase
supabase start
supabase db reset
```

The Supabase folder contains initial migration, seed, edge function, and policy placeholders. Production auth and payment workflows are intentionally not implemented yet.

## Development Principles

- Keep MVP modules simple and testable.
- Prefer explicit data contracts over hidden business logic.
- Keep scoring and rent checks deterministic until real data quality improves.
- Use TODOs for production auth, AI, payments, and moderation automation.
- Keep admin actions auditable from the first real implementation.

## Documentation

Start with:

- [Product Spec](docs/product-spec.md)
- [Architecture](docs/architecture.md)
- [Data Model](docs/data-model.md)
- [API Contracts](docs/api-contracts.md)
