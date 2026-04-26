import { AdminShell } from "@/components/AdminShell";
import { PageHeader } from "@/components/PageHeader";
import { updateLocalityScores } from "@/lib/actions";
import { createAdminSupabaseClient } from "@/lib/supabase";

export const dynamic = "force-dynamic";

type LocalityWithScores = {
  id: string;
  name: string;
  slug: string;
  locality_scores: ScoreRow | ScoreRow[] | null;
};

type ScoreRow = {
  rent_score: number | null;
  commute_score: number | null;
  food_score: number | null;
  social_life_score: number | null;
  quiet_score: number | null;
  newcomer_friendliness_score: number | null;
  kannada_dependency_score: number | null;
  broker_risk_score: number | null;
  water_reliability_score: number | null;
  confidence_level: string | null;
  last_verified_at: string | null;
};

const scoreFields = [
  "rent_score",
  "commute_score",
  "food_score",
  "social_life_score",
  "quiet_score",
  "newcomer_friendliness_score",
  "kannada_dependency_score",
  "broker_risk_score",
  "water_reliability_score"
];

export default async function LocalitiesPage() {
  const supabase = createAdminSupabaseClient();
  const { data, error } = await supabase
    .from("localities")
    .select(
      "id, name, slug, locality_scores(rent_score, commute_score, food_score, social_life_score, quiet_score, newcomer_friendliness_score, kannada_dependency_score, broker_risk_score, water_reliability_score, confidence_level, last_verified_at)"
    )
    .order("name");

  const localities = (data ?? []) as unknown as LocalityWithScores[];

  return (
    <AdminShell>
      <PageHeader
        title="Localities"
        description="Review locality scores, confidence, and verification freshness. Score edits update `last_verified_at`."
      />
      {error ? <ErrorBanner message={error.message} /> : null}
      <div className="overflow-hidden rounded-lg border border-stone-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-stone-200 text-sm">
          <thead className="bg-stone-100 text-left text-xs uppercase text-neutral-500">
            <tr>
              <th className="px-4 py-3">Locality</th>
              <th className="px-4 py-3">Scores</th>
              <th className="px-4 py-3">Confidence</th>
              <th className="px-4 py-3">Last verified</th>
              <th className="px-4 py-3">Edit scores</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-200">
            {localities.map((locality) => (
              <tr className="align-top" key={locality.id}>
                <td className="px-4 py-4">
                  <p className="font-medium text-neutral-950">{locality.name}</p>
                  <p className="text-xs text-neutral-500">{locality.slug}</p>
                </td>
                <td className="px-4 py-4 text-xs text-neutral-700">
                  <ScoreList scores={getScoreRow(locality)} />
                </td>
                <td className="px-4 py-4">
                  <span className="rounded-full bg-stone-100 px-2 py-1 text-xs font-medium">
                    {getScoreRow(locality)?.confidence_level ?? "missing"}
                  </span>
                </td>
                <td className="px-4 py-4 text-sm text-neutral-600">
                  {formatDate(getScoreRow(locality)?.last_verified_at)}
                </td>
                <td className="px-4 py-4">
                  <ScoreForm locality={locality} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminShell>
  );
}

function ScoreList({ scores }: { scores: ScoreRow | null }) {
  if (!scores) {
    return <span>No score row</span>;
  }

  return (
    <div className="grid grid-cols-2 gap-x-4 gap-y-1">
      {scoreFields.slice(0, 6).map((field) => (
        <span key={field}>
          {field.replaceAll("_", " ")}: <strong>{scores[field as keyof typeof scores] ?? "-"}</strong>
        </span>
      ))}
    </div>
  );
}

function ScoreForm({ locality }: { locality: LocalityWithScores }) {
  const scores = getScoreRow(locality);

  return (
    <form action={updateLocalityScores} className="grid min-w-[360px] gap-2">
      <input name="locality_id" type="hidden" value={locality.id} />
      <div className="grid grid-cols-3 gap-2">
        {scoreFields.map((field) => (
          <label className="text-xs text-neutral-600" key={field}>
            {field.replaceAll("_", " ")}
            <input
              className="mt-1 w-full rounded-md border border-stone-300 px-2 py-1"
              max={10}
              min={0}
              name={field}
              type="number"
              defaultValue={(scores?.[field as keyof typeof scores] as number | null) ?? 0}
            />
          </label>
        ))}
      </div>
      <label className="text-xs text-neutral-600">
        confidence
        <select
          className="mt-1 w-full rounded-md border border-stone-300 px-2 py-1"
          name="confidence_level"
          defaultValue={scores?.confidence_level ?? "low"}
        >
          <option value="low">low</option>
          <option value="medium">medium</option>
          <option value="high">high</option>
        </select>
      </label>
      <button className="rounded-md bg-neutral-950 px-3 py-2 text-xs font-medium text-white">
        Save scores
      </button>
    </form>
  );
}

function ErrorBanner({ message }: { message: string }) {
  return <p className="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{message}</p>;
}

function formatDate(value?: string | null) {
  return value ? new Date(value).toLocaleDateString() : "Not verified";
}

function getScoreRow(locality: LocalityWithScores) {
  if (Array.isArray(locality.locality_scores)) {
    return locality.locality_scores[0] ?? null;
  }

  return locality.locality_scores;
}
