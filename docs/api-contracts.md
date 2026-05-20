# API Contracts

## Area Recommendations

`POST /functions/v1/area-recommendations`

Returns the top 5 deterministic locality recommendations for a newcomer. The MVP uses seeded `localities` and `locality_scores` data only. It does not call external maps APIs.

### Request

```json
{
  "work_location_text": "Bellandur",
  "budget_min": 18000,
  "budget_max": 35000,
  "commute_tolerance_minutes": 35,
  "lifestyle_tags": ["cafes", "metro"],
  "preferences": {
    "wants_quiet": false,
    "wants_social_life": true,
    "wants_low_cost": true,
    "wants_food_options": true,
    "wants_low_kannada_dependency": true,
    "wants_low_broker_risk": true
  }
}
```

### Scoring

The MVP score is deterministic and weighted from stored locality scores:

- `rent_score`: high weight, increased when `wants_low_cost` is true.
- `commute_score`: high weight, increased when commute tolerance is tight.
- `newcomer_friendliness_score`.
- `food_score`, increased when `wants_food_options` is true.
- `social_life_score` or `quiet_score`, depending on preference.
- `broker_risk_score` inverted, because lower broker risk is better.
- `kannada_dependency_score` inverted when low Kannada dependency is preferred.

If explicit preference booleans are not set, simple `lifestyle_tags` such as `quiet`, `nightlife`, `budget`, `cafes`, `food`, `english friendly`, `low broker risk`, and `no broker` can imply the matching preference.

AI is not used to rank areas. Later, AI may generate friendlier explanations from these deterministic reasons, but it must not invent facts, distances, commute times, or rent data.

### Response

```json
{
  "recommendations": [
    {
      "locality_id": "uuid",
      "name": "HSR Layout",
      "slug": "hsr-layout",
      "fit": "green",
      "score": 82,
      "top_reasons": [
        "HSR Layout scores well for affordability.",
        "HSR Layout scores well for commute."
      ],
      "risks": [
        "No major MVP scoring risks found; still verify rent and commute before deciding."
      ],
      "confidence_level": "medium",
      "last_verified_at": "2026-04-26T00:00:00Z"
    }
  ],
  "explanation_mode": "deterministic",
  "notes": [
    "No external maps APIs are used in the MVP.",
    "AI may later summarize these deterministic reasons, but it must not invent facts."
  ]
}
```

### Fit Labels

- `green`: score >= 75.
- `yellow`: score >= 55 and < 75.
- `red`: score < 55.

## AI Report Placeholder

`POST /functions/v1/ai-report`

Generates a deterministic, template-based locality report from the same source data as area recommendations. No external AI API is called.

### Response

```json
{
  "summary": "HSR Layout is the strongest deterministic match...",
  "top_5_areas": [
    {
      "locality_id": "uuid",
      "name": "HSR Layout",
      "slug": "hsr-layout",
      "fit": "green",
      "score": 82,
      "reasons": ["HSR Layout scores well for affordability."],
      "risks": ["No major MVP scoring risks found; still verify rent and commute before deciding."],
      "rent_note": "HSR Layout: rent fit uses stored rent_score 8/10 and does not estimate a live market price.",
      "commute_note": "HSR Layout: commute fit uses stored commute_score 8/10 for the MVP recommendation.",
      "confidence_level": "medium",
      "last_verified_at": "2026-04-26T00:00:00Z"
    }
  ],
  "fit_counts": {
    "green": 2,
    "yellow": 3,
    "red": 0
  },
  "risks": [],
  "rent_notes": [],
  "commute_notes": [],
  "survival_tips": [],
  "confidence_level": "medium",
  "explanation_mode": "template",
  "source_of_truth": "deterministic_area_recommendations"
}
```

The future AI generator must only explain deterministic scores and stored data; it must not invent rent, safety, or commute facts.

## Rewards, Streaks, And Points

`POST /functions/v1/rewards`

Awards deterministic points, updates streaks where applicable, and returns progress derived from `points_ledger`.

### Request

```json
{
  "action": "complete_kannada_lesson",
  "source_id": "uuid"
}
```

Supported actions:

- `summary`: returns progress without awarding points.
- `complete_kannada_lesson`: +10 points once per lesson and increments streak once per calendar day.
- `complete_daily_quest`: awards `quests.points` once per quest and increments streak once per calendar day.
- `answer_forum_question`: +5 points once per comment.
- `accept_forum_answer`: +25 points once per accepted comment.

### Response

```json
{
  "awarded": true,
  "duplicate": false,
  "event_type": "kannada_lesson_completed",
  "points_delta": 10,
  "total_points": 110,
  "current_rank": "Settler",
  "next_rank": "Street Smart",
  "points_to_next_rank": 390,
  "current_streak": 3,
  "longest_streak": 5,
  "last_activity_date": "2026-04-27"
}
```

### Rules

- Never mutate a stored total-points field.
- Insert one `points_ledger` row per points event.
- Derive total points from non-reversed `points_ledger` rows.
- Prevent duplicate active rewards with unique `(user_id, source_type, source_id)` ledger entries.
- Streaks update only for Kannada lesson completion and daily quest completion.
- Quest points are now awarded from approved `quest_submissions`; iOS should not call `complete_daily_quest` directly for reviewed quests.

Ranks:

- `Newcomer`: 0
- `Settler`: 100
- `Street Smart`: 500
- `Area Scout`: 1500
- `Local Guide`: 5000
- `City Sage`: 15000

## Quest Submissions

Quest types:

- `learn_kannada`
- `forum_help`
- `photo_walk`
- `rent_signal`
- `area_tip`

### Active Quests

`GET /rest/v1/quests?is_active=eq.true`

```json
{
  "id": "quest-uuid",
  "title": "Share one rent signal from your locality",
  "description": "Submit one recent rent or deposit observation.",
  "quest_type": "rent_signal",
  "points": 20,
  "is_active": true
}
```

### Submit Quest Proof

`POST /rest/v1/quest_submissions`

```json
{
  "quest_id": "quest-uuid",
  "user_id": "auth-user-uuid",
  "text_response": "2BHK semi-furnished near HSR, rent around 48k, deposit 5 months.",
  "photo_url": "quest-proof/auth-user-uuid/proof-image-uuid.jpg",
  "verification_status": "pending"
}
```

Rules:

- Most quests submit as `pending`.
- `learn_kannada` can submit as `approved` and auto-award points.
- Admin review changes submissions to `approved` or `rejected`.
- Points are inserted into `points_ledger` only when a submission first becomes `approved`.
- Daily quests prevent duplicate approved submissions for the same `quest_id`, `user_id`, and `submission_date`.
- Photo proof uploads go to the private Supabase Storage bucket `quest-proof`.
- Clients upload to an object path under the authenticated user's UUID folder, then store the bucket-qualified object path in `photo_url`.

## Forum Moderation

Forum moderation is deterministic and database-backed in the MVP. No AI moderation is used.

### Create Forum Post

`POST /rest/v1/forum_posts`

Authenticated users can create their own posts. iOS currently uses anonymous Supabase auth in development mode.

```json
{
  "user_id": "auth-user-uuid",
  "title": "Whitefield deposit norms for 1BHK?",
  "body": "Seeing 5 to 10 month deposits depending on the building.",
  "category": "rent",
  "urgency": "normal",
  "moderation_status": "pending"
}
```

New posts are not visible until an admin approves them.

### Read Forum Posts

`GET /rest/v1/forum_posts?moderation_status=in.(approved,visible)`

The iOS app reads only `approved` posts and legacy seeded `visible` posts. Rejected, pending, hidden, or removed content should not be shown.

### Report Content

`POST /rest/v1/moderation_reports`

```json
{
  "reporter_id": "auth-user-uuid",
  "target_type": "forum_post",
  "target_id": "post-or-comment-uuid",
  "reason": "User reported from iOS",
  "status": "open"
}
```

Allowed MVP target types are `forum_post` and `forum_comment`.

### Admin Review

Admin approve/reject actions update `forum_posts.moderation_status` or `forum_comments.moderation_status`, then insert a row into `moderation_actions`.

```json
{
  "admin_user_id": null,
  "target_type": "forum_post",
  "target_id": "post-uuid",
  "action": "approve",
  "notes": "Set forum post status to approved."
}
```

`admin_user_id` is temporarily nullable until production admin auth is implemented.

## Mentor Marketplace

Mentor profiles can be linked to a Supabase `user_id` or kept as standalone placeholders with `user_id = null`.

Specialties:

- `Area selection`
- `Rent negotiation`
- `Kannada basics`
- `Broker/landlord issues`
- `Student/fresher settling`
- `Cost reduction`

### Active Mentor List

`GET /rest/v1/mentors?is_verified=eq.true`

### Booking Request

`POST /rest/v1/mentor_bookings`

```json
{
  "mentor_id": "mentor-uuid",
  "user_id": "auth-user-uuid",
  "topic": "Need help choosing between HSR and BTM",
  "preferred_time_text": "Saturday morning or weekday after 7 PM",
  "status": "pending"
}
```

Booking statuses:

- `pending`
- `accepted`
- `completed`
- `cancelled`

Payments are not part of the MVP.
