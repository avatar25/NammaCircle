# NammaCircle iOS

SwiftUI iOS app skeleton for the NammaCircle MVP.

## Architecture

- SwiftUI views
- MVVM view models
- Services layer
- Models shaped around the Supabase MVP tables
- Mock services first
- Supabase service placeholders for later integration

## Source Layout

```txt
NammaCircle/
  App/
  Models/
  Services/
  ViewModels/
  Views/
```

## Screens

- `OnboardingView`: work location, budget, commute tolerance, lifestyle tags, and preferences
- `HomeView`: Kannada lesson, daily quest, recommended locality, and forum shortcut
- `LocalityMapView`: MapKit locality pins with fit colors
- `LocalityDetailView`: scores, risks, rent estimate placeholder, recent signals placeholder
- `RentCheckView`: rent/deposit form with mock deterministic result
- `KannadaLessonView`: phrase card, usage note, local streak update
- `ForumView`: approved posts, create post sheet, post detail with comments, and report buttons
- `QuestsView`: quest list, detail, text/photo placeholder submission
- `MentorView`: mentor list and booking request placeholder

## Visual Direction

The iOS MVP now uses a warm Bengaluru-local aesthetic inspired by illustrated neighborhood guide apps:

- Cream and warm-sand screen backgrounds with deep green primary actions
- Saffron, terracotta, rose, teal, and leaf accents for scores, quests, lessons, and community surfaces
- Soft rounded cards, capsule badges, progress bars, and map markers from `Views/Components/DesignSystem.swift`
- Lightweight SwiftUI illustration primitives for skyline, auto, foliage, lesson, rent, community, and quest moments

Keep new user-facing screens aligned with these primitives before adding one-off colors or custom card styles.

## Xcode Setup

1. Open Xcode.
2. Create a new iOS App project named `NammaCircle`.
3. Choose SwiftUI for the interface and Swift for the language.
4. Save the project inside `/ios`.
5. Add the files under `ios/NammaCircle` to the app target.
6. Ensure `ios/NammaCircle/App/NammaCircleApp.swift` is the only `@main` app entry point in the target.
7. Add the Supabase Swift package dependency to the app target:
   `https://github.com/supabase/supabase-swift.git`
8. Build and run on an iOS simulator.

`ios/Package.swift` records the same Supabase Swift dependency for reference.

## Data Mode

Mock mode is the default so the app can run without secrets:

```sh
NAMMA_DATA_MODE=mock
```

To use Supabase, set these as Xcode scheme environment variables or app `Info.plist` values:

```sh
NAMMA_DATA_MODE=supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

The app also accepts `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` for parity with the admin app.

Never put the service role key in the iOS app.

## Current Integration State

The app keeps mock services available:

- `MockLocalityService`
- `MockRentCheckService`
- `MockKannadaService`
- `MockForumService`
- `MockQuestService`
- `MockMentorService`

Supabase service classes now read:

- `localities`
- `locality_scores`
- published `kannada_lessons` and `kannada_phrases`
- approved and legacy visible forum posts/comments
- active quests
- current user's quest submission statuses
- verified mentors

`RentCheckService` calls the `rent-check` edge function and falls back to local deterministic logic if the endpoint is unavailable.

Forum post creation uses anonymous Supabase auth when the Supabase Swift package is linked and Anonymous Sign-Ins are enabled in Supabase. New posts are submitted as `pending`, the UI shows "Submitted for review.", and only `approved` or legacy `visible` posts/comments are fetched. Report buttons insert rows into `moderation_reports`.

Quest submissions also use anonymous Supabase auth in development. Most quest proof is submitted as `pending`; `learn_kannada` quests auto-submit as `approved`. Points are awarded by the backend when a submission is approved, not directly by the iOS client. Photo upload is currently a placeholder toggle.

Full production auth is intentionally not implemented yet.

Do not add payments or real AI until the MVP data flows are validated.
