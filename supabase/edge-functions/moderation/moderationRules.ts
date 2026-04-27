export const APPROVED_FORUM_STATUSES = ["approved", "visible"] as const;
export const REVIEWABLE_FORUM_STATUSES = ["pending", "flagged", "hidden"] as const;

export type ForumModerationStatus =
  | "pending"
  | "approved"
  | "rejected"
  | "flagged"
  | "hidden"
  | "visible"
  | "removed";

export function defaultForumStatus(): ForumModerationStatus {
  return "pending";
}

export function isForumContentVisible(status: string | null | undefined): boolean {
  return APPROVED_FORUM_STATUSES.includes(status as typeof APPROVED_FORUM_STATUSES[number]);
}

export function needsForumModeration(status: string | null | undefined): boolean {
  return REVIEWABLE_FORUM_STATUSES.includes(status as typeof REVIEWABLE_FORUM_STATUSES[number]);
}

export function canUserCreateForumContentWithStatus(
  status: string | null | undefined
): boolean {
  return status === "pending";
}

export function adminActionForStatus(status: ForumModerationStatus): "approve" | "reject" | "review" {
  if (status === "approved" || status === "visible") {
    return "approve";
  }

  if (status === "rejected" || status === "removed") {
    return "reject";
  }

  return "review";
}
