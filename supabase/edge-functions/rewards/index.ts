import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import {
  applyStreakActivity,
  assertSourceID,
  dailyQuestRewardRule,
  nextRankForPoints,
  rankForPoints,
  staticRewardRule,
  type RewardAction,
  type RewardRule,
  type StreakState
} from "./rewardLogic.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

type RewardRequest = {
  action: RewardAction | "summary";
  source_id?: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  try {
    const input = (await req.json()) as RewardRequest;
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Missing Supabase edge function environment variables.");
    }

    const userId = await getUserId(req, supabaseUrl);

    if (!userId) {
      return jsonResponse({ error: "Authenticated user is required." }, 401);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      global: {
        headers: {
          apikey: serviceRoleKey
        }
      }
    });

    if (input.action === "summary") {
      return jsonResponse(await getProgressSummary(supabase, userId));
    }

    assertSourceID(input.source_id);
    const rule = await resolveRewardRule(supabase, input.action, input.source_id);
    const duplicate = await hasExistingReward(supabase, userId, rule.sourceType, input.source_id);

    if (duplicate) {
      return jsonResponse({
        awarded: false,
        duplicate: true,
        ...(await getProgressSummary(supabase, userId))
      });
    }

    const { error: insertError } = await supabase.from("points_ledger").insert({
      user_id: userId,
      event_type: rule.eventType,
      points_delta: rule.points,
      source_type: rule.sourceType,
      source_id: input.source_id
    });

    if (insertError) {
      if (insertError.code === "23505") {
        return jsonResponse({
          awarded: false,
          duplicate: true,
          ...(await getProgressSummary(supabase, userId))
        });
      }

      throw insertError;
    }

    if (input.action === "complete_kannada_lesson") {
      await supabase.from("lesson_attempts").insert({
        user_id: userId,
        lesson_id: input.source_id
      });
    }

    if (rule.updatesStreak) {
      await updateStreak(supabase, userId);
    }

    return jsonResponse({
      awarded: true,
      duplicate: false,
      event_type: rule.eventType,
      points_delta: rule.points,
      ...(await getProgressSummary(supabase, userId))
    });
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Unexpected rewards error."
      },
      400
    );
  }
});

async function resolveRewardRule(
  supabase: ReturnType<typeof createClient>,
  action: RewardAction,
  sourceId: string
): Promise<RewardRule> {
  if (action === "complete_daily_quest") {
    const { data, error } = await supabase
      .from("quests")
      .select("points")
      .eq("id", sourceId)
      .single();

    if (error) {
      throw error;
    }

    return dailyQuestRewardRule(data.points);
  }

  const rule = staticRewardRule(action);

  if (!rule) {
    throw new Error(`Unsupported reward action: ${action}`);
  }

  return rule;
}

async function hasExistingReward(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  sourceType: string,
  sourceId: string
) {
  const { data, error } = await supabase
    .from("points_ledger")
    .select("id")
    .eq("user_id", userId)
    .eq("source_type", sourceType)
    .eq("source_id", sourceId)
    .is("reversed_at", null)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return Boolean(data);
}

async function updateStreak(supabase: ReturnType<typeof createClient>, userId: string) {
  const today = new Date().toISOString().slice(0, 10);
  const { data, error } = await supabase
    .from("user_streaks")
    .select("current_streak,longest_streak,last_activity_date")
    .eq("user_id", userId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  const next = applyStreakActivity(data as StreakState | null, today);

  if (!next.incremented && data) {
    return;
  }

  const { error: upsertError } = await supabase.from("user_streaks").upsert({
    user_id: userId,
    current_streak: next.current_streak,
    longest_streak: next.longest_streak,
    last_activity_date: next.last_activity_date
  });

  if (upsertError) {
    throw upsertError;
  }
}

async function getProgressSummary(supabase: ReturnType<typeof createClient>, userId: string) {
  const [{ data: ledger, error: ledgerError }, { data: streak, error: streakError }] =
    await Promise.all([
      supabase
        .from("points_ledger")
        .select("points_delta")
        .eq("user_id", userId)
        .is("reversed_at", null),
      supabase
        .from("user_streaks")
        .select("current_streak,longest_streak,last_activity_date")
        .eq("user_id", userId)
        .maybeSingle()
    ]);

  if (ledgerError) {
    throw ledgerError;
  }

  if (streakError) {
    throw streakError;
  }

  const totalPoints = (ledger ?? []).reduce(
    (sum, row) => sum + Number(row.points_delta ?? 0),
    0
  );
  const nextRank = nextRankForPoints(totalPoints);

  return {
    total_points: totalPoints,
    current_rank: rankForPoints(totalPoints),
    next_rank: nextRank?.name ?? null,
    points_to_next_rank: nextRank ? Math.max(nextRank.points - totalPoints, 0) : null,
    current_streak: streak?.current_streak ?? 0,
    longest_streak: streak?.longest_streak ?? 0,
    last_activity_date: streak?.last_activity_date ?? null
  };
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
