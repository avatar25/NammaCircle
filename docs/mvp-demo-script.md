# NammaCircle MVP Demo Script

Use this script for a short end-to-end MVP walkthrough. Run the iOS app in mock mode for the fastest demo, and run the admin dashboard against a local Supabase database when showing moderation queues.

## Before The Demo

```sh
cd /Users/shiben/Desktop/NammaCircle
supabase start
supabase db reset
npm --prefix admin install
npm --prefix admin run dev
```

Open the admin dashboard at `http://localhost:3000/dashboard`.

For iOS, open the checked-in Xcode project:

```sh
cd /Users/shiben/Desktop/NammaCircle
open ios/NammaCircleApp/NammaCircleApp.xcodeproj
```

Select the `NammaCircleApp` scheme and run on an installed simulator. The shared scheme defaults to `NAMMA_DATA_MODE=mock`.

## Walkthrough

1. User opens app

   Launch NammaCircle on the simulator. Start on onboarding if no profile state is present, or reset app state from the simulator before the demo.

2. Completes onboarding

   Enter an office location such as `Bellandur`, a budget range such as `25000-45000`, a commute tolerance such as `45`, and lifestyle tags like `cafes, quiet, food`.

3. Sees locality recommendations

   Continue to Home. Show the recommended locality card, then open the locality map and tap a locality pin. Call out fit color, confidence level, score breakdown, risks, and recent-signal placeholder.

4. Checks rent fairness

   Open Rent Check. Choose a locality, BHK, furnishing, rent, deposit, and maintenance. Submit the form and show the deterministic result label, score, deposit warning, explanation, and negotiation points.

5. Completes Kannada lesson

   Open the Kannada lesson card. Read the Kannada phrase, transliteration, meaning, and usage note. Tap complete lesson.

6. Gets streak/points

   Return to Home and show current streak, total points, and rank. Explain that points are recorded through `points_ledger`; totals are derived, not stored directly.

7. Opens forum and submits a question

   Open Forum. Create a locality or rent question. Submit it and show the `Submitted for review.` message. Explain that new posts are pending until admin approval.

8. Completes quest

   Open Quests. Select an active quest. Submit a text response; use the photo placeholder where relevant. Show status as pending unless it is a `learn_kannada` quest, which can auto-approve.

9. Requests mentor help

   Open Mentors. Pick a verified mentor, enter a help topic and preferred time text, then submit the booking request. Show booking status as pending. Mention that payments are intentionally not implemented.

10. Admin reviews pending items

   In the admin dashboard, open:

   - `/dashboard` for queue counts
   - `/forum` to approve or reject pending posts/comments
   - `/quests` to review quest submissions and award points after approval
   - `/rent-reports` to approve or reject rent reports
   - `/localities` to inspect scores and confidence levels
   - `/mentors` to verify mentors and manage booking status

   Confirm moderation actions are logged in `moderation_actions`, and trust-sensitive data uses deterministic decisions and visible confidence levels.

## Demo Boundaries

- Production auth is not implemented.
- Payments are not implemented.
- Real AI is not implemented.
- Mock mode is the safest iOS demo path.
- Supabase mode is available for integration testing when env vars and anonymous auth are configured.
