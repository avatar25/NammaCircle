# Trust And Safety

NammaCircle treats locality scores, rent data, forum moderation, and admin actions as trust-sensitive MVP systems. The app should prefer deterministic, auditable decisions over opaque automation.

## Forum Moderation

- New forum posts default to `pending`.
- Admin review changes posts/comments to `approved` or `rejected`.
- Only `approved` content is visible to users. Legacy seeded `visible` content is still readable during migration.
- Rejected or removed content must stay hidden from iOS clients.
- Reported posts/comments appear in the admin forum moderation dashboard.
- Admin approve/reject actions are inserted into `moderation_actions`.

## Reporting

Users can report posts or comments from iOS. Reports are stored in `moderation_reports` with:

- `target_type`: `forum_post` or `forum_comment`
- `target_id`: the reported content id
- `reason`: MVP free-text or default app reason
- `status`: starts as `open`

Reports are not automatic takedowns in the MVP. They create review work for admins.

## Admin Principles

- Admin tools should use server-side Supabase service role access only.
- The service role key must never be exposed to browser or iOS code.
- Actions that change content visibility should leave an audit row in `moderation_actions`.
- Production admin auth is still a TODO; before launch, replace placeholder access with admin role claims or an `admin_users` table.

## AI Policy

No real AI moderation is implemented in the MVP. Future AI may summarize or explain deterministic moderation signals, but it must not invent facts about neighborhoods, rent norms, safety, people, or forum users.

## Data Confidence

Forum moderation decisions should consider:

- Direct user report context
- Content category and urgency
- Repeat reports on the same target
- Whether the content contains rent, safety, broker, or locality claims

Claims that affect housing, safety, rent fairness, or broker trust should be reviewed more conservatively than general community chatter.
