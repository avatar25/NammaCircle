import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

const cards = [
  {
    key: "pendingForumPosts",
    label: "Pending forum posts",
    hint: "New, flagged, or hidden posts needing review"
  },
  {
    key: "openReports",
    label: "Open reports",
    hint: "User reports on posts and comments"
  },
  {
    key: "pendingQuestSubmissions",
    label: "Pending quest submissions",
    hint: "Quest proof waiting on admin review"
  },
  {
    key: "pendingRentReports",
    label: "Pending rent reports",
    hint: "User rent reports before trust-sensitive use"
  },
  {
    key: "localitiesNeedingVerification",
    label: "Localities needing verification",
    hint: "Low confidence or stale locality scores"
  },
  {
    key: "totalUsers",
    label: "Total users",
    hint: "Placeholder until production auth is wired"
  }
] as const;

export default async function DashboardPage() {
  const supabase = createAdminSupabaseClient();
  const [
    forumPosts,
    openReports,
    questSubmissions,
    rentReports,
    localityScores
  ] = await Promise.all([
    countRows(supabase, "forum_posts", "moderation_status", ["pending", "flagged", "hidden"]),
    countRows(supabase, "moderation_reports", "status", ["open", "reviewing"]),
    countRows(supabase, "quest_submissions", "verification_status", ["pending"]),
    countRows(supabase, "rent_reports", "moderation_status", ["pending", "flagged"]),
    countLocalitiesNeedingVerification(supabase)
  ]);

  const values = {
    pendingForumPosts: forumPosts,
    openReports,
    pendingQuestSubmissions: questSubmissions,
    pendingRentReports: rentReports,
    localitiesNeedingVerification: localityScores,
    totalUsers: "TODO"
  };

  return (
    <AdminShell>
      <PageHeader
        title="Dashboard"
        description="MVP moderation and data-health overview. Counts are read server-side with the admin Supabase client."
      />
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
        {cards.map((card) => (
          <article className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm" key={card.key}>
            <p className="text-sm font-medium text-neutral-600">{card.label}</p>
            <p className="mt-3 text-3xl font-semibold text-neutral-950">{values[card.key]}</p>
            <p className="mt-3 text-xs leading-5 text-neutral-500">{card.hint}</p>
          </article>
        ))}
      </section>
    </AdminShell>
  );
}

async function countRows(
  supabase: ReturnType<typeof createAdminSupabaseClient>,
  table: string,
  column: string,
  statuses: string[]
) {
  const { count, error } = await supabase
    .from(table)
    .select("id", { count: "exact", head: true })
    .in(column, statuses);

  if (error) {
    return "N/A";
  }

  return count ?? 0;
}

async function countLocalitiesNeedingVerification(
  supabase: ReturnType<typeof createAdminSupabaseClient>
) {
  const staleBefore = new Date();
  staleBefore.setDate(staleBefore.getDate() - 45);

  const { count, error } = await supabase
    .from("locality_scores")
    .select("locality_id", { count: "exact", head: true })
    .or(`confidence_level.eq.low,last_verified_at.is.null,last_verified_at.lt.${staleBefore.toISOString()}`);

  if (error) {
    return "N/A";
  }

  return count ?? 0;
}
