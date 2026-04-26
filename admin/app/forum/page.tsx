import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { StatusButton } from "@/components/StatusButton";
import { moderateForumComment, moderateForumPost } from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function ForumPage() {
  const supabase = createAdminSupabaseClient();
  const [postsResult, commentsResult] = await Promise.all([
    supabase
      .from("forum_posts")
      .select("id, title, body, category, urgency, moderation_status, created_at, localities(name)")
      .in("moderation_status", ["flagged", "hidden"])
      .order("created_at", { ascending: false }),
    supabase
      .from("forum_comments")
      .select("id, body, moderation_status, created_at, forum_posts(title)")
      .in("moderation_status", ["flagged", "hidden"])
      .order("created_at", { ascending: false })
  ]);

  return (
    <AdminShell>
      <PageHeader
        title="Forum Moderation"
        description="Review posts and comments that need moderation. Approved posts/comments become visible again."
      />
      <ModerationTable
        action={moderateForumPost}
        error={postsResult.error?.message}
        rows={(postsResult.data ?? []) as Record<string, unknown>[]}
        title="Posts needing review"
        type="post"
      />
      <div className="mt-8">
        <ModerationTable
          action={moderateForumComment}
          error={commentsResult.error?.message}
          rows={(commentsResult.data ?? []) as Record<string, unknown>[]}
          title="Comments needing review"
          type="comment"
        />
      </div>
    </AdminShell>
  );
}

function ModerationTable({
  title,
  rows,
  error,
  action,
  type
}: {
  title: string;
  rows: Record<string, unknown>[];
  error?: string;
  action: (formData: FormData) => Promise<void>;
  type: "post" | "comment";
}) {
  return (
    <section>
      <h2 className="mb-3 text-lg font-semibold">{title}</h2>
      {error ? <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
      <div className="overflow-hidden rounded-lg border border-stone-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-stone-200 text-sm">
          <thead className="bg-stone-100 text-left text-xs uppercase text-neutral-500">
            <tr>
              <th className="px-4 py-3">Content</th>
              <th className="px-4 py-3">Context</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-200">
            {rows.map((row) => (
              <tr className="align-top" key={String(row.id)}>
                <td className="max-w-xl px-4 py-4">
                  <p className="font-medium text-neutral-950">
                    {type === "post" ? String(row.title ?? "-") : "Comment"}
                  </p>
                  <p className="mt-1 line-clamp-3 text-neutral-600">{String(row.body ?? "")}</p>
                </td>
                <td className="px-4 py-4 text-neutral-600">
                  {type === "post"
                    ? `${String(row.category ?? "-")} / ${String(row.urgency ?? "-")}`
                    : relatedTitle(row.forum_posts)}
                </td>
                <td className="px-4 py-4">{String(row.moderation_status ?? "-")}</td>
                <td className="flex gap-2 px-4 py-4">
                  <StatusButton action={action} id={String(row.id)} label="Approve" status="visible" />
                  <StatusButton action={action} id={String(row.id)} label="Reject" status="removed" />
                </td>
              </tr>
            ))}
            {rows.length === 0 ? (
              <tr>
                <td className="px-4 py-6 text-sm text-neutral-500" colSpan={4}>
                  Nothing needs moderation right now.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </section>
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
