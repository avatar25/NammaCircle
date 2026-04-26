import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { toggleMentorVerification } from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function MentorsPage() {
  const supabase = createAdminSupabaseClient();
  const { data, error } = await supabase
    .from("mentors")
    .select("id, display_name, bio, specialties, hourly_rate_inr, is_verified, created_at")
    .order("created_at", { ascending: false });

  return (
    <AdminShell>
      <PageHeader
        title="Mentors"
        description="Verify or unverify mentor profiles. Payment and production scheduling are intentionally out of MVP scope."
      />
      {error ? <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{error.message}</p> : null}
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {((data ?? []) as Record<string, unknown>[]).map((mentor) => (
          <article className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm" key={String(mentor.id)}>
            <div className="flex items-start justify-between gap-3">
              <div>
                <h2 className="font-semibold">{String(mentor.display_name ?? "-")}</h2>
                <p className="mt-1 text-sm text-neutral-600">{String(mentor.bio ?? "")}</p>
              </div>
              <span className="rounded-full bg-stone-100 px-2 py-1 text-xs">
                {mentor.is_verified ? "verified" : "unverified"}
              </span>
            </div>
            <p className="mt-4 text-sm text-neutral-600">
              Specialties: {Array.isArray(mentor.specialties) ? mentor.specialties.join(", ") : "-"}
            </p>
            <p className="mt-1 text-sm text-neutral-600">
              Hourly rate: INR {String(mentor.hourly_rate_inr ?? "-")}
            </p>
            <form action={toggleMentorVerification} className="mt-4">
              <input name="id" type="hidden" value={String(mentor.id)} />
              <input name="is_verified" type="hidden" value={String(Boolean(mentor.is_verified))} />
              <button className="rounded-md border border-stone-300 bg-white px-3 py-2 text-sm font-medium hover:bg-stone-100">
                {mentor.is_verified ? "Unverify mentor" : "Verify mentor"}
              </button>
            </form>
          </article>
        ))}
      </div>
    </AdminShell>
  );
}
