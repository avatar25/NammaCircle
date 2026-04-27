# NammaCircle MVP Product Spec

## One-Line Pitch

NammaCircle is a Bangalore survival app that helps newcomers choose where to live, judge rent fairness, learn useful Kannada, ask trusted local questions, and get help from mentors.

## Target Users

- Newcomers moving to Bengaluru for work, school, or family.
- Early-career professionals comparing office commute, rent, safety, and lifestyle tradeoffs.
- Non-Kannada speakers who want practical daily language help.
- Renters evaluating listings, deposits, and broker claims.
- Local mentors willing to help newcomers with neighborhood and settling-in questions.
- Admins responsible for keeping locality data, forum content, mentor profiles, and quest submissions trustworthy.

## Core User Journeys

### 1. Area Recommendation

The newcomer enters:

- Office location or nearest landmark.
- Monthly rent budget.
- Lifestyle preferences such as commute tolerance, nightlife, quiet streets, family-friendliness, metro access, and food/cafe access.

The app returns recommended areas with:

- Overall locality score.
- Commute, affordability, safety, and lifestyle score breakdowns.
- Short explanation of why each area was recommended.
- Data confidence level for each recommendation.

### 2. Rent Fairness Check

The user enters:

- Locality.
- BHK type.
- Quoted monthly rent.
- Deposit amount.
- Optional notes such as furnishing, gated society, distance to metro, and maintenance charges.

The app returns:

- Fairness label: `low`, `fair`, `high`, or `very_high`.
- Rent and deposit explanation using deterministic reference ranges.
- Confidence level based on available locality data.
- Clear disclaimer that this is guidance, not legal or financial advice.

### 3. Kannada Daily Lesson And Streak

The user opens the daily Kannada lesson, completes a short phrase exercise, and maintains a streak.

The MVP should support:

- One daily lesson.
- Phrase, transliteration, meaning, and context.
- Completion state.
- Streak count placeholder that can later attach to authenticated users.

### 4. Forum Locality/Rent Question

The user asks a locality or rent question in the forum.

The MVP should support:

- Creating posts.
- Adding comments.
- Reporting posts or comments.
- Status labels for pending, approved, rejected, flagged, hidden, and legacy visible/removed content.
- Admin moderation review before sensitive surfaced claims become trusted data.

### 5. Daily Quest And Points

The user completes a daily city quest and earns points.

Example quests:

- Learn one Kannada phrase.
- Take a metro ride.
- Visit a local public service office.
- Ask one useful forum question.

The MVP should support:

- Quest list.
- Point value.
- Completion state.
- Admin review for quests that need proof or moderation.

### 6. Mentor Help Request

The user browses mentor profiles and requests help.

The MVP should support:

- Mentor profile cards with locality, languages, topics, and short bio.
- Booking request form with a short note.
- Request status: `requested`, `accepted`, `declined`, or `completed`.
- No payments, payouts, calendars, or automated matching in the MVP.

### 7. Admin Review

The admin reviews:

- User reports.
- Forum flags.
- Locality data changes.
- Quest submissions.
- Mentor profile submissions.

The MVP admin dashboard should prioritize:

- Trust-sensitive queues.
- Clear status changes.
- Human-readable audit notes.
- Deterministic moderation actions over automated enforcement.

## MVP Feature List

- Locality map/list with score breakdowns.
- Area recommendation input flow.
- Rent and deposit fairness checker.
- Kannada daily lesson and streak placeholder.
- Forum posts, comments, reports, and content statuses.
- Quests, point values, and completion records.
- Mentor profiles and booking requests.
- Admin moderation dashboard for reports, flags, locality data, quests, and mentors.
- Supabase/Postgres source of truth with idempotent migrations where possible.

## Non-Goals

- Payments, subscriptions, payouts, or paid bookings.
- Real AI recommendations or AI moderation.
- Production authentication and role management.
- Legal, financial, or brokerage advice.
- Push notifications.
- Fully automated mentor scheduling.
- Full marketplace, classifieds, or rental listing inventory.
- Scraping private or paywalled rental data.

## Monetization Hooks For Later

These are future hooks only and should not be implemented in the MVP:

- Paid mentor sessions.
- Verified relocation concierge packages.
- Premium locality reports.
- Employer relocation bundles.
- Sponsored but clearly labeled local services.
- Rental paperwork review partners.
- Kannada course upgrades.

Any future monetization must preserve trust, labeling, and user control.

## Trust And Safety Principles

- Treat locality scores, rent ranges, deposits, forum claims, and moderation actions as trust-sensitive data.
- Show confidence levels when data is incomplete or based on small samples.
- Prefer deterministic explanations over vague claims.
- Separate user-generated content from verified or admin-reviewed data.
- Keep moderation actions auditable.
- Avoid presenting recommendations as guarantees.
- Never invent data to fill gaps.
- Keep personal data collection minimal until production auth is designed.

## Forum Moderation Principles

- Make it easy to report abusive, misleading, discriminatory, spam, or personally identifying content.
- Default to human review for reports and sensitive locality/rent claims.
- Use clear content statuses: `pending`, `approved`, `rejected`, `flagged`, `hidden`; keep legacy `visible`/`removed` readable during migration only.
- Do not automatically convert forum anecdotes into locality or rent reference data.
- Preserve enough audit context for admins to understand why content was changed.
- Avoid public shaming, harassment, caste/religion/language discrimination, and broker spam.

## Data Confidence Model

Every locality score, rent range, and recommendation should carry a confidence level:

- `high`: recent verified/admin-reviewed data with enough samples.
- `medium`: usable data, but limited freshness, sample size, or coverage.
- `low`: sparse, old, user-reported, or partially verified data.
- `unknown`: no reliable data yet.

Confidence should be based on:

- Source type: admin-reviewed, partner-provided, public dataset, or user-reported.
- Freshness: when the data was last updated.
- Sample size: how many relevant observations exist.
- Locality specificity: exact locality versus nearby approximation.
- Consistency: whether recent entries agree or conflict.

The product should surface lower confidence with plain language, not hide it.
