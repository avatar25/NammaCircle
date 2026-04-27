"use server";

import { revalidatePath } from "next/cache";
import { createAdminSupabaseClient } from "./supabase";

type ModerationStatus = "approved" | "rejected" | "hidden" | "visible";
type QuestType = "learn_kannada" | "forum_help" | "photo_walk" | "rent_signal" | "area_tip";
type MentorBookingStatus = "pending" | "accepted" | "completed" | "cancelled";

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
  await moderateForumTarget(
    "forum_posts",
    "forum_post",
    String(formData.get("id")),
    formData.get("status") as ModerationStatus
  );
  revalidatePath("/forum");
  revalidatePath("/dashboard");
}

export async function moderateForumComment(formData: FormData) {
  await moderateForumTarget(
    "forum_comments",
    "forum_comment",
    String(formData.get("id")),
    formData.get("status") as ModerationStatus
  );
  revalidatePath("/forum");
  revalidatePath("/dashboard");
}

export async function createQuest(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase.from("quests").insert({
    title: String(formData.get("title")),
    description: String(formData.get("description")),
    quest_type: questType(formData.get("quest_type")),
    points: toNumber(formData.get("points")),
    is_active: formData.get("is_active") === "on",
    sponsor_name: nullableString(formData.get("sponsor_name"))
  });

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/quests");
  revalidatePath("/dashboard");
}

export async function updateQuest(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("quests")
    .update({
      title: String(formData.get("title")),
      description: String(formData.get("description")),
      quest_type: questType(formData.get("quest_type")),
      points: toNumber(formData.get("points")),
      is_active: formData.get("is_active") === "on",
      sponsor_name: nullableString(formData.get("sponsor_name"))
    })
    .eq("id", String(formData.get("id")));

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/quests");
  revalidatePath("/dashboard");
}

export async function toggleQuestActive(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("quests")
    .update({ is_active: formData.get("is_active") !== "true" })
    .eq("id", String(formData.get("id")));

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

export async function createMentor(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase.from("mentors").insert({
    user_id: nullableString(formData.get("user_id")),
    display_name: String(formData.get("display_name")),
    bio: nullableString(formData.get("bio")),
    specialties: specialtyList(formData),
    hourly_rate_inr: toNullableNumber(formData.get("hourly_rate_inr")),
    is_verified: formData.get("is_verified") === "on"
  });

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/mentors");
}

export async function updateMentor(formData: FormData) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("mentors")
    .update({
      user_id: nullableString(formData.get("user_id")),
      display_name: String(formData.get("display_name")),
      bio: nullableString(formData.get("bio")),
      specialties: specialtyList(formData),
      hourly_rate_inr: toNullableNumber(formData.get("hourly_rate_inr")),
      is_verified: formData.get("is_verified") === "on"
    })
    .eq("id", String(formData.get("id")));

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/mentors");
}

export async function updateMentorBookingStatus(formData: FormData) {
  const status = String(formData.get("status")) as MentorBookingStatus;
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase
    .from("mentor_bookings")
    .update({ status })
    .eq("id", String(formData.get("id")));

  if (error) {
    throw new Error(error.message);
  }

  revalidatePath("/mentors");
  revalidatePath("/dashboard");
}

async function updateStatus(table: string, id: string, payload: Record<string, unknown>) {
  const supabase = createAdminSupabaseClient();
  const { error } = await supabase.from(table).update(payload).eq("id", id);

  if (error) {
    throw new Error(error.message);
  }
}

async function moderateForumTarget(
  table: "forum_posts" | "forum_comments",
  targetType: "forum_post" | "forum_comment",
  id: string,
  status: ModerationStatus
) {
  const supabase = createAdminSupabaseClient();
  const { error: updateError } = await supabase
    .from(table)
    .update({ moderation_status: status })
    .eq("id", id);

  if (updateError) {
    throw new Error(updateError.message);
  }

  const { error: actionError } = await supabase.from("moderation_actions").insert({
    admin_user_id: null,
    target_type: targetType,
    target_id: id,
    action: status === "approved" || status === "visible" ? "approve" : "reject",
    notes: `Set forum ${targetType === "forum_post" ? "post" : "comment"} status to ${status}.`
  });

  if (actionError) {
    throw new Error(actionError.message);
  }
}

function toNumber(value: FormDataEntryValue | null) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function toNullableNumber(value: FormDataEntryValue | null) {
  const text = String(value ?? "").trim();
  if (!text) {
    return null;
  }

  const parsed = Number(text);
  return Number.isFinite(parsed) ? parsed : null;
}

function nullableString(value: FormDataEntryValue | null) {
  const text = String(value ?? "").trim();
  return text.length > 0 ? text : null;
}

function questType(value: FormDataEntryValue | null): QuestType {
  const allowed: QuestType[] = [
    "learn_kannada",
    "forum_help",
    "photo_walk",
    "rent_signal",
    "area_tip"
  ];
  const normalized = String(value ?? "");
  return allowed.includes(normalized as QuestType) ? (normalized as QuestType) : "area_tip";
}

function specialtyList(formData: FormData) {
  return formData
    .getAll("specialties")
    .map((value) => String(value))
    .filter(Boolean);
}
