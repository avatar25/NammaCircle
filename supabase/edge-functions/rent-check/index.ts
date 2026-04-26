import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import {
  buildRentReference,
  evaluateRentFairness,
  normalizeBhk,
  type RentCheckInput
} from "./rentFairness.ts";

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
    const input = (await req.json()) as RentCheckInput;
    validateInput(input);

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

    const userId = await getUserId(req, supabaseUrl);
    const bhk = normalizeBhk(input.bhk);

    const { data: reports, error: reportsError } = await supabase
      .from("rent_reports")
      .select("monthly_rent, bhk")
      .eq("locality_id", input.locality_id)
      .eq("moderation_status", "approved")
      .order("created_at", { ascending: false })
      .limit(200);

    if (reportsError) {
      throw reportsError;
    }

    const { data: baseline, error: baselineError } = await supabase
      .from("rent_baselines")
      .select("median_rent, confidence_level")
      .eq("locality_id", input.locality_id)
      .eq("bhk", bhk)
      .maybeSingle();

    if (baselineError) {
      throw baselineError;
    }

    const matchingReportRents = (reports ?? [])
      .filter((report) => normalizeBhk(report.bhk) === bhk)
      .map((report) => report.monthly_rent);

    if (!baseline && matchingReportRents.length < 5) {
      return jsonResponse(
        {
          error: "No rent baseline found for this locality and BHK."
        },
        422
      );
    }

    const reference = buildRentReference(
      matchingReportRents,
      baseline?.median_rent ?? 0,
      baseline?.confidence_level ?? "low"
    );
    const result = evaluateRentFairness({ ...input, bhk }, reference);

    const { data: insertedCheck, error: insertError } = await supabase
      .from("rent_checks")
      .insert({
        user_id: userId,
        locality_id: input.locality_id,
        bhk,
        monthly_rent: input.monthly_rent,
        deposit: input.deposit ?? null,
        furnishing: input.furnishing ?? null,
        maintenance: input.maintenance ?? null,
        result_label: result.label,
        result_score: result.score,
        explanation: result.explanation,
        median_rent: result.medianRent,
        report_count: result.reportCount,
        reference_source: result.referenceSource,
        confidence_level: result.confidenceLevel,
        deposit_warning: result.depositWarning,
        recommended_negotiation_points: result.recommendedNegotiationPoints
      })
      .select("id, created_at")
      .single();

    if (insertError) {
      throw insertError;
    }

    return jsonResponse({
      rent_check_id: insertedCheck.id,
      created_at: insertedCheck.created_at,
      ...result
    });
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected rent check error."
      },
      400
    );
  }
});

function validateInput(input: RentCheckInput) {
  if (!input.locality_id) {
    throw new Error("locality_id is required.");
  }

  if (!input.bhk) {
    throw new Error("bhk is required.");
  }

  if (!Number.isFinite(input.monthly_rent) || input.monthly_rent <= 0) {
    throw new Error("monthly_rent must be a positive number.");
  }

  if (input.deposit != null && input.deposit < 0) {
    throw new Error("deposit cannot be negative.");
  }

  if (input.maintenance != null && input.maintenance < 0) {
    throw new Error("maintenance cannot be negative.");
  }
}

async function getUserId(req: Request, supabaseUrl: string): Promise<string | null> {
  const authHeader = req.headers.get("Authorization");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");

  if (!authHeader || !anonKey) {
    return null;
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: {
      headers: {
        Authorization: authHeader
      }
    }
  });

  const {
    data: { user }
  } = await userClient.auth.getUser();

  return user?.id ?? null;
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
