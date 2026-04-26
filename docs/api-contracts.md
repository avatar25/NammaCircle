# API Contracts

These contracts are placeholders for the MVP. Final implementation can be Supabase client queries, edge functions, or Next.js route handlers depending on product needs.

## Localities

`GET /localities`

Returns visible locality records and score components.

`GET /localities/:id`

Returns one locality with notes and related rent reference data.

## Rent Fairness

`POST /rent-checks`

Request:

```json
{
  "localityId": "uuid",
  "bhkType": "1BHK",
  "quotedRent": 35000
}
```

Response:

```json
{
  "fairnessLabel": "high",
  "message": "This rent looks above the current MVP reference range."
}
```

TODO: keep this deterministic. Do not add real AI in the MVP.

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
