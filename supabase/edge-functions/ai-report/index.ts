import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import {
  type AreaRecommendationInput,
  type LocalityRow,
  type LocalityScoreRow,
  type RecommendationCandidate
} from "../area-recommendations/areaRecommendations.ts";
import { generateLocalityReport } from "./localityReport.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  try {
    const recommendationInput = (await req.json()) as AreaRecommendationInput;
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Missing Supabase edge function environment variables.");
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      global: {
        headers: {
          apikey: serviceRoleKey
        }
      }
    });
    const candidates = await fetchCandidates(supabase);

    return jsonResponse(
      generateLocalityReport({
        recommendation_input: recommendationInput,
        candidates
      })
    );
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected AI report placeholder error."
      },
      400
    );
  }
});

async function fetchCandidates(supabase: ReturnType<typeof createClient>) {
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

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json"
    }
  });
}
