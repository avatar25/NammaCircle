import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import {
  recommendAreas,
  type AreaRecommendationInput,
  type LocalityRow,
  type LocalityScoreRow,
  type RecommendationCandidate
} from "./areaRecommendations.ts";

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
    const input = (await req.json()) as AreaRecommendationInput;
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

    const { data: localities, error: localitiesError } = await supabase
      .from("localities")
      .select("id, name, slug, city, description");

    if (localitiesError) {
      throw localitiesError;
    }

    const { data: scores, error: scoresError } = await supabase
      .from("locality_scores")
      .select(
        "locality_id, rent_score, commute_score, food_score, social_life_score, quiet_score, safety_confidence_score, newcomer_friendliness_score, kannada_dependency_score, broker_risk_score, water_reliability_score, last_verified_at, confidence_level"
      );

    if (scoresError) {
      throw scoresError;
    }

    const candidates = joinLocalitiesAndScores(
      (localities ?? []) as LocalityRow[],
      (scores ?? []) as LocalityScoreRow[]
    );

    return jsonResponse({
      recommendations: recommendAreas(input, candidates, 5),
      explanation_mode: "deterministic",
      notes: [
        "No external maps APIs are used in the MVP.",
        "AI may later summarize these deterministic reasons, but it must not invent facts."
      ]
    });
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected area recommendation error."
      },
      400
    );
  }
});

function joinLocalitiesAndScores(
  localities: LocalityRow[],
  scores: LocalityScoreRow[]
): RecommendationCandidate[] {
  const localityById = new Map(localities.map((locality) => [locality.id, locality]));

  return scores.flatMap((score) => {
    const locality = localityById.get(score.locality_id);

    if (!locality) {
      return [];
    }

    return [{ ...locality, ...score }];
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
