import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import {
  createMentor,
  toggleMentorVerification,
  updateMentor,
  updateMentorBookingStatus
} from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function MentorsPage() {
  const supabase = createAdminSupabaseClient();
  const [mentorsResult, bookingsResult] = await Promise.all([
    supabase
      .from("mentors")
      .select("id, user_id, display_name, bio, specialties, hourly_rate_inr, is_verified, created_at")
      .order("created_at", { ascending: false }),
    supabase
      .from("mentor_bookings")
      .select("id, mentor_id, user_id, topic, preferred_time_text, status, scheduled_at, created_at, mentors(display_name)")
      .order("created_at", { ascending: false })
  ]);

  return (
    <AdminShell>
      <PageHeader
        title="Mentors"
        description="Create mentor profiles, manage specialties and rates, and review booking requests. Payments are not implemented."
      />
      {mentorsResult.error ? <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{mentorsResult.error.message}</p> : null}
      <section className="grid gap-6 xl:grid-cols-[380px_1fr]">
        <CreateMentorForm />
        <MentorList rows={(mentorsResult.data ?? []) as Record<string, unknown>[]} />
      </section>
      <section className="mt-8">
        <h2 className="mb-3 text-lg font-semibold">Booking requests</h2>
        <BookingsTable
          error={bookingsResult.error?.message}
          rows={(bookingsResult.data ?? []) as Record<string, unknown>[]}
        />
      </section>
    </AdminShell>
  );
}

const specialties = [
  "Area selection",
  "Rent negotiation",
  "Kannada basics",
  "Broker/landlord issues",
  "Student/fresher settling",
  "Cost reduction"
];

function CreateMentorForm() {
  return (
    <form action={createMentor} className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm">
      <h2 className="text-lg font-semibold">Create mentor</h2>
      <label className="mt-4 block text-sm text-neutral-600">
        Display name
        <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="display_name" required />
      </label>
      <label className="mt-3 block text-sm text-neutral-600">
        User ID
        <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="user_id" placeholder="Optional auth user UUID" />
      </label>
      <label className="mt-3 block text-sm text-neutral-600">
        Bio
        <textarea className="mt-1 min-h-24 w-full rounded-md border border-stone-300 px-3 py-2" name="bio" />
      </label>
      <label className="mt-3 block text-sm text-neutral-600">
        Hourly rate INR
        <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" min={0} name="hourly_rate_inr" type="number" />
      </label>
      <SpecialtyCheckboxes selected={[]} />
      <label className="mt-3 flex items-center gap-2 text-sm text-neutral-700">
        <input name="is_verified" type="checkbox" />
        Verified
      </label>
      <button className="mt-4 rounded-md bg-neutral-950 px-4 py-2 text-sm font-medium text-white">
        Create mentor
      </button>
    </form>
  );
}

function MentorList({ rows }: { rows: Record<string, unknown>[] }) {
  return (
    <div className="grid gap-4">
      {rows.map((mentor) => (
        <article className="rounded-lg border border-stone-200 bg-white p-5 shadow-sm" key={String(mentor.id)}>
          <form action={updateMentor} className="space-y-3">
            <input name="id" type="hidden" value={String(mentor.id)} />
            <div className="grid gap-3 lg:grid-cols-[1fr_180px]">
              <label className="text-sm text-neutral-600">
                Display name
                <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="display_name" defaultValue={String(mentor.display_name ?? "")} required />
              </label>
              <label className="text-sm text-neutral-600">
                Hourly rate INR
                <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" min={0} name="hourly_rate_inr" type="number" defaultValue={mentor.hourly_rate_inr == null ? "" : String(mentor.hourly_rate_inr)} />
              </label>
            </div>
            <label className="block text-sm text-neutral-600">
              User ID
              <input className="mt-1 w-full rounded-md border border-stone-300 px-3 py-2" name="user_id" defaultValue={String(mentor.user_id ?? "")} placeholder="Optional auth user UUID" />
            </label>
            <label className="block text-sm text-neutral-600">
              Bio
              <textarea className="mt-1 min-h-20 w-full rounded-md border border-stone-300 px-3 py-2" name="bio" defaultValue={String(mentor.bio ?? "")} />
            </label>
            <SpecialtyCheckboxes selected={Array.isArray(mentor.specialties) ? mentor.specialties.map(String) : []} />
            <label className="flex items-center gap-2 text-sm text-neutral-700">
              <input name="is_verified" type="checkbox" defaultChecked={Boolean(mentor.is_verified)} />
              Verified
            </label>
            <button className="rounded-md bg-neutral-950 px-3 py-2 text-xs font-medium text-white">
              Save mentor
            </button>
          </form>
          <form action={toggleMentorVerification} className="mt-2">
            <input name="id" type="hidden" value={String(mentor.id)} />
            <input name="is_verified" type="hidden" value={String(Boolean(mentor.is_verified))} />
            <button className="rounded-md border border-stone-300 bg-white px-3 py-2 text-xs font-medium hover:bg-stone-100">
              {mentor.is_verified ? "Unverify mentor" : "Verify mentor"}
            </button>
          </form>
        </article>
      ))}
      {rows.length === 0 ? (
        <p className="rounded-lg border border-stone-200 bg-white p-5 text-sm text-neutral-500">No mentors yet.</p>
      ) : null}
    </div>
  );
}

function SpecialtyCheckboxes({ selected }: { selected: string[] }) {
  return (
    <fieldset className="mt-3">
      <legend className="text-sm text-neutral-600">Specialties</legend>
      <div className="mt-2 grid gap-2 sm:grid-cols-2">
        {specialties.map((specialty) => (
          <label className="flex items-center gap-2 text-sm text-neutral-700" key={specialty}>
            <input name="specialties" type="checkbox" value={specialty} defaultChecked={selected.includes(specialty)} />
            {specialty}
          </label>
        ))}
      </div>
    </fieldset>
  );
}

function BookingsTable({ rows, error }: { rows: Record<string, unknown>[]; error?: string }) {
  return (
    <div className="overflow-hidden rounded-lg border border-stone-200 bg-white shadow-sm">
      {error ? <p className="m-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
      <table className="min-w-full divide-y divide-stone-200 text-sm">
        <thead className="bg-stone-100 text-left text-xs uppercase text-neutral-500">
          <tr>
            <th className="px-4 py-3">Mentor</th>
            <th className="px-4 py-3">Topic</th>
            <th className="px-4 py-3">Preferred time</th>
            <th className="px-4 py-3">Status</th>
            <th className="px-4 py-3">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-stone-200">
          {rows.map((row) => (
            <tr className="align-top" key={String(row.id)}>
              <td className="px-4 py-4">{mentorName(row.mentors)}</td>
              <td className="max-w-md px-4 py-4 text-neutral-700">{String(row.topic ?? "-")}</td>
              <td className="px-4 py-4 text-neutral-600">{String(row.preferred_time_text ?? "-")}</td>
              <td className="px-4 py-4">{String(row.status ?? "-")}</td>
              <td className="flex flex-wrap gap-2 px-4 py-4">
                <BookingStatusButton id={String(row.id)} label="Accept" status="accepted" />
                <BookingStatusButton id={String(row.id)} label="Complete" status="completed" />
                <BookingStatusButton id={String(row.id)} label="Cancel" status="cancelled" />
              </td>
            </tr>
          ))}
          {rows.length === 0 ? (
            <tr>
              <td className="px-4 py-6 text-sm text-neutral-500" colSpan={5}>No booking requests yet.</td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </div>
  );
}

function BookingStatusButton({ id, label, status }: { id: string; label: string; status: string }) {
  return (
    <form action={updateMentorBookingStatus}>
      <input name="id" type="hidden" value={id} />
      <input name="status" type="hidden" value={status} />
      <button className="rounded-md border border-stone-300 bg-white px-3 py-1.5 text-xs font-medium hover:bg-stone-100">
        {label}
      </button>
    </form>
  );
}

function mentorName(value: unknown) {
  if (Array.isArray(value)) {
    return String(value[0]?.display_name ?? "-");
  }

  if (value && typeof value === "object" && "display_name" in value) {
    return String(value.display_name);
  }

  return "-";
}
