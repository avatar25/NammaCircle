# Data Model

## Core Entities

### Locality

- `id`
- `name`
- `city`
- `commute_score`
- `safety_score`
- `affordability_score`
- `notes`

### Rent Check

- `id`
- `locality_id`
- `bhk_type`
- `quoted_rent`
- `fairness_label`

### Kannada Lesson

- `id`
- `title`
- `phrase`
- `transliteration`
- `meaning`

### Forum Post

- `id`
- `title`
- `body`
- `status`

### Forum Comment

- `id`
- `post_id`
- `body`
- `status`

### Quest

- `id`
- `title`
- `description`
- `quest_type`
- `points`
- `is_active`

Quest types are `learn_kannada`, `forum_help`, `photo_walk`, `rent_signal`, and `area_tip`.

### Quest Submission

- `id`
- `quest_id`
- `user_id`
- `text_response`
- `photo_url`
- `verification_status`
- `submission_date`

Approved quest submissions write to `points_ledger`. Daily quests allow only one approved submission for the same user, quest, and day.

### Mentor

- `id`
- `name`
- `locality`
- `bio`
- `status`

### Mentor Booking

- `id`
- `mentor_id`
- `requester_note`
- `status`

## Deferred Entities

- User profiles
- Auth identities
- Payment records
- AI recommendation logs
- Push notification tokens
