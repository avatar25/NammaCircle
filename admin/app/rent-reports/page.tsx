import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { StatusButton } from "@/components/StatusButton";
import { moderateRentReport } from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

type SearchParams = {
  locality?: string;
  moderation_status?: string;
};

export default async function RentReportsPage({
  searchParams
}: {
  searchParams: Promise<SearchParams>;
}) {
  const params = await searchParams;
  const supabase = createAdminSupabaseClient();
  const { data: localities } = await supabase.from("localities").select("id, name").order("name");
  let query = supabase
    .from("rent_reports")
    .select("id, bhk, furnishing, monthly_rent, deposit, maintenance, source_type, notes, moderation_status, created_at, localities(name)")
    .order("created_at", { ascending: false });

  if (params.locality) {
    query = query.eq("locality_id", params.locality);
  }

  if (params.moderation_status) {
    query = query.eq("moderation_status", params.moderation_status);
  }

  const { data, error } = await query;

  return (
    <AdminShell>
      <PageHeader
        title="Rent Reports"
        description="Moderate user-submitted rent reports before they influence trust-sensitive rent guidance."
      />
      <FilterForm
        localities={(localities ?? []) as { id: string; name: string }[]}
        selectedLocality={params.locality}
        selectedStatus={params.moderation_status}
      />
      {error ? <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{error.message}</p> : null}
      <Table rows={(data ?? []) as Record<string, unknown>[]} />
    </AdminShell>
  );
}

function FilterForm({
  localities,
  selectedLocality,
  selectedStatus
}: {
  localities: { id: string; name: string }[];
  selectedLocality?: string;
  selectedStatus?: string;
}) {
  return (
    <form className="mb-4 flex flex-wrap gap-3 rounded-lg border border-stone-200 bg-white p-4">
      <select className="rounded-md border border-stone-300 px-3 py-2 text-sm" name="locality" defaultValue={selectedLocality ?? ""}>
        <option value="">All localities</option>
        {localities.map((locality) => (
          <option key={locality.id} value={locality.id}>
            {locality.name}
          </option>
        ))}
      </select>
      <select className="rounded-md border border-stone-300 px-3 py-2 text-sm" name="moderation_status" defaultValue={selectedStatus ?? ""}>
        <option value="">All statuses</option>
        <option value="pending">pending</option>
        <option value="flagged">flagged</option>
        <option value="approved">approved</option>
        <option value="rejected">rejected</option>
      </select>
      <button className="rounded-md bg-neutral-950 px-4 py-2 text-sm font-medium text-white">Filter</button>
    </form>
  );
}

function Table({ rows }: { rows: Record<string, unknown>[] }) {
  return (
    <div className="overflow-hidden rounded-lg border border-stone-200 bg-white shadow-sm">
      <table className="min-w-full divide-y divide-stone-200 text-sm">
        <thead className="bg-stone-100 text-left text-xs uppercase text-neutral-500">
          <tr>
            <th className="px-4 py-3">Locality</th>
            <th className="px-4 py-3">Rent</th>
            <th className="px-4 py-3">Details</th>
            <th className="px-4 py-3">Status</th>
            <th className="px-4 py-3">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-stone-200">
          {rows.map((row) => (
            <tr key={String(row.id)}>
              <td className="px-4 py-4">{relatedName(row.localities)}</td>
              <td className="px-4 py-4">
                <p className="font-medium">INR {String(row.monthly_rent ?? "-")}</p>
                <p className="text-xs text-neutral-500">Deposit: INR {String(row.deposit ?? "-")}</p>
              </td>
              <td className="px-4 py-4 text-neutral-600">
                {String(row.bhk ?? "-")} / {String(row.furnishing ?? "unknown")} / maintenance {String(row.maintenance ?? "-")}
              </td>
              <td className="px-4 py-4">{String(row.moderation_status ?? "-")}</td>
              <td className="flex gap-2 px-4 py-4">
                <StatusButton action={moderateRentReport} id={String(row.id)} label="Approve" status="approved" />
                <StatusButton action={moderateRentReport} id={String(row.id)} label="Reject" status="rejected" />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function relatedName(value: unknown) {
  if (Array.isArray(value)) {
    return String(value[0]?.name ?? "-");
  }

  if (value && typeof value === "object" && "name" in value) {
    return String(value.name);
  }

  return "-";
}
