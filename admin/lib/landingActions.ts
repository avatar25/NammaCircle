"use server";

import { createAdminSupabaseClient } from "./supabase";
import {
  recommendAreas,
  type AreaRecommendation,
  type AreaRecommendationInput,
  type LocalityRow,
  type LocalityScoreRow,
  type RecommendationCandidate
} from "../../supabase/edge-functions/area-recommendations/areaRecommendations";

export type LandingLeadState = {
  ok: boolean;
  error?: string;
  matches: Array<Pick<
    AreaRecommendation,
    "locality_id" | "name" | "slug" | "fit" | "score" | "top_reasons" | "risks" | "confidence_level"
  >>;
};

const initialPreferences = {
  wants_quiet: false,
  wants_social_life: true,
  wants_low_cost: true,
  wants_food_options: true,
  wants_low_kannada_dependency: true,
  wants_low_broker_risk: true
};

export async function getAreaMatch(
  _previousState: LandingLeadState,
  formData: FormData
): Promise<LandingLeadState> {
  try {
    const officeLocation = String(formData.get("office_location") ?? "").trim();
    const budgetText = String(formData.get("budget") ?? "").trim();
    const commuteTolerance = toPositiveNumber(formData.get("commute_tolerance")) ?? 45;
    const lifestyleTags = parseTags(String(formData.get("lifestyle_tags") ?? ""));
    const contact = nullableString(formData.get("contact"));
    const budget = parseBudget(budgetText);

    if (!officeLocation) {
      return { ok: false, error: "Office location is required.", matches: [] };
    }

    if (!budgetText) {
      return { ok: false, error: "Budget is required.", matches: [] };
    }

    const input: AreaRecommendationInput = {
      work_location_text: officeLocation,
      budget_min: budget.min,
      budget_max: budget.max,
      commute_tolerance_minutes: commuteTolerance,
      lifestyle_tags: lifestyleTags,
      preferences: {
        ...initialPreferences,
        wants_quiet: lifestyleTags.includes("quiet"),
        wants_social_life: lifestyleTags.some((tag) => ["social", "nightlife", "cafes"].includes(tag)),
        wants_food_options: lifestyleTags.some((tag) => ["food", "cafes"].includes(tag))
      }
    };
    const supabase = createAdminSupabaseClient();
    const candidates = await fetchCandidates(supabase);
    const matches = recommendAreas(input, candidates, 3).map((match) => ({
      locality_id: match.locality_id,
      name: match.name,
      slug: match.slug,
      fit: match.fit,
      score: match.score,
      top_reasons: match.top_reasons,
      risks: match.risks,
      confidence_level: match.confidence_level
    }));

    const { error } = await supabase.from("leads").insert({
      office_location_text: officeLocation,
      budget_text: budgetText,
      budget_min: budget.min,
      budget_max: budget.max,
      commute_tolerance_minutes: commuteTolerance,
      lifestyle_tags: lifestyleTags,
      contact,
      top_matches: matches,
      source: "landing_page"
    });

    if (error) {
      throw error;
    }

    return { ok: true, matches };
  } catch (error) {
    return {
      ok: false,
      error: error instanceof Error ? error.message : "Could not generate your area match.",
      matches: []
    };
  }
}

async function fetchCandidates(supabase: ReturnType<typeof createAdminSupabaseClient>) {
  const [{ data: localities, error: localitiesError }, { data: scores, error: scoresError }] =
    await Promise.all([
      supabase.from("localities").select("id, name, slug, city, description"),
      supabase
        .from("locality_scores")
        .select(
          "locality_id, rent_score, commute_score, food_score, social_life_score, quiet_score, safety_confidence_score, newcomer_friendliness_score, kannada_dependency_score, broker_risk_score, water_reliability_score, last_verified_at, confidence_level"
        )
    ]);

  if (localitiesError) {
    throw localitiesError;
  }

  if (scoresError) {
    throw scoresError;
  }

  return joinLocalitiesAndScores(
    (localities ?? []) as LocalityRow[],
    (scores ?? []) as LocalityScoreRow[]
  );
}

function joinLocalitiesAndScores(
  localities: LocalityRow[],
  scores: LocalityScoreRow[]
): RecommendationCandidate[] {
  const localityById = new Map(localities.map((locality) => [locality.id, locality]));

  return scores.flatMap((score) => {
    const locality = localityById.get(score.locality_id);
    return locality ? [{ ...locality, ...score }] : [];
  });
}

function parseBudget(value: string) {
  const numbers = value.match(/\d[\d,]*/g)?.map((number) => Number(number.replaceAll(",", ""))) ?? [];

  if (numbers.length >= 2) {
    return {
      min: Math.min(numbers[0], numbers[1]),
      max: Math.max(numbers[0], numbers[1])
    };
  }

  if (numbers.length === 1) {
    return {
      min: null,
      max: numbers[0]
    };
  }

  return {
    min: null,
    max: null
  };
}

function parseTags(value: string) {
  return value
    .split(",")
    .map((tag) => tag.trim().toLowerCase())
    .filter(Boolean);
}

function toPositiveNumber(value: FormDataEntryValue | null) {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : null;
}

function nullableString(value: FormDataEntryValue | null) {
  const text = String(value ?? "").trim();
  return text.length > 0 ? text : null;
}
