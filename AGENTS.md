# AGENTS.md

Guidance for agents working on NammaCircle.

## Project Context

NammaCircle is a Bangalore survival app. It helps people navigate Bengaluru through locality scores, rent fairness checks, Kannada lessons, forum support, quests, mentors, and admin moderation.

## Engineering Principles

- Prefer simple, production-shaped MVP code over over-engineered abstractions.
- Prefer small vertical slices that can be run and tested.
- Use deterministic logic first. AI should explain decisions, not invent facts.
- Treat locality scores, rent data, and moderation actions as trust-sensitive data.
- Add comments only where they clarify non-obvious logic.
- Do not add paid third-party services unless explicitly requested.

## Tech Choices

- Use TypeScript for web, admin, and backend code.
- Use SwiftUI for iOS code.
- Use Supabase, Postgres, and PostGIS as the source of truth.

## Data And Security

- Never hardcode secrets.
- Keep database migrations idempotent where possible.
- Keep trust-sensitive data changes auditable where practical.
- Do not implement production auth, payments, or real AI unless explicitly requested.

## Documentation

- Add clear README instructions after each major change.
- Keep docs aligned with the current MVP scope and actual implementation state.
