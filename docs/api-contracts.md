# API Contracts

These contracts are MVP-facing placeholders unless a concrete implementation is noted. Final implementation can be Supabase client queries, edge functions, or Next.js route handlers depending on product needs.

## Rent Fairness Check

`POST /functions/v1/rent-check`

Runs a deterministic rent fairness check and stores the result in `rent_checks`.

### Request

```json
{
  "locality_id": "uuid",
  "bhk": "2BHK",
  "monthly_rent": 42000,
  "deposit": 250000,
  "furnishing": "semi_furnished",
  "maintenance": 3000
}
```

### Logic

1. Normalize `bhk` by trimming spaces and uppercasing.
2. Load approved `rent_reports` for the same `locality_id` and `bhk`.
3. If at least 5 reports exist, calculate the median from those reports.
4. If fewer than 5 reports exist, use `rent_baselines` seeded data.
5. Compare submitted rent to the median:
   - `good_deal`: rent <= median * 0.9
   - `fair`: rent <= median * 1.1
   - `expensive`: rent <= median * 1.3
   - `suspicious_or_overpriced`: rent > median * 1.3
6. Add deposit warning:
   - `warning`: deposit > 6 months of rent
   - `strong_warning`: deposit > 10 months of rent
7. Insert the result into `rent_checks`.

### Response

```json
{
  "rent_check_id": "uuid",
  "created_at": "2026-04-26T12:00:00Z",
  "label": "fair",
  "score": 72,
  "medianRent": 43000,
  "reportCount": 7,
  "referenceSource": "reports",
  "confidenceLevel": "medium",
  "depositWarning": "none",
  "explanation": "For 2BHK, the submitted rent is 2% below the median rent of INR 43000 from 7 recent reports. Result: fair.",
  "recommendedNegotiationPoints": [
    "Clarify whether maintenance is included in rent and which services it covers.",
    "Verify the condition and inventory for the semi_furnished furnishing claim."
  ]
}
```

### Notes

- This is deterministic guidance, not legal or financial advice.
- No real AI is used.
- If report volume is low, the response clearly says baseline data was used.
- Production admin controls for updating rent baselines are still TODO.

## Localities

`GET /localities`

Returns visible locality records and score components.

`GET /localities/:id`

Returns one locality with notes and related rent reference data.

## Kannada Lessons

`GET /kannada-lessons/today`

Returns the daily Kannada lesson.

`POST /kannada-lessons/:id/complete`

Marks a lesson complete and updates streak data once user profiles exist.

## Forum

`GET /forum-posts`

Returns visible forum posts.

`POST /forum-posts`

Creates a forum post.

`POST /forum-posts/:id/comments`

Creates a comment on a forum post.

## Quests

`GET /quests`

Returns active quests.

`POST /quests/:id/complete`

Records quest completion and awards points once user profiles exist.

## Mentors

`GET /mentors`

Returns approved mentor profiles.

`POST /mentor-bookings`

Creates a mentor booking request.

## Admin

`GET /admin/moderation-queue`

Returns content and profiles needing review.

`POST /admin/moderation-actions`

Records a moderation action.

TODO: protect all admin APIs with production auth before launch.
