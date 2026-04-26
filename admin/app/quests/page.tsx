import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { StatusButton } from "@/components/StatusButton";
import { createQuest, reviewQuestSubmission } from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function QuestsPage() {
  const supabase = createAdminSupabaseClient();
  const [questsResult, submissionsResult] = await Promise.all([
    supabase
      .from("quests")
      .select("id, title, description, quest_type, points, is_active, sponsor_name, created_at, localities(name)")
      .order("created_at", { ascending: false }),
    supabase
      .from("quest_submissions")
      .select("id, text_response, photo_url, verification_status, created_at, reviewed_at, quests(title)")
      .order("created_at", { ascending: false })
  ]);

  return (
    <AdminShell>
      <PageHeader
        title="Quests"
        description="Create lightweight city quests and review user submissions before points are trusted."
      />
      <section className="grid gap-6 xl:grid-cols-[380px_1fr]">
        <CreateQuestForm />
        <QuestList rows={(questsResult.data ?? []) as Record<string, unknown>[]} error={questsResult.error?.message} />
      </section>
      <section className="mt-8">
        <h2 className="mb-3 text-lg font-semibold">Quest submissions</h2>
        <SubmissionsTable
          rows={(submissionsResult.data ?? []) as Record<string, unknown>[]}
          error={submissionsResult.error?.message}
        />
      </section>
    </AdminShell>
  );
}

function CreateQuestForm() {
  return (
    <form action={createQuest} className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm">
      <h2 className="text-lg font-semibold">Create quest</h2>
      <label className="mt-4 block text-sm text-neutral-600">
        Title
        <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="title" required />
      </label>
      <label className="mt-3 block text-sm text-neutral-600">
        Description
        <textarea className="mt-1 min-h-24 w-full rounded-md border border-stone-300 px-3 py-2" name="description" required />
      </label>
      <div className="mt-3 grid grid-cols-2 gap-3">
        <label className="text-sm text-neutral-600">
          Type
          <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="quest_type" defaultValue="daily" />
        </label>
        <label className="text-sm text-neutral-600">
          Points
          <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" min={0} name="points" type="number" defaultValue={10} />
        </label>
      </div>
      <label className="mt-3 flex items-center gap-2 text-sm text-neutral-700">
        <input name="is_active" type="checkbox" defaultChecked />
        Active
      </label>
      <button className="mt-4 rounded-md bg-neutral-950 px-4 py-2 text-sm font-medium text-white">
        Create quest
      </button>
    </form>
  );
}

function QuestList({ rows, error }: { rows: Record<string, unknown>[]; error?: string }) {
  return (
    <div className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm">
      <h2 className="text-lg font-semibold">Quest list</h2>
      {error ? <p className="mt-3 rounded-md bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
      <div className="mt-4 space-y-3">
        {rows.map((row) => (
          <article className="rounded-md border border-stone-200 p-4" key={String(row.id)}>
            <div className="flex items-start justify-between gap-3">
              <div>
                <h3 className="font-medium">{String(row.title ?? "-")}</h3>
                <p className="mt-1 text-sm text-neutral-600">{String(row.description ?? "")}</p>
              </div>
              <span className="rounded-full bg-stone-100 px-2 py-1 text-xs">
                {String(row.points ?? 0)} pts
              </span>
            </div>
            <p className="mt-2 text-xs text-neutral-500">
              {String(row.quest_type ?? "-")} / {row.is_active ? "active" : "inactive"}
            </p>
          </article>
        ))}
      </div>
    </div>
  );
}

function SubmissionsTable({ rows, error }: { rows: Record<string, unknown>[]; error?: string }) {
  return (
    <div className="overflow-hidden rounded-lg border border-stone-200 bg-white shadow-sm">
      {error ? <p className="m-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
      <table className="min-w-full divide-y divide-stone-200 text-sm">
        <thead className="bg-stone-100 text-left text-xs uppercase text-neutral-500">
          <tr>
            <th className="px-4 py-3">Quest</th>
            <th className="px-4 py-3">Response</th>
            <th className="px-4 py-3">Status</th>
            <th className="px-4 py-3">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-stone-200">
          {rows.map((row) => (
            <tr className="align-top" key={String(row.id)}>
              <td className="px-4 py-4">{relatedTitle(row.quests)}</td>
              <td className="max-w-xl px-4 py-4 text-neutral-600">{String(row.text_response ?? "-")}</td>
              <td className="px-4 py-4">{String(row.verification_status ?? "-")}</td>
              <td className="flex gap-2 px-4 py-4">
                <StatusButton action={reviewQuestSubmission} id={String(row.id)} label="Approve" status="approved" />
                <StatusButton action={reviewQuestSubmission} id={String(row.id)} label="Reject" status="rejected" />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function relatedTitle(value: unknown) {
  if (Array.isArray(value)) {
    return String(value[0]?.title ?? "-");
  }

  if (value && typeof value === "object" && "title" in value) {
    return String(value.title);
  }

  return "-";
}
