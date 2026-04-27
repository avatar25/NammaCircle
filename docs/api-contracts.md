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

Ranks:

- `Newcomer`: 0
- `Settler`: 100
- `Street Smart`: 500
- `Area Scout`: 1500
- `Local Guide`: 5000
- `City Sage`: 15000
