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
- verified mentors

`RentCheckService` calls the `rent-check` edge function and falls back to local deterministic logic if the endpoint is unavailable.

Forum post creation uses anonymous Supabase auth when the Supabase Swift package is linked and Anonymous Sign-Ins are enabled in Supabase. New posts are submitted as `pending`, the UI shows "Submitted for review.", and only `approved` or legacy `visible` posts/comments are fetched. Report buttons insert rows into `moderation_reports`.

Full production auth is intentionally not implemented yet.

Do not add payments or real AI until the MVP data flows are validated.
