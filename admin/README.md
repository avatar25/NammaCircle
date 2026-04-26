# NammaCircle Admin

Next.js + TypeScript + Tailwind dashboard for the NammaCircle MVP.

## MVP Admin Areas

- Review and hide forum posts/comments
- Manage locality score metadata
- Review mentor profiles
- Track quest submissions
- Inspect basic activity metrics

## Not Implemented Yet

- Production auth
- Role-based access control
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

Open `http://localhost:3000/dashboard`.

## Auth Notes

Auth is intentionally a placeholder for the MVP. Server-side admin actions use `SUPABASE_SERVICE_ROLE_KEY`; never expose that key to client components or browser code. Replace `lib/admin-auth.ts` with production auth and admin role checks before launch.
