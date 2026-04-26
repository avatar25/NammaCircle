# Architecture

## Overview

NammaCircle uses a simple MVP architecture:

- SwiftUI iOS app for consumer-facing flows
- Next.js admin dashboard for moderation and operations
- Supabase for Postgres, local development, and future edge functions
- Markdown docs as the source of product and contract decisions

## Client Apps

### iOS

The iOS app owns the main user experience:

- Locality browsing
- Rent fairness check
- Kannada lessons and streaks
- Forum
- Quests
- Mentor discovery and booking request

### Admin

The admin dashboard owns operational review:

- Forum moderation
- Locality metadata edits
- Mentor profile review
- Quest submission review

## Backend

Supabase is the planned backend for:

- Postgres data storage
- Row level security
- Seeded local development data
- Future edge functions for deterministic server-side checks

## Deferred Architecture

- Production auth
- Payment processing
- Real AI
- Push notifications
- Analytics warehouse
