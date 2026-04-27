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
- `ForumView`: posts, create post sheet, post detail with comments
- `QuestsView`: quest list, detail, text/photo placeholder submission
- `MentorView`: mentor list and booking request placeholder

## Xcode Setup

1. Open Xcode.
2. Create a new iOS App project named `NammaCircle`.
3. Choose SwiftUI for the interface and Swift for the language.
4. Save the project inside `/ios`.
5. Add the files under `ios/NammaCircle` to the app target.
6. Ensure `ios/NammaCircle/App/NammaCircleApp.swift` is the only `@main` app entry point in the target.
7. Build and run on an iOS simulator.

## Current Integration State

The app uses mock services:

- `MockLocalityService`
- `MockRentCheckService`
- `MockKannadaService`
- `MockForumService`
- `MockQuestService`
- `MockMentorService`

Supabase service classes exist as placeholders. Do not add production auth, payments, or real AI until the MVP data flows are validated.
