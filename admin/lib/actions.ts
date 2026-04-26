"use server";

import { revalidatePath } from "next/cache";
import { createAdminSupabaseClient } from "./supabase";

type ModerationStatus = "approved" | "rejected" | "hidden" | "visible";

export async function updateLocalityScores(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const localityId = String(formData.get("locality_id"));

  const payload = {
    rent_score: toNumber(formData.get("rent_score")),
    commute_score: toNumber(formData.get("commute_score")),
    food_score: toNumber(formData.get("food_score")),
    social_life_score: toNumber(formData.get("social_life_score")),
    quiet_score: toNumber(formData.get("quiet_score")),
    newcomer_friendliness_score: toNumber(formData.get("newcomer_friendliness_score")),
    kannada_dependency_score: toNumber(formData.get("kannada_dependency_score")),
    broker_risk_score: toNumber(formData.get("broker_risk_score")),
    water_reliability_score: toNumber(formData.get("water_reliability_score")),
    confidence_level: String(formData.get("confidence_level") || "low"),
    last_verified_at: new Date().toISOString()
  };

  const { error } = await supabase
    .from("locality_scores")
    .update(payload)
    .eq("locality_id", localityId);

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/localities");
  revalidatePath("/dashboard");
}

export async function moderateRentReport(formData: FormData) {
  await updateStatus("rent_reports", String(formData.get("id")), {
    moderation_status: formData.get("status") as ModerationStatus
  });
  revalidatePath("/rent-reports");
  revalidatePath("/dashboard");
}

export async function moderateForumPost(formData: FormData) {
  await updateStatus("forum_posts", String(formData.get("id")), {
    moderation_status: formData.get("status") as ModerationStatus
  });
  revalidatePath("/forum");
  revalidatePath("/dashboard");
}

export async function moderateForumComment(formData: FormData) {
  await updateStatus("forum_comments", String(formData.get("id")), {
    moderation_status: formData.get("status") as ModerationStatus
  });
  revalidatePath("/forum");
  revalidatePath("/dashboard");
}

export async function createQuest(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase.from("quests").insert({
    title: String(formData.get("title")),
    description: String(formData.get("description")),
    quest_type: String(formData.get("quest_type") || "daily"),
    points: toNumber(formData.get("points")),
    is_active: formData.get("is_active") === "on"
  });

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/quests");
  revalidatePath("/dashboard");
}

export async function reviewQuestSubmission(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("quest_submissions")
    .update({
      verification_status: String(formData.get("status")),
      reviewed_at: new Date().toISOString()
    })
    .eq("id", String(formData.get("id")));

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/quests");
  revalidatePath("/dashboard");
}

export async function toggleMentorVerification(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("mentors")
    .update({ is_verified: formData.get("is_verified") !== "true" })
    .eq("id", String(formData.get("id")));

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/mentors");
}

async function updateStatus(table: string, id: string, payload: Record<string, unknown>) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase.from(table).update(payload).eq("id", id);

  if (error) {
    throw new Error(error.message);
  }
}

function toNumber(value: FormDataEntryValue | null) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}
