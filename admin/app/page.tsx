const moderationItems = [
  "Forum reports",
  "Locality score edits",
  "Mentor profile review",
  "Quest submissions"
];

export default function AdminDashboard() {
  return (
    <main className="min-h-screen px-6 py-8">
      <div className="mx-auto max-w-6xl">
        <header className="mb-8">
          <p className="text-sm font-medium uppercase tracking-wide text-emerald-700">
            NammaCircle Admin
          </p>
          <h1 className="mt-2 text-3xl font-semibold text-neutral-950">
            Moderation Dashboard
          </h1>
          <p className="mt-3 max-w-2xl text-neutral-700">
            Clean placeholder for the MVP admin surface. Production auth,
            payments, and AI moderation are intentionally not implemented yet.
          </p>
        </header>

        <section className="grid gap-4 md:grid-cols-2">
          {moderationItems.map((item) => (
            <article
              className="rounded-lg border border-neutral-200 bg-white p-5 shadow-sm"
              key={item}
            >
              <h2 className="text-lg font-semibold text-neutral-950">{item}</h2>
              <p className="mt-2 text-sm text-neutral-600">
                TODO: connect this panel to Supabase once the MVP schema is
                finalized.
              </p>
            </article>
          ))}
        </section>
      </div>
    </main>
  );
}
