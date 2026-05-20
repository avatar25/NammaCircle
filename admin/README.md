# NammaCircle Admin

Next.js + TypeScript + Tailwind dashboard for the NammaCircle MVP.

## MVP Admin Areas

- Review pending forum posts/comments
- Inspect user reports on posts/comments
- Log forum approve/reject actions in `moderation_actions`
- Manage locality score metadata
- Review mentor profiles
- Track quest submissions
- Create, edit, activate, and deactivate MVP quests
- Approve/reject quest submissions; approved submissions award points through the backend trigger
- Public landing page at `/` with deterministic area matching and lead capture
- Inspect basic activity metrics

## Not Implemented Yet

- Production auth
- Payments or payouts
- AI moderation

## Local Development

Copy the example env file:

```sh
cp .env.example .env.local
```

Then fill in:

```sh
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

Then run:

```sh
npm install
npm run dev
```

Open `http://localhost:3000` for the landing page or `http://localhost:3000/dashboard` for admin.

## Auth Notes

Auth is intentionally a placeholder for the MVP. Server-side admin actions still use `SUPABASE_SERVICE_ROLE_KEY`; never expose that key to client components or browser code. Database RLS also supports authenticated admin users whose trusted Supabase Auth app metadata marks them as admin. Replace `lib/admin-auth.ts` with production sign-in/session checks before launch.
