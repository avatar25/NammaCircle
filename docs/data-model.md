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
- `points`

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
