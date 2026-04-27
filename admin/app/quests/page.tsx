import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { StatusButton } from "@/components/StatusButton";
import { createQuest, reviewQuestSubmission, toggleQuestActive, updateQuest } from "@/lib/actions";
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
      .select("id, text_response, photo_url, verification_status, created_at, reviewed_at, user_id, quests(title, quest_type, points)")
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
          <QuestTypeSelect />
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
      <label className="mt-3 block text-sm text-neutral-600">
        Sponsor name
        <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="sponsor_name" placeholder="Optional" />
      </label>
      <button className="mt-4 rounded-md bg-neutral-950 px-4 py-2 text-sm font-medium text-white">
        Create quest
      </button>
    </form>
  );
}

function QuestTypeSelect({ defaultValue }: { defaultValue?: string }) {
  return (
    <select className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="quest_type" defaultValue={defaultValue ?? "area_tip"}>
      <option value="learn_kannada">learn_kannada</option>
      <option value="forum_help">forum_help</option>
      <option value="photo_walk">photo_walk</option>
      <option value="rent_signal">rent_signal</option>
      <option value="area_tip">area_tip</option>
    </select>
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
            <form action={updateQuest} className="space-y-3">
              <input name="id" type="hidden" value={String(row.id)} />
              <div className="grid gap-3 lg:grid-cols-[1fr_160px]">
                <label className="text-sm text-neutral-600">
                  Title
                  <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="title" defaultValue={String(row.title ?? "")} required />
                </label>
                <label className="text-sm text-neutral-600">
                  Points
                  <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" min={0} name="points" type="number" defaultValue={Number(row.points ?? 0)} />
                </label>
              </div>
              <label className="block text-sm text-neutral-600">
                Description
                <textarea className="mt-1 min-h-20 w-full rounded-md border border-stone-300 px-3 py-2" name="description" defaultValue={String(row.description ?? "")} required />
              </label>
              <div className="grid gap-3 lg:grid-cols-3">
                <label className="text-sm text-neutral-600">
                  Type
                  <QuestTypeSelect defaultValue={String(row.quest_type ?? "area_tip")} />
                </label>
                <label className="text-sm text-neutral-600">
                  Sponsor
                  <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="sponsor_name" defaultValue={String(row.sponsor_name ?? "")} placeholder="Optional" />
                </label>
                <label className="mt-7 flex items-center gap-2 text-sm text-neutral-700">
                  <input name="is_active" type="checkbox" defaultChecked={Boolean(row.is_active)} />
                  Active
                </label>
              </div>
              <div>
                <button className="rounded-md bg-neutral-950 px-3 py-2 text-xs font-medium text-white">
                  Save quest
                </button>
              </div>
            </form>
            <div className="mt-2">
              <ToggleQuestButton id={String(row.id)} isActive={Boolean(row.is_active)} />
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function ToggleQuestButton({ id, isActive }: { id: string; isActive: boolean }) {
  return (
    <form action={toggleQuestActive}>
      <input name="id" type="hidden" value={id} />
      <input name="is_active" type="hidden" value={String(isActive)} />
      <button className="rounded-md border border-stone-300 bg-white px-3 py-2 text-xs font-medium hover:bg-stone-100">
        {isActive ? "Deactivate" : "Activate"}
      </button>
    </form>
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
              <td className="px-4 py-4">
                <p className="font-medium">{relatedTitle(row.quests)}</p>
                <p className="mt-1 text-xs text-neutral-500">{relatedQuestMeta(row.quests)}</p>
              </td>
              <td className="max-w-xl px-4 py-4 text-neutral-600">
                <p>{String(row.text_response ?? "-")}</p>
                {row.photo_url ? <p className="mt-2 text-xs text-neutral-500">Photo: {String(row.photo_url)}</p> : null}
              </td>
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

function relatedQuestMeta(value: unknown) {
  const quest = Array.isArray(value) ? value[0] : value;

  if (quest && typeof quest === "object") {
    const type = "quest_type" in quest ? String(quest.quest_type) : "-";
    const points = "points" in quest ? String(quest.points) : "0";
    return `${type} / ${points} pts`;
  }

  return "-";
}
